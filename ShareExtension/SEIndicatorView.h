//
//  SEIndicatorView.h
//  ShareExtension
//
//  Created by Vincent on 2020/1/23.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SEIndicatorView : UIView

/**是否加载中*/
@property(nonatomic, readonly, getter=isAnimating) BOOL animating;

/**显示加载窗*/
- (void)startAnimating;

/**隐藏加载窗*/
- (void)stopAnimating;

/**
 显示加载弹窗
 @param delay 延迟时间
 @param eventHandler 事件回调
 @param completionHandler 结束回调
 */
- (void)startAnimatingDelay:(NSTimeInterval)delay eventHandler:(void(^)(void))eventHandler completionHandler:(void(^)(void))completionHandler;

@end

NS_ASSUME_NONNULL_END
