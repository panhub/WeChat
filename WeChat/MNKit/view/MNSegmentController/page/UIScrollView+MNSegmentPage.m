//
//  UIScrollView+MNPage.m
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UIScrollView+MNSegmentPage.h"
#import <objc/runtime.h>

static NSString *MNPageIndexKey = @"com.mn.page.index.key";
static NSString *MNPageOffsetKey = @"com.mn.page.offset.change.key";
static NSString *MNPageContentKey = @"com.mn.page.content.key";
static NSString *MNPageObservedKey = @"com.mn.page.observed.key";

@implementation UIScrollView (MNSegmentPage)

- (void)setPageIndex:(NSUInteger)pageIndex {
    objc_setAssociatedObject(self, &MNPageIndexKey, @(pageIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)pageIndex {
    NSNumber *pageIndex = objc_getAssociatedObject(self, &MNPageIndexKey);
    if (pageIndex) {
        return [pageIndex unsignedIntegerValue];
    }
    return NSIntegerMin;
}

- (void)setChangeOffsetEnabled:(BOOL)changeOffsetEnabled {
    objc_setAssociatedObject(self, &MNPageOffsetKey, @(changeOffsetEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)changeOffsetEnabled {
    NSNumber *enabled = objc_getAssociatedObject(self, &MNPageOffsetKey);
    if (enabled) return [enabled boolValue];
    return NO;
}

- (void)setContentSizeReached:(BOOL)contentSizeReached {
    objc_setAssociatedObject(self, &MNPageContentKey, @(contentSizeReached), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)contentSizeReached {
    NSNumber *reachContentSize = objc_getAssociatedObject(self, &MNPageContentKey);
    if (reachContentSize) {
        return [reachContentSize boolValue];
    }
    return NO;
}

- (void)setObserved:(BOOL)observed {
    objc_setAssociatedObject(self, &MNPageObservedKey, @(observed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)observed {
    NSNumber *observed = objc_getAssociatedObject(self, &MNPageObservedKey);
    if (observed) {
        return [observed boolValue];
    }
    return NO;
}

@end
