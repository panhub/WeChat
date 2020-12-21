//
//  MNFlipTransitionAnimator.m
//  MNKit
//
//  Created by Vincent on 2018/7/4.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNFlipTransitionAnimator.h"

@implementation MNFlipTransitionAnimator
- (NSTimeInterval)duration {
    return .76f;
}

- (void)pushTransitionAnimation {
    [super pushTransitionAnimation];
    
    [self.toView setHidden:NO];
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    [self.containerView insertSubview:self.toView belowSubview:self.fromView];
    
    UIView *fromView = [self.fromView transitionSnapshotView];
    if (self.fromView.tabBar_) [fromView addSubview:self.fromView.tabBar_];
    [self.containerView insertSubview:fromView aboveSubview:self.fromView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *toView = [self.toView transitionSnapshotView];
        [self.containerView insertSubview:toView belowSubview:self.toView];
        
        [self.toView setHidden:YES];
        [self.fromView setHidden:YES];
        
        UIColor *color = [[UIApplication sharedApplication] keyWindow].backgroundColor;
        [[[UIApplication sharedApplication] keyWindow] setBackgroundColor:[UIColor blackColor]];
        [UIView transitionWithView:self.containerView duration:(self.duration - .26f) options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
            
            [self.containerView bringSubviewToFront:toView];
            
        } completion:^(BOOL finished) {
            [self restoreTabBarTransitionSnapshot];
            [fromView removeFromSuperview];
            [self.fromView setHidden:NO];
            [self.fromView removeFromSuperview];
            [self.containerView insertSubview:self.toView belowSubview:toView];
            [self.toView setHidden:NO];
            [self.toController willFinishTransitionAnimation];
            [[[UIApplication sharedApplication] keyWindow] setBackgroundColor:color];
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *toView = [self.toView transitionSnapshotView];
        [self.containerView insertSubview:toView belowSubview:self.toView];
        
        [self.toView setHidden:YES];
        [self.fromView setHidden:YES];
        
        UIColor *color = [[UIApplication sharedApplication] keyWindow].backgroundColor;
        [[[UIApplication sharedApplication] keyWindow] setBackgroundColor:[UIColor blackColor]];
        [UIView transitionWithView:self.containerView duration:(self.duration - .26f) options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            
            [self.containerView bringSubviewToFront:toView];
            
        } completion:^(BOOL finished) {
            [[[UIApplication sharedApplication] keyWindow] setBackgroundColor:color];
            [fromView removeFromSuperview];
            [self.fromView removeFromSuperview];
            [self.containerView insertSubview:self.toView belowSubview:toView];
            [self.toView setHidden:NO];
            [self finishTabBarTransitionAnimation];
            [self.toController willFinishTransitionAnimation];
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
