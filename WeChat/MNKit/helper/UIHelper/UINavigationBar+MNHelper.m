//
//  UINavigationBar+MNHelper.m
//  MNKit
//
//  Created by Vicent on 2020/8/27.
//

#import "UINavigationBar+MNHelper.h"
#import "UIApplication+MNHelper.h"

@implementation UINavigationBar (MNHelper)

+ (CGFloat)height {
    static CGFloat navigation_bar_total_height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        navigation_bar_total_height = [UINavigationBar NavigationBarHeight] + [UIApplication statusBarHeight];
    });
    return navigation_bar_total_height;
}

+ (CGFloat)barHeight {
    static CGFloat navigation_bar_height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        navigation_bar_height = [UINavigationBar NavigationBarHeight];
    });
    return navigation_bar_height;
}

+ (CGFloat)NavigationBarHeight {
    if (NSThread.isMainThread) return CGRectGetHeight(UINavigationController.new.navigationBar.frame);
    __block CGFloat height = 0.f;
    dispatch_sync(dispatch_get_main_queue(), ^{
        height = CGRectGetHeight(UINavigationController.new.navigationBar.frame);
    });
    return height;
}

@end
