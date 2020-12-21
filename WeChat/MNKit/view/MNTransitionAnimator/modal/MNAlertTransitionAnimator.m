//
//  MNAlertTransitionAnimator.m
//  MNKit
//
//  Created by Vicent on 2020/10/18.
//

#import "MNAlertTransitionAnimator.h"

@implementation MNAlertTransitionAnimator
- (NSTimeInterval)duration {
    return self.transitionOperation == MNControllerTransitionOperationPush ? .33f : .2f;
}

- (void)pushTransitionAnimation {
    
    self.toView.center_mn = self.containerView.bounds_center;
    self.toView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    [self.containerView addSubview:self.toView];
    
    self.containerView.backgroundColor = UIColor.clearColor;
    
    [UIView animateWithDuration:self.duration delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.toView.transform = CGAffineTransformIdentity;
        self.containerView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:.4f];
    } completion:^(BOOL finished) {
        [self.toController willFinishTransitionAnimation];
        [self completeTransitionAnimation];
    }];
}

- (void)popTransitionAnimation {
    
    [UIView animateWithDuration:self.duration delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.fromView.alpha = 0.f;
        self.fromView.transform = CGAffineTransformMakeScale(.9f, .9f);
        self.containerView.backgroundColor = UIColor.clearColor;
    } completion:^(BOOL finished) {
        [self.toController willFinishTransitionAnimation];
        [self completeTransitionAnimation];
    }];
}

@end
