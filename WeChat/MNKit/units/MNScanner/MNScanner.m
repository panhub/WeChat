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
#import "AVCaptureDevice+MNFormat.h"

@interface MNScanner ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation MNScanner
- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessionQueue = dispatch_queue_create("com.mn.scanner.session.queue", DISPATCH_QUEUE_SERIAL);
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sessionDidStartRunningNotification:) name:AVCaptureSessionDidStartRunningNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(sessionDidStopRunningNotification:) name:AVCaptureSessionDidStopRunningNotification object:nil];
    }
    return self;
}

- (void)prepareRunning {
#if !TARGET_IPHONE_SIMULATOR
    __weak typeof(self) weakself = self;
    [MNAuthenticator requestCameraAuthorizationStatusWithHandler:^(BOOL allowed) {
        if (!allowed) {
            [weakself failureWithCode:AVErrorApplicationIsNotAuthorized description:@"获取摄像权限失败"];
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __strong typeof(self) self = weakself;
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
            } else if ([session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
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
            self.previewLayer = previewLayer;
            
            self.device = device;
            self.session = session;
            self.deviceInput = deviceInput;
            self.videoDataOutput = videoDataOutput;
            self.metadataOutput = metadataOutput;
            
            self.outputView = self.outputView;
            
            self.scanRect = self.scanRect;
            
            // 开启扫描
            __weak typeof(self) weak_self = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weak_self startRunning];
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
    return (_session && _session.isRunning);
}

- (void)startRunning {
    __weak typeof(self) weakself = self;
    dispatch_async(self.sessionQueue, ^{
        if (!weakself.session.isRunning) {
            [weakself.session startRunning];
        }
    });
}

- (void)stopRunning {
    __weak typeof(self) weakself = self;
    dispatch_async(self.sessionQueue, ^{
        if (weakself.session.isRunning) {
            [weakself.session stopRunning];
        }
    });
}

#pragma mark - Setter
- (void)setOutputView:(UIView *)outputView {
    if (!outputView) return;
    _outputView = outputView;
    if (_previewLayer) {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) self = weakself;
            [self.previewLayer removeFromSuperlayer];
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.previewLayer.frame = outputView.bounds;
            [CATransaction commit];
            [outputView.layer insertSublayer:self.previewLayer atIndex:0];
        });
    }
    self.scanRect = self.scanRect;
}

- (void)setScanRect:(CGRect)scanRect {
    if (CGRectEqualToRect(scanRect, CGRectZero)) return;
    _scanRect = scanRect;
    if (_outputView && _metadataOutput) {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) self = weakself;
            CGFloat x = (self.outputView.height_mn - CGRectGetHeight(scanRect))/2.f/self.outputView.height_mn;
            CGFloat y = (self.outputView.width_mn - CGRectGetWidth(scanRect))/2.f/self.outputView.width_mn;
            CGFloat w = CGRectGetHeight(scanRect)/self.outputView.height_mn;
            CGFloat h = CGRectGetWidth(scanRect)/self.outputView.width_mn;
            self.metadataOutput.rectOfInterest = CGRectMake(x, y, w, h);
        });
    }
}

#pragma mark - 手电筒
- (BOOL)isTorchScene {
    return (_device && _device.torchMode == AVCaptureTorchModeOn);
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
    if (shouldNotifyDelegate && [self.delegate respondsToSelector:@selector(scannerDidChangeTorchScene:)]) {
        [self.delegate scannerDidChangeTorchScene:self];
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
    if (shouldNotifyDelegate && [self.delegate respondsToSelector:@selector(scannerDidChangeTorchScene:)]) {
        [self.delegate scannerDidChangeTorchScene:self];
    }
    return result;
}

#pragma mark - 对焦
- (BOOL)setFocus:(CGPoint)point {
    if (!_previewLayer) return NO;
    __block BOOL result = NO;
    point = [self.previewLayer captureDevicePointOfInterestForPoint:point];
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
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (result.length && [weakself.delegate respondsToSelector:@selector(scannerDidReadMetadataWithResult:)]) {
            [weakself.delegate scannerDidReadMetadataWithResult:result];
        }
    });
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFDictionaryRef metadata = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadata];
    CFRelease(metadata);
    NSDictionary *exifMetadata = [[dic objectForKey:(NSString *)kCGImagePropertyExifDictionary] copy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakself.delegate respondsToSelector:@selector(scannerUpdateSampleBrightness:)]) {
            [weakself.delegate scannerUpdateSampleBrightness:brightnessValue];
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
// 开始运行
- (void)sessionDidStartRunningNotification:(NSNotification *)notify {
    if (![notify.object isKindOfClass:AVCaptureSession.class]) return;
    if (((AVCaptureSession *)notify.object) != _session) return;
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakself.delegate respondsToSelector:@selector(scannerDidStartRunning:)]) {
            [weakself.delegate scannerDidStartRunning:weakself];
        }
    });
}
// 结束运行
- (void)sessionDidStopRunningNotification:(NSNotification *)notify {
    if (![notify.object isKindOfClass:AVCaptureSession.class]) return;
    if (((AVCaptureSession *)notify.object) != _session) return;
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakself.delegate respondsToSelector:@selector(scannerDidStopRunning:)]) {
            [weakself.delegate scannerDidStopRunning:weakself];
        }
    });
}

#pragma mark - dealloc
- (void)dealloc {
    _delegate = nil;
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
#endif
