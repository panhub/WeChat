//
//  MNSegmentPageView.m
//  MNKit
//
//  Created by Vincent on 2018/4/14.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNSegmentPageView.h"

@interface MNSegmentPageView ()

@end
@implementation MNSegmentPageView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.scrollsToTop = NO;
        self.scrollEnabled = YES;
        self.bounces = NO;
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
- (void)updateContentSizeWithNumberOfPages:(NSInteger)numberOfPages {
    numberOfPages = MAX(numberOfPages, 1);
    CGSize contentSize = self.frame.size;
    contentSize.width = numberOfPages*contentSize.width;
    if (CGSizeEqualToSize(self.contentSize, contentSize) == NO) {
        [self setContentSize:contentSize];
    }
}

#pragma mark - Visible Page Frame
- (CGFloat)offsetXOfIndex:(NSUInteger)pageIndex {
    pageIndex = MAX(0, pageIndex);
    return pageIndex*self.frame.size.width;
}

#pragma mark - Update Offset
- (void)updateOffsetWithIndex:(NSUInteger)pageIndex {
    CGFloat width = self.frame.size.width;
    CGFloat offsetX = pageIndex*width;
    offsetX = MIN(offsetX, (self.contentSize.width - width));
    if (self.contentOffset.x != offsetX) {
        [self setContentOffset:CGPointMake(offsetX, 0.f)];
    }
}

- (NSUInteger)currentPageIndex {
    CGFloat width = self.frame.size.width;
    CGFloat offsetX = self.contentOffset.x;
    NSInteger index = offsetX/width;
    index = MAX(0, index);
    return index;
}

@end

