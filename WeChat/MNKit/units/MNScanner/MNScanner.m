//
//  MNScanner.m
//  MNKit
//
//  Created by Vincent on 2018/7/4.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNScanner.h"
#import "MNAuthenticator.h"
#import <AVFoundation/AVFoundation.h>

@interface MNScanner ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, weak) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end

@implementation MNScanner
+ (instancetype)scanner {
    return [MNScanner new];
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    [self initialized];
    #if TARGET_IPHONE_SIMULATOR
    return self;
    #endif
    [self startCapture];
    return self;
}

- (void)initialized {
    self.scanRect = CGRectZero;
    self.sessionPreset = AVCaptureSessionPresetHigh;
}

- (void)startCapture {
    [MNAuthenticator requestCameraAuthorizationStatusWithHandler:^(BOOL allowed) {
        if (!allowed) {
            [UIAlertView showMessage:@"请允许应用访问您的摄像头!"];
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //获取摄像设备
            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            _device = device;
            
            //创建摄像设备输入流
            AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            _deviceInput = deviceInput;
            
            //创建元数据输出流
            AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
            [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            _metadataOutput = metadataOutput;
            
            //创建摄像数据输出流
            AVCaptureVideoDataOutput *videoDataOutput = [AVCaptureVideoDataOutput new];
            [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
            _videoDataOutput = videoDataOutput;
            
            //创建会话对象
            AVCaptureSession *session = [[AVCaptureSession alloc] init];
            // 会话采集率: AVCaptureSessionPresetHigh
            session.sessionPreset = AVCaptureSessionPresetHigh;
            //添加摄像设备输入流到会话对象
            if ([session canAddInput:deviceInput]) {
                [session addInput:deviceInput];
            }
            //添加摄像输出流到会话对象,构成识了别光线强弱
            if ([session canAddOutput:videoDataOutput]) {
                [session addOutput:videoDataOutput];
            }
            if ([session canAddOutput:metadataOutput]) {
                [session addOutput:metadataOutput];
                //设置数据输出类型,需要将数据输出添加到会话后再指定元数据类型,否则会报错
                //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
                metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                                       AVMetadataObjectTypeEAN8Code,
                                                       AVMetadataObjectTypeEAN13Code,
                                                       AVMetadataObjectTypeCode128Code];
            }
            _session = session;
            
            //判断处理图像数据流边界
            self.scanRect = _scanRect;
            
            //预览图层,传递session是为了告诉图层将来显示什么内容
            AVCaptureVideoPreviewLayer *videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
            videoPreviewLayer.contentsScale = [[UIScreen mainScreen] scale];
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            _videoPreviewLayer = videoPreviewLayer;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_outputView) {
                    videoPreviewLayer.frame = _outputView.bounds;
                    [_outputView.layer insertSublayer:videoPreviewLayer atIndex:0];
                }
                [self startRunning];
            });
        });
    }];
}

- (CALayer *)previewLayer {
    return _videoPreviewLayer;
}

- (BOOL)isRunning {
    return (_session && _session.isRunning);
}

- (BOOL)isLighting {
    return (_device && _device.torchMode == AVCaptureTorchModeOn);
}

#pragma mark - 设置输出视图层
- (void)setOutputView:(UIView *)outputView {
    if (_videoPreviewLayer) {
        [_videoPreviewLayer removeFromSuperlayer];
        _videoPreviewLayer.frame = outputView.bounds;
        [outputView.layer insertSublayer:_videoPreviewLayer atIndex:0];
    }
    _outputView = outputView;
    [self setScanRect:_scanRect];
}

#pragma mark - 设置采集质量
- (void)setSessionPreset:(NSString *)sessionPreset {
    if ([sessionPreset isEqualToString:_sessionPreset]) return;
    if (!_session) return;
    _sessionPreset = sessionPreset;
    BOOL running = _session.isRunning;
    [self stopRunning];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_session beginConfiguration];
        _session.sessionPreset = sessionPreset;
        [_session commitConfiguration];
        if (running) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startRunning];
            });
        }
    });
}

#pragma mark - 设置扫描区域
- (void)setScanRect:(CGRect)scanRect {
    if (CGRectEqualToRect(scanRect, CGRectZero)) return;
    _scanRect = scanRect;
    if (_metadataOutput && _outputView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect rect = [self scanRectOfInterestWithRect:_scanRect];
            _metadataOutput.rectOfInterest = rect;
        });
    }
}

#pragma mark - 扫描区域转换坐标
- (CGRect)scanRectOfInterestWithRect:(CGRect)rect {
    if (_outputView) {
        CGFloat x = (_outputView.height_mn - CGRectGetHeight(rect))/2.f/_outputView.height_mn;
        CGFloat y = (_outputView.width_mn - CGRectGetWidth(rect))/2.f/_outputView.width_mn;
        CGFloat w = CGRectGetHeight(rect)/_outputView.height_mn;
        CGFloat h = CGRectGetWidth(rect)/_outputView.width_mn;
        return CGRectMake(x, y, w, h);
    }
    return CGRectMake(0.f, 0.f, 1.f, 1.f);
}

#pragma mark - 对焦
- (void)setFocusPoint:(CGPoint)focusPoint completion:(void(^)(BOOL succeed))completion {
    if (!_outputView || !_device || !_session) {
        if (completion) completion(NO);
        return;
    }
    if (![_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        if (completion) completion(NO);
        return;
    }
    CGSize size = _outputView.size_mn;
    if (size.width <= 0 || size.height <= 0) {
        if (completion) completion(NO);
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGPoint point = CGPointMake(focusPoint.y/size.height ,1.f - focusPoint.x/size.width );
        @synchronized (self) {
            [_session beginConfiguration];
            [_device lockForConfiguration:nil];
            [_device setFocusPointOfInterest:point];
            [_device setFocusMode:AVCaptureFocusModeAutoFocus];
            [_device unlockForConfiguration];
            [_session commitConfiguration];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(YES);
            });
        }
    });
}

#pragma mark - 开启/关闭手电筒
- (BOOL)openLighting {
    if (!_session || !_device) return NO;
    if (![_device hasTorch] || ![_device isTorchModeSupported:AVCaptureTorchModeOn]) return NO;
    if (_device.torchMode == AVCaptureTorchModeOn) return YES;
    @synchronized (self) {
        [_session beginConfiguration];
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOn];
        //[_device setFlashMode:AVCaptureFlashModeOn];
        [_device unlockForConfiguration];
        [_session commitConfiguration];
    }
    if ([_delegate respondsToSelector:@selector(scannerDidOpenLighting:)]) {
        [_delegate scannerDidOpenLighting:self];
    }
    return YES;
}

- (BOOL)closeLighting {
    if (!_device || !_session) return NO;
    if (![_device hasTorch] || ![_device isTorchModeSupported:AVCaptureTorchModeOff]) return NO;
    if (_device.torchMode == AVCaptureTorchModeOff) return YES;
    @synchronized (self) {
        [_session beginConfiguration];
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOff];
        //[_device setFlashMode:AVCaptureFlashModeOff];
        [_device unlockForConfiguration];
        [_session commitConfiguration];
    }
    if ([_delegate respondsToSelector:@selector(scannerDidCloseLighting:)]) {
        [_delegate scannerDidCloseLighting:self];
    }
    return YES;
}

#pragma mark - 开启/关闭扫描
- (void)startRunning {
    if (_session && !_session.isRunning) {
        [_session startRunning];
        if ([_delegate respondsToSelector:@selector(scannerDidStartRunning:)]) {
            [_delegate scannerDidStartRunning:self];
        }
    }
}

- (void)stopRunning {
    if (_session && _session.isRunning) {
        [_session stopRunning];
        if ([_delegate respondsToSelector:@selector(scannerDidStopRunning:)]) {
            [_delegate scannerDidStopRunning:self];
        }
    }
}

#pragma mark - - - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count <= 0) return;
    if ([_delegate respondsToSelector:@selector(scannerDidReadMetadataWithResult:)]) {
        AVMetadataMachineReadableCodeObject *obj = [metadataObjects firstObject];
        NSString *result = [obj stringValue];
        if (result.length > 0) [_delegate scannerDidReadMetadataWithResult:result];
    }
}

#pragma mark - - - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if ([_delegate respondsToSelector:@selector(scannerDidSampleCurrentBrightnessValue:)]) {
        CFDictionaryRef metadata = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
        NSDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadata];
        CFRelease(metadata);
        NSDictionary *exifMetadata = [[dic objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
        float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
        [_delegate scannerDidSampleCurrentBrightnessValue:brightnessValue];
    }
}

#pragma mark - 解析图片二维码信息
+ (void)readImageMetadata:(UIImage *)image completion:(void(^)(NSString *result))completion {
    if (!image) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:nil
                                              options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    NSArray <CIFeature *>*features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    NSString *result;
    if (features.count > 0) {
        CIQRCodeFeature *feature = (CIQRCodeFeature *)[features lastObject];
        result = feature.messageString;
    }
    if (completion) {
        completion(result);
    }
}

- (void)dealloc {
    self.delegate = nil;
    [self closeLighting];
    [self stopRunning];
    MNDeallocLog;
}

@end
