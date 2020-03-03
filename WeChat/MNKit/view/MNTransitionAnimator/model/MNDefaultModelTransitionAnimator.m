//
//  MNDefaultModelTransitionAnimator.m
//  MNKit
//
//  Created by Vincent on 2018/3/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNDefaultModelTransitionAnimator.h"

@implementation MNDefaultModelTransitionAnimator
- (NSTimeInterval)duration {
    return self.transitionOperation == MNControllerTransitionOperationPush ? .56f : .3f;
}

- (void)pushTransitionAnimation {
    
    [self.containerView addSubview:self.fromView];
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    [self.containerView insertSubview:self.toView belowSubview:self.fromView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.toView.hidden = NO;
        UIView *toView = [self.toView transitionSnapshotView];
        toView.top_mn = self.containerView.height_mn;
        [self.containerView insertSubview:toView aboveSubview:self.fromView];
        /// 避免self.fromView有透明度, 影响效果
        self.toView.hidden = YES;
        
        [UIView animateWithDuration:(self.duration - .26f)
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             toView.top_mn = self.toView.top_mn;
                         } completion:^(BOOL finished) {
                             [self.toView setHidden:NO];
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

    UIView *fromView = [self.fromView transitionSnapshotView];
    fromView.top_mn = self.fromView.top_mn;
    [self.containerView insertSubview:fromView aboveSubview:self.fromView];
    
    self.toView.hidden = NO;
    [self.containerView insertSubview:self.toView aboveSubview:self.fromView];
    
    self.fromView.hidden = YES;

    [UIView animateWithDuration:self.duration
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        fromView.top_mn = self.containerView.height_mn;
    } completion:^(BOOL finished) {
        self.fromView.hidden = NO;
        [fromView removeFromSuperview];
        [self.toController mn_transition_viewWillAppear];
        [self completeTransitionAnimation];
    }];
}

@end
