//
//  MNPortalTransitionAnimator.m
//  MNKit
//
//  Created by Vincent on 2018/4/9.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNPortalTransitionAnimator.h"

@implementation MNPortalTransitionAnimator
- (NSTimeInterval)duration {
    return .58f;
}

- (void)pushTransitionAnimation {
    [super pushTransitionAnimation];
    //添加控制器
    [self.toView setHidden:NO];
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    [self.containerView insertSubview:self.toView belowSubview:self.fromView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *toView = [self.toView transitionSnapshotView];
        [self.containerView insertSubview:toView belowSubview:self.fromView];
        toView.transform = CGAffineTransformMakeScale(.8f, .8f);
        
        //左右截屏
        UIView *fromLeftView = [self.fromView snapshotViewWithRect:CGRectMake(0.f, 0.f, self.fromView.width_mn/2.f, self.fromView.height_mn)];
        fromLeftView.left_mn = (self.containerView.width_mn - self.fromView.width_mn)/2.f;
        [self.containerView insertSubview:fromLeftView belowSubview:self.fromView];
        
        UIView *fromRightView = [self.fromView snapshotViewWithRect:CGRectMake(self.fromView.width_mn/2.f, 0.f, self.fromView.width_mn/2.f, self.fromView.height_mn)];
        fromRightView.left_mn = fromLeftView.right_mn;
        [self.containerView insertSubview:fromRightView belowSubview:self.fromView];
        
        [self.fromView setHidden:YES];
        [self.toView setHidden:YES];
        
        UIColor *color = [[UIApplication sharedApplication] keyWindow].backgroundColor;
        [[[UIApplication sharedApplication] keyWindow] setBackgroundColor:[UIColor blackColor]];
        [UIView animateWithDuration:(self.duration - .26f) animations:^{
            fromLeftView.right_mn = 0.f;
            fromRightView.left_mn = self.containerView.width_mn;
            toView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self.toView setHidden:NO];
            [self restoreTabBarTransitionSnapshot];
            [fromLeftView removeFromSuperview];
            [fromRightView removeFromSuperview];
            [self.toController willFinishTransitionAnimation];
            [[[UIApplication sharedApplication] keyWindow] setBackgroundColor:color];
            [UIView animateWithDuration:.25f animations:^{
                toView.alpha = 0.f;
            } completion:^(BOOL finished) {
                [toView removeFromSuperview];
                [self.containerView setBackgroundColor:[UIColor clearColor]];
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
    [self.containerView insertSubview:fromView belowSubview:self.fromView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *toLeftView = [self.toView snapshotViewWithRect:CGRectMake(0.f, 0.f, self.toView.width_mn/2.f, self.toView.height_mn)];
        toLeftView.right_mn = 0.f;
        [self.containerView insertSubview:toLeftView belowSubview:self.fromView];
        
        UIView *toRightView = [self.toView snapshotViewWithRect:CGRectMake(self.toView.width_mn/2.f, 0.f, self.toView.width_mn/2.f, self.toView.height_mn)];
        toRightView.left_mn = self.containerView.width_mn;
        [self.containerView insertSubview:toRightView belowSubview:self.fromView];
        
        [self.fromView setHidden:YES];
        [self.toView setHidden:YES];
        
        UIColor *color = [[UIApplication sharedApplication] keyWindow].backgroundColor;
        [[[UIApplication sharedApplication] keyWindow] setBackgroundColor:[UIColor blackColor]];
        [UIView animateWithDuration:(self.duration - .26f) animations:^{
            toLeftView.left_mn = 0.f;
            toRightView.right_mn = self.containerView.width_mn;
            fromView.transform = CGAffineTransformMakeScale(.8f, .8f);
        } completion:^(BOOL finished) {
            [fromView removeFromSuperview];
            [self.toView setHidden:NO];
            [self finishTabBarTransitionAnimation];
            [self.toController willFinishTransitionAnimation];
            [[[UIApplication sharedApplication] keyWindow] setBackgroundColor:color];
            [UIView animateWithDuration:.25f animations:^{
                toLeftView.alpha = 0.f;
                toRightView.alpha = 0.f;
            } completion:^(BOOL finished) {
                [toLeftView removeFromSuperview];
                [toRightView removeFromSuperview];
                [self.containerView setBackgroundColor:[UIColor clearColor]];
                [self completeTransitionAnimation];
            }];
        }];
    });
}
@end
