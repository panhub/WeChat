//
//  MNModelViewController.m
//  MNKit
//
//  Created by Vincent on 2018/2/27.
//  Copyright © 2018年 Apple.lnc. All rights reserved.
//

#import "MNModelViewController.h"
#import "MNTransitionAnimator.h"

@interface MNModelViewController ()
{
    UIStatusBarStyle UIApplicationStatusBarStyle;
}
@end

@implementation MNModelViewController
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.childController = NO;
    }
    return self;
}

- (void)initialized {
    [super initialized];
    /** 踩坑笔记:
     如果没有设置Custom在present动画完成后,presentingView会从视图结构中移除(只是移除,并未销毁),在disMiss的动画逻辑中,要把它放回视图结构中(不主动添加,UIKit也会自己添加);如果设置Custom,那么present完成后,它一直都在自己所属的视图结构中.
     UIModalPresentationCustom:转场时 containerView 并不担任 presentingView 的父视图,后者由 UIKit 另行管理. 在 present转场结束后,fromView(presentingView) 未被移出视图结构,在 dismissal 中,不要像其他转场中那样将 toView(presentingView) 加入 containerView 中,否则本来可见的 presentingView 将会被移除出自身所处的视图结构消失不见. 使用 Custom 模式时一定要注意到这一点
     对于 Custom 模式,我们可以参照其他转场里的处理规则来打理:present 转场结束后主动将 fromView(presentingView) 移出它的视图结构,并用一个变量来维护 presentingView 的父视图,以便在 dismissal 转场中恢复;在 dismissal 转场中,presentingView 的角色由原来的 fromView 切换成了 toView,我们再将其重新恢复它原来的视图结构中. 测试表明这样做是可行的. 但是这样一来,需要在转场代理中维护一个动画控制器并且这个动画控制器要维护 presentingView 的父视图,这样的代价也是巨大的.
     建议不要干涉UIKit对 Modal 转场的处理,我们去适应它. 在 Custom 模式下,由于 presentingView 不受 containerView 管理,在 dismissal 转场中不要像其他的转场那样将 toView(presentingView) 加入 containerView,否则 presentingView 将消失不见,而应用则也很可能假死;在 presentation 转场中,最好不要手动将 fromView(presentingView) 移出其父视图,这样不就不用特意去维护其父视图。
     */
    UIApplicationStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    self.modalPresentationStyle = [self modelTransitionType] == MNControllerTransitionTypeDefaultModel ? UIModalPresentationFullScreen : UIModalPresentationCustom;
    self.transitioningDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self shouldChangeStatusBarStyle]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIApplicationStatusBarStyle animated:animated];
    }
}

#pragma mark - MNNavigationBarDelegate
- (void)navigationBarLeftBarItemTouchUpInside:(UIView *)leftBarItem {
    [self dismiss];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Controller Config
- (MNControllerTransitionStyle)transitionAnimationStyle {
    return MNControllerTransitionStyleModel;
}

- (MNControllerTransitionType)modelTransitionType {
    return MNControllerTransitionTypeDefaultModel;
}

- (BOOL)shouldChangeStatusBarStyle {
    return YES;
}

#pragma mark - 取代默认转场
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    MNTransitionAnimator *animator = [MNTransitionAnimator animatorWithType:[self modelTransitionType]];
    animator.transitionOperation = MNControllerTransitionOperationPush;
    animator.tabBarTransitionType = MNTabBarTransitionTypeNone;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    MNTransitionAnimator *animator = [MNTransitionAnimator animatorWithType:[self modelTransitionType]];
    animator.transitionOperation = MNControllerTransitionOperationPop;
    animator.tabBarTransitionType = MNTabBarTransitionTypeNone;
    return animator;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator{
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
