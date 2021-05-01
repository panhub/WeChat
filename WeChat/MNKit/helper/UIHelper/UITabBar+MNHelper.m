//
//  UITabBar+MNHelper.m
//  MNKit
//
//  Created by Vicent on 2020/8/27.
//

#import "UITabBar+MNHelper.h"
#import "UIApplication+MNHelper.h"

@implementation UITabBar (MNHelper)

+ (CGFloat)height {
    static CGFloat tab_bar_height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tab_bar_height = [UITabBar TabBarHeight] + [UITabBar safeHeight];
    });
    return tab_bar_height;
}

+ (CGFloat)safeHeight {
    static CGFloat tab_bar_safe_height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tab_bar_safe_height = UIApplication.statusBarHeight > 20.f ? 34.f : 0.f;
    });
    return tab_bar_safe_height;
}

+ (CGFloat)TabBarHeight {
    if (NSThread.isMainThread) return CGRectGetHeight(UITabBarController.new.tabBar.frame);
    __block CGFloat height = 0.f;
    dispatch_sync(dispatch_get_main_queue(), ^{
        height = CGRectGetHeight(UITabBarController.new.tabBar.frame);
    });
    return height;
}

@end
