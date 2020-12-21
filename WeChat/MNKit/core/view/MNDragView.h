//
//  MNDragView.h
//  MNKit
//
//  Created by Vincent on 2017/12/16.
//  Copyright © 2017年 小斯. All rights reserved.
//  浮窗视图

#import <UIKit/UIKit.h>
@class MNDragView;

UIKIT_EXTERN const CGFloat MNDragViewMargin;

@protocol MNDragViewDelegate <NSObject>
@optional
- (void)dragViewWillBeginClicking:(MNDragView *)dragView;
- (void)dragViewDidClicking:(MNDragView *)dragView;
- (void)dragViewWillBeginDragging:(MNDragView *)dragView;
- (void)dragViewDidDragging:(MNDragView *)dragView;
- (void)dragViewDidEndDragging:(MNDragView *)dragView willDecelerate:(BOOL)decelerate;
- (void)dragViewWillBeginDecelerating:(MNDragView *)dragView;
- (void)dragViewDidEndDecelerating:(MNDragView *)dragView;
- (void)dragViewWillBeginSleeping:(MNDragView *)dragView;
- (void)dragViewDidEndSleeping:(MNDragView *)dragView;
- (BOOL)dragViewShouldBeginDragging:(MNDragView *)dragView;
- (BOOL)dragViewShouldBeginClicking:(MNDragView *)dragView;
@end

@interface MNDragView : UIImageView
/**
 移动范围
 */
@property (nonatomic) CGRect bounding;
/**
 闲置时不透明度
 */
@property (nonatomic) CGFloat sleepAlpha;
/**
 闲置时间
 */
@property (nonatomic) NSTimeInterval timeoutInterval;
/**
 是否可以点击
 */
@property (nonatomic, getter=isTouchEnabled) BOOL touchEnabled;

/**
 是否可以滑动
 */
@property (nonatomic, getter=isScrollEnabled) BOOL scrollEnabled;
/**
 事件代理
 */
@property (nonatomic, weak) id<MNDragViewDelegate> delegate;
/**
 内容视图
 */
@property (nonatomic, readonly, strong) UIImageView *contentView;

/**
 显示与隐藏
 @param alpha 透明度
 @param animated 是否动态
 */
- (void)setAlpha:(CGFloat)alpha animated:(BOOL)animated;

@end
