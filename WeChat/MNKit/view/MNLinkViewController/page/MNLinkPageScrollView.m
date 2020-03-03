//
//  MNLinkPageScrollView.m
//  MNKit
//
//  Created by Vincent on 2018/12/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNLinkPageScrollView.h"

@implementation MNLinkPageScrollView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.bounces = NO;
        self.scrollsToTop = NO;
        self.scrollEnabled = YES;
        self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        if (@available(iOS 11.0, *)) {
            if ([self respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
                self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
        #endif
    }
    return self;
}

#pragma mark - Update Content
- (void)updateContentSizeWithNumberOfPages:(NSUInteger)numberOfPages {
    numberOfPages = MAX(numberOfPages, 1);
    CGSize contentSize = self.frame.size;
    contentSize.height = numberOfPages*contentSize.height;
    if (CGSizeEqualToSize(self.contentSize, contentSize) == NO) {
        [self setContentSize:contentSize];
    }
}

#pragma mark - Visible Page Frame
- (CGFloat)offsetYOfIndex:(NSUInteger)pageIndex {
    pageIndex = MAX(0, pageIndex);
    return pageIndex*self.frame.size.height;
}

#pragma mark - Update Offset
- (void)updateOffsetWithIndex:(NSUInteger)pageIndex {
    CGFloat height = self.frame.size.height;
    CGFloat offsetY = pageIndex*height;
    offsetY = MIN(offsetY, (self.contentSize.height - height));
    if (self.contentOffset.y != offsetY) {
        [self setContentOffset:CGPointMake(0.f, offsetY)];
    }
}

#pragma mark - Current Index
- (NSUInteger)currentPageIndex {
    CGFloat height = self.frame.size.height;
    CGFloat offsetY = self.contentOffset.y;
    NSInteger index = offsetY/height;
    return MAX(0, index);
}


@end
