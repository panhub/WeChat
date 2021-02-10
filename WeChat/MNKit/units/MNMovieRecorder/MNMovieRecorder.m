/* @project  __PROJECTNAME__
 *  @header  __FILENAME__
 *  @date  __DATE__
 *  @copyright  __COPYRIGHT__
 *  @author  小斯
 *  @brief  视频录制
 */

#import "MNMovieRecorder.h"
#import "MNAuthenticator.h"
#import "MNFileManager.h"
#import "MNMovieWriter.h"
#import "UIAlertView+MNHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>


/**
 录制状态
 - MNMovieRecordStatusIdle: 未知, 闲置状态
 - MNMovieRecordStatusPreparing: 即将开始
 - MNMovieRecordStatusRecording: 正在录制视频
 - MNMovieRecordStatusFinish: 录制完成
 */
typedef NS_ENUM(NSInteger, MNMovieRecordStatus) {
    MNMovieRecordStatusIdle = 0,
    MNMovieRecordStatusPreparing,
    MNMovieRecordStatusRecording,
    MNMovieRecordStatusFinish
};

MNMoviePresetName const MNMoviePresetLowQuality = @"com.mn.movie.preset.low";
MNMoviePresetName const MNMoviePresetMediumQuality = @"com.mn.movie.preset.medium";
MNMoviePresetName const MNMoviePresetHighQuality = @"com.mn.movie.preset.high";
MNMoviePresetName const MNMoviePreset1280x720 = @"com.mn.movie.preset.1280x720";
MNMoviePresetName const MNMoviePreset1920x1080 = @"com.mn.movie.preset.1920x1080";

@interface MNMovieRecorder ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic) MNMovieRecordStatus status;
@property (nonatomic) MNMovieDevicePosition capturePosition;
@property (nonatomic, copy) NSError *error;
@property(nonatomic, copy) AVAudioSessionCategory sessionCategory;
@property (nonatomic, strong) MNMovieWriter *movieWriter;
@property (nonatomic, strong) dispatch_queue_t writeQueue;
@property (nonatomic, strong) dispatch_queue_t outputQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoLayer;
@end

@implementation MNMovieRecorder
- (instancetype)init {
    if (self = [super init]) {
        [self initialized];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL {
    if (self = [self init]) {
        self.URL = URL;
    }
    return self;
}

- (void)initialized {
    _frameRate = 30;
    _movieWriter = MNMovieWriter.new;
    _resizeMode = MNMovieResizeModeResizeAspect;
    _devicePosition = MNMovieDevicePositionBack;
    _presetName = MNMoviePreset1280x720;
    _writeQueue = dispatch_queue_create("com.mn.capture.write.queue", DISPATCH_QUEUE_SERIAL);
    _outputQueue = dispatch_queue_create("com.mn.capture.output.queue", DISPATCH_QUEUE_SERIAL);
    _movieOrientation = MNMovieOrientationPortrait;
    _sessionCategory = AVAudioSession.sharedInstance.category;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)prepareCapturing {
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [MNAuthenticator requestCameraAuthorizationStatusWithHandler:^(BOOL allowed) {
            if (!allowed) {
                [weakself failureWithCode:AVErrorApplicationIsNotAuthorized description:@"获取摄像权限失败"];
                return;
            }
            [MNAuthenticator requestMicrophoneAuthorizationStatusWithHandler:^(BOOL allow) {
                if (!allow) {
                    [weakself failureWithCode:AVErrorApplicationIsNotAuthorized description:@"获取麦克风权限失败"];
                    return;
                }
                if ([weakself setupVideo] && [weakself setupAudio] && [weakself setupImage] ) {
                    [weakself setOutputView:weakself.outputView];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself.session startRunning];
                    });
                }
            }];
        }];
    });
}

- (void)prepareRecording {
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [MNAuthenticator requestCameraAuthorizationStatusWithHandler:^(BOOL allowed) {
            if (!allowed) {
                [weakself failureWithCode:AVErrorApplicationIsNotAuthorized description:@"获取摄像权限失败"];
                return;
            }
            [MNAuthenticator requestMicrophoneAuthorizationStatusWithHandler:^(BOOL allow) {
                if (!allow) {
                    [weakself failureWithCode:AVErrorApplicationIsNotAuthorized description:@"获取麦克风权限失败"];
                    return;
                }
                if ([weakself setupVideo] && [weakself setupAudio]) {
                    [weakself setOutputView:weakself.outputView];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself.session startRunning];
                    });
                }
            }];
        }];
    });
}

- (void)prepareSnapping {
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [MNAuthenticator requestCameraAuthorizationStatusWithHandler:^(BOOL allowed) {
            if (!allowed) {
                [weakself failureWithCode:AVErrorApplicationIsNotAuthorized description:@"获取摄像权限失败"];
                return;
            }
            if ([weakself setupVideo] && [weakself setupImage]) {
                [weakself setOutputView:weakself.outputView];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.session startRunning];
                });
            }
        }];
    });
}

#pragma mark - 设置音/视频/图片
- (BOOL)setupVideo {
    if (!self.session) {
        [self failureWithDescription:@"录像会话初始化失败"];
        return NO;
    }
    AVCaptureDevice *device = [self deviceWithPosition:self.capturePosition];
    if (!device) {
        [self failureWithDescription:@"录像设备初始化失败"];
        return NO;
    }
    CMTime frameDuration = CMTimeMake(1, (int32_t)self.frameRate);
    if ([device lockForConfiguration:NULL] ) {
        device.activeVideoMaxFrameDuration = frameDuration;
        device.activeVideoMinFrameDuration = frameDuration;
        [device unlockForConfiguration];
    } else {
        NSLog(@"videoDevice lockForConfiguration failed");
    }
    NSError *error;
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        [self failureWithDescription:@"录像设备初始化失败"];
        return NO;
    }
    if (![self.session canAddInput:videoInput]) {
        [self failureWithDescription:@"录像设备初始化失败"];
        return NO;
    }
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    videoOutput.alwaysDiscardsLateVideoFrames = YES; // 立即丢弃上一帧节省内存开销
    [videoOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]}];
    [videoOutput setSampleBufferDelegate:self queue:self.outputQueue];
    if (![self.session canAddOutput:videoOutput]) {
        [self failureWithDescription:@"录像设备初始化失败"];
        return NO;
    }
    [self.session addInput:videoInput];
    [self.session addOutput:videoOutput];
    self.videoInput = videoInput;
    self.videoOutput = videoOutput;
    return YES;
}

- (BOOL)setupAudio {
    if (!self.session) {
        [self failureWithDescription:@"录像会话初始化失败"];
        return NO;
    }
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (!device) {
        [self failureWithDescription:@"录音设备初始化失败"];
        return NO;
    }
    NSError *error;
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        [self failureWithDescription:@"录音设备初始化失败"];
        return NO;
    }
    if (![self.session canAddInput:audioInput]) {
        [self failureWithDescription:@"录音设备初始化失败"];
        return NO;
    }
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioOutput setSampleBufferDelegate:self queue:self.outputQueue];
    if (![self.session canAddOutput:audioOutput]) {
        [self failureWithDescription:@"录音设备初始化失败"];
        return NO;
    }
    [self.session addInput:audioInput];
    [self.session addOutput:audioOutput];
    self.audioInput = audioInput;
    self.audioOutput = audioOutput;
    return YES;
}

- (BOOL)setupImage {
    if (!self.session) {
        [self failureWithDescription:@"录像会话初始化失败"];
        return NO;
    }
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    [imageOutput setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG}];
    if (![self.session canAddOutput:imageOutput]) {
        [self failureWithDescription:@"录像设备初始化失败"];
        return NO;
    }
    [self.session addOutput:imageOutput];
    self.imageOutput = imageOutput;
    return YES;
}

#pragma mark - 开始/停止捕获
- (void)startRunning {
    @synchronized (self) {
        if (_session && !_session.isRunning) [_session startRunning];
    }
}

- (void)stopRunning {
    @synchronized (self) {
        if (_session && _session.isRunning) [_session stopRunning];
    }
}

#pragma mark - 开始/停止录像
- (void)startRecording {
    @synchronized (self) {
        if (self.status == MNMovieRecordStatusPreparing || self.status == MNMovieRecordStatusRecording) {
            //@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already recording" userInfo:nil];
            NSLog(@"Already recording");
            return;
        }
        [self setStatus:MNMovieRecordStatusPreparing error:nil];
    }
    
    if (![self makeRecordSessionActive]) {
        [self failureWithDescription:@"设置录制会话失败"];
        return;
    }
    
    self.error = nil;
    //self.movieWriter.delegate = self;
    self.movieWriter.URL = self.URL;
    self.movieWriter.frameRate = self.frameRate;
    self.movieWriter.devicePosition = (AVCaptureDevicePosition)self.devicePosition;
    self.movieWriter.movieOrientation = (AVCaptureVideoOrientation)self.movieOrientation;
    
    [self.movieWriter prepareWriting];
}

- (void)stopRecording {
    @synchronized (self) {
        if (self.status != MNMovieRecordStatusRecording) {
            NSLog(@"Not recording");
            return;
        }
    }
    [self.movieWriter finishWriting];
}

- (BOOL)deleteRecording {
    if (self.isRecording) return NO;
    return [NSFileManager.defaultManager removeItemAtURL:self.URL error:nil];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (self.status != MNMovieRecordStatusPreparing && self.status != MNMovieRecordStatusRecording) return;
    
    if (output == self.videoOutput) {
        
        [self.movieWriter appendSampleBuffer:sampleBuffer mediaType:AVMediaTypeVideo];
        
    } else if (output == self.audioOutput) {
        
        [self.movieWriter appendSampleBuffer:sampleBuffer mediaType:AVMediaTypeAudio];
        
    }
}

#pragma mark - 手电筒控制
- (BOOL)openLighting {
    __block BOOL succeed = NO;
    [self changeDeviceConfigurationHandler:^(AVCaptureDevice *device) {
        if ([device hasTorch] && [device isTorchModeSupported:AVCaptureTorchModeOn]) {
            if (device.torchMode != AVCaptureTorchModeOn) {
                [device setTorchMode:AVCaptureTorchModeOn];
            }
            succeed = YES;
        }
    }];
    return succeed;
}

- (BOOL)closeLighting {
    __block BOOL succeed = NO;
    [self changeDeviceConfigurationHandler:^(AVCaptureDevice *device) {
        if ([device hasTorch] && [device isTorchModeSupported:AVCaptureTorchModeOff]) {
            if (device.torchMode != AVCaptureTorchModeOff) {
                [device setTorchMode:AVCaptureTorchModeOff];
            }
            succeed = YES;
        }
    }];
    return succeed;
}

#pragma mark - 切换摄像头
- (BOOL)convertCapturePosition {
    return [self setDeviceCapturePosition:(MNMovieDevicePositionFront - self.capturePosition)];
}

- (BOOL)setDeviceCapturePosition:(MNMovieDevicePosition)capturePosition {
    if (capturePosition == _capturePosition) return YES;
    if (!_session) return NO;
    /**切换到前置摄像头时, 关闭手电筒*/
    if (capturePosition == MNMovieDevicePositionFront) {
        [self closeLighting];
    }
    /**转换摄像头*/
    AVCaptureDevice *device = [self deviceWithPosition:capturePosition];
    if (!device) return NO;
    NSError *error;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) return NO;
    [self.session stopRunning];
    [self.session beginConfiguration];
    if ([self.session canAddInput:videoInput]) {
        [self.session removeInput:self.videoInput];
        [self.session addInput:videoInput];
        self.videoInput = videoInput;
    }
    [self.session commitConfiguration];
    [self.session startRunning];
    BOOL success = self.videoInput == videoInput;
    if (success) _capturePosition = capturePosition;
    return success;
}

#pragma mark - 获取照片
- (void)captureStillImageAsynchronously:(void(^)(UIImage *))completion {
    if (!self.imageOutput) {
        if (completion) completion(nil);
        return;
    }
    AVCaptureConnection *captureConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (error || imageDataSampleBuffer == NULL) {
            if (completion) completion(nil);
            return;
        }
        NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:data];
        image = [image resizingOrientation];
        if (completion) completion(image);
    }];
}

#pragma mark - 对焦
- (BOOL)setFocusPoint:(CGPoint)point {
    if (!_videoInput || !_videoLayer || !_session.isRunning) return NO;
    CGPoint focus = [_videoLayer captureDevicePointOfInterestForPoint:point];
    __block BOOL succeed = NO;
    [self changeDeviceConfigurationHandler:^(AVCaptureDevice *device) {
        if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([device isFocusPointOfInterestSupported]) {
            [device setFocusPointOfInterest:focus];
        }
        if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([device isExposurePointOfInterestSupported]) {
            [device setExposurePointOfInterest:focus];
        }
    }];
    return succeed;
}

#pragma mark - 改变设备设置状态
- (void)changeDeviceConfigurationHandler:(void(^)(AVCaptureDevice *device))configurationHandler {
    if (!_session) return;
    AVCaptureDevice *device = [_videoInput device];
    if (!device) return;
    NSError *error;
    if (![device lockForConfiguration:&error] || error) {
        NSLog(@"lockForConfiguration error: %@", error);
        return;
    }
    [_session beginConfiguration];
    if (configurationHandler) configurationHandler(device);
    [_session commitConfiguration];
    [device unlockForConfiguration];
}

#pragma mark - 发生错误
- (void)failureWithDescription:(NSString *)message {
    [self failureWithCode:AVErrorScreenCaptureFailed description:message];
}

- (void)failureWithCode:(NSUInteger)code description:(NSString *)description {
    @synchronized (self) {
        [self setStatus:MNMovieRecordStatusFinish error:[NSError errorWithDomain:AVFoundationErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:description}]];
    }
}

#pragma mark - Notification
- (void)didEnterBackgroundNotification {
    [self stopRecording];
    [self stopRunning];
    [self closeLighting];
}

- (void)willEnterForegroundNotification {
    [self startRunning];
}

#pragma mark - 设置会话
- (BOOL)makeRecordSessionActive {
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
    if (!error) [[AVAudioSession sharedInstance] setActive:YES error:&error];
    return !error;
}

- (BOOL)renewSessionActive {
    if (!self.sessionCategory) return NO;
    if ([AVAudioSession.sharedInstance.category isEqualToString:self.sessionCategory]) return YES;
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:self.sessionCategory error:&error];
    if (!error) [[AVAudioSession sharedInstance] setActive:YES error:&error];
    return !error;
}

#pragma mark - Setter
- (void)setOutputView:(UIView *)outputView {
    if (!outputView) return;
    _outputView = outputView;
    if (!_session) return;
    AVLayerVideoGravity videoGravity = self.videoLayerGravity;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoLayer removeFromSuperlayer];
        self.videoLayer.frame = outputView.bounds;
        self.videoLayer.videoGravity = videoGravity;
        [outputView.layer insertSublayer:self.videoLayer atIndex:0];
    });
}

- (AVLayerVideoGravity)videoLayerGravity {
    if (_resizeMode == MNMovieResizeModeResize) {
        return AVLayerVideoGravityResize;
    } else if (_resizeMode == MNMovieResizeModeResizeAspect) {
        return AVLayerVideoGravityResizeAspect;
    }
    return AVLayerVideoGravityResizeAspectFill;
}

- (void)setResizeMode:(MNMovieResizeMode)resizeMode {
    if (self.isRecording || resizeMode == _resizeMode) return;
    _resizeMode = resizeMode;
    _videoLayer.videoGravity = [self videoLayerGravity];
}

- (void)setStatus:(MNMovieRecordStatus)status error:(NSError *)error {
    
    BOOL shouldNotifyDelegate = NO;
    
    if (status != _status) {
        if (status == MNMovieRecordStatusRecording) {
            shouldNotifyDelegate = YES;
        } else if (status == MNMovieRecordStatusFinish) {
            shouldNotifyDelegate = YES;
            if (error) self.error = error;
        }
        _status = status;
    }
    
    if (shouldNotifyDelegate && self.delegate) {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) self = weakself;
            if (status == MNMovieRecordStatusFinish) {
                if (error) {
                    if ([self.delegate respondsToSelector:@selector(movieRecorder:didFailWithError:)]) {
                        [self.delegate movieRecorder:self didFailWithError:error];
                    }
                } else {
                    if ([self.delegate respondsToSelector:@selector(movieRecorderDidFinishRecording:)]) {
                        [self.delegate movieRecorderDidFinishRecording:self];
                    }
                }
            } else if (status == MNMovieRecordStatusRecording && [self.delegate respondsToSelector:@selector(movieRecorderDidStartRecording:)]) {
                [self.delegate movieRecorderDidStartRecording:self];
            }
        });
    }
}

#pragma mark - Getter
- (AVCaptureSession *)session {
    if (!_session) {
        AVCaptureSession *session = [AVCaptureSession new];
        session.usesApplicationAudioSession = NO;
        AVCaptureSessionPreset sessionPreset = [self sessionPresetWithName:self.presetName];
        if ([session canSetSessionPreset:sessionPreset]) {
            session.sessionPreset = sessionPreset;
        } else if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            session.sessionPreset = AVCaptureSessionPreset1920x1080;
        } else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            session.sessionPreset = AVCaptureSessionPreset1280x720;
        } else if ([session canSetSessionPreset:AVCaptureSessionPresetMedium]) {
            session.sessionPreset = AVCaptureSessionPresetMedium;
        } if (NSProcessInfo.processInfo.processorCount == 1 && [session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
            session.sessionPreset = AVCaptureSessionPreset640x480;
        } else if ([session canSetSessionPreset:AVCaptureSessionPresetLow]) {
            session.sessionPreset = AVCaptureSessionPresetLow;
        }
        _session = session;
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)videoLayer {
    if (!_videoLayer) {
        AVCaptureVideoPreviewLayer *videoLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _videoLayer = videoLayer;
    }
    return _videoLayer;
}

- (BOOL)isRunning {
    return (_session && _session.isRunning);
}

- (BOOL)isRecording {
    return self.status == MNMovieRecordStatusRecording;
}

- (Float64)duration {
    if (!self.URL || ![NSFileManager.defaultManager fileExistsAtPath:self.URL.path]) return 0.f;
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.URL options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
    if (!asset) return 0.f;
    return CMTimeGetSeconds(asset.duration);
}

- (int)frameRate {
    if (NSProcessInfo.processInfo.processorCount == 1) return 15;
    return MIN(30, MAX(_frameRate, 15));
}

- (AVCaptureDevice *)deviceWithPosition:(MNMovieDevicePosition)capturePosition {
    AVCaptureDevicePosition position = capturePosition == MNMovieDevicePositionFront ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    AVCaptureDevice *device;
    NSArray <AVCaptureDevice *>*devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *result in devices) {
        if (result.position != position) continue;
        device = result;
    }
    return device;
}

- (AVCaptureSessionPreset)sessionPresetWithName:(MNMoviePresetName)presetName {
    AVCaptureSessionPreset sessionPreset = AVCaptureSessionPreset1280x720;
    if ([presetName isEqualToString:MNMoviePresetHighQuality]) {
        sessionPreset = AVCaptureSessionPresetHigh;
    } else if ([presetName isEqualToString:MNMoviePresetMediumQuality]) {
        sessionPreset = AVCaptureSessionPresetMedium;
    } else if ([presetName isEqualToString:MNMoviePreset1280x720]) {
        sessionPreset = AVCaptureSessionPreset1280x720;
    } else if ([presetName isEqualToString:MNMoviePreset1920x1080]) {
        sessionPreset = AVCaptureSessionPreset1920x1080;
    } else if ([presetName isEqualToString:MNMoviePresetLowQuality]) {
        sessionPreset = AVCaptureSessionPresetLow;
    }
    return sessionPreset;
}

#pragma mark - dealloc
- (void)dealloc {
    _delegate = nil;
    _movieWriter.delegate = nil;
    [self closeLighting];
    [self stopRunning];
    [self stopRecording];
    [self renewSessionActive];
    [_videoLayer removeFromSuperlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

@end
