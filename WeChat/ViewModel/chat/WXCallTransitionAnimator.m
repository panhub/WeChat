//
//  WXCallTransitionAnimator.m
//  WeChat
//
//  Created by Vincent on 2020/2/6.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXCallTransitionAnimator.h"

@implementation WXCallTransitionAnimator
- (MNTabBarTransitionType)tabBarTransitionType {
    return MNTabBarTransitionTypeAdsorb;
}

- (NSTimeInterval)duration {
    return self.transitionOperation == MNControllerTransitionOperationPush ? .54f : (self.isDecline ? .61f : .17f);
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *toView = [self.toView transitionSnapshotView];
        toView.transform = CGAffineTransformMakeTranslation(0.f, -toView.bottom_mn);
        [self.containerView insertSubview:toView aboveSubview:fromView];
        
        [self.toView setHidden:YES];
        [self.fromView setHidden:YES];
        
        [UIView animateWithDuration:(self.duration - .26f)
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             toView.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             [self.toView setHidden:NO];
                             [self.fromView setHidden:NO];
                             [self restoreTabBarTransitionSnapshot];
                             [fromView removeFromSuperview];
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

- (void)popTransitionAnimation {
    [super popTransitionAnimation];
    /**先添加控制器*/
    [self.toView setHidden:NO];
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    [self.containerView insertSubview:self.toView belowSubview:self.fromView];
    
    UIView *fromView = [self.fromView transitionSnapshotView];
    [self.containerView insertSubview:fromView aboveSubview:self.fromView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *toView = [self.toView transitionSnapshotView];
        [self.containerView insertSubview:toView belowSubview:fromView];
        
        [self.fromView setHidden:YES];
        [self.toView setHidden:YES];
        
        [UIView animateWithDuration:(self.duration - .01f)
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             fromView.alpha = 0.f;
                             if (self.isDecline) {
                                 fromView.transform = CGAffineTransformMakeScale(1.03f, 1.03f);
                             } else {
                                 fromView.transform = CGAffineTransformMakeTranslation(0.f, -22.f);
                             }
                         } completion:^(BOOL finished) {
                             [self.toView setHidden:NO];
                             [fromView removeFromSuperview];
                             [self finishTabBarTransitionAnimation];
                             [self.toController willFinishTransitionAnimation];
                             [toView removeFromSuperview];
                             [self completeTransitionAnimation];
                         }];
    });
}
@end
