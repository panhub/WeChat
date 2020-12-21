//
//  UIScrollView+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2017/12/18.
//  Copyright © 2017年 小斯. All rights reserved.
//  UIScrollView

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (MNHelper)

/**
 快速实例化
 @param frame frame
 @param delegate 交互代理
 @return ScrollView实例
 */
+ (__kindof UIScrollView *)scrollViewWithFrame:(CGRect)frame
                                      delegate:(id<UIScrollViewDelegate> _Nullable)delegate;

/**
 调整滚动视图的行为,禁止布局受安全区域的影响
 */
- (void)adjustContentInset;

#pragma mark - Scrolls
- (BOOL)scrollsToBottom;

- (BOOL)scrollsToLeft;

- (BOOL)scrollsToRight;

- (void)scrollToTopWithAnimated:(BOOL)animated;

- (void)scrollToBottomWithAnimated:(BOOL)animated;

- (void)scrollToLeftWithAnimated:(BOOL)animated;

- (void)scrollToRightWithAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
