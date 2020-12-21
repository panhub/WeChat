//
//  UIApplication+MNNetworkActivity.m
//  MNKit
//
//  Created by Vicent on 2020/8/5.
//

#import "UIApplication+MNNetworkActivity.h"
#import <objc/runtime.h>

static NSString * const MNApplicationActivityAssociatedKey = @"com.mn.application.activity.associated.key";

@implementation UIApplication (MNNetworkActivity)
+ (void)load {
    SEL systemSelector = NSSelectorFromString(@"setNetworkActivityIndicatorVisible:");
    SEL swizzledSelector = NSSelectorFromString(@"mn_setNetworkActivityIndicatorVisible:");
    Method systemMethod = class_getInstanceMethod(self, systemSelector);
    if (!systemMethod) return;
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    if (!swizzledMethod) return;
    BOOL didAddMethod = class_addMethod(self, systemSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(self, swizzledSelector,
                            method_getImplementation(systemMethod),
                            method_getTypeEncoding(systemMethod));
    } else {
        method_exchangeImplementations(systemMethod, swizzledMethod);
    }
}

- (void)mn_setNetworkActivityIndicatorVisible:(BOOL)isVisible {
    NSInteger activityCount = [self activityCount];
    if (isVisible) {
        activityCount ++;
    } else {
        activityCount --;
    }
    [self setActivityCount:activityCount];
}

- (NSInteger)activityCount {
    NSNumber *number = objc_getAssociatedObject(self, &MNApplicationActivityAssociatedKey);
    return number ? [number unsignedIntegerValue] : 0;
}

- (void)setActivityCount:(NSInteger)activityCount {
    objc_setAssociatedObject(self, &MNApplicationActivityAssociatedKey, @(activityCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self mn_setNetworkActivityIndicatorVisible:(activityCount > 0)];
    });
}

+ (void)startNetworkActivityIndicating {
    self.sharedApplication.networkActivityIndicatorVisible = YES;
}

+ (void)closeNetworkActivityIndicating {
    self.sharedApplication.networkActivityIndicatorVisible = NO;
}

@end
