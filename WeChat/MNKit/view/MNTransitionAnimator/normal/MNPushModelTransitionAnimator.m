//
//  MNPushModelTransitionAnimator.m
//  MNKit
//
//  Created by Vincent on 2019/3/22.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPushModelTransitionAnimator.h"

@implementation MNPushModelTransitionAnimator

- (MNTabBarTransitionType)tabBarTransitionType {
    return MNTabBarTransitionTypeAdsorb;
}

- (NSTimeInterval)duration {
    return .56f;
    //return self.transitionOperation == MNControllerTransitionOperationPush ? .56f : .3f;
}

- (void)pushTransitionAnimation {
    [super pushTransitionAnimation];
    self.containerView.backgroundColor = [UIColor blackColor];
    /**先添加控制器*/
    [self.toView setHidden:NO];
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    [self.containerView insertSubview:self.toView aboveSubview:self.fromView];
    
    UIView *fromView = [self.fromView transitionSnapshotView];
    if (self.fromView.tabBar_) [fromView addSubview:self.fromView.tabBar_];
    [self.containerView insertSubview:fromView aboveSubview:self.toView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *toView = [self.toView transitionSnapshotView];
        toView.transform = CGAffineTransformMakeTranslation(0.f, self.containerView.height_mn - toView.top_mn);
        [self.containerView insertSubview:toView aboveSubview:fromView];
        
        [self.toView setHidden:YES];
        [self.fromView setHidden:YES];
        
        [UIView animateWithDuration:(self.duration - .26f)
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             fromView.transform = CGAffineTransformMakeScale(.93f, .93f);
                             toView.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             [self.toView setHidden:NO];
                             [self.fromView setHidden:NO];
                             [self restoreTabBarTransitionSnapshot];
                             [self.containerView setBackgroundColor:[UIColor clearColor]];
                             [fromView removeFromSuperview];
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
    self.containerView.backgroundColor = [UIColor blackColor];
    /**先添加控制器*/
    [self.toView setHidden:NO];
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    [self.containerView insertSubview:self.toView belowSubview:self.fromView];
    
    UIView *fromView = [self.fromView transitionSnapshotView];
    [self.containerView insertSubview:fromView aboveSubview:self.fromView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *toView = [self.toView transitionSnapshotView];
        toView.transform = CGAffineTransformMakeScale(.93f, .93f);
        [self.containerView insertSubview:toView belowSubview:fromView];
        
        [self.fromView setHidden:YES];
        [self.toView setHidden:YES];
        
        [UIView animateWithDuration:(self.duration - .26f)
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             fromView.transform = CGAffineTransformMakeTranslation(0.f, self.containerView.height_mn - fromView.top_mn);
                             toView.transform = CGAffineTransformIdentity;
                             
                         } completion:^(BOOL finished) {
                             [self.toView setHidden:NO];
                             [fromView removeFromSuperview];
                             [self finishTabBarTransitionAnimation];
                             [self.containerView setBackgroundColor:[UIColor clearColor]];
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

/*
- (void)pushTransitionAnimation {
    [super pushTransitionAnimation];
    
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    [self.containerView insertSubview:self.toView belowSubview:self.fromView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.toView.hidden = NO;
        UIView *toView = [self.toView transitionSnapshotView];
        toView.top_mn = self.containerView.height_mn;
        [self.containerView insertSubview:toView aboveSubview:self.fromView];
        self.toView.hidden = YES;
        
        [UIView animateWithDuration:(self.duration - .26f)
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             toView.top_mn = self.toView.top_mn;
                         } completion:^(BOOL finished) {
                             self.toView.hidden = NO;
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
    
    self.toView.hidden = NO;
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    [self.containerView insertSubview:self.toView belowSubview:self.fromView];
    
    UIView *fromView = [self.fromView transitionSnapshotView];
    [self.containerView insertSubview:fromView aboveSubview:self.fromView];
    
    self.fromView.hidden = YES;
    
    [UIView animateWithDuration:self.duration
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         fromView.top_mn = self.containerView.height_mn;
                     } completion:^(BOOL finished) {
                         [fromView removeFromSuperview];
                         [self finishTabBarTransitionAnimation];
                         [self.toController mn_transition_viewWillAppear];
                         [self completeTransitionAnimation];
                     }];
}
*/

@end
