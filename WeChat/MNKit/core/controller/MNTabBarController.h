//
//  MNTabBarController.h
//  MNKit
//
//  Created by Vincent on 2017/11/9.
//  Copyright © 2017年 小斯. All rights reserved.
//  标签控制器

#import <UIKit/UIKit.h>
#import "MNTabBar.h"
#import "MNTransitionAnimator.h"
@class MNTabBarController;

NS_ASSUME_NONNULL_BEGIN

@protocol MNTabBarControllerRepeatSelect <NSObject>
@optional
- (void)tabBarControllerDidRepeatSelectItem:(MNTabBarController *)tabBarController;
@end

@interface MNTabBarController : UITabBarController <UITabBarControllerDelegate, MNTabBarDelegate>

/**主控制器*/
@property (nonatomic, copy) NSArray<NSString *>* controllers;

/**
 询问导航类
 @param index 控制器索引
 @return 导航类
 */
- (Class _Nullable)navigationClassAtIndex:(NSInteger)index;

/**
 转场动画
 @param operation 转场方向
 @param fromVC 起始控制器
 @param toVC 目的控制器
 @return 转场动画
 */
- (MNTransitionAnimator *_Nullable)tabBarControllerTransitionForOperation:(MNControllerTransitionOperation)operation fromViewController:(__kindof UIViewController *)fromVC toViewController:(__kindof UIViewController *)toVC;

@end
NS_ASSUME_NONNULL_END
