//
//  MNSlideTransitionAnimator.m
//  MNKit
//
//  Created by Vincent on 2018/1/5.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNSlideTransitionAnimator.h"

@implementation MNSlideTransitionAnimator
- (NSTimeInterval)duration {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? .56f : .71f;
}

- (void)pushTransitionAnimation {
    [super pushTransitionAnimation];
    /**先添加控制器*/
    [self.toView setHidden:NO];
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    [self.containerView insertSubview:self.toView aboveSubview:self.fromView];
    
    UIView *fromView = [self.fromView transitionSnapshotView];
    if (self.fromView.tabBar_) [fromView addSubview:self.fromView.tabBar_];
    [self.containerView insertSubview:fromView aboveSubview:self.toView];
    
    UIView *shadowView = [[UIView alloc]initWithFrame:self.containerView.bounds];
    shadowView.backgroundColor = [UIColor clearColor];
    [self.containerView insertSubview:shadowView aboveSubview:fromView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *toView = [self.toView transitionSnapshotView];
        toView.left_mn = self.containerView.width_mn;
        [toView makeTransitionShadow];
        [self.containerView insertSubview:toView aboveSubview:shadowView];
        
        [self.toView setHidden:YES];
        [self.fromView setHidden:YES];
        
        [UIView animateWithDuration:(self.duration - .26f) delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fromView.transform = CGAffineTransformMakeTranslation(-(fromView.left_mn + fromView.width_mn/2.f), 0.f);
            shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2f];
            toView.transform = CGAffineTransformMakeTranslation(-(toView.left_mn - self.toView.left_mn), 0.f);
        } completion:^(BOOL finished) {
            [self.toView setHidden:NO];
            [self.fromView setHidden:NO];
            [self restoreTabBarTransitionSnapshot];
            [fromView removeFromSuperview];
            [shadowView removeFromSuperview];
            [self.toController mn_transition_viewWillAppear];
            [UIView animateWithDuration:.25f animations:^{
                toView.alpha = 0.f;
            } completion:^(BOOL finished) {
                [toView removeFromSuperview];
                [self completeTransitionAnimation];
            }];
        }];
    });
}

- (void)popTransitionAnimation {
    [super popTransitionAnimation];
    
    /**先添加控制器*/
    [self.toView setHidden:NO];
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    [self.containerView insertSubview:self.toView belowSubview:self.fromView];
    
    UIView *fromView = [self.fromView transitionSnapshotView];
    [fromView makeTransitionShadow];
    [self.containerView insertSubview:fromView aboveSubview:self.fromView];
    
    UIView *shadowView = [[UIView alloc]initWithFrame:self.containerView.bounds];
    shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2f];
    [self.containerView insertSubview:shadowView belowSubview:self.fromView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIView *toView = [self.toView transitionSnapshotView];
        toView.transform = CGAffineTransformMakeTranslation(-(toView.left_mn + toView.width_mn/2.f), 0.f);
        [self.containerView insertSubview:toView belowSubview:shadowView];
        
        [self.fromView setHidden:YES];
        [self.toView setHidden:YES];
        
        [UIView animateWithDuration:(self.duration - .26f) delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fromView.transform = CGAffineTransformMakeTranslation((self.containerView.width_mn - fromView.left_mn), 0.f);
            shadowView.backgroundColor = [UIColor clearColor];
            toView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self.toView setHidden:NO];
            [fromView removeFromSuperview];
            [shadowView removeFromSuperview];
            [self finishTabBarTransitionAnimation];
            [self.toController mn_transition_viewWillAppear];
            [UIView animateWithDuration:.25f animations:^{
                toView.alpha = 0.f;
            } completion:^(BOOL finished) {
                [toView removeFromSuperview];
                [self completeTransitionAnimation];
            }];
        }];
    });
}

#pragma mark - 交互转场
- (void)interactiveTransitionAnimation {
    /**先添加控制器*/
    [self.toView setHidden:NO];
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    self.toView.centerX_mn = 0.f;
    [self.containerView insertSubview:self.toView belowSubview:self.fromView];
    
    UIView *fromView = [self.fromView transitionSnapshotView];
    [fromView makeTransitionShadow];
    [self.containerView insertSubview:fromView aboveSubview:self.fromView];
    self.fromView.snapshot_ = fromView;
    
    [self.fromView setHidden:YES];
    [UIView animateWithDuration:self.duration animations:^{
        self.toView.left_mn = 0.f;
        fromView.left_mn = self.containerView.width_mn;
    } completion:^(BOOL finished) {
        [self completeTransitionAnimation];
    }];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    if (!self.interactive) return;
    if (transitionCompleted) {
        [self finishTabBarTransitionAnimation];
        [self.fromView.snapshot_ removeFromSuperview];
        [self.fromView setSnapshot_:nil];
        [self.fromView removeFromSuperview];
    } else {
        [self.toView removeFromSuperview];
        [self.fromView setHidden:NO];
        [UIView animateWithDuration:.15f animations:^{
            self.fromView.snapshot_.alpha = 0.f;
        } completion:^(BOOL finished) {
            [self.fromView.snapshot_ removeFromSuperview];
            [self.fromView setSnapshot_:nil];
        }];
    }
}

@end
