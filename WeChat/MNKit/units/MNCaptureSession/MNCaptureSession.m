/* @project  __PROJECTNAME__
 *  @header  __FILENAME__
 *  @date  __DATE__
 *  @copyright  __COPYRIGHT__
 *  @author  小斯
 *  @brief  视频录制
 */

#import "MNCaptureSession.h"
#import "MNAuthenticator.h"
#import "MNFileManager.h"
#import "MNMovieWriter.h"
#import "UIAlertView+MNHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

MNCapturePresetName const MNCapturePresetLowQuality = @"com.mn.capture.low";
MNCapturePresetName const MNCapturePresetMediumQuality = @"com.mn.capture.medium";
MNCapturePresetName const MNCapturePresetHighQuality = @"com.mn.capture.high";
MNCapturePresetName const MNCapturePreset1280x720 = @"com.mn.capture.preset.1280x720";
MNCapturePresetName const MNCapturePreset1920x1080 = @"com.mn.capture.preset.1920x1080";

@interface MNCaptureSession ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic) MNCaptureStatus status;
@property (nonatomic) MNCapturePosition capturePosition;
@property (nonatomic, strong) NSError *error;
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
@property(nonatomic, copy) AVAudioSessionCategory sessionCategory;
@end

@implementation MNCaptureSession
+ (MNCaptureSession *)capturer {
    return MNCaptureSession.new;
}
- (instancetype)init {
    if (self = [super init]) {
        [self initialized];
    }
    return self;
}

- (instancetype)initWithOutputPath:(NSString *)outputPath {
    if (self = [self init]) {
        self.outputPath = outputPath;
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
    _resizeMode = MNCaptureResizeModeResizeAspect;
    _capturePosition = MNCapturePositionBack;
    _presetName = MNCapturePreset1280x720;
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
            if (![weakself setSessionActive:YES]) {
                [weakself failureWithDescription:@"录像设备初始化失败"];
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
        if (self.status == MNCaptureStatusPreparing || self.status == MNCaptureStatusRecording) {
            //@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already recording" userInfo:nil];
            NSLog(@"Already recording");
            return;
        }
        [self setStatus:MNCaptureStatusPreparing error:nil];
    }
    
    if (![self makeRecordSessionActive]) {
        [self failureWithDescription:@"设置录制会话失败"];
        return;
    }
    
    //self.movieWriter.delegate = self;
    self.movieWriter.URL = self.URL;
    self.movieWriter.frameRate = self.frameRate;
    self.movieWriter.devicePosition = (AVCaptureDevicePosition)self.capturePosition;
    self.movieWriter.movieOrientation = (AVCaptureVideoOrientation)self.movieOrientation;
    
    [self.movieWriter prepareWriting];
}

- (void)stopRecording {
    @synchronized (self) {
        if (self.status != MNCaptureStatusRecording) {
            NSLog(@"Not recording");
            return;
        }
    }
    [self.movieWriter finishWriting];
}

- (void)failRecording {
}

- (BOOL)deleteRecording {
    if (self.isRecording) return NO;
    return [NSFileManager.defaultManager removeItemAtPath:self.outputPath error:nil];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (self.status != MNCaptureStatusPreparing && self.status != MNCaptureStatusRecording) return;
    
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
    return [self setDeviceCapturePosition:(MNCapturePositionFront - self.capturePosition)];
}

- (BOOL)setDeviceCapturePosition:(MNCapturePosition)capturePosition {
    if (capturePosition == _capturePosition) return YES;
    if (!_session) return NO;
    /**切换到前置摄像头时, 关闭手电筒*/
    if (capturePosition == MNCapturePositionFront) {
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

- (void)failureWithCode:(NSUInteger)code description:(NSString *)description{
    [self setStatus:MNCaptureStatusFinish error:[NSError errorWithDomain:AVFoundationErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:description}]];
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
    [self updateOutputSizeIfNeeded];
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
    if (_resizeMode == MNCaptureResizeModeResize) {
        return AVLayerVideoGravityResize;
    } else if (_resizeMode == MNCaptureResizeModeResizeAspect) {
        return AVLayerVideoGravityResizeAspect;
    }
    return AVLayerVideoGravityResizeAspectFill;
}

- (void)setResizeMode:(MNCaptureResizeMode)resizeMode {
    if (self.isRecording || resizeMode == _resizeMode) return;
    _resizeMode = resizeMode;
    _videoLayer.videoGravity = [self videoLayerGravity];
}

- (void)setOutputPath:(NSString *)outputPath {
    if (self.isRecording || outputPath.pathExtension.length <= 0) return;
    [NSFileManager.defaultManager removeItemAtPath:outputPath error:nil];
    /// 只创建文件夹路径, 文件由数据写入时自行创建<踩坑总结>
    if ([NSFileManager.defaultManager createDirectoryAtPath:outputPath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil]) {
        _outputPath = outputPath.copy;
    }
}

- (BOOL)setSessionActive:(BOOL)active {
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
    if (!error) return [[AVAudioSession sharedInstance] setActive:active error:&error];
    return NO;
}

- (void)setStatus:(MNCaptureStatus)status error:(NSError *)error {
    
    BOOL shouldNotifyDelegate = NO;
    
    if (status != _status) {
        if (status == MNCaptureStatusRecording) {
            shouldNotifyDelegate = YES;
        } else if (status == MNCaptureStatusFinish) {
            shouldNotifyDelegate = YES;
            if (error) self.error = error;
        }
        _status = status;
    }
    
    if (shouldNotifyDelegate && self.delegate) {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) self = weakself;
            if (status == MNCaptureStatusFinish) {
                if (error) {
                    if ([self.delegate respondsToSelector:@selector(captureSession:didFailWithError:)]) {
                        [self.delegate captureSession:self didFailWithError:error];
                    }
                } else {
                    if ([self.delegate respondsToSelector:@selector(captureSessionDidFinishRecording:)]) {
                        [self.delegate captureSessionDidFinishRecording:self];
                    }
                }
            } else if (status == MNCaptureStatusRecording && [self.delegate respondsToSelector:@selector(captureSessionDidStartRecording:)]) {
                [self.delegate captureSessionDidStartRecording:self];
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
    return self.status == MNCaptureStatusRecording;
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

- (void)updateOutputSizeIfNeeded {
    if (!self.outputView || !CGSizeEqualToSize(self.outputSize, CGSizeZero)) return;
    CGFloat width = self.outputView.bounds.size.width;
    CGFloat height = self.outputView.bounds.size.height;
    if (fabs(width/height - 720.f/1280.f) <= .01f) {
        self.outputSize = CGSizeMake(720.f, 1280.f);
    } else if (fabs(width/height - 1280.f/720.f) <= .01f) {
        self.outputSize = CGSizeMake(1280.f, 720.f);
    } else if (fabs(width/height - 640.f/480.f) <= .01f) {
        self.outputSize = CGSizeMake(640.f, 480.f);
    } else if (fabs(width/height - 480.f/640.f) <= .01f) {
        self.outputSize = CGSizeMake(480.f, 640.f);
    } else {
        CGFloat scale = UIScreen.mainScreen.scale;
        width = width*scale;
        height = height*scale;
        CGFloat width8 = floor(ceil(width)/8.f)*8.f;
        CGFloat width16 = floor(ceil(width)/16.f)*16.f;
        if (width8 != width && width16 != width) width = width16;
        CGFloat height8 = floor(ceil(height)/8.f)*8.f;
        CGFloat height16 = floor(ceil(height)/16.f)*16.f;
        if (height8 != height && height16 != height) height = height16;
        self.outputSize = CGSizeMake(width, height);
    }
}

- (AVCaptureDevice *)deviceWithPosition:(MNCapturePosition)capturePosition {
    AVCaptureDevicePosition position = capturePosition == MNCapturePositionFront ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    AVCaptureDevice *device;
    NSArray <AVCaptureDevice *>*devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *result in devices) {
        if (result.position != position) continue;
        device = result;
    }
    return device;
}

- (AVCaptureSessionPreset)sessionPresetWithName:(MNCapturePresetName)presetName {
    AVCaptureSessionPreset sessionPreset = AVCaptureSessionPreset1280x720;
    if ([presetName isEqualToString:MNCapturePresetHighQuality]) {
        sessionPreset = AVCaptureSessionPresetHigh;
    } else if ([presetName isEqualToString:MNCapturePresetMediumQuality]) {
        sessionPreset = AVCaptureSessionPresetMedium;
    } else if ([presetName isEqualToString:MNCapturePreset1280x720]) {
        sessionPreset = AVCaptureSessionPreset1280x720;
    } else if ([presetName isEqualToString:MNCapturePreset1920x1080]) {
        sessionPreset = AVCaptureSessionPreset1920x1080;
    } else if ([presetName isEqualToString:MNCapturePresetLowQuality]) {
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
