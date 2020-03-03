//
//  MNModelNavigationController.m
//  MNKit
//
//  Created by Vincent on 2018/4/20.
//  Copyright © 2018年 Apple.lnc. All rights reserved.
//

#import "MNModelNavigationController.h"
#import "MNDefaultModelTransitionAnimator.h"

@interface MNModelNavigationController ()<UIViewControllerTransitioningDelegate>
{
    UIStatusBarStyle UIApplicationStatusBarStyle;
}
@end

@implementation MNModelNavigationController
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        UIApplicationStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.transitioningDelegate = self;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIApplicationStatusBarStyle animated:animated];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    MNTransitionAnimator *animator = [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeDefaultModel];
    animator.transitionOperation = MNControllerTransitionOperationPush;
    animator.tabBarTransitionType = MNTabBarTransitionTypeNone;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    MNTransitionAnimator *animator = [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeDefaultModel];
    animator.transitionOperation = MNControllerTransitionOperationPop;
    animator.tabBarTransitionType = MNTabBarTransitionTypeNone;
    return animator;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return nil;
}

#pragma mark - Controller Config
- (MNControllerTransitionStyle)transitionAnimationStyle {
    return MNControllerTransitionStyleModel;
}

- (void)dealloc {
    MNLog(@"--dealloc --%@",NSStringFromClass([self class]));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
