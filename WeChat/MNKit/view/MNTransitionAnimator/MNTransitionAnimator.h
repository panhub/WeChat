//
//  MNTransitionAnimator.h
//  MNKit
//
//  Created by Vincent on 2018/1/5.
//  Copyright © 2018年 小斯. All rights reserved.
//  控制器转场动画管理者者(子类具体实现动画效果)

#import<UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**控制器转场类型*/
typedef NS_ENUM(NSInteger, MNControllerTransitionType) {
    MNControllerTransitionTypeSlide = 0,                /**滑动*/
    MNControllerTransitionTypeSoluble,                  /**溶解消失*/
    MNControllerTransitionTypeDistance,                /**远近切换*/
    MNControllerTransitionTypePortal,                   /**开关门*/
    MNControllerTransitionTypeFlip,                      /**翻转*/
    MNControllerTransitionTypePushModel,            /**进栈的形式下模仿模态弹出*/
    MNControllerTransitionTypeDefaultModel,        /**默认的Model转场*/
    MNControllerTransitionTypeMenuModel,          /**菜单转场*/
    MNControllerTransitionType3DMenuModel,      /**3D菜单转场*/
    MNControllerTransitionTypeMusicModel          /**音乐播放定制转场*/
};

/**
 转场时TabBar的处理方式
 - MNTabBarTransitionTypeNone: 不做操作<主要适用于标签控制器>
 - MNTabBarTransitionTypeAdsorb: 吸附于控制器
 - MNTabBarTransitionTypeSlide: 上下移动
 */
typedef NS_ENUM(NSInteger, MNTabBarTransitionType) {
    MNTabBarTransitionTypeNone = 0,
    MNTabBarTransitionTypeAdsorb,
    MNTabBarTransitionTypeSlide
};

/**
 动画方向
 - MNControllerTransitionOperationPush: 进站
 - MNControllerTransitionOperationPop: 出栈
 */
typedef NS_ENUM(NSInteger, MNControllerTransitionOperation) {
    MNControllerTransitionOperationPush = 1,
    MNControllerTransitionOperationPop = 0
};

@interface MNTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign, readwrite) BOOL interactive;
@property (nonatomic, assign, readwrite) NSTimeInterval duration;
@property (nonatomic, assign, readwrite) MNControllerTransitionOperation transitionOperation;
@property (nonatomic, assign, readwrite) MNTabBarTransitionType tabBarTransitionType;
@property (nonatomic, weak, readwrite) UIView *tabView;
@property (nonatomic, weak, readonly) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, weak, readonly) UIViewController *fromController;
@property (nonatomic, weak, readonly) UIView *fromView;
@property (nonatomic, weak, readonly) UIViewController *toController;
@property (nonatomic, weak, readonly) UIView *toView;
@property (nonatomic, weak, readonly) UIView *containerView;

/**
 转场对象实例化(类似工厂)
 @param type 获取指定类型的转场对象
 @return 转场对象
 */
+ (instancetype)animatorWithType:(MNControllerTransitionType)type;

#pragma mark - Overwrite by Subclass
/**
 Push/Present转场
 */
- (void)pushTransitionAnimation;
/**
 Pop/Dismiss转场
 */
- (void)popTransitionAnimation;
/**
 交互转场
 */
- (void)interactiveTransitionAnimation;
/**
 转场结束tabbar出现
 */
- (void)finishTabBarTransitionAnimation;
/**
 恢复Tabbar截图
 */
- (void)restoreTabBarTransitionSnapshot;
/**
 转场完成, 一定要调用
 */
- (void)completeTransitionAnimation;

@end



@interface UIView (MNTransition)
/**
 转场时记录tabbar截图
 */
@property(nonatomic) UIView *tabBar_;
/**
 交互转场时记录当前截屏
 */
@property(nonatomic) UIView *snapshot_;
/**
 转场时捕获快照
 @return 视图快照
 */
- (UIView *)transitionSnapshotView;
/**
 转场时给截图添加阴影
 */
- (void)makeTransitionShadow;

@end




@interface UIViewController (MNControllerTransition)
/**优先选择的转场动画*/
- (MNTransitionAnimator *)pushTransitionAnimator;
- (MNTransitionAnimator *)popTransitionAnimator;
/**视图已经出现*/
- (void)mn_transition_viewWillAppear;
@end
