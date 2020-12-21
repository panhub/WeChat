//
//  MNNavigationController.h
//  MNKit
//
//  Created by Vincent on 2017/11/9.
//  Copyright © 2017年 小斯. All rights reserved.
//  导航控制器基类

#import <UIKit/UIKit.h>
#import "MNTransitionAnimator.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNNavigationController : UINavigationController<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

/**是否正在手动滑动返回*/
@property (nonatomic, readonly, getter=isInteractiveTransition) BOOL interactiveTransition;

/**
 返回导航转场动画者
 @param operation 转场方向
 @param fromVC 起始控制器
 @param toVC 目标控制器
 @return 动画者
 */
- (MNTransitionAnimator *_Nullable)navigationControllerTransitionForOperation:(MNControllerTransitionOperation)operation fromViewController:(__kindof UIViewController *)fromVC toViewController:(__kindof UIViewController *)toVC;

@end
NS_ASSUME_NONNULL_END
