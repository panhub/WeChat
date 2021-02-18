//
//  MNScanner.m
//  MNKit
//
//  Created by Vincent on 2018/7/4.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNScanner.h"
#if __has_include(<AVFoundation/AVFoundation.h>)
#import "MNAuthenticator.h"
#import <AVFoundation/AVFoundation.h>

@interface MNScanner ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
// 保证后台时关闭, 前台时开启
@property (nonatomic) BOOL shouldSessionRunning;
// 摄像设备
@property (nonatomic, strong) AVCaptureDevice *device;
// 捕捉会话
@property (nonatomic, strong) AVCaptureSession *session;
// 捕捉输出
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation MNScanner
- (instancetype)init {
    self = [super init];
    if (self) {
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
    return self;
}

- (void)prepareRunning {
#if !TARGET_IPHONE_SIMULATOR
    [MNAuthenticator requestCameraAuthorizationStatusWithHandler:^(BOOL allowed) {
        if (!allowed) {
            [self failureWithCode:AVErrorApplicationIsNotAuthorized description:@"获取摄像权限失败"];
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 扫描会话
            AVCaptureSession *session = [AVCaptureSession new];
            session.usesApplicationAudioSession = NO;
            session.sessionPreset = AVCaptureSessionPresetHigh;
            if ([session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
                session.sessionPreset = AVCaptureSessionPresetHigh;
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
            } else {
                [self failureWithDescription:@"获取会话失败"];
                return;
            }
        
            //获取摄像设备
            AVCaptureDevice *device;
            NSArray <AVCaptureDevice *>*devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            if (devices.count) device = devices.firstObject;
            
            if (!device) {
                [self failureWithDescription:@"获取摄像头失败"];
                return;
            }
            
            //创建摄像设备输入流
            CMTime frameDuration = CMTimeMake(1, NSProcessInfo.processInfo.processorCount == 1 ? 15 : 30);
            if ([device lockForConfiguration:NULL] ) {
                device.activeVideoMaxFrameDuration = frameDuration;
                device.activeVideoMinFrameDuration = frameDuration;
                [device unlockForConfiguration];
            }
            NSError *error;
            AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
            if (error) {
                [self failureWithDescription:@"扫描设备初始化失败"];
                return;
            }
            
            if (![session canAddInput:deviceInput]) {
                [self failureWithDescription:@"扫描设备初始化失败"];
                return;
            }
            
            [session addInput:deviceInput];
            
            //创建摄像数据输出流
            AVCaptureVideoDataOutput *videoDataOutput = [AVCaptureVideoDataOutput new];
            [videoDataOutput setSampleBufferDelegate:self queue:dispatch_queue_create("com.mn.scanner.data.output", DISPATCH_QUEUE_SERIAL)];
            if (![session canAddOutput:videoDataOutput]) {
                [self failureWithDescription:@"扫描设备初始化失败"];
                return;
            }
            
            [session addOutput:videoDataOutput];
            
            //创建元数据输出流
            AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
            [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_queue_create("com.mn.scanner.metadata.output", DISPATCH_QUEUE_SERIAL)];
            if (![session canAddOutput:metadataOutput]) {
                [self failureWithDescription:@"扫描设备初始化失败"];
                return;
            }
            
            //设置数据输出类型,需要将数据输出添加到会话后再指定元数据类型,否则会报错
            [session addOutput:metadataOutput];
            
            //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
            metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                                   AVMetadataObjectTypeEAN8Code,
                                                   AVMetadataObjectTypeEAN13Code,
                                                   AVMetadataObjectTypeCode128Code];
            
            //预览图层,传递session是为了告诉图层将来显示什么内容
            AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
            previewLayer.contentsScale = UIScreen.mainScreen.scale;
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            _previewLayer = previewLayer;
            
            _device = device;
            _session = session;
            _deviceInput = deviceInput;
            _videoDataOutput = videoDataOutput;
            _metadataOutput = metadataOutput;
            
            self.outputView = self.outputView;
            
            self.scanRect = self.scanRect;
            
            // 开启扫描
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startRunning];
            });
        });
    }];
#endif
}

#pragma mark - Fail
- (void)failureWithDescription:(NSString *)message {
    [self failureWithCode:AVErrorScreenCaptureFailed description:message];
}

- (void)failureWithCode:(NSUInteger)code description:(NSString *)description {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(scanner:didFailWithError:)]) {
            [self.delegate scanner:self didFailWithError:[NSError errorWithDomain:AVFoundationErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:description}]];
        }
    });
}

#pragma mark - 开启/关闭扫描
- (BOOL)isRunning {
    @synchronized (self) {
        return (_session && _session.isRunning);
    }
}

- (void)startRunning {
    
    BOOL shouldNotifyDelegate = NO;
    
    @synchronized (self) {
        if (_session && !_session.isRunning) {
            [_session startRunning];
            _shouldSessionRunning = YES;
            shouldNotifyDelegate = YES;
        }
    }
    
    if (shouldNotifyDelegate && [self.delegate respondsToSelector:@selector(scannerDidStartRunning:)]) {
        [self.delegate scannerDidStartRunning:self];
    }
}

- (void)stopRunning {
    
    BOOL shouldNotifyDelegate = NO;
    
    @synchronized (self) {
        if (_session && _session.isRunning) {
            [_session stopRunning];
            _shouldSessionRunning = NO;
            shouldNotifyDelegate = YES;
        }
    }
    
    if (shouldNotifyDelegate && [self.delegate respondsToSelector:@selector(scannerDidStopRunning:)]) {
        [self.delegate scannerDidStopRunning:self];
    }
}

#pragma mark - Setter
- (void)setOutputView:(UIView *)outputView {
    if (!outputView) return;
    _outputView = outputView;
    if (_previewLayer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_previewLayer removeFromSuperlayer];
            _previewLayer.frame = outputView.bounds;
            [outputView.layer insertSublayer:_previewLayer atIndex:0];
        });
    }
    self.scanRect = self.scanRect;
}

- (void)setScanRect:(CGRect)scanRect {
    if (CGRectEqualToRect(scanRect, CGRectZero)) return;
    _scanRect = scanRect;
    if (_outputView && _metadataOutput) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat x = (_outputView.height_mn - CGRectGetHeight(scanRect))/2.f/_outputView.height_mn;
            CGFloat y = (_outputView.width_mn - CGRectGetWidth(scanRect))/2.f/_outputView.width_mn;
            CGFloat w = CGRectGetHeight(scanRect)/_outputView.height_mn;
            CGFloat h = CGRectGetWidth(scanRect)/_outputView.width_mn;
            _metadataOutput.rectOfInterest = CGRectMake(x, y, w, h);
        });
    }
}

#pragma mark - 手电筒
- (BOOL)isOnTorch {
    @synchronized (self) {
        return (_device && _device.torchMode == AVCaptureTorchModeOn);
    }
}

- (BOOL)openTorch {
    __block BOOL result = NO;
    __block BOOL shouldNotifyDelegate = NO;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (device && device.hasTorch && [device isTorchModeSupported:AVCaptureTorchModeOn]) {
            result = YES;
            if (device.torchMode != AVCaptureTorchModeOn) {
                device.torchMode = AVCaptureTorchModeOn;
                shouldNotifyDelegate = YES;
            }
        }
    }];
    if (shouldNotifyDelegate && [self.delegate respondsToSelector:@selector(scannerDidOpenTorch:)]) {
        [self.delegate scannerDidOpenTorch:self];
    }
    return result;
}

- (BOOL)closeTorch {
    __block BOOL result = NO;
    __block BOOL shouldNotifyDelegate = NO;
    [self performDeviceChangeHandler:^(AVCaptureDevice * _Nullable device) {
        if (device && device.hasTorch && [device isTorchModeSupported:AVCaptureTorchModeOff]) {
            result = YES;
            if (device.torchMode != AVCaptureTorchModeOff) {
                device.torchMode = AVCaptureTorchModeOff;
                shouldNotifyDelegate = YES;
            }
        }
    }];
    if (shouldNotifyDelegate && [self.delegate respondsToSelector:@selector(scannerDidCloseTorch:)]) {
        [self.delegate scannerDidCloseTorch:self];
    }
    return result;
}

#pragma mark - 对焦
- (BOOL)setFocusPoint:(CGPoint)point {
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

#pragma mark - 设备
- (void)performDeviceChangeHandler:(void(^)(AVCaptureDevice *_Nullable))resultHandler {
    AVCaptureDevice *device = self.deviceInput.device;
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

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count <= 0) return;
    AVMetadataMachineReadableCodeObject *obj = [metadataObjects firstObject];
    NSString *result = [obj stringValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (result.length && [self.delegate respondsToSelector:@selector(scannerDidReadMetadataWithResult:)]) {
            [self.delegate scannerDidReadMetadataWithResult:result];
        }
    });
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFDictionaryRef metadata = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadata];
    CFRelease(metadata);
    NSDictionary *exifMetadata = [[dic objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(scannerUpdateCurrentSampleBrightness:)]) {
            [self.delegate scannerUpdateCurrentSampleBrightness:brightnessValue];
        }
    });
}

#pragma mark - 解析图片二维码信息
+ (void)readImageMetadata:(UIImage *)image completion:(void(^)(NSString *result))completion {
    if (!image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(nil);
        });
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                  context:nil
                                                  options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
        NSArray <CIFeature *>*features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        NSString *result;
        if (features.count > 0) {
            CIQRCodeFeature *feature = (CIQRCodeFeature *)[features lastObject];
            result = feature.messageString;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(result);
        });
    });
}

#pragma mark - Notification
// 前台
- (void)willEnterForegroundNotification:(NSNotification *)notify {
    if (self.shouldSessionRunning) [self startRunning];
}
// 后台
- (void)didEnterBackgroundNotification:(NSNotification *)notify {
    if (self.shouldSessionRunning) {
        [self.session stopRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(scannerDidStopRunning:)]) {
                [self.delegate scannerDidStopRunning:self];
            }
        });
    }
}
// 中断
- (void)sessionWasInterruptedNotification:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(scannerDidStopRunning:)]) {
            [self.delegate scannerDidStopRunning:self];
        }
    });
}
// 中断结束
- (void)sessionInterruptionEndedNotification:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(scannerDidStartRunning:)]) {
            [self.delegate scannerDidStartRunning:self];
        }
    });
}

#pragma mark - dealloc
- (void)dealloc {
    _delegate = nil;
    [self closeTorch];
    [self stopRunning];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
#endif
