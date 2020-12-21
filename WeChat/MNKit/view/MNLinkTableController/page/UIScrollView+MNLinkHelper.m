//
//  UIScrollView+MNLinkHelper.m
//  MNKit
//
//  Created by Vincent on 2019/6/25.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "UIScrollView+MNLinkHelper.h"

@implementation UIScrollView (MNLinkHelper)

- (void)link_scrollToTopAnimated:(BOOL)animated {
    CGSize contentSize = self.contentSize;
    if (contentSize.height <= self.bounds.size.height) return;
    CGPoint contentOffset = self.contentOffset;
    contentOffset.y = 0.f - self.contentInset.top;
    [self setContentOffset:contentOffset animated:animated];
}

- (void)link_scrollToBottomAnimated:(BOOL)animated {
    CGSize contentSize = self.contentSize;
    if (contentSize.height <= self.bounds.size.height) return;
    CGPoint contentOffset = self.contentOffset;
    contentOffset.y = contentSize.height - self.bounds.size.height + self.contentInset.bottom;
    [self setContentOffset:contentOffset animated:animated];
}

@end
