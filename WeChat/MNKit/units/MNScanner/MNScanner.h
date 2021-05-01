//
//  MNScanner.h
//  MNKit
//
//  Created by Vincent on 2018/7/4.
//  Copyright © 2018年 小斯. All rights reserved.
//  二维码扫描

#import <Foundation/Foundation.h>
#if __has_include(<AVFoundation/AVFoundation.h>)
@class MNScanner;

NS_ASSUME_NONNULL_BEGIN

@protocol MNScannerDelegate <NSObject>
@required
- (void)scannerDidReadMetadataWithResult:(NSString *)result;
@optional
- (void)scannerDidStartRunning:(MNScanner *)scanner;
- (void)scannerDidStopRunning:(MNScanner *)scanner;
- (void)scannerDidChangeTorchScene:(MNScanner *)scanner;
- (void)scannerUpdateSampleBrightness:(CGFloat)brightnessValue;
- (void)scanner:(MNScanner *)scanner didFailWithError:(NSError *)error;
@end

@interface MNScanner : NSObject
/**扫描范围*/
@property (nonatomic) CGRect scanRect;
/**图像输出*/
@property (nonatomic, weak) UIView *outputView;
/**是否在扫描*/
@property (nonatomic, readonly) BOOL isRunning;
/**是否开着手电筒*/
@property (nonatomic, readonly) BOOL isTorchScene;
/**回调代理*/
@property (nonatomic, weak, nullable) id<MNScannerDelegate> delegate;

/**开启扫描配置*/
- (void)prepareRunning;

#pragma mark - 扫描
- (void)startRunning;
- (void)stopRunning;

#pragma mark - 手电筒
- (BOOL)openTorch;
- (BOOL)closeTorch;

#pragma mark - 对焦
- (BOOL)setFocus:(CGPoint)focusPoint;

#pragma mark - 读取图片信息
+ (void)readImageMetadata:(UIImage *)image completion:(void(^_Nullable)(NSString *_Nullable))completion;

@end

NS_ASSUME_NONNULL_END
#endif
