//
//  MNTabBarController.h
//  MNKit
//
//  Created by Vincent on 2017/11/9.
//  Copyright © 2017年 小斯. All rights reserved.
//  标签控制器

#import <UIKit/UIKit.h>
#import "MNTabBar.h"
@class MNTabBarController;

@protocol MNTabBarControllerRepeatSelect <NSObject>
@optional
- (void)tabBarControllerDidRepeatSelectItem:(MNTabBarController *)tabBarController;
@end

@interface MNTabBarController : UITabBarController <UITabBarControllerDelegate, MNTabBarDelegate>

@property (nonatomic, copy) NSArray<NSString *>* controllers;

/**
 导航类类型
 @return 导航类
 */
+ (Class)navigationClass;

@end
