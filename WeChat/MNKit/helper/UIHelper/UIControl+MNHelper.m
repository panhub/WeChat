//
//  UIControl+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/10/9.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UIControl+MNHelper.h"
#import "NSObject+MNSwizzle.h"
#import <objc/message.h>

static NSString * MNControlIgnoreKey = @"mn.control.ignore.key";
static NSString * MNControlTimeIntervalKey = @"mn.control.time.interval.key";
@implementation UIControl (MNHelper)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MNSwizzleInstanceMethod(self, @selector(sendAction:to:forEvent:), @selector(mn_sendAction:to:forEvent:));
    });
}

#pragma mark - 避免重复点击问题
- (void)mn_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    /// Tabbar上的按钮, 直接处理, 不做操作
    if ([self isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
        [self mn_sendAction:action to:target forEvent:event];
        return;
    }
    if ([self ignore]) return;
    NSTimeInterval interval = self.timeInterval;
    if (interval > 0.f) {
        [self setIgnore:YES];
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(mn_endIgnore) object:nil];
        [self performSelector:@selector(mn_endIgnore) withObject:nil afterDelay:interval];
    }
    [self mn_sendAction:action to:target forEvent:event];
}

- (void)mn_endIgnore {
    [self setIgnore:NO];
}

- (NSTimeInterval)timeInterval {
    NSNumber *interval = objc_getAssociatedObject(self, &MNControlTimeIntervalKey);
    if (interval) {
        return [interval doubleValue];
    }
    return 0.f;
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    objc_setAssociatedObject(self, &MNControlTimeIntervalKey, @(timeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ignore {
    NSNumber *ignore = objc_getAssociatedObject(self, &MNControlIgnoreKey);
    if (ignore) return [ignore boolValue];
    return NO;
}

- (void)setIgnore:(BOOL)ignore {
    objc_setAssociatedObject(self, &MNControlIgnoreKey, @(ignore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
