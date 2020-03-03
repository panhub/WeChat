//
//  MNScanner.h
//  MNKit
//
//  Created by Vincent on 2018/7/4.
//  Copyright © 2018年 小斯. All rights reserved.
//  扫描器

#import <Foundation/Foundation.h>
@class MNScanner;

@protocol MNScannerDelegate <NSObject>
@required
- (void)scannerDidReadMetadataWithResult:(NSString *)result;
@optional
- (void)scannerDidStartRunning:(MNScanner *)scanner;
- (void)scannerDidStopRunning:(MNScanner *)scanner;
- (void)scannerDidOpenLighting:(MNScanner *)scanner;
- (void)scannerDidCloseLighting:(MNScanner *)scanner;
- (void)scannerDidSampleCurrentBrightnessValue:(CGFloat)brightnessValue;
@end

@interface MNScanner : NSObject
/**扫描范围*/
@property (nonatomic) CGRect scanRect;
/**图像输出*/
@property (nonatomic, weak) UIView *outputView;
/**预览层*/
@property (nonatomic, weak, readonly) CALayer *previewLayer;
/**是否在扫描*/
@property (nonatomic, readonly, getter=isRunning) BOOL running;
/**是否开着手电筒*/
@property (nonatomic, readonly, getter=isLighting) BOOL lighting;
/**回调代理*/
@property (nonatomic, weak) id<MNScannerDelegate> delegate;
/**扫码格式*/
@property (nonatomic, copy, readonly) NSString *sessionPreset;

#pragma mark - 快速实例化
+ (instancetype)scanner;

#pragma mark - 手电筒控制
- (BOOL)openLighting;
- (BOOL)closeLighting;

#pragma mark - 开启/关闭扫描
- (void)startRunning;
- (void)stopRunning;

#pragma mark - 对焦
- (void)setFocusPoint:(CGPoint)focusPoint completion:(void(^)(BOOL succeed))completion;

#pragma mark - 读取图片信息
+ (void)readImageMetadata:(UIImage *)image completion:(void(^)(NSString *result))completion;

@end
