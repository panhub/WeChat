//
//  WXTabBarController.h
//  WeChat
//
//  Created by Vincent on 2019/2/23.
//  Copyright © 2019年 小斯. All rights reserved.
//  微信标签控制器

#import "MNTabBarController.h"

@interface WXTabBarController : MNTabBarController
/**
 微信标签控制器实例化入口
 @return 微信标签控制器
 */
+ (instancetype)tabBarController;

/**
 重置控制器
 */
- (void)reset;

/**
 更新朋友圈角标
 @return 角标数量
 */
- (NSInteger)updateMomentBadgeValue;

@end

