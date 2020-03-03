/* @project  __PROJECTNAME__
 *  @header  __FILENAME__
 *  @date  __DATE__
 *  @copyright  __COPYRIGHT__
 *  @author  小斯
 *  @brief  视频录制
 */

#import "MNCapturer.h"
#import "MNAuthenticator.h"
#import "MNFileManager.h"
#import "UIAlertView+MNHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface MNCapturer ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) MNCaptureCameraPosition capturePosition;
@property (nonatomic, getter=isRecording) BOOL recording;
@property (nonatomic, getter=isLocking) BOOL locking;
@property (nonatomic, getter=isWriteEnabled) BOOL writeEnabled;
@property (nonatomic, strong) NSDictionary *audioSettings;
@property (nonatomic, strong) NSDictionary *videoSettings;
@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetWriterInput *videoInputWriter;
@property (nonatomic, strong) AVAssetWriterInput *audioInputWriter;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;
@end

@implementation MNCapturer
+ (MNCapturer *)recorder {
    return [MNCapturer new];
}
- (instancetype)init {
    if (self = [super init]) {
        [self initialized];
        [self startCapture];
    }
    return self;
}

- (instancetype)initWithContentsOfFile:(NSString *)filePath {
    if (self = [self init]) {
        self.filePath = filePath;
    }
    return self;
}

- (void)initialized {
    _locking = NO;
    _recording = NO;
    _writeEnabled = NO;
    _resizeMode = MNCaptureResizeModeResizeAspect;
    _capturePosition = MNCaptureCameraPositionBack;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)startCapture {
    [MNAuthenticator requestCameraAuthorizationStatusWithHandler:^(BOOL allowed) {
        if (!allowed) {
            [self capturerDidFailure:@"请开启摄像头权限后重试!"];
            return;
        }
        [MNAuthenticator requestMicrophoneAuthorizationStatusWithHandler:^(BOOL allow) {
            if (!allow) {
                [self capturerDidFailure:@"请开启麦克风权限后重试!"];
                return;
            }
            if (![self setCategory]) {
                [self capturerDidFailure:@"录像设备初始化失败!"];
                return;
            }
            dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
                [self setupVideo];
                [self setupAudio];
                [self setupImageCaptureOutput];
                [self setOutputView:_outputView];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_session startRunning];
                });
            });
        }];
    }];
}

- (BOOL)setCategory {
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
    if (!error) {
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
    }
    return error == nil;
}

#pragma mark - 设置视频/音频
- (void)setupVideo {
    NSError *error = nil;
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self captureDeviceWithPosition:_capturePosition] error:&error];
    if (error) {
        [self capturerDidFailure:@"录像设备初始化失败!"];
        return;
    }
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    } else {
        [self capturerDidFailure:@"录像设备初始化失败!"];
        return;
    }
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
    [self.videoOutput setSampleBufferDelegate:self queue:self.queue];
    if ([self.session canAddOutput:self.videoOutput]) {
        [self.session addOutput:self.videoOutput];
    } else {
        [self capturerDidFailure:@"录像设备初始化失败!"];
    }
}

- (void)setupAudio {
    NSError *error = nil;
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:&error];
    if (error) {
        [self capturerDidFailure:@"录像设备初始化失败!"];
        return;
    }
    if ([self.session canAddInput:self.audioInput]) {
        [self.session addInput:self.audioInput];
    } else {
        [self capturerDidFailure:@"录像设备初始化失败!"];
        return;
    }
    self.audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioOutput setSampleBufferDelegate:self queue:self.queue];
    if ([self.session canAddOutput:self.audioOutput]) {
        [self.session addOutput:self.audioOutput];
    } else {
        [self capturerDidFailure:@"录像设备初始化失败!"];
    }
}

- (void)setupImageCaptureOutput {
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    [imageOutput setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG}];
    if ([self.session canAddOutput:imageOutput]) {
        [self.session addOutput:imageOutput];
        self.imageOutput = imageOutput;
    }
}

#pragma mark - 开始/停止捕获
- (void)startRunning {
    if (!_session.isRunning) {
        [_session startRunning];
    }
}

- (void)stopRunning {
    if (_session.isRunning) {
        [_session stopRunning];
    }
}

#pragma mark - 开始/停止录像
- (void)startCapturing {
    if (_recording || _filePath.length <= 0 || !_session.isRunning) return;
    __weak typeof(self)weakself = self;
    [self startWritingWithCompletionHandler:^{
        weakself.recording = YES;
        if ([weakself.delegate respondsToSelector:@selector(capturer:didStartCapturingWithContentsOfFile:)]) {
            [weakself.delegate capturer:weakself didStartCapturingWithContentsOfFile:weakself.filePath];
        }
    }];
}

- (void)stopCapturing {
    if (!_recording) return;
    _recording = NO;
    __weak typeof(self)weakself = self;
    [self finishWritingWithCompletionHandler:^{
        if ([weakself.delegate respondsToSelector:@selector(capturer:didFinishCapturingWithContentsOfFile:)]) {
            [self.delegate capturer:weakself didFinishCapturingWithContentsOfFile:weakself.filePath];
        }
    }];
}

- (BOOL)deleteCapturing {
    if (self.isRecording) return NO;
    _filePath = @"";
    _writeEnabled = NO;
    return [MNFileManager removeItemAtPath:_filePath error:nil];
}

- (void)startWritingWithCompletionHandler:(void (^)(void))handler {
    NSError *error;
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:_filePath] fileType:AVFileTypeMPEG4 error:&error];
    if (error) return;
    AVAssetWriterInput *videoInputWriter = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:self.videoSettings];
    /// 必须设为YES, 需要从 session 实时获取数据
    videoInputWriter.expectsMediaDataInRealTime = YES;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationLandscapeRight) {
        videoInputWriter.transform = CGAffineTransformMakeRotation(M_PI);
    } else if (orientation == UIDeviceOrientationLandscapeLeft) {
        videoInputWriter.transform = CGAffineTransformMakeRotation(0);
    } else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        videoInputWriter.transform = CGAffineTransformMakeRotation(M_PI+M_PI_2);
    } else {
        videoInputWriter.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    if ([writer canAddInput:videoInputWriter]) {
        [writer addInput:videoInputWriter];
    } else return;
    /// 音频
    AVAssetWriterInput *audioInputWriter = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:self.audioSettings];
    audioInputWriter.expectsMediaDataInRealTime = YES;
    if ([writer canAddInput:audioInputWriter]) {
        [writer addInput:audioInputWriter];
    } else {
        return;
    }
    self.writer = writer;
    self.videoInputWriter = videoInputWriter;
    self.audioInputWriter = audioInputWriter;
    self.writeEnabled = NO;
    if (handler) handler();
}

- (void)finishWritingWithCompletionHandler:(void (^)(void))handler {
    if (_writer && _writer.status == AVAssetWriterStatusWriting) {
        __weak typeof(self)weakself = self;
        [_writer finishWritingWithCompletionHandler:^{
            weakself.writer = nil;
            weakself.videoInputWriter = nil;
            weakself.audioInputWriter = nil;
            weakself.writeEnabled = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) handler();
            });
        }];
    } else {
        _writer = nil;
        _videoInputWriter = nil;
        _audioInputWriter = nil;
        _writeEnabled = NO;
        [_writer finishWritingWithCompletionHandler:^{}];
        if (handler) handler();
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    /// 调整摄像头, 停止录制时不写入
    if (!_writer || !self.isRecording || self.isLocking) return;
    @autoreleasepool {
        if (connection == [self.videoOutput connectionWithMediaType:AVMediaTypeVideo]) {
            /// 视频
            @synchronized (self) {
                [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
            }
        } else if (connection == [self.audioOutput connectionWithMediaType:AVMediaTypeAudio]) {
            /// 音频
            @synchronized (self) {
                [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
            }
        }
    }
}

- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(AVMediaType)mediaType {
    if (sampleBuffer == NULL) return;
    @autoreleasepool {
        /// 写入数据
        if (!self.isWriteEnabled && mediaType == AVMediaTypeVideo) {
            [self.writer startWriting];
            [self.writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
            self.writeEnabled = YES;
        }
        
        if (mediaType == AVMediaTypeVideo && self.videoInputWriter.readyForMoreMediaData) {
            /// 写入视频数据
            if (![self.videoInputWriter appendSampleBuffer:sampleBuffer]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopCapturing];
                });
            }
        } else if (mediaType == AVMediaTypeAudio && self.audioInputWriter.readyForMoreMediaData) {
            /// 写入音频数据
            if (![self.audioInputWriter appendSampleBuffer:sampleBuffer]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopCapturing];
                });
            }
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
    return [self setDeviceCapturePosition:(1 - self.capturePosition)];
}

- (BOOL)setDeviceCapturePosition:(MNCaptureCameraPosition)capturePosition {
    if (capturePosition == _capturePosition) return YES;
    /**切换到前置摄像头时, 关闭手电筒*/
    if (capturePosition == MNCaptureCameraPositionFront) {
        [self closeLighting];
    }
    if ([self convertDeviceCapturePosition:capturePosition]) {
        _capturePosition = capturePosition;
        return YES;
    }
    return NO;
}

- (BOOL)convertDeviceCapturePosition:(MNCaptureCameraPosition)position {
    if (!_session) return NO;
    NSError *error;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:[self captureDeviceWithPosition:position] error:&error];
    if (error) return NO;
    _locking = YES;
    [self.session stopRunning];
    [self.session beginConfiguration];
    [self.session removeInput:_videoInput];
    if ([self.session canAddInput:videoInput]) {
        [self.session addInput:videoInput];
        self.videoInput = videoInput;
    }
    [self.session commitConfiguration];
    [self.session startRunning];
    _locking = NO;
    return YES;
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
    if (!_videoInput || !_layer || !_session.isRunning) return NO;
    CGPoint focus = [_layer captureDevicePointOfInterestForPoint:point];
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

#pragma mark - 获取摄像头
- (AVCaptureDevice *)captureDeviceWithPosition:(MNCaptureCameraPosition)capturePosition {
    AVCaptureDevicePosition position = capturePosition == MNCaptureCameraPositionFront ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    NSArray <AVCaptureDevice *>*devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

#pragma mark - 改变设备设置状态
- (void)changeDeviceConfigurationHandler:(void(^)(AVCaptureDevice *device))configurationHandler {
    if (!_session) return;
    AVCaptureDevice *device = [_videoInput device];
    if (!device) return;
    NSError *error;
    [_session beginConfiguration];
    if ([device lockForConfiguration:&error]) {
        configurationHandler(device);
        [device unlockForConfiguration];
    } else {
        NSLog(@"'change device configuration' error: %@",error.localizedDescription);
    }
    [_session commitConfiguration];
}

#pragma mark - 发生错误
- (void)capturerDidFailure:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(capturer:didCapturingFailure:)]) {
            [self.delegate capturer:self didCapturingFailure:message];
        }
    });
}

#pragma mark - Notification
- (void)didEnterBackgroundNotification {
    [self stopRunning];
    [self stopCapturing];
    [self closeLighting];
}

- (void)willEnterForegroundNotification {
    [self startRunning];
}

#pragma mark - Setter
- (void)setOutputView:(UIView *)outputView {
    if (!outputView || outputView == _outputView) return;
    _outputView = outputView;
    AVLayerVideoGravity videoGravity = [self previewLayerGravity];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.layer.frame = outputView.bounds;
        self.layer.videoGravity = videoGravity;
        [_layer removeFromSuperlayer];
        [outputView.layer insertSublayer:self.layer atIndex:0];
    });
}

- (AVLayerVideoGravity)previewLayerGravity {
    if (_resizeMode == MNCaptureResizeModeResize) {
        return AVLayerVideoGravityResize;
    } else if (_resizeMode == MNCaptureResizeModeResizeAspect) {
        return AVLayerVideoGravityResizeAspect;
    }
    return AVLayerVideoGravityResizeAspectFill;
}

- (void)setResizeMode:(MNCaptureResizeMode)resizeMode {
    if (_recording || resizeMode == _resizeMode) return;
    _resizeMode = resizeMode;
    _layer.videoGravity = [self previewLayerGravity];
}

- (void)setFilePath:(NSString *)filePath {
    if (self.isRecording) return;
    _filePath = @"";
    [MNFileManager removeItemAtPath:filePath error:nil];
    /// 只创建文件夹路径, 文件由数据写入时自行创建<踩坑总结>
    if ([MNFileManager createDirectoryAtPath:filePath error:nil]) {
        /// 等待数据
        _writeEnabled = NO;
        _filePath = filePath.copy;
    }
}

#pragma mark - Getter
- (AVCaptureSession *)session {
    if (!_session) {
        AVCaptureSession *session = [AVCaptureSession new];
        if ([session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            session.sessionPreset = AVCaptureSessionPresetHigh;
        } else if ([session canSetSessionPreset:AVCaptureSessionPresetMedium]) {
            session.sessionPreset = AVCaptureSessionPresetMedium;
        } else {
            session.sessionPreset = AVCaptureSessionPresetLow;
        }
        _session = session;
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)layer {
    if (!_layer) {
        AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _layer = layer;
    }
    return _layer;
}

- (BOOL)isRunning {
    return (_session && _session.isRunning);
}

- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_queue_create("com.mn.video.record.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _queue;
}

- (Float64)duration {
    if (self.isRecording || self.filePath.length <= 0) return 0.f;
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.filePath] options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
    return CMTimeGetSeconds(asset.duration);
}

- (NSDictionary *)videoSettings {
    if (!_videoSettings) {
        /// 实际方向与真实方向不同
        CGFloat scale = [[UIScreen mainScreen] scale];
        CGFloat height = CGRectGetWidth(_outputView.frame);
        CGFloat width = CGRectGetHeight(_outputView.frame);
        /// 像素
        NSInteger pixels = width*height;
        /// 每像素比特
        CGFloat bitsPerPixel = 12.f;
        NSInteger bitsPerSecond = pixels*bitsPerPixel;
        /// 码率和帧率设置
        NSDictionary *compressionSetting = @{AVVideoAverageBitRateKey:@(bitsPerSecond), AVVideoExpectedSourceFrameRateKey:@(15), AVVideoMaxKeyFrameIntervalKey:@(15), AVVideoProfileLevelKey:AVVideoProfileLevelH264BaselineAutoLevel};
        _videoSettings = @{AVVideoWidthKey:@(width*scale), AVVideoHeightKey:@(height*scale), AVVideoCodecKey:AVVideoCodecH264, AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill, AVVideoCompressionPropertiesKey:compressionSetting};
    }
    return _videoSettings;
}

- (NSDictionary *)audioSettings {
    if (!_audioSettings) {
        _audioSettings = @{AVEncoderBitRatePerChannelKey:@(28000),
                           AVFormatIDKey:@(kAudioFormatMPEG4AAC),
                           AVNumberOfChannelsKey:@(1),
                           AVSampleRateKey:@(22050)};
    }
    return _audioSettings;
}

#pragma mark - dealloc
- (void)dealloc {
    _delegate = nil;
    [self closeLighting];
    [self stopRunning];
    [self stopCapturing];
    [_layer removeFromSuperlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    MNDeallocLog;
}

@end
