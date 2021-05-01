//
//  UIViewController+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/1/25.
//  Copyright © 2018年 小斯. All rights reserved.
//  控制器扩展

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (MNHelper)
/**
 添加子控制器
 @param childController 子控制器
 @param view 添加到自身的View <nil则默认self.view>
 */
- (void)addChildViewController:(UIViewController *)childController inView:(UIView *_Nullable)view;

/**
 退出视图控制器
 @param animated 是否动画过程
 */
- (void)popWithAnimated:(BOOL)animated;

/**
 从父控制器中删除自身
 */
- (void)removeFromParentController;

/**
 禁止自动布局
 */
- (void)layoutExtendAdjustEdges;

@end


@interface UINavigationController (MNHelper)
/**
 寻找栈内指定类型控制器
 @param cls 指定类型
 @return 栈内指定类型控制器<nullable>
 */
- (__kindof UIViewController * _Nullable)seekViewControllerOfClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
