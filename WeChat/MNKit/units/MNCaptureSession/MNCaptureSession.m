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
#import "UIAlertView+MNHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

MNCapturePresetName const MNCapturePresetLowQuality = @"com.mn.capture.low";
MNCapturePresetName const MNCapturePresetMediumQuality = @"com.mn.capture.medium";
MNCapturePresetName const MNCapturePresetHighQuality = @"com.mn.capture.high";

@interface MNCaptureSession ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic) dispatch_queue_t writeQueue;
@property (nonatomic) dispatch_queue_t outputQueue;
@property (nonatomic) MNCapturePosition capturePosition;
@property (nonatomic) MNCaptureSessionStatus status;
@property (nonatomic, getter=isStarting) BOOL starting;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSDictionary *audioSetting;
@property (nonatomic, strong) NSDictionary *videoSetting;
@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *videoWriterInput;
@property (nonatomic, strong) AVAssetWriterInput *audioWriterInput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoLayer;
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

- (void)initialized {
    _frameRate = 25;
    _resizeMode = MNCaptureResizeModeResizeAspect;
    _capturePosition = MNCapturePositionBack;
    _writeQueue = dispatch_queue_create("com.mn.capture.write.queue", DISPATCH_QUEUE_SERIAL);
    _outputQueue = dispatch_queue_create("com.mn.capture.output.queue", DISPATCH_QUEUE_SERIAL);
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
                [weakself captureFailureWithCode:AVErrorApplicationIsNotAuthorized description:@"获取摄像权限失败"];
                return;
            }
            [MNAuthenticator requestMicrophoneAuthorizationStatusWithHandler:^(BOOL allow) {
                if (!allow) {
                    [weakself captureFailureWithCode:AVErrorApplicationIsNotAuthorized description:@"获取麦克风权限失败"];
                    return;
                }
                if (![weakself setSessionActive:YES]) {
                    [weakself captureFailureWithDescription:@"录像设备初始化失败"];
                    return;
                }
                if ([weakself setupVideo] && [weakself setupAudio] && [weakself setupStillImage] ) {
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
                [weakself captureFailureWithCode:AVErrorApplicationIsNotAuthorized description:@"获取摄像权限失败"];
                return;
            }
            [MNAuthenticator requestMicrophoneAuthorizationStatusWithHandler:^(BOOL allow) {
                if (!allow) {
                    [weakself captureFailureWithCode:AVErrorApplicationIsNotAuthorized description:@"获取麦克风权限失败"];
                    return;
                }
                if (![weakself setSessionActive:YES]) {
                    [weakself captureFailureWithDescription:@"录像设备初始化失败"];
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

- (void)prepareStilling {
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [MNAuthenticator requestCameraAuthorizationStatusWithHandler:^(BOOL allowed) {
            if (!allowed) {
                [weakself captureFailureWithCode:AVErrorApplicationIsNotAuthorized description:@"获取摄像权限失败"];
                return;
            }
            if (![weakself setSessionActive:YES]) {
                [weakself captureFailureWithDescription:@"录像设备初始化失败"];
                return;
            }
            if ([weakself setupVideo] && [weakself setupStillImage]) {
                [weakself setOutputView:weakself.outputView];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.session startRunning];
                });
            }
        }];
    });
}

#pragma mark - 设置视频/音频
- (BOOL)setupVideo {
    NSError *error = nil;
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self captureDeviceWithPosition:self.capturePosition] error:&error];
    if (error) {
        [self captureFailureWithDescription:@"录像设备初始化失败"];
        return NO;
    }
    if (![self.session canAddInput:self.videoInput]) {
        [self captureFailureWithDescription:@"录像设备初始化失败"];
        return NO;
    }
    AVCaptureConnection *connection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    [self.session addInput:self.videoInput];
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
    [self.videoOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]}];
    [self.videoOutput setSampleBufferDelegate:self queue:self.outputQueue];
    if (![self.session canAddOutput:self.videoOutput]) {
        [self captureFailureWithDescription:@"录像设备初始化失败"];
        return NO;
    }
    [self.session addOutput:self.videoOutput];
    return YES;
}

- (BOOL)setupAudio {
    NSError *error = nil;
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:&error];
    if (error) {
        [self captureFailureWithDescription:@"录音设备初始化失败"];
        return NO;
    }
    if (![self.session canAddInput:self.audioInput]) {
        [self captureFailureWithDescription:@"录音设备初始化失败"];
        return NO;
    }
    [self.session addInput:self.audioInput];
    self.audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioOutput setSampleBufferDelegate:self queue:self.outputQueue];
    if (![self.session canAddOutput:self.audioOutput]) {
        [self captureFailureWithDescription:@"录音设备初始化失败"];
        return NO;
    }
    [self.session addOutput:self.audioOutput];
    return YES;
}

- (BOOL)setupStillImage {
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    [imageOutput setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG}];
    if (![self.session canAddOutput:imageOutput]) {
        [self captureFailureWithDescription:@"录像设备初始化失败"];
        return NO;
    }
    [self.session addOutput:imageOutput];
    self.imageOutput = imageOutput;
    return YES;
}

#pragma mark - 开始/停止捕获
- (void)startRunning {
    if (_session && !_session.isRunning) [_session startRunning];
}

- (void)stopRunning {
    if (_session && _session.isRunning) [_session stopRunning];
}

#pragma mark - 开始/停止录像
- (void)startRecording {
    if (self.isRecording) return;
    if (self.outputPath.length <= 0) {
        [self captureFailureWithDescription:@"文件输出路径错误"];
        return;
    }
    if (!_session || !_session.isRunning) {
        [self captureFailureWithDescription:@"录像设备初始化错误"];
        return;
    }
    self.error = nil;
    self.starting = NO;
    __weak typeof(self)weakself = self;
    [NSFileManager.defaultManager removeItemAtPath:self.outputPath error:nil];
    [self startWritingWithCompletionHandler:^{
        if (weakself.error) {
            [weakself captureFailureWithError:weakself.error];
        } else {
            weakself.status = MNCaptureSessionStatusRecording;
            if ([weakself.delegate respondsToSelector:@selector(captureSessionDidStartRecording:)]) {
                [weakself.delegate captureSessionDidStartRecording:weakself];
            }
        }
    }];
}

- (void)startWritingWithCompletionHandler:(void (^)(void))completionHandler {
    NSError *error;
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:self.outputPath] fileType:AVFileTypeMPEG4 error:&error];
    if (error) {
        self.error = error;
        if (completionHandler) completionHandler();
        return;
    }
    AVAssetWriterInput *videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:self.videoSetting];
    /// 必须设为YES, 需要从 session 实时获取数据
    videoWriterInput.expectsMediaDataInRealTime = YES;
    //videoWriterInput.transform = CGAffineTransformMakeRotation(M_PI_2);
    if ([assetWriter canAddInput:videoWriterInput]) {
        [assetWriter addInput:videoWriterInput];
    } else {
        self.error = [NSError errorWithDomain:AVFoundationErrorDomain
                                         code:AVErrorExportFailed
                                     userInfo:@{NSLocalizedDescriptionKey:@"视频写入失败"}];
        if (completionHandler) completionHandler();
        return;
    }
    /// 音频
    AVAssetWriterInput *audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:self.audioSetting];
    audioWriterInput.expectsMediaDataInRealTime = YES;
    if ([assetWriter canAddInput:audioWriterInput]) {
        [assetWriter addInput:audioWriterInput];
    } else {
        self.error = [NSError errorWithDomain:AVFoundationErrorDomain
                                         code:AVErrorExportFailed
                                     userInfo:@{NSLocalizedDescriptionKey:@"音频写入失败"}];
        if (completionHandler) completionHandler();
        return;
    }
    self.error = nil;
    self.assetWriter = assetWriter;
    self.videoWriterInput = videoWriterInput;
    self.audioWriterInput = audioWriterInput;
    if (completionHandler) completionHandler();
}

- (void)stopRecording {
    if (!self.isRecording) return;
    __weak typeof(self)weakself = self;
    self.status = MNCaptureSessionStatusCompleted;
    [self.assetWriter finishWritingWithCompletionHandler:^{
        if (!weakself.error) weakself.error = weakself.assetWriter.error;
        if (weakself.error) weakself.status = MNCaptureSessionStatusFailed;
        weakself.assetWriter = nil;
        weakself.videoWriterInput = nil;
        weakself.audioWriterInput = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself.delegate respondsToSelector:@selector(captureSessionDidFinishRecording:)]) {
                [weakself.delegate captureSessionDidFinishRecording:weakself];
            }
        });
    }];
}

- (void)failRecording {
    self.assetWriter = nil;
    self.videoWriterInput = nil;
    self.audioWriterInput = nil;
    self.status = MNCaptureSessionStatusFailed;
    if (!self.error) {
        self.error = [NSError errorWithDomain:AVFoundationErrorDomain
                                         code:AVErrorExportFailed
                                     userInfo:@{NSLocalizedDescriptionKey:@"视频写入失败"}];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(captureSessionDidFinishRecording:)]) {
            [self.delegate captureSessionDidFinishRecording:self];
        }
    });
}

- (BOOL)deleteRecording {
    if (self.isRecording) return NO;
    return [NSFileManager.defaultManager removeItemAtPath:self.outputPath error:nil];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    /// 调整摄像头, 停止录制时不写入
    @synchronized (self) {
        if (sampleBuffer == NULL || !self.assetWriter || self.status != MNCaptureSessionStatusRecording) return;
        @autoreleasepool {
            if (output == self.videoOutput) {
                if (self.isStarting == NO) {
                    if ([self.assetWriter startWriting]) {
                        [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                        self.starting = YES;
                    } else {
                        [self failRecording];
                        return;
                    }
                }
                [self appendSampleBuffer:sampleBuffer mediaType:AVMediaTypeVideo];
            } else if (output == self.audioOutput) {
                [self appendSampleBuffer:sampleBuffer mediaType:AVMediaTypeAudio];
            }
        }
    }
}

- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer mediaType:(AVMediaType)mediaType {
    if (mediaType == AVMediaTypeVideo && self.videoWriterInput.readyForMoreMediaData) {
        if (![self.videoWriterInput appendSampleBuffer:sampleBuffer]) {
            [self failRecording];
        }
    } else if (mediaType == AVMediaTypeAudio && self.audioWriterInput.readyForMoreMediaData) {
        if (![self.audioWriterInput appendSampleBuffer:sampleBuffer]) {
            [self failRecording];
        }
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
    AVCaptureDevice *device = [self captureDeviceWithPosition:capturePosition];
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
- (void)captureFailureWithDescription:(NSString *)message {
    [self captureFailureWithCode:AVErrorScreenCaptureFailed description:message];
}

- (void)captureFailureWithCode:(NSUInteger)code description:(NSString *)description{
    [self captureFailureWithError:[NSError errorWithDomain:AVFoundationErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:description}]];
}

- (void)captureFailureWithError:(NSError *)error {
    __weak typeof(self)weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakself.error = error;
        if ([weakself.delegate respondsToSelector:@selector(captureSessionDidFailureWithError:)]) {
            [weakself.delegate captureSessionDidFailureWithError:weakself];
        }
    });
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

#pragma mark - Getter
- (AVCaptureSession *)session {
    if (!_session) {
        AVCaptureSession *session = [AVCaptureSession new];
        session.usesApplicationAudioSession = NO;
        session.sessionPreset = [session canSetSessionPreset:AVCaptureSessionPresetHigh] ? AVCaptureSessionPresetHigh : AVCaptureSessionPresetMedium;
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
    return self.status == MNCaptureSessionStatusRecording;
}

- (Float64)duration {
    if (self.isRunning || ![NSFileManager.defaultManager fileExistsAtPath:self.outputPath]) return 0.f;
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.outputPath] options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
    if (!asset) return 0.f;
    return CMTimeGetSeconds(asset.duration);
}

- (NSInteger)frameRate {
    return MIN(30, MAX(_frameRate, 15));
}

- (MNCapturePresetName)presetName {
    return [_presetName hasPrefix:@"com.mn.capture."] ? _presetName : MNCapturePresetMediumQuality;
}

- (NSDictionary *)videoSetting {
    if (!_videoSetting) {
        //NSDictionary *dc = [self.videoOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeMPEG4];
        //NSDictionary *d = [dc objectForKey:AVVideoCompressionPropertiesKey];
        CGFloat width = self.outputSize.width;
        CGFloat height = self.outputSize.height;
        /// 码率和帧率设置
        NSDictionary *compressionSetting = @{AVVideoAverageBitRateKey:@(width*height*6.f), AVVideoExpectedSourceFrameRateKey:@(self.frameRate), AVVideoProfileLevelKey:self.videoProfileLevel};
        _videoSetting = @{AVVideoWidthKey:@(width), AVVideoHeightKey:@(height), AVVideoCodecKey:AVVideoCodecH264, AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill, AVVideoCompressionPropertiesKey:compressionSetting};
    }
    return _videoSetting;
}

- (NSDictionary *)audioSetting {
    if (!_audioSetting) {
        //_audioSetting = @{AVEncoderBitRatePerChannelKey:@(28000), AVFormatIDKey:@(kAudioFormatMPEG4AAC), AVNumberOfChannelsKey:@(1), AVSampleRateKey:@(22050)};
        AudioChannelLayout channelLayout = {
            .mChannelLayoutTag = kAudioChannelLayoutTag_Stereo,
            .mChannelBitmap = kAudioChannelBit_Left,
            .mNumberChannelDescriptions = 0
        };
        NSData *channelLayoutData = [NSData dataWithBytes:&channelLayout length:offsetof(AudioChannelLayout, mChannelDescriptions)];
        _audioSetting = @{AVFormatIDKey:@(kAudioFormatMPEG4AAC),
                                   AVSampleRateKey:@(44100),
                                   AVNumberOfChannelsKey:@(2),
                                   AVChannelLayoutKey:channelLayoutData};
    }
    return _audioSetting;
}

- (NSString *)videoProfileLevel {
    NSString *profileLevel = AVVideoProfileLevelH264HighAutoLevel;
    if ([self.presetName isEqualToString:MNCapturePresetLowQuality]) {
        profileLevel = AVVideoProfileLevelH264BaselineAutoLevel;
    } else if ([self.presetName isEqualToString:MNCapturePresetMediumQuality]) {
        profileLevel = AVVideoProfileLevelH264MainAutoLevel;
    }
    return profileLevel;
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

- (AVCaptureDevice *)captureDeviceWithPosition:(MNCapturePosition)capturePosition {
    AVCaptureDevicePosition position = capturePosition == MNCapturePositionFront ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    NSArray <AVCaptureDevice *>*devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position != position) continue;
        return device;
    }
    return nil;
}

#pragma mark - dealloc
- (void)dealloc {
    _delegate = nil;
    [self closeLighting];
    [self stopRunning];
    [self stopRecording];
    [_videoLayer removeFromSuperlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"===dealloc===%@", NSStringFromClass(self.class));
}

@end
