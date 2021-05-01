//
//  MNScrollView.m
//  MNKit
//
//  Created by Vincent on 2019/2/10.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNScrollView.h"

@implementation MNScrollView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.scrollsToTop = NO;
        self.scrollEnabled = YES;
        self.bounces = NO;
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
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

- (void)setScrollDirection:(MNScrollViewDirection)scrollDirection {
    if (scrollDirection == _scrollDirection) return;
    _scrollDirection = scrollDirection;
    NSUInteger currentPageIndex = self.currentPageIndex;
    [self updateContentWithNumberOfPages:self.numberOfPages];
    currentPageIndex = MIN(currentPageIndex, MAX(0, self.numberOfPages - 1));
    [self updateOffsetWithPageIndex:currentPageIndex animated:NO];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (numberOfPages == _numberOfPages) return;
    _numberOfPages = numberOfPages;
    NSUInteger currentPageIndex = self.currentPageIndex;
    [self updateContentWithNumberOfPages:numberOfPages];
    currentPageIndex = MIN(currentPageIndex, MAX(0, self.numberOfPages - 1));
    [self updateOffsetWithPageIndex:currentPageIndex animated:NO];
}

- (void)updateContentWithNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    numberOfPages = MAX(numberOfPages, 1);
    CGSize contentSize = self.frame.size;
    if (self.scrollDirection == MNScrollViewDirectionVertical) {
        contentSize.height = numberOfPages*contentSize.height;
    } else {
        contentSize.width = numberOfPages*contentSize.width;
    }
    if (CGSizeEqualToSize(self.contentSize, contentSize) == NO) {
        [self setContentSize:contentSize];
    }
}

- (void)updateOffsetWithPageIndex:(NSInteger)pageIndex animated:(BOOL)animated {
    if (pageIndex >= self.numberOfPages) return;
    CGPoint contentOffset = CGPointZero;
    if (self.scrollDirection == MNScrollViewDirectionVertical) {
        contentOffset.y = self.frame.size.height*pageIndex;
    } else {
        contentOffset.x = self.frame.size.width*pageIndex;
    }
    if (!CGPointEqualToPoint(self.contentOffset, contentOffset)) {
        [self setContentOffset:contentOffset animated:animated];
    }
}

- (CGPoint)contentOffsetOfPageIndex:(NSInteger)pageIndex {
    if (pageIndex >= self.numberOfPages) return CGPointZero;
    CGPoint contentOffset = CGPointZero;
    if (self.scrollDirection == MNScrollViewDirectionVertical) {
        contentOffset.y = self.frame.size.height*pageIndex;
    } else {
        contentOffset.x = self.frame.size.width*pageIndex;
    }
    return contentOffset;
}

- (NSInteger)currentPageIndex {
    if (self.scrollDirection == MNScrollViewDirectionVertical) {
        return MAX(round(self.contentOffset.y/self.frame.size.height), 0);
    }
    return MAX(round(self.contentOffset.x/self.frame.size.width), 0);
}

@end
