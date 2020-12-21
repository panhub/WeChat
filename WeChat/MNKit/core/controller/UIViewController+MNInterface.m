//
//  UIViewController+MNConfiguration.m
//  MNKit
//
//  Created by Vincent on 2018/1/9.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UIViewController+MNInterface.h"
#import <objc/message.h>

static NSString * MNNavInteractiveEnabledKey = @"mn.nav.interactive.enabled.key";
static NSString * MNNavInteractiveRecognizerKey = @"mn.nav.interactive.recognizer.key";
static NSString * MNTabViewAssociatedKey = @"mn.tab.view.associated.key";

@implementation UIViewController (MNInterface)
- (NSString *)tabBarItemTitle {
    return nil;
}
- (UIImage *)tabBarItemImage {
    return nil;
}
- (UIImage *)tabBarItemSelectedImage {
    return nil;
}
- (BOOL)isRootViewController {
    return NO;
}
- (BOOL)isChildViewController {
    return NO;
}
#pragma mark - 寻找自身父控制器
- (UIViewController *)parentController {
    UIViewController *viewController = self.parentViewController;
    do {
        if (![viewController isChildViewController]) return viewController;
        viewController = viewController.parentViewController;
    } while (viewController);
    return nil;
}
#pragma mark - 角标处理
- (void)setBadgeValue:(NSString *)badgeValue {
    if ([self isKindOfClass:[UITabBarController class]]) return;
    UINavigationController *nav = [self isKindOfClass:[UINavigationController class]] ? (UINavigationController *)self : self.navigationController;
    if (!nav) return;
    UITabBarController *tab = nav.tabBarController;
    if ([tab.viewControllers containsObject:nav]) {
        [tab.tabView setBadgeValue:badgeValue ofIndex:[tab.viewControllers indexOfObject:nav]];
    }
}
- (NSString *)badgeValue {
    if ([self isKindOfClass:[UITabBarController class]]) return nil;
    UINavigationController *nav = [self isKindOfClass:[UINavigationController class]] ? (UINavigationController *)self : self.navigationController;
    if (!nav) return nil;
    UITabBarController *tab = nav.tabBarController;
    if ([tab.viewControllers containsObject:nav]) {
        return [tab.tabView badgeValueOfIndex:[tab.viewControllers indexOfObject:nav]];
    }
    return nil;
}

@end


@implementation UIViewController (MNInteractiveTransition)
- (BOOL)shouldInteractivePopTransition {
    return YES;
}
- (void)beganInteractivePopTransition {}
- (void)endInteractivePopTransition {}
- (void)cancelInteractivePopTransition {}
- (MNControllerTransitionStyle)transitionAnimationStyle {
    return MNControllerTransitionStyleStack;
}
@end


@implementation UINavigationController (MNInteractiveTransition)

- (UIScreenEdgePanGestureRecognizer *)interactiveGestureRecognizer {
    return objc_getAssociatedObject(self, &MNNavInteractiveRecognizerKey);
}

- (void)setInteractiveGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)interactiveGestureRecognizer {
    objc_setAssociatedObject(self, &MNNavInteractiveRecognizerKey, interactiveGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)interactiveTransitionEnabled {
    NSNumber *enabled = objc_getAssociatedObject(self, &MNNavInteractiveEnabledKey);
    if (enabled == nil) return YES;
    return [enabled boolValue];
}

- (void)setInteractiveTransitionEnabled:(BOOL)interactiveTransitionEnabled{
    objc_setAssociatedObject(self, &MNNavInteractiveEnabledKey, @(interactiveTransitionEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end



@implementation UITabBarController (MNInterface)

- (void)setTabView:(MNTabBar *)tabView {
    objc_setAssociatedObject(self, &MNTabViewAssociatedKey, tabView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MNTabBar *)tabView {
    return objc_getAssociatedObject(self, &MNTabViewAssociatedKey);
}

@end


@implementation UIView (MNInterface)

- (void)setBadgeValue:(NSString *)badgeValue ofIndex:(NSUInteger)index {}

- (NSString *)badgeValueOfIndex:(NSUInteger)index {
    return nil;
}

@end
