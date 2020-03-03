//
//  MNDistanceTransitionAnimator.m
//  MNKit
//
//  Created by Vincent on 2018/2/27.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNDistanceTransitionAnimator.h"

@implementation MNDistanceTransitionAnimator
- (NSTimeInterval)duration {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? .56f : .71f;
}

- (void)pushTransitionAnimation {
    [super pushTransitionAnimation];
    [self.containerView setBackgroundColor:[UIColor blackColor]];
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
        
        [UIView animateWithDuration:(self.duration - .26f)
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             fromView.transform = CGAffineTransformMakeScale(.93f, .93f);
                             shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2f];
                             toView.transform = CGAffineTransformMakeTranslation(-(toView.left_mn - self.toView.left_mn), 0.f);
                             
                         } completion:^(BOOL finished) {
                             [self.toView setHidden:NO];
                             [self.fromView setHidden:NO];
                             [self restoreTabBarTransitionSnapshot];
                             [self.containerView setBackgroundColor:[UIColor clearColor]];
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
    
    [self.containerView setBackgroundColor:[UIColor blackColor]];
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
        toView.transform = CGAffineTransformMakeScale(.93f, .93f);
        [self.containerView insertSubview:toView belowSubview:shadowView];
        
        [self.fromView setHidden:YES];
        [self.toView setHidden:YES];
        
        [UIView animateWithDuration:(self.duration - .26f)
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             fromView.transform = CGAffineTransformMakeTranslation((self.containerView.width_mn - fromView.left_mn), 0.f);
                             shadowView.backgroundColor = [UIColor clearColor];
                             toView.transform = CGAffineTransformIdentity;
                             
                         } completion:^(BOOL finished) {
                             [self.toView setHidden:NO];
                             [fromView removeFromSuperview];
                             [shadowView removeFromSuperview];
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

@end
