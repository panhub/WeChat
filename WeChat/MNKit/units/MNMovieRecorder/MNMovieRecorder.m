/* @project  __PROJECTNAME__
 *  @header  __FILENAME__
 *  @date  __DATE__
 *  @copyright  __COPYRIGHT__
 *  @author  小斯
 *  @brief  视频录制
 */

#import "MNMovieRecorder.h"
#if __has_include(<AVFoundation/AVFoundation.h>)
#import "MNAuthenticator.h"
#import "MNMovieWriter.h"
#import <AVFoundation/AVFoundation.h>

/**
 录制状态
 - MNMovieRecordStatusIdle: 默认 闲置状态
 - MNMovieRecordStatusRecording: 正在录制视频
 - MNMovieRecordStatusFinish: 录制结束
 - MNMovieRecordStatusCancelled: 录制取消
 - MNMovieRecordStatusFailed: 录制失败
 */
typedef NS_ENUM(NSInteger, MNMovieRecordStatus) {
    MNMovieRecordStatusIdle = 0,
    MNMovieRecordStatusRecording,
    MNMovieRecordStatusFinish,
    MNMovieRecordStatusCancelled,
    MNMovieRecordStatusFailed
};

MNMoviePresetName const MNMoviePresetLowQuality = @"com.mn.movie.preset.low";
MNMoviePresetName const MNMoviePresetMediumQuality = @"com.mn.movie.preset.medium";
MNMoviePresetName const MNMoviePresetHighQuality = @"com.mn.movie.preset.high";
MNMoviePresetName const MNMoviePreset1280x720 = @"com.mn.movie.preset.1280x720";
MNMoviePresetName const MNMoviePreset1920x1080 = @"com.mn.movie.preset.1920x1080";

@interface MNMovieRecorder ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, MNMovieWriteDelegate>
@property (nonatomic) BOOL shouldSessionRunning;
@property (nonatomic) MNMovieRecordStatus status;
@property (nonatomic, strong) MNMovieWriter *movieWriter;
@property (nonatomic, strong) dispatch_queue_t outputQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
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
    _presetName = MNMoviePresetHighQuality;
    _devicePosition = MNMovieDevicePositionBack;
    _movieOrientation = MNMovieOrientationPortrait;
    _resizeMode = MNMovieResizeModeResizeAspect;
    _outputQueue = dispatch_queue_create("com.mn.capture.output.queue", DISPATCH_QUEUE_SERIAL);
#ifdef __IPHONE_9_0
    if (@available(iOS 9.0, *)) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sessionWasInterruptedNotification:) name:AVCaptureSessionWasInterruptedNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sessionInterruptionEndedNotification:) name:AVCaptureSessionInterruptionEndedNotification object:nil];
    } else {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
#else
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
#endif
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

#pragma mark - Fail
- (void)failureWithDescription:(NSString *)message {
    [self failureWithCode:AVErrorScreenCaptureFailed description:message];
}

- (void)failureWithCode:(NSUInteger)code description:(NSString *)description {
    @synchronized (self) {
        [self setStatus:MNMovieRecordStatusFailed error:[NSError errorWithDomain:AVFoundationErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:description}]];
    }
}

#pragma mark - 设置音/视频/图片
- (BOOL)setupVideo {
    if (!self.session) {
        [self failureWithDescription:@"录像会话初始化失败"];
        return NO;
    }
    AVCaptureDevice *device = [self deviceWithPosition:self.devicePosition];
    if (!device) {
        [self failureWithDescription:@"录像设备初始化失败"];
        return NO;
    }
    CMTime frameDuration = CMTimeMake(1, (int32_t)self.frameRate);
    if ([device lockForConfiguration:NULL] ) {
        device.activeVideoMaxFrameDuration = frameDuration;
        device.activeVideoMinFrameDuration = frameDuration;
        [device unlockForConfiguration];
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
- (BOOL)isRunning {
    @synchronized (self) {
        return (_session && _session.isRunning);
    }
}

- (void)startRunning {
    @synchronized (self) {
        if (_session && !_session.isRunning) {
            [_session startRunning];
            _shouldSessionRunning = YES;
        }
    }
}

- (void)stopRunning {
    @synchronized (self) {
        if (_session && _session.isRunning) {
            [_session stopRunning];
            _shouldSessionRunning = NO;
        }
    }
}

#pragma mark - 录像
- (BOOL)isRecording {
    @synchronized (self) {
        return self.status == MNMovieRecordStatusRecording;
    }
}

- (void)startRecording {
    @synchronized (self) {
        if (self.status == MNMovieRecordStatusRecording) return;
        self.status = MNMovieRecordStatusRecording;
    }
    self.movieWriter.URL = self.URL;
    self.movieWriter.delegate = self;
    self.movieWriter.frameRate = self.frameRate;
    self.movieWriter.devicePosition = (AVCaptureDevicePosition)self.devicePosition;
    self.movieWriter.movieOrientation = (AVCaptureVideoOrientation)self.movieOrientation;
    [self.movieWriter startWriting];
}

- (void)stopRecording {
    @synchronized (self) {
        if (self.status != MNMovieRecordStatusRecording) return;
    }
    [self closeTorch];
    [self.movieWriter finishWriting];
}

- (void)cancelRecording {
    @synchronized (self) {
        if (self.status != MNMovieRecordStatusRecording) return;
    }
    [self closeTorch];
    [self.movieWriter cancelWriting];
}

- (BOOL)deleteRecording {
    if (self.isRecording) return NO;
    return [NSFileManager.defaultManager removeItemAtURL:self.URL error:nil];
}

#pragma mark - 照片
- (void)takeStillImageAsynchronously:(void(^)(UIImage *))completion {
    if (!self.imageOutput) {
        if (completion) completion(nil);
        return;
    }
    AVCaptureConnection *imageConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (imageConnection.isVideoOrientationSupported) imageConnection.videoOrientation = self.videoOrientation;
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:imageConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (error || imageDataSampleBuffer == NULL) {
            if (completion) completion(nil);
            return;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        if (completion) completion([UIImage imageWithData:imageData]);
    }];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // 判断此时录制状态是否满足视频写入条件
    if (self.status == MNMovieRecordStatusRecording) {

        if (output == self.videoOutput) {

            [self.movieWriter appendSampleBuffer:sampleBuffer mediaType:AVMediaTypeVideo];

        } else if (output == self.audioOutput) {

            [self.movieWriter appendSampleBuffer:sampleBuffer mediaType:AVMediaTypeAudio];

        }
    }
}

#pragma mark - MNMovieWriteDelegate
- (void)movieWriterDidStartWriting:(MNMovieWriter *)movieWriter {
    @synchronized (self) {
        [self setStatus:MNMovieRecordStatusRecording error:nil];
    }
}

- (void)movieWriterDidFinishWriting:(MNMovieWriter *)movieWriter {
    @synchronized (self) {
        [self setStatus:MNMovieRecordStatusFinish error:nil];
    }
}

- (void)movieWriterDidCancelWriting:(MNMovieWriter *)movieWriter {
    @synchronized (self) {
        [self setStatus:MNMovieRecordStatusCancelled error:nil];
    }
}

- (void)movieWriter:(MNMovieWriter *)movieWriter didFailWithError:(NSError *)error {
    @synchronized (self) {
        [self setStatus:MNMovieRecordStatusFailed error:error];
    }
}

#pragma mark - 手电筒
- (BOOL)isOnTorch {
    AVCaptureDevice *device = self.videoInput.device;
    return (device && device.torchMode == AVCaptureTorchModeOn);
}

- (NSError *)openTorch {
    __block NSError *error;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (!device || !device.hasTorch) {
            error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"未发现手电筒"}];
        } else if (device.torchMode != AVCaptureTorchModeOn) {
            // 打开手电筒前 关闭闪光灯
            if (device.hasFlash && device.flashMode == AVCaptureFlashModeOn) {
                device.flashMode = AVCaptureFlashModeOff;
            }
            if ([device isTorchModeSupported:AVCaptureTorchModeOn]) {
                device.torchMode = AVCaptureTorchModeOn;
            } else {
                error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"设备不支持此操作"}];
            }
        }
    }];
    return error;
}

- (NSError *)closeTorch {
    __block NSError *error;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (!device || !device.hasTorch) {
            error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"未发现手电筒"}];
        } else if (device.torchMode != AVCaptureTorchModeOff) {
            if ([device isTorchModeSupported:AVCaptureTorchModeOff]) {
                device.torchMode = AVCaptureTorchModeOff;
            } else {
                error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"设备不支持此操作"}];
            }
        }
    }];
    return error;
}

#pragma mark - 闪光灯
- (BOOL)isOnFlash {
    AVCaptureDevice *device = self.videoInput.device;
    return (device && device.flashMode == AVCaptureFlashModeOn);
}

- (NSError *)openFlash {
    __block NSError *error;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (!device || !device.hasFlash) {
            error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"未发现闪光灯"}];
        } else if (device.flashMode != AVCaptureFlashModeOn) {
            // 打开闪光灯前关闭手电筒
            if (device.hasTorch && device.torchMode == AVCaptureTorchModeOn) {
                device.torchMode = AVCaptureTorchModeOff;
            }
            if ([device isFlashModeSupported:AVCaptureFlashModeOn]) {
                device.flashMode = AVCaptureFlashModeOn;
            } else {
                error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"设备不支持此操作"}];
            }
        }
    }];
    return error;
}

- (NSError *)closeFlash {
    __block NSError *error;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (!device || !device.hasFlash) {
            error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"未发现闪光灯"}];
        } else if (device.flashMode != AVCaptureFlashModeOff) {
            if ([device isFlashModeSupported:AVCaptureFlashModeOff]) {
                device.flashMode = AVCaptureFlashModeOff;
            } else {
                error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"设备不支持此操作"}];
            }
        }
    }];
    return error;
}

#pragma mark - 摄像头
- (BOOL)convertCapturePosition {
    return [self convertCapturePosition:(MNMovieDevicePositionBack + MNMovieDevicePositionFront - self.devicePosition) error:NULL];
}

- (BOOL)convertCapturePosition:(MNMovieDevicePosition)capturePosition error:(NSError **)error {
    if (capturePosition == self.devicePosition) return YES;
    if (!_session) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"录制会话已结束"}];
        }
        return NO;
    }
    // 新的摄像头
    AVCaptureDevice *device = [self deviceWithPosition:capturePosition];
    if (!device) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"获取摄像头失败"}];
        }
        return NO;
    }
    CMTime frameDuration = CMTimeMake(1, (int32_t)self.frameRate);
    if ([device lockForConfiguration:NULL] ) {
        device.activeVideoMaxFrameDuration = frameDuration;
        device.activeVideoMinFrameDuration = frameDuration;
        [device unlockForConfiguration];
    }
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:NULL];
    if (!videoInput) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"切换摄像头失败"}];
        }
        return NO;
    }
    // 关闭手电筒/闪光灯
    [self closeFlash];
    [self closeTorch];
    [self.session beginConfiguration];
    if (self.videoInput) [self.session removeInput:self.videoInput];
    if ([self.session canAddInput:videoInput]) {
        // 添加动画效果
        if (_previewLayer) {
            CATransition *transition = [CATransition animation];
            transition.type = @"oglFlip";
            transition.subtype = kCATransitionFromLeft;
            transition.duration = .5f;
            transition.removedOnCompletion = NO;
            transition.fillMode = kCAFillModeForwards;
            [self.previewLayer addAnimation:transition forKey:nil];
        }
        // 转换
        [self.session addInput:videoInput];
        [self.session commitConfiguration];
        self.videoInput = videoInput;
        self.devicePosition = capturePosition;
    } else {
        if (self.videoInput) [self.session addInput:self.videoInput];
        [self.session commitConfiguration];
        if (error != NULL) {
            *error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"切换摄像头失败"}];
        }
        return NO;
    }
    return YES;
}

#pragma mark - 对焦
- (BOOL)setFocus:(CGPoint)point {
    if (!_previewLayer) return NO;
    point = [self.previewLayer captureDevicePointOfInterestForPoint:point];
    __block BOOL result = NO;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (device && device.isFocusPointOfInterestSupported &&
            [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            result = YES;
        }
    }];
    return result;
}

#pragma mark - 曝光
- (BOOL)setExposure:(CGPoint)point {
    if (!_previewLayer) return NO;
    point = [self.previewLayer captureDevicePointOfInterestForPoint:point];
    __block BOOL result = NO;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (device && device.isExposurePointOfInterestSupported &&
            [device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = AVCaptureExposureModeAutoExpose;
            result = YES;
        }
    }];
    return result;
}

#pragma mark - -缩放
- (BOOL)setZoomFactor:(CGFloat)factor withRate:(float)rate {
    __block BOOL result = NO;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (device) {
            [device rampToVideoZoomFactor:factor withRate:4.0];
            result = YES;
        }
    }];
    return result;
}

#pragma mark - 设备
- (void)performDeviceChangeHandler:(void(^)(AVCaptureDevice *_Nullable))resultHandler {
    AVCaptureDevice *device = self.videoInput.device;
    if (!device) {
        if (resultHandler) resultHandler(nil);
        return;
    }
    NSError *error;
    if (![device lockForConfiguration:&error] || error) {
        if (resultHandler) resultHandler(nil);
    } else {
        if (resultHandler) resultHandler(device);
        [device unlockForConfiguration];
    }
}

#pragma mark - Notification
// 前台
- (void)willEnterForegroundNotification:(NSNotification *)notify {
    if (self.shouldSessionRunning) [self startRunning];
}
// 后台
- (void)didEnterBackgroundNotification:(NSNotification *)notify {
    if (self.shouldSessionRunning) [_session stopRunning];
    [self cancelRecording];
}
// 中断
- (void)sessionWasInterruptedNotification:(NSNotification *)notify {
    [self cancelRecording];
}
// 中断结束
- (void)sessionInterruptionEndedNotification:(NSNotification *)notify {
    NSLog(@"中断结束");
}

#pragma mark - Setter
- (void)setOutputView:(UIView *)outputView {
    _outputView = outputView;
    if (!_session) return;
    AVLayerVideoGravity videoGravity = self.videoLayerGravity;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.previewLayer removeFromSuperlayer];
        self.previewLayer.frame = outputView.bounds;
        self.previewLayer.videoGravity = videoGravity;
        [outputView.layer insertSublayer:self.previewLayer atIndex:0];
    });
}

- (void)setResizeMode:(MNMovieResizeMode)resizeMode {
    if (self.isRecording || resizeMode == _resizeMode) return;
    _resizeMode = resizeMode;
    _previewLayer.videoGravity = [self videoLayerGravity];
}

- (void)setStatus:(MNMovieRecordStatus)status error:(NSError *)error {
    
    _status = status;
    
    BOOL shouldNotifyDelegate = NO;
    
    if (status >= MNMovieRecordStatusRecording) {
        shouldNotifyDelegate = YES;
        if (status >= MNMovieRecordStatusFinish) {
            _movieWriter = nil;
            [self closeTorch];
        }
    }
    
    if (shouldNotifyDelegate && self.delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == MNMovieRecordStatusRecording && [self.delegate respondsToSelector:@selector(movieRecorderDidStartRecording:)]) {
                [self.delegate movieRecorderDidStartRecording:self];
            } else if (status == MNMovieRecordStatusFinish && [self.delegate respondsToSelector:@selector(movieRecorderDidFinishRecording:)]) {
                [self.delegate movieRecorderDidFinishRecording:self];
            } else if (status == MNMovieRecordStatusCancelled && [self.delegate respondsToSelector:@selector(movieRecorderDidCancelRecording:)]) {
                [self.delegate movieRecorderDidCancelRecording:self];
            } else if (status == MNMovieRecordStatusFinish && [self.delegate respondsToSelector:@selector(movieRecorder:didFailWithError:)]) {
                [self.delegate movieRecorder:self didFailWithError:error];
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
        } else if (NSProcessInfo.processInfo.processorCount == 1 && [session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
            session.sessionPreset = AVCaptureSessionPreset640x480;
        } else if ([session canSetSessionPreset:AVCaptureSessionPresetLow]) {
            session.sessionPreset = AVCaptureSessionPresetLow;
        }
        _session = session;
    }
    return _session;
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

- (MNMovieSizeRatio)presetSizeRatio {
    if (!_session || !_session.sessionPreset) {
        return MNMovieSizeRatioUnknown;
    }
    AVCaptureSessionPreset presetName = _session.sessionPreset;
#ifdef __IPHONE_9_0
    if (@available(iOS 9.0, *)) {
        if ([presetName isEqualToString:AVCaptureSessionPreset3840x2160]) {
            return self.movieOrientation <= MNMovieOrientationPortraitUpsideDown ? MNMovieSizeRatio9x16 : MNMovieSizeRatio16x9;
        }
    }
#endif
    if ([presetName isEqualToString:AVCaptureSessionPresetHigh] || [presetName isEqualToString:AVCaptureSessionPreset1920x1080] || [presetName isEqualToString:AVCaptureSessionPreset1280x720] || [presetName isEqualToString:AVCaptureSessionPresetiFrame960x540]) {
        return self.movieOrientation <= MNMovieOrientationPortraitUpsideDown ? MNMovieSizeRatio9x16 : MNMovieSizeRatio16x9;
    }
    return self.movieOrientation <= MNMovieOrientationPortraitUpsideDown ? MNMovieSizeRatio3x4 : MNMovieSizeRatio4x3;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        previewLayer.contentsScale = UIScreen.mainScreen.scale;
        _previewLayer = previewLayer;
    }
    return _previewLayer;
}

- (AVLayerVideoGravity)videoLayerGravity {
    if (_resizeMode == MNMovieResizeModeResize) {
        return AVLayerVideoGravityResize;
    } else if (_resizeMode == MNMovieResizeModeResizeAspect) {
        return AVLayerVideoGravityResizeAspect;
    }
    return AVLayerVideoGravityResizeAspectFill;
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

- (AVCaptureVideoOrientation)videoOrientation {
    AVCaptureVideoOrientation orientation;
    switch (self.movieOrientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
}

#pragma mark - dealloc
- (void)dealloc {
    _delegate = nil;
    _movieWriter.delegate = nil;
    [self stopRunning];
    [self cancelRecording];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
#endif
