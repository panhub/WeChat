//
//  UIViewController+MNConfiguration.h
//  MNKit
//
//  Created by Vincent on 2018/1/9.
//  Copyright © 2018年 小斯. All rights reserved.
//  为控制器提供配置信息

#import <UIKit/UIKit.h>
#import "MNTabBar.h"
#import "MNTransitionAnimator.h"

/**
 控制器的转场方式
 - MNControllerTransitionStyleModal: 模态转场
 - MNControllerTransitionStyleStack: 进出栈
 */
typedef NS_ENUM(NSInteger, MNControllerTransitionStyle) {
    MNControllerTransitionStyleModal = 0,
    MNControllerTransitionStyleStack
};

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (MNInterface)
/**角标*/
@property (nonatomic) NSString *badgeValue;
/**标签控制器按钮标题<首选, nil则取控制器title>*/
- (NSString *)tabBarItemTitle;
/**标签控制器按钮正常状态下的图片*/
- (UIImage *)tabBarItemImage;
/**标签控制器按钮选中状态下的图片*/
- (UIImage *)tabBarItemSelectedImage;
/**是否是主视图控制器, 默认NO*/
- (BOOL)isRootViewController;
/**是否是作为子控制器被添加, 默认NO*/
- (BOOL)isChildViewController;
/**寻找自身父控制器*/
- (UIViewController *_Nullable)parentController;
@end

@interface UIViewController (MNInteractiveTransition)
/**是否允许手势转场*/
- (BOOL)shouldInteractivePopTransition;
/**开始手势转场*/
- (void)beganInteractivePopTransition;
/**结束手势转场*/
- (void)endInteractivePopTransition;
/**取消手势转场*/
- (void)cancelInteractivePopTransition;
/**获取控制器的转场方式, 决定了是否创建自定义导航栏和转场动画的选择*/
- (MNControllerTransitionStyle)transitionAnimationStyle;
@end


@interface UINavigationController (MNInteractiveTransition)
/**是否关闭导航手势滑动*/
@property (nonatomic) BOOL interactiveTransitionEnabled;
/**手势实例*/
@property (nonatomic, strong, nullable) UIScreenEdgePanGestureRecognizer *interactiveGestureRecognizer;
@end


@interface UITabBarController (MNInterface)
/**自定义TabBar*/
@property (nonatomic, strong, nullable) MNTabBar *tabView;
@end


@interface UIView (MNInterface)
/**
 自定义TabBar设置角标
 @param badgeValue 角标内容
 @param index 索引
 */
- (void)setBadgeValue:(NSString *)badgeValue ofIndex:(NSUInteger)index;
/**
 获取自定义TabBar设置角标
 @param index 索引
 @return 角标内容
 */
- (NSString *_Nullable)badgeValueOfIndex:(NSUInteger)index;

@end
NS_ASSUME_NONNULL_END
