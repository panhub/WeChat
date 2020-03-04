//
//  MNNavigationController.m
//  MNKit
//
//  Created by Vincent on 2017/11/9.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "MNNavigationController.h"
#import "UIView+MNLayout.h"
#import "UIViewController+MNInterface.h"
#import "MNBaseViewController.h"
#import "MNTransitionAnimator.h"
#import "MNConfiguration.h"
#import "UIViewController+MNHelper.h"
#import "MNTransitionAnimator.h"

@interface MNNavigationController ()
/**
 交互转场驱动器
 命名为interactiveTransition会崩溃, 应该是和内部属性冲突导致
 */
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransitionDriver;
@end

@implementation MNNavigationController
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*
     要使用的协议
     UIViewControllerInteractiveTransitioning 交互协议，主要在右滑返回时用到
     UIViewControllerAnimatedTransitioning 动画协议，含有动画时间及转场上下文两个必须实现协议
     UIViewControllerContextTransitioning 动画协议里边的协议之一，动画实现的主要部分
     UIPrecentDrivenInteractiveTransition 用在交互协议，百分比控制当前动画进度。
     */
    [self.navigationBar setHidden:YES];
    [self layoutExtendAdjustEdges];
    /**先关闭系统手势创建一个滑动手势作用于系统手势的view上*/
    UIGestureRecognizer *recognizer = self.interactivePopGestureRecognizer;
    UIView *recognizerView = recognizer.view;
    [recognizerView removeGestureRecognizer:recognizer];
    /**创建一个滑动手势*/
    UIScreenEdgePanGestureRecognizer *gestureRecognizer = [UIScreenEdgePanGestureRecognizer new];
    gestureRecognizer.edges = UIRectEdgeLeft;
    gestureRecognizer.delegate = self;
    gestureRecognizer.enabled = YES;
    gestureRecognizer.maximumNumberOfTouches = 1;
    [gestureRecognizer addTarget:self action:@selector(interactiveTransitionHandle:)];
    [recognizerView addGestureRecognizer:gestureRecognizer];
    self.interactiveGestureRecognizer = gestureRecognizer;
    self.interactiveTransitionEnabled = YES;
}

#pragma mark - 交互转场控制
- (void)interactiveTransitionHandle:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGFloat x = [recognizer translationInView:recognizer.view].x;
    CGFloat progress = x/recognizer.view.bounds.size.width;
    progress = MIN(1.f, MAX(.01f, progress));
    UIGestureRecognizerState state = recognizer.state;
    if (state == UIGestureRecognizerStateBegan) {
        _interactiveTransitionDriver = [[UIPercentDrivenInteractiveTransition alloc]init];
        [self popViewControllerAnimated:YES];
    } else if (state == UIGestureRecognizerStateChanged) {
        [_interactiveTransitionDriver updateInteractiveTransition:progress];
    } else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        if (progress >= .3f) {
            [_interactiveTransitionDriver finishInteractiveTransition];
        } else {
            [_interactiveTransitionDriver cancelInteractiveTransition];
        }
        _interactiveTransitionDriver = nil;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return (self.viewControllers.count > 1 && self.interactiveTransitionEnabled && ![[self valueForKey:@"_isTransitioning"] boolValue]);
}

#pragma mark - UINavigationControllerDelegate (verson >=7.0 )
//交互动画, 即右滑返回时用到
- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    return _interactiveTransitionDriver;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(MNNavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationNone) return nil;
    MNControllerTransitionOperation _operation = (operation == UINavigationControllerOperationPush ? MNControllerTransitionOperationPush : MNControllerTransitionOperationPop);
    MNTransitionAnimator *animator = operation == UINavigationControllerOperationPush ? [toVC pushTransitionAnimator] : [fromVC popTransitionAnimator];
    if (!animator) {
        animator = [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeSlide];
    }
    animator.tabView = fromVC.tabBarController.tabView;
    animator.interactive = (_interactiveTransitionDriver != nil);
    animator.transitionOperation = _operation;
    animator.tabBarTransitionType = MNTabBarTransitionTypeAdsorb;
    return animator;
}

#pragma mark - 屏幕旋转相关
- (BOOL)shouldAutorotate {
    if (self.viewControllers.count > 0) {
        return [[self.viewControllers lastObject] supportedInterfaceOrientations];
    }
    return YES;
}
- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    if (navigationController.viewControllers.count > 0) {
        return [[navigationController.viewControllers lastObject] supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskAll;
}
- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
    return IS_IPAD ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait;
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
