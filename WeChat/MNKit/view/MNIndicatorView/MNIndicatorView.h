//
//  MNIndicatorView.h
//  MNKit
//
//  Created by Vincent on 2020/1/28.
//  Copyright © 2020 Vincent. All rights reserved.
//  加载指示图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNIndicatorView : UIView
/**轨迹进度*/
@property (nonatomic) float progress;
/**轨迹宽度*/
@property (nonatomic) CGFloat lineWidth;
/**轨迹颜色*/
@property (nonatomic, copy) UIColor *color;
/**动画时长*/
@property NSTimeInterval duration;
/**动画颜色*/
@property (nonatomic, copy) UIColor *lineColor;
/**暂停隐藏*/
@property (nonatomic, getter=isHidesWhenStopped) BOOL hidesWhenStopped;
/**隐藏显示是否动画*/
@property (nonatomic, getter=isHidesUseAnimation) BOOL hidesUseAnimation;
/**是否动画*/
@property (nonatomic, getter=isAnimating) BOOL animating;

/**
 开启动画
 */
- (void)startAnimating;

/**
 暂停动画
 */
- (void)stopAnimating;

/**
 暂停动画
 @param endHandler 结束回调
 */
- (void)stopAnimatingWithHandler:(void(^_Nullable)(void))endHandler;

@end

NS_ASSUME_NONNULL_END
