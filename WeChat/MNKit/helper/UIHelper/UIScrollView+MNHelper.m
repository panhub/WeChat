//
//  UIScrollView+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2017/12/18.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "UIScrollView+MNHelper.h"

@implementation UIScrollView (MNHelper)
#pragma mark - 快速实例化
+ (UIScrollView *)scrollViewWithFrame:(CGRect)frame delegate:(id<UIScrollViewDelegate>)delegate {
    UIScrollView *scrollView = [[self alloc] initWithFrame:frame];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.bounces = YES;
    scrollView.scrollEnabled = YES;
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [scrollView adjustContentInset];
    if (delegate) scrollView.delegate = delegate;
    return scrollView;
}

#pragma mark - 调整滚动视图的行为
- (void)adjustContentInset {
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 11.0, *)) {
        if ([self respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
            /**这种情况下adjustContentInset值不受SafeAreaInset(安全区域)值的影响 adjustedContentInset = contentInset*/
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    #endif
}

#pragma mark - Scrolls
- (BOOL)scrollsToBottom {
    if (!self.isScrollEnabled) return NO;
    [self scrollToBottomWithAnimated:YES];
    return YES;
}

- (BOOL)scrollsToLeft {
    if (!self.isScrollEnabled) return NO;
    [self scrollToLeftWithAnimated:YES];
    return YES;
}

- (BOOL)scrollsToRight {
    if (!self.isScrollEnabled) return NO;
    [self scrollToRightWithAnimated:YES];
    return YES;
}

- (void)scrollToTopWithAnimated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.y = 0.f - self.contentInset.top;
    [self setContentOffset:offset animated:animated];
}

- (void)scrollToBottomWithAnimated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.y = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
    [self setContentOffset:offset animated:animated];
}

- (void)scrollToLeftWithAnimated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.x = 0.f - self.contentInset.left;
    [self setContentOffset:offset animated:animated];
}

- (void)scrollToRightWithAnimated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.x = self.contentSize.width - self.bounds.size.width + self.contentInset.right;
    [self setContentOffset:offset animated:animated];
}

@end
