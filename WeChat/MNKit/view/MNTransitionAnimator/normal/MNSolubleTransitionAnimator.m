//
//  MNSolubleTransitionAnimator.m
//  MNKit
//
//  Created by Vincent on 2018/1/20.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNSolubleTransitionAnimator.h"

@implementation MNSolubleTransitionAnimator
- (NSTimeInterval)duration {
    return .51f;
}

- (void)pushTransitionAnimation {
    [super pushTransitionAnimation];
    
    [self.toView setHidden:NO];
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    [self.containerView insertSubview:self.toView belowSubview:self.fromView];
    
    UIView *fromView = [self.fromView transitionSnapshotView];
    if (self.fromView.tabBar_) [fromView addSubview:self.fromView.tabBar_];
    [self.containerView insertSubview:fromView aboveSubview:self.fromView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *toView = [self.toView transitionSnapshotView];
        toView.alpha = 0.f;
        
        [self.toView setHidden:YES];
        [self.fromView setHidden:YES];
        
        [self.containerView insertSubview:self.toView aboveSubview:fromView];
        [self.containerView insertSubview:toView aboveSubview:self.toView];
        
        [UIView animateWithDuration:(self.duration - .26f) animations:^{
            toView.alpha = 1.f;
        } completion:^(BOOL finished) {
            [self restoreTabBarTransitionSnapshot];
            [fromView removeFromSuperview];
            [self.toView setHidden:NO];
            [self.fromView setHidden:NO];
            [self.fromView removeFromSuperview];
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
    
    [self.toView setHidden:NO];
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    [self.containerView insertSubview:self.toView belowSubview:self.fromView];
    
    UIView *fromView = [self.fromView transitionSnapshotView];
    [self.containerView insertSubview:fromView aboveSubview:self.fromView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *toView = [self.toView transitionSnapshotView];
        toView.alpha = 0.f;

        [self.fromView setHidden:YES];
        [self.toView setHidden:YES];
        
        [self.containerView insertSubview:self.toView aboveSubview:fromView];
        [self.containerView insertSubview:toView aboveSubview:self.toView];
        
        [UIView animateWithDuration:(self.duration - .26f) animations:^{
            toView.alpha = 1.f;
        } completion:^(BOOL finished) {
            [fromView removeFromSuperview];
            [self.fromView removeFromSuperview];
            [self.toView setHidden:NO];
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

@end
