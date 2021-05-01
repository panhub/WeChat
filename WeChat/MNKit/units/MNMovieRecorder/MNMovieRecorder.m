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
#import "MNDeviceMotior.h"
#import <UIKit/UIImage.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "AVCaptureDevice+MNFormat.h"
#if __has_include(<ImageIO/CGImageProperties.h>)
#import <ImageIO/CGImageProperties.h>
#endif

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

static const NSString *MNMovieRecordAdjustingExposureContext;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

#ifdef __IPHONE_10_0
@interface MNMovieRecorder ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, MNMovieWriteDelegate, AVCapturePhotoCaptureDelegate>
@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput API_AVAILABLE(ios(10.0));
#else
@interface MNMovieRecorder ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, MNMovieWriteDelegate>
#endif
@property (nonatomic) MNMovieRecordStatus status;
@property (nonatomic, strong) MNDeviceMotior *motior;
@property (nonatomic, strong) MNCaptureLivePhoto *livePhoto;
@property (nonatomic, strong) MNMovieWriter *movieWriter;
@property (nonatomic, strong) dispatch_queue_t photoQueue;
@property (nonatomic, strong) dispatch_queue_t outputQueue;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSessionPreset suitableSessionPreset;
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

- (instancetype)initWithDelegate:(id<MNMovieRecordDelegate>)delegate {
    if (self = [self init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)initialized {
    _frameRate = 30;
    _motior = MNDeviceMotior.new;
    _motior.updateInterval = .3f;
    _movieWriter = MNMovieWriter.new;
    _movieWriter.delegate = self;
    _sessionPreset = AVCaptureSessionPresetHigh;
    _devicePosition = MNMovieDevicePositionBack;
    _movieOrientation = MNMovieOrientationAuto;
    _resizeMode = MNMovieResizeModeResizeAspect;
    _photoQueue = dispatch_queue_create("com.mn.capture.photo.queue", DISPATCH_QUEUE_SERIAL);
    _outputQueue = dispatch_queue_create("com.mn.capture.output.queue", DISPATCH_QUEUE_SERIAL);
    _sessionQueue = dispatch_queue_create("com.mn.capture.session.queue", DISPATCH_QUEUE_SERIAL);
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sessionDidStartRunningNotification:) name:AVCaptureSessionDidStartRunningNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sessionDidStopRunningNotification:) name:AVCaptureSessionDidStopRunningNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sessionWasInterruptedNotification:) name:AVCaptureSessionWasInterruptedNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sessionInterruptionEndedNotification:) name:AVCaptureSessionInterruptionEndedNotification object:nil];
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
                if ([weakself setupVideo] && [weakself setupAudio] && [weakself setupPhoto] ) {
                    [weakself setOutputView:weakself.outputView];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakself startRunning];
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
                        [weakself startRunning];
                    });
                }
            }];
        }];
    });
}

- (void)prepareTaking {
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
#ifdef __IPHONE_10_0
        if (@available(iOS 10.0, *)) {
            [weakself prepareCapturing];
            return;
        }
#endif
        [MNAuthenticator requestCameraAuthorizationStatusWithHandler:^(BOOL allowed) {
            if (!allowed) {
                [weakself failureWithCode:AVErrorApplicationIsNotAuthorized description:@"获取摄像权限失败"];
                return;
            }
            if ([weakself setupVideo] && [weakself setupPhoto]) {
                [weakself setOutputView:weakself.outputView];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself startRunning];
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
    AVFrameRateRange *frameRateRange = device.maxFrameRateRange;
    AVCaptureDeviceFormat *frameRateFormat = device.maxFrameRateFormat;
    if ([device lockForConfiguration:NULL] ) {
        if (frameRateFormat) device.activeFormat = frameRateFormat;
        // 帧时长与帧率是倒数关系, 所以最大帧率对应最小帧时长
        if (frameRateRange) device.activeVideoMinFrameDuration = frameRateRange.minFrameDuration;
        if (frameRateRange) device.activeVideoMaxFrameDuration = frameRateRange.minFrameDuration;
        if (device.isSmoothAutoFocusEnabled) device.smoothAutoFocusEnabled = YES;
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
    // 视频不翻转镜像 要不导致拍摄中切换摄像头倒置现象
    /*
    if (device.position == AVCaptureDevicePositionFront) {
        AVCaptureConnection *videoConnection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
        if (videoConnection.isVideoMirroringSupported) videoConnection.videoMirrored = YES;
    }
    */
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

- (BOOL)setupPhoto {
    if (!self.session) {
        [self failureWithDescription:@"录像会话初始化失败"];
        return NO;
    }
#ifdef __IPHONE_10_0
    if (@available(iOS 10.0, *)) {
        AVCapturePhotoOutput *photoOutput = [[AVCapturePhotoOutput alloc] init];
        photoOutput.highResolutionCaptureEnabled = YES;
#ifdef __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            photoOutput.maxPhotoQualityPrioritization = AVCapturePhotoQualityPrioritizationQuality;
        }
#endif
        if (![self.session canAddOutput:photoOutput]) {
            [self failureWithDescription:@"拍照设备初始化失败"];
            return NO;
        }
        [self.session addOutput:photoOutput];
        self.photoOutput = photoOutput;
        if (self.photoOutput.isLivePhotoCaptureSupported) {
            self.photoOutput.livePhotoCaptureEnabled = YES;
            self.photoOutput.livePhotoAutoTrimmingEnabled = YES;
        }
        if (self.videoInput.device.position == AVCaptureDevicePositionFront) {
            AVCaptureConnection *photoConnection = [photoOutput connectionWithMediaType:AVMediaTypeVideo];
            if (photoConnection.isVideoMirroringSupported) photoConnection.videoMirrored = YES;
        }
        return YES;
    }
#endif
    return [self setupImage];
}

- (BOOL)setupImage {
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    [imageOutput setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG}];
    if (![self.session canAddOutput:imageOutput]) {
        [self failureWithDescription:@"拍照设备初始化失败"];
        return NO;
    }
    [self.session addOutput:imageOutput];
    self.imageOutput = imageOutput;
    if (self.videoInput.device.position == AVCaptureDevicePositionFront) {
        AVCaptureConnection *imageConnection = [imageOutput connectionWithMediaType:AVMediaTypeVideo];
        if (imageConnection.isVideoMirroringSupported) imageConnection.videoMirrored = YES;
    }
    return YES;
}

#pragma mark - 开始/停止捕获
- (BOOL)isRunning {
    return (_session && _session.isRunning);
}

- (void)startRunning {
    __weak typeof(self) weakself = self;
    dispatch_async(self.sessionQueue, ^{
        __strong typeof(self) self = weakself;
        if (!self.session.isRunning) {
            [self.session startRunning];
        }
    });
}

- (void)stopRunning {
    __weak typeof(self) weakself = self;
    dispatch_async(self.sessionQueue, ^{
        __strong typeof(self) self = weakself;
        if (self.session.isRunning) {
            [self.session stopRunning];
        }
    });
}

#pragma mark - 拍照
- (void)takePhoto {
    if (!self.isRunning) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
            [self.delegate movieRecorderDidTakingPhoto:nil error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorSessionNotRunning userInfo:@{NSLocalizedDescriptionKey:@"捕获设备未开启"}]];
        }
        return;
    }
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
            [self.delegate movieRecorderDidTakingPhoto:nil error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"正在捕获视频"}]];
        }
        return;
    }
#ifdef __IPHONE_10_0
    if (@available(iOS 10.0, *)) {
        if (!self.photoOutput) {
            if ([self.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
                [self.delegate movieRecorderDidTakingPhoto:nil error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"图片捕获初始化失败"}]];
            }
            return;
        }
        if (![self.photoOutput.availablePhotoCodecTypes containsObject:AVVideoCodecJPEG]) {
            if ([self.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
                [self.delegate movieRecorderDidTakingPhoto:nil error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"设备不支持JPEG图像捕获"}]];
            }
            return;
        }
        // 实例化拍照设置 默认JPEG
        AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettings];
        photoSettings.highResolutionPhotoEnabled = YES;
        AVCaptureFlashMode flashMode = AVCaptureFlashModeOff;
        if ([self.delegate respondsToSelector:@selector(movieRecorderTakingPhotoShouldUsingFlash:)] && [self.delegate movieRecorderTakingPhotoShouldUsingFlash:self] && [self.photoOutput.supportedFlashModes containsObject:@(AVCaptureFlashModeOn)]) {
            flashMode = AVCaptureFlashModeOn;
        }
        photoSettings.flashMode = flashMode;
        photoSettings.autoStillImageStabilizationEnabled = YES;
        AVCaptureConnection *photoConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
        // videoOrientation并不会真正的修改图片像素点的位置, 只是给图片设置一个合适的方向
        if (photoConnection.isVideoOrientationSupported) photoConnection.videoOrientation = self.photoOrientation;
        [self.photoOutput capturePhotoWithSettings:photoSettings delegate:self];
        return;
    }
#endif
    if (!self.imageOutput) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
            [self.delegate movieRecorderDidTakingPhoto:nil error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"图片捕获初始化失败"}]];
        }
        return;
    }
    __weak typeof(self) weakself = self;
    AVCaptureConnection *imageConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    // videoOrientation并不会真正的修改图片像素点的位置, 只是给图片设置一个合适的方向
    if (imageConnection.isVideoOrientationSupported) imageConnection.videoOrientation = self.photoOrientation;
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:imageConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (error || imageDataSampleBuffer == NULL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
                    [weakself.delegate movieRecorderDidTakingPhoto:nil error:(error ? : [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"图片捕获失败"}])];
                }
            });
            return;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        MNCapturePhoto *photo = [MNCapturePhoto photoWithImageData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!photo) {
                if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
                    [weakself.delegate movieRecorderDidTakingPhoto:nil error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"图片捕获失败"}]];
                }
                return;
            }
            if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
                [weakself.delegate movieRecorderDidTakingPhoto:photo error:nil];
            }
        });
    }];
}

#ifdef __IPHONE_10_0
- (void)takeLivePhoto {
    if (!self.isRunning) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
            [self.delegate movieRecorderDidTakingPhoto:nil error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorSessionNotRunning userInfo:@{NSLocalizedDescriptionKey:@"捕获设备未开启"}]];
        }
        return;
    }
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
            [self.delegate movieRecorderDidTakingPhoto:nil error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"正在捕获视频"}]];
        }
        return;
    }
    if (!self.photoOutput) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
            [self.delegate movieRecorderDidTakingPhoto:nil error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"图片捕获初始化失败"}]];
        }
        return;
    }
    if (self.photoOutput.isLivePhotoCaptureSupported == NO || self.photoOutput.isLivePhotoCaptureEnabled == NO) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
            [self.delegate movieRecorderDidTakingPhoto:nil error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"当前会话配置不支持LivePhoto拍摄"}]];
        }
        return;
    }
    // LivePhoto视频地址
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"MN-LivePhoto/MN-LIVE.MOV"]];
    [NSFileManager.defaultManager removeItemAtURL:fileURL error:nil];
    if (![NSFileManager.defaultManager createDirectoryAtPath:fileURL.path.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil]) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
            [self.delegate movieRecorderDidTakingPhoto:nil error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"无法创建LivePhoto文件"}]];
        }
        return;
    }
    // LivePhoto参数
    AVCapturePhotoSettings *photoSettings = [[AVCapturePhotoSettings alloc] init];
    photoSettings.livePhotoMovieFileURL = fileURL;
    if (self.photoOutput.availableLivePhotoVideoCodecTypes.count) photoSettings.livePhotoVideoCodecType = self.photoOutput.availableLivePhotoVideoCodecTypes.firstObject;
    self.photoOutput.livePhotoCaptureSuspended = NO;
    AVCaptureConnection *photoConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
    if (photoConnection.isVideoOrientationSupported) photoConnection.videoOrientation = self.photoOrientation;
    [self.photoOutput capturePhotoWithSettings:photoSettings delegate:self];
}

- (void)startTakingLivePhoto {
    if (!_session) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidChangeSessionPreset:error:)]) {
            [self.delegate movieRecorderDidChangeSessionPreset:self error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorSessionNotRunning userInfo:@{NSLocalizedDescriptionKey:@"捕获会话不存在"}]];
        }
        return;
    }
    if ([self.session.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidChangeSessionPreset:error:)]) {
            [self.delegate movieRecorderDidChangeSessionPreset:self error:nil];
        }
        return;
    }
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidChangeSessionPreset:error:)]) {
            [self.delegate movieRecorderDidChangeSessionPreset:self error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"正在捕获视频"}]];
        }
        return;
    }
    if (!self.photoOutput) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidChangeSessionPreset:error:)]) {
            [self.delegate movieRecorderDidChangeSessionPreset:self error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"图片捕获初始化失败"}]];
        }
        return;
    }
    // 设置新的预设参数
    if (![self.session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidChangeSessionPreset:error:)]) {
            [self.delegate movieRecorderDidChangeSessionPreset:self error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"当前会话配置不支持LivePhoto拍摄"}]];
        }
        return;
    }
    
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        weakself.session.sessionPreset = AVCaptureSessionPresetPhoto;
        weakself.sessionPreset = AVCaptureSessionPresetPhoto;
#ifdef __IPHONE_10_0
        if (@available(iOS 10.0, *)) {
            if (weakself.photoOutput && weakself.photoOutput.isLivePhotoCaptureSupported && !weakself.photoOutput.isLivePhotoCaptureEnabled) {
                BOOL isRunning = weakself.session.isRunning;
                if (isRunning) [weakself.session stopRunning];
                weakself.photoOutput.livePhotoCaptureEnabled = YES;
                weakself.photoOutput.livePhotoAutoTrimmingEnabled = YES;
                if (isRunning) [weakself.session startRunning];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidChangeSessionPreset:error:)]) {
                        [weakself.delegate movieRecorderDidChangeSessionPreset:weakself error:nil];
                    }
                });
                return;
            }
        }
#endif
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidChangeSessionPreset:error:)]) {
                [weakself.delegate movieRecorderDidChangeSessionPreset:weakself error:nil];
            }
        });
    });
}

- (void)stopTakingLivePhoto {
    if (!_session) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidChangeSessionPreset:error:)]) {
            [self.delegate movieRecorderDidChangeSessionPreset:self error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorSessionNotRunning userInfo:@{NSLocalizedDescriptionKey:@"捕获会话不存在"}]];
        }
        return;
    }
    if (![self.session.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidChangeSessionPreset:error:)]) {
            [self.delegate movieRecorderDidChangeSessionPreset:self error:nil];
        }
        return;
    }
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidChangeSessionPreset:error:)]) {
            [self.delegate movieRecorderDidChangeSessionPreset:self error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"正在捕获视频"}]];
        }
        return;
    }
    // 设置新的预设参数
    if (![self.session canSetSessionPreset:self.suitableSessionPreset]) {
        if ([self.delegate respondsToSelector:@selector(movieRecorderDidChangeSessionPreset:error:)]) {
            [self.delegate movieRecorderDidChangeSessionPreset:self error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"无法恢复会话预设"}]];
        }
        return;
    }
    
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        weakself.session.sessionPreset = weakself.suitableSessionPreset;
        weakself.sessionPreset = weakself.suitableSessionPreset;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidChangeSessionPreset:error:)]) {
                [weakself.delegate movieRecorderDidChangeSessionPreset:weakself error:nil];
            }
        });
    });
}

#endif

#pragma mark - 录像
- (BOOL)isRecording {
    @synchronized (self) {
        return self.status == MNMovieRecordStatusRecording;
    }
}

- (void)startRecording {
    if (!self.isRunning) {
        [self failureWithCode:AVErrorSessionNotRunning description:@"捕获未开启"];
        return;
    }
    @synchronized (self) {
        if (self.status == MNMovieRecordStatusRecording) return;
        self.status = MNMovieRecordStatusRecording;
    }
    self.movieWriter.frameRate = self.frameRate;
    self.movieWriter.transform = self.videoTransform;
    [self.movieWriter startWriting];
}

- (void)stopRecording {
    @synchronized (self) {
        if (self.status != MNMovieRecordStatusRecording) return;
    }
    [self.movieWriter finishWriting];
}

- (void)cancelRecording {
    @synchronized (self) {
        if (self.status != MNMovieRecordStatusRecording) return;
    }
    [self.movieWriter cancelWriting];
}

- (BOOL)deleteRecording {
    if (self.isRecording) return NO;
    return [NSFileManager.defaultManager removeItemAtURL:self.URL error:nil];
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

#pragma mark - AVCapturePhotoCaptureDelegate
#ifdef __IPHONE_10_0
- (void)captureOutput:(AVCapturePhotoOutput *)output willBeginCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings {
    if (self.isMuteTaking) AudioServicesDisposeSystemSoundID(1110-2);
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakself.delegate respondsToSelector:@selector(movieRecorder:didBeginTakingPhoto:)]) {
            [weakself.delegate movieRecorder:weakself didBeginTakingPhoto:(resolvedSettings.livePhotoMovieDimensions.width > 0.f && resolvedSettings.livePhotoMovieDimensions.height > 0.f)];
        }
    });
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error {
    
    __weak typeof(self) weakself = self;
    dispatch_async(self.photoQueue, ^{
        
        BOOL isLivePhoto = (resolvedSettings.livePhotoMovieDimensions.width > 0.f && resolvedSettings.livePhotoMovieDimensions.height > 0.f);
        
        if (error && !isLivePhoto) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
                    [weakself.delegate movieRecorderDidTakingPhoto:nil error:(error ? : [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"图片捕获失败"}])];
                }
            });
            return;
        }
        
        // 解析图片
        NSData *imageData = error ? nil : [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
        MNCapturePhoto *photo = [MNCapturePhoto photoWithImageData:imageData];
        
        if (isLivePhoto) {
            weakself.livePhoto = [MNCaptureLivePhoto liveWithPhoto:photo];
            if (weakself.livePhoto) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([weakself.delegate respondsToSelector:@selector(movieRecorder:didTakingLiveStillImage:)]) {
                        [weakself.delegate movieRecorder:weakself didTakingLiveStillImage:weakself.livePhoto];
                    }
                });
            }
            return;
        }
        
        if (!photo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
                    [weakself.delegate movieRecorderDidTakingPhoto:nil error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"图片捕获失败"}]];
                }
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
                [weakself.delegate movieRecorderDidTakingPhoto:photo error:nil];
            }
        });
    });
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingLivePhotoToMovieFileAtURL:(NSURL *)outputFileURL duration:(CMTime)duration photoDisplayTime:(CMTime)photoDisplayTime resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings error:(nullable NSError *)error {
    
    __weak typeof(self) weakself = self;
    dispatch_async(self.photoQueue, ^{

        if (error || !outputFileURL || !weakself.livePhoto) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
                    [weakself.delegate movieRecorderDidTakingPhoto:nil error:(error ? : [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"LivePhoto捕获失败"}])];
                }
            });
            return;
        }
        
        MNCaptureLivePhoto *livePhoto = weakself.livePhoto;
        livePhoto.videoURL = outputFileURL;
        livePhoto.duration = duration;
        livePhoto.photoDisplayTime = photoDisplayTime;
        weakself.livePhoto = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
                [weakself.delegate movieRecorderDidTakingPhoto:livePhoto error:nil];
            }
        });
    });
}
#endif
#ifdef __IPHONE_11_0
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)capturePhoto error:(nullable NSError *)error {

    __weak typeof(self) weakself = self;
    dispatch_async(self.photoQueue, ^{
        
        AVCaptureResolvedPhotoSettings *resolvedSettings = capturePhoto.resolvedSettings;
        BOOL isLivePhoto = (resolvedSettings.livePhotoMovieDimensions.width > 0.f && resolvedSettings.livePhotoMovieDimensions.height > 0.f);
        
        if (error && !isLivePhoto) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
                    [weakself.delegate movieRecorderDidTakingPhoto:nil error:(error ? : [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"图片捕获失败"}])];
                }
            });
            return;
        }
        
        // 解析图片
        MNCapturePhoto *photo = error ? nil : [MNCapturePhoto photoWithImageData:capturePhoto.fileDataRepresentation];
        
        if (isLivePhoto) {
            weakself.livePhoto = [MNCaptureLivePhoto liveWithPhoto:photo];
            if (weakself.livePhoto) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([weakself.delegate respondsToSelector:@selector(movieRecorder:didTakingLiveStillImage:)]) {
                        [weakself.delegate movieRecorder:weakself didTakingLiveStillImage:weakself.livePhoto];
                    }
                });
            }
            return;
        }
        
        if (!photo) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
                    [weakself.delegate movieRecorderDidTakingPhoto:nil error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorScreenCaptureFailed userInfo:@{NSLocalizedDescriptionKey:@"图片捕获失败"}]];
                }
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidTakingPhoto:error:)]) {
                [weakself.delegate movieRecorderDidTakingPhoto:photo error:nil];
            }
        });
    });
}
#endif

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
- (BOOL)isTorchScene {
    AVCaptureDevice *device = self.videoInput.device;
    return (device && device.torchMode == AVCaptureTorchModeOn);
}

- (void)openTorch {
    __block NSError *error;
    __block BOOL changeFlash = NO;
    __block BOOL changeTorch = NO;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (!device || !device.hasTorch) {
            error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"未发现手电筒"}];
        } else if (device.torchMode != AVCaptureTorchModeOn) {
            // 打开手电筒前 关闭闪光灯
            if (device.hasFlash && device.flashMode == AVCaptureFlashModeOn) {
                changeFlash = YES;
                device.flashMode = AVCaptureFlashModeOff;
            }
            if ([device isTorchModeSupported:AVCaptureTorchModeOn]) {
                changeTorch = YES;
                device.torchMode = AVCaptureTorchModeOn;
            } else {
                error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"设备不支持此操作"}];
            }
        }
    }];
    if (changeFlash && [self.delegate respondsToSelector:@selector(movieRecorderDidChangeFlashScene:error:)]) {
        [self.delegate movieRecorderDidChangeFlashScene:self error:nil];
    }
    if (changeTorch && [self.delegate respondsToSelector:@selector(movieRecorderDidChangeTorchScene:error:)]) {
        [self.delegate movieRecorderDidChangeTorchScene:self error:error];
    }
}

- (void)closeTorch {
    __block NSError *error;
    __block BOOL changeTorch = NO;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (!device || !device.hasTorch) {
            error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"未发现手电筒"}];
        } else if (device.torchMode != AVCaptureTorchModeOff) {
            if ([device isTorchModeSupported:AVCaptureTorchModeOff]) {
                changeTorch = YES;
                device.torchMode = AVCaptureTorchModeOff;
            } else {
                error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"设备不支持此操作"}];
            }
        }
    }];
    if (changeTorch && [self.delegate respondsToSelector:@selector(movieRecorderDidChangeTorchScene:error:)]) {
        [self.delegate movieRecorderDidChangeTorchScene:self error:error];
    }
}

#pragma mark - 闪光灯
- (BOOL)isFlashScene {
    AVCaptureDevice *device = self.videoInput.device;
    return (device && device.flashMode == AVCaptureFlashModeOn);
}

- (void)openFlash {
    __block NSError *error;
    __block BOOL changeFlash = NO;
    __block BOOL changeTorch = NO;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (!device || !device.hasFlash) {
            error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"未发现闪光灯"}];
        } else if (device.flashMode != AVCaptureFlashModeOn) {
            // 打开闪光灯前关闭手电筒
            if (device.hasTorch && device.torchMode == AVCaptureTorchModeOn) {
                changeTorch = YES;
                device.torchMode = AVCaptureTorchModeOff;
            }
            if ([device isFlashModeSupported:AVCaptureFlashModeOn]) {
                changeFlash = YES;
                device.flashMode = AVCaptureFlashModeOn;
            } else {
                error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"设备不支持此操作"}];
            }
        }
    }];
    if (changeTorch && [self.delegate respondsToSelector:@selector(movieRecorderDidChangeTorchScene:error:)]) {
        [self.delegate movieRecorderDidChangeTorchScene:self error:nil];
    }
    if (changeFlash && [self.delegate respondsToSelector:@selector(movieRecorderDidChangeFlashScene:error:)]) {
        [self.delegate movieRecorderDidChangeFlashScene:self error:error];
    }
}

- (void)closeFlash {
    __block NSError *error;
    __block BOOL changeFlash = NO;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (!device || !device.hasFlash) {
            error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"未发现闪光灯"}];
        } else if (device.flashMode != AVCaptureFlashModeOff) {
            if ([device isFlashModeSupported:AVCaptureFlashModeOff]) {
                changeFlash = YES;
                device.flashMode = AVCaptureFlashModeOff;
            } else {
                error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorTorchLevelUnavailable userInfo:@{NSLocalizedDescriptionKey:@"设备不支持此操作"}];
            }
        }
    }];
    if (changeFlash && [self.delegate respondsToSelector:@selector(movieRecorderDidChangeFlashScene:error:)]) {
        [self.delegate movieRecorderDidChangeFlashScene:self error:nil];
    }
}

#pragma mark - 摄像头
- (void)convertCameraWithCompletionHandler:(void(^)(NSError *))completionHandler {
    return [self convertCameraPosition:(MNMovieDevicePositionBack + MNMovieDevicePositionFront - self.devicePosition) completionHandler:completionHandler];
}

- (void)convertCameraPosition:(MNMovieDevicePosition)capturePosition completionHandler:(void(^)(NSError * error))completionHandler {
    __weak typeof(self) weakself = self;
    dispatch_async(self.sessionQueue, ^{
        __strong typeof(self) self = weakself;
        if (capturePosition == self.devicePosition) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) completionHandler(nil);
            });
            return;
        }
        AVCaptureDevice *device = [self deviceWithPosition:capturePosition];
        if (!device) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) completionHandler([NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"获取相机失败"}]);
            });
            return;
        }
        AVFrameRateRange *frameRateRange = device.maxFrameRateRange;
        AVCaptureDeviceFormat *frameRateFormat = device.maxFrameRateFormat;
        if ([device lockForConfiguration:NULL] ) {
            if (frameRateFormat) device.activeFormat = frameRateFormat;
            // 帧时长与帧率是倒数关系, 所以最大帧率对应最小帧时长
            if (frameRateRange) device.activeVideoMinFrameDuration = frameRateRange.minFrameDuration;
            if (frameRateRange) device.activeVideoMaxFrameDuration = frameRateRange.minFrameDuration;
            if (device.isSmoothAutoFocusEnabled) device.smoothAutoFocusEnabled = YES;
            [device unlockForConfiguration];
        }
        AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:NULL];
        if (!videoInput) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) completionHandler([NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"切换相机失败"}]);
            });
            return;
        }
        
        // 添加动画效果
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            CATransition *transition = [CATransition animation];
            transition.type = @"oglFlip";
            transition.subtype = device.position == AVCaptureDevicePositionFront ? kCATransitionFromLeft : kCATransitionFromRight;
            transition.duration = .5f;
            transition.removedOnCompletion = NO;
            transition.fillMode = kCAFillModeForwards;
            [self.previewLayer removeAllAnimations];
            [self.previewLayer addAnimation:transition forKey:nil];
        });
        */
        
        // 手电筒/闪光灯设置
        AVCaptureFlashMode flashMode = self.videoInput.device.flashMode;
        AVCaptureTorchMode torchMode = self.videoInput.device.torchMode;
        if (flashMode != AVCaptureFlashModeOff) [self closeFlash];
        if (device.position == AVCaptureDevicePositionFront && torchMode != AVCaptureTorchModeOff) [self closeTorch];
        
        BOOL isRunning = self.session.isRunning;
        if (isRunning) [self.session stopRunning];
        [self.session beginConfiguration];
        if (self.videoInput) [self.session removeInput:self.videoInput];
        
        if ([self.session canAddInput:videoInput]) {
            // 转换
            [self.session addInput:videoInput];
#ifdef __IPHONE_10_0
            if (self.photoOutput) {
                if (self.photoOutput.isLivePhotoCaptureSupported) {
                    self.photoOutput.livePhotoCaptureEnabled = YES;
                    self.photoOutput.livePhotoAutoTrimmingEnabled = YES;
                }
                if (device.position == AVCaptureDevicePositionFront) {
                    AVCaptureConnection *photoConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
                    if (photoConnection.isVideoMirroringSupported) photoConnection.videoMirrored = YES;
                }
            }
#endif
            if (self.imageOutput && device.position == AVCaptureDevicePositionFront) {
                AVCaptureConnection *imageConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
                if (imageConnection.isVideoMirroringSupported) imageConnection.videoMirrored = YES;
            }
            // 视频不翻转镜像 要不导致拍摄中切换摄像头倒置现象
            /*
            if (self.videoOutput && device.position == AVCaptureDevicePositionFront) {
                AVCaptureConnection *videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
                if (videoConnection.isVideoMirroringSupported) videoConnection.videoMirrored = YES;
            }
            */
            [self.session commitConfiguration];
            if (isRunning) [self.session startRunning];
            
            self.videoInput = videoInput;
            self.devicePosition = capturePosition;
            
            // 同步闪光灯配置 手电筒配置不同步(前置没有摄像头, 后置要主动开启)
            if (flashMode == AVCaptureFlashModeOn) [self openFlash];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) completionHandler(nil);
            });
        } else {
            if (self.videoInput) [self.session addInput:self.videoInput];
            [self.session commitConfiguration];
            if (isRunning) [self.session startRunning];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) completionHandler([NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"切换相机失败"}]);
            });
        }
    });
}

#pragma mark - 对焦
- (BOOL)setFocus:(CGPoint)point {
    if (!_previewLayer) return NO;
    __block BOOL result = NO;
    point = [self.previewLayer captureDevicePointOfInterestForPoint:point];
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (device && device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
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
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&MNMovieRecordAdjustingExposureContext];
            }
        }
    }];
    return result;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == &MNMovieRecordAdjustingExposureContext) {
        AVCaptureDevice *device = object;
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&MNMovieRecordAdjustingExposureContext];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([device lockForConfiguration:NULL]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                }
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - -缩放
- (BOOL)setZoomFactor:(CGFloat)factor withRate:(float)rate {
    __block BOOL result = NO;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (device && !device.isRampingVideoZoom) {
            //videoMaxZoomFactor的值可能会非常大, 在 iphone8p上这一个值是16, 缩放到这么大的图像是没有太大意义的, 因此需要人为设置一个最大缩放值, 这里选择5.0
            CGFloat maxZoomFactor = MIN(device.activeFormat.videoMaxZoomFactor, 5.f);
            CGFloat zoomFactor = MAX(1.f, MIN(factor, maxZoomFactor));
            if (device.videoZoomFactor != zoomFactor) {
                if (rate > 0.f) {
                    [device rampToVideoZoomFactor:zoomFactor withRate:rate];
                } else {
                    [device setVideoZoomFactor:zoomFactor];
                }
            }
            result = YES;
        }
    }];
    return result;
}

- (BOOL)cancelZoom {
    __block BOOL result = NO;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (device && !device.isRampingVideoZoom) {
            [device cancelVideoZoomRamp];
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
// 中断
- (void)sessionWasInterruptedNotification:(NSNotification *)notify {
    if (![notify.object isKindOfClass:AVCaptureSession.class]) return;
    if (((AVCaptureSession *)notify.object) != _session) return;
    [self cancelRecording];
}
// 中断结束
- (void)sessionInterruptionEndedNotification:(NSNotification *)notify {}
// 开始运行
- (void)sessionDidStartRunningNotification:(NSNotification *)notify {
    if (![notify.object isKindOfClass:AVCaptureSession.class]) return;
    if (((AVCaptureSession *)notify.object) != _session) return;
    [self.motior startMotior];
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidStartRunning:)]) {
            [weakself.delegate movieRecorderDidStartRunning:weakself];
        }
    });
}
// 结束运行
- (void)sessionDidStopRunningNotification:(NSNotification *)notify {
    if (![notify.object isKindOfClass:AVCaptureSession.class]) return;
    if (((AVCaptureSession *)notify.object) != _session) return;
    [self.motior stopMotior];
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakself.delegate respondsToSelector:@selector(movieRecorderDidStopRunning:)]) {
            [weakself.delegate movieRecorderDidStopRunning:weakself];
        }
    });
}

#pragma mark - Setter
- (void)setURL:(NSURL *)URL {
    _URL = URL.copy;
    self.movieWriter.URL = URL;
}

- (void)setOutputView:(UIView *)outputView {
    _outputView = outputView;
    if (!_session) return;
    AVLayerVideoGravity videoGravity = self.videoLayerGravity;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.previewLayer removeFromSuperlayer];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.previewLayer.frame = outputView.bounds;
        self.previewLayer.videoGravity = videoGravity;
        [CATransaction commit];
        [outputView.layer insertSublayer:self.previewLayer atIndex:0];
    });
}

- (void)setResizeMode:(MNMovieResizeMode)resizeMode {
    if (resizeMode == _resizeMode) return;
    _resizeMode = resizeMode;
    if (_previewLayer) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _previewLayer.videoGravity = [self videoLayerGravity];
        [CATransaction commit];
    }
}

- (void)setStatus:(MNMovieRecordStatus)status error:(NSError *)error {
    
    _status = status;
    
    BOOL shouldNotifyDelegate = NO;
    
    if (status >= MNMovieRecordStatusRecording) {
        shouldNotifyDelegate = YES;
        if (status >= MNMovieRecordStatusFinish) {
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
        session.usesApplicationAudioSession = YES;
        AVCaptureSessionPreset sessionPreset = self.sessionPreset ? : AVCaptureSessionPresetHigh;
        if ([session canSetSessionPreset:sessionPreset]) {
            session.sessionPreset = sessionPreset;
        } else {
            MNMovieSizeRatio presetSizeRatio = [self sizeRatioWithSessionPreset:sessionPreset];
            if (presetSizeRatio <= MNMovieSizeRatio9x16) {
                if ([session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
                    session.sessionPreset = AVCaptureSessionPresetHigh;
                } else if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
                    session.sessionPreset = AVCaptureSessionPreset1920x1080;
                } else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
                    session.sessionPreset = AVCaptureSessionPreset1280x720;
                } else if ([session canSetSessionPreset:AVCaptureSessionPresetiFrame1280x720]) {
                    session.sessionPreset = AVCaptureSessionPresetiFrame1280x720;
                } else if ([session canSetSessionPreset:AVCaptureSessionPresetiFrame960x540]) {
                    session.sessionPreset = AVCaptureSessionPresetiFrame960x540;
                }
            } else {
                if ([session canSetSessionPreset:AVCaptureSessionPresetMedium]) {
                    session.sessionPreset = AVCaptureSessionPresetMedium;
                } else if ([session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
                    session.sessionPreset = AVCaptureSessionPreset640x480;
                } else if ([session canSetSessionPreset:AVCaptureSessionPreset352x288]) {
                    session.sessionPreset = AVCaptureSessionPreset352x288;
                } else if ([session canSetSessionPreset:AVCaptureSessionPresetLow]) {
                    session.sessionPreset = AVCaptureSessionPresetLow;
                }
            }
            if (!session.sessionPreset) session.sessionPreset = AVCaptureSessionPresetInputPriority;
        }
        _session = session;
        _sessionPreset = session.sessionPreset;
        _suitableSessionPreset = session.sessionPreset;
    }
    return _session;
}

- (MNMovieSizeRatio)presetSizeRatio {
    return [self sizeRatioWithSessionPreset:self.session.sessionPreset];
}

- (MNMovieSizeRatio)sizeRatioWithSessionPreset:(AVCaptureSessionPreset)sessionPreset {
    if (!sessionPreset) return MNMovieSizeRatioUnknown;
#ifdef __IPHONE_9_0
    if (@available(iOS 9.0, *)) {
        if ([sessionPreset isEqualToString:AVCaptureSessionPreset3840x2160]) {
            return MNMovieSizeRatio9x16;
        }
    }
#endif
    if ([sessionPreset isEqualToString:AVCaptureSessionPresetInputPriority]) {
        return (NSProcessInfo.processInfo.processorCount <= 1) ? MNMovieSizeRatio3x4 : MNMovieSizeRatio9x16;
    }
    if ([sessionPreset isEqualToString:AVCaptureSessionPresetHigh] || [sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080] || [sessionPreset isEqualToString:AVCaptureSessionPreset1280x720] || [sessionPreset isEqualToString:AVCaptureSessionPresetiFrame1280x720] || [sessionPreset isEqualToString:AVCaptureSessionPresetiFrame960x540]) {
        return MNMovieSizeRatio9x16;
    }
    return MNMovieSizeRatio3x4;
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

- (AVCaptureVideoOrientation)photoOrientation {
    AVCaptureVideoOrientation orientation;
    switch (self.motior.orientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        {
            orientation = self.movieOrientation <= MNMovieOrientationPortrait ? AVCaptureVideoOrientationPortrait : AVCaptureVideoOrientationLandscapeLeft;
        } break;
        case UIDeviceOrientationLandscapeLeft:
        {
            orientation = self.movieOrientation == MNMovieOrientationPortrait ? AVCaptureVideoOrientationPortrait : AVCaptureVideoOrientationLandscapeRight;
        } break;
        case UIDeviceOrientationLandscapeRight:
        {
            orientation = self.movieOrientation == MNMovieOrientationPortrait ? AVCaptureVideoOrientationPortrait : AVCaptureVideoOrientationLandscapeLeft;
        } break;
        case UIDeviceOrientationPortraitUpsideDown:
        {
            if (self.movieOrientation == MNMovieOrientationAuto) {
                orientation = AVCaptureVideoOrientationPortrait;
            } else if (self.movieOrientation == MNMovieOrientationPortrait) {
                orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            } else {
                orientation = AVCaptureVideoOrientationLandscapeRight;
            }
        } break;
        default:
        {
            orientation = AVCaptureVideoOrientationPortrait;
        } break;
    }
    return orientation;
}

- (CGAffineTransform)videoTransform {
    CGFloat radian = M_PI_2;
    //if (self.videoInput.device.position == AVCaptureDevicePositionFront) radian += M_PI;
    switch (self.motior.orientation) {
        case UIDeviceOrientationPortrait:
        {
            if (self.movieOrientation == MNMovieOrientationLandscape) {
                radian += M_PI_2;
            }
        } break;
        case UIDeviceOrientationLandscapeLeft:
        {
            if (self.movieOrientation != MNMovieOrientationPortrait) {
                radian -= M_PI_2;
            }
        } break;
        case UIDeviceOrientationLandscapeRight:
        {
            if (self.movieOrientation != MNMovieOrientationPortrait) {
                radian += M_PI_2;
            }
        } break;
        case UIDeviceOrientationPortraitUpsideDown:
        {
            if (self.movieOrientation == MNMovieOrientationPortrait) {
                radian += M_PI;
            } else if (self.movieOrientation == MNMovieOrientationLandscape) {
                radian -= M_PI_2;
            }
        } break;
        default:
            break;
    }
    return CGAffineTransformMakeRotation(radian);
}

#pragma mark - dealloc
- (void)dealloc {
    _delegate = nil;
    _movieWriter.delegate = nil;
    [self cancelRecording];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
#pragma clang diagnostic pop
#endif
