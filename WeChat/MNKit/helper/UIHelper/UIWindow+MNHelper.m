//
//  UIWindow+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2019/1/31.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "UIWindow+MNHelper.h"

@implementation UIWindow (MNHelper)
#pragma mark - 获取主Window
+ (UIWindow *)mainWindow {
    return [[[UIApplication sharedApplication] delegate] window];
}

#pragma mark - 寻找最上层控制器
+ (UIViewController *)presentedViewController {
    UIViewController *viewController = self.mainWindow.rootViewController;
    do {
        if (viewController.presentedViewController) {
            viewController = viewController.presentedViewController;
        } else if ([viewController isKindOfClass:UINavigationController.class]) {
            UINavigationController *nav = (UINavigationController *)viewController;
            viewController = nav.viewControllers.count ? nav.viewControllers.lastObject : nil;
        } else if ([viewController isKindOfClass:UITabBarController.class]) {
            UITabBarController *tab = (UITabBarController *)viewController;
            viewController = tab.viewControllers.count ? tab.selectedViewController : nil;
        } else {
            break;
        }
    } while (viewController != nil);
    return viewController;
}

#pragma mark - 寻找最上层导航控制器
+ (UINavigationController *)presentedNavigationController {
    UIViewController *vc = self.presentedViewController;
    UINavigationController *nav;
    do {
        if ([vc isKindOfClass:UINavigationController.class]) {
            nav = (UINavigationController *)vc;
        } else if (vc.navigationController) {
            vc = vc.navigationController;
        } else if (vc.tabBarController) {
            vc = vc.tabBarController;
        } else if (vc.presentingViewController) {
            vc = vc.presentingViewController;
        } else {
            break;
        }
    } while (vc && !nav);
    return nav;
}

#pragma mark - 关闭键盘
+ (BOOL)endEditing:(BOOL)force {
    return [[self mainWindow] endEditing:force];
}

@end
