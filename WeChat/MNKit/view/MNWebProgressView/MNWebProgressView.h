//
//  MNWebProgressView.h
//  MNKit
//
//  Created by Vincent on 2018/11/29.
//  Copyright © 2018年 小斯. All rights reserved.
//  WebView进度条

#import <UIKit/UIKit.h>

@interface MNWebProgressView : UIView

/**
 进度
 */
@property (nonatomic) CGFloat progress;

/**
 消失延迟
 */
@property (nonatomic) NSTimeInterval fadeOutDelay;

/**
 消失/出现动画间隔
 */
@property (nonatomic) NSTimeInterval fadeAnimationDuration;

/**
 进度动画间隔
 */
@property (nonatomic) NSTimeInterval progressAnimationDuration;

/**
 设置进度
 @param progress 进度值
 @param animated 是否动画进行
 */
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;


+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;


@end

