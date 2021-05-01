//
//  MNScanView.h
//  MNKit
//
//  Created by Vincent on 2018/7/4.
//  Copyright © 2018年 小斯. All rights reserved.
//  扫描视图

#import <UIKit/UIKit.h>
@class MNScanView;

@protocol MNScanViewDelegate <NSObject>
@optional
- (void)scanView:(MNScanView *)scanView didClickAtPoint:(CGPoint)point;
@end

@interface MNScanView : UIView
/**扫描区域*/
@property (nonatomic) CGRect scanRect;
/**边角宽高*/
@property (nonatomic) CGSize cornerSize;
/**扫描边框宽度*/
@property (nonatomic) CGFloat borderWidth;
/**边角颜色*/
@property (nonatomic, strong) UIColor *cornerColor;
/**边框颜色*/
@property (nonatomic, strong) UIColor *borderColor;
/**扫描条图片*/
@property (nonatomic, strong) UIImage *scanLineImage;
/**标记是否在扫描*/
@property (nonatomic, readonly, getter=isScanning) BOOL scanning;
/**回调代理*/
@property (nonatomic, weak) id<MNScanViewDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**开始扫描动画*/
- (void)startScanning;

/**停止扫描动画*/
- (void)stopScanning;

@end
