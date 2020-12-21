//
//  MN3DMenuTransitionAnimator.m
//  MNKit
//
//  Created by Vincent on 2019/2/24.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MN3DMenuTransitionAnimator.h"

@implementation MN3DMenuTransitionAnimator
- (NSTimeInterval)duration {
    return .5f;
}

- (void)pushTransitionAnimation {
    
    if ([self.toController respondsToSelector:@selector(beginDismissTransitionAnimation)]) {
        UIView *modalTouchView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        modalTouchView.left_mn = self.toView.width_mn;
        modalTouchView.backgroundColor = UIColor.clearColor;
        [self.containerView addSubview:modalTouchView];
        self.containerView.modalTouchView = modalTouchView;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.toController action:@selector(beginDismissTransitionAnimation)];
        recognizer.numberOfTapsRequired = 1;
        [modalTouchView addGestureRecognizer:recognizer];
    }
    
    CGFloat width = self.toView.width_mn;
    self.toView.top_mn = 0.f;
    self.toView.right_mn = width/2.f;
    [self.containerView addSubview:self.toView];
    
    self.toView.layer.anchorPoint = CGPointMake(1.f, .5f);
    self.toView.layer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 1, 0);

    CATransform3D identity = CATransform3DIdentity;
    identity.m34 = -1.f/1000.f;
    CATransform3D rotateTransform = CATransform3DRotate(identity, 0.f, 0, 1, 0);
    CATransform3D translateTransform = CATransform3DMakeTranslation(width, 0.f, 0.f);
    
    self.containerView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:self.duration animations:^{
        self.fromView.left_mn = width;
        self.toView.layer.transform = CATransform3DConcat(rotateTransform, translateTransform);
        self.containerView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.07f];
    } completion:^(BOOL finished) {
        self.toView.layer.anchorPoint = CGPointMake(.5f, .5f);
        self.toView.layer.transform = CATransform3DIdentity;
        self.toView.left_mn = 0.f;
        if (self.containerView.modalTouchView) [self.containerView bringSubviewToFront:self.containerView.modalTouchView];
        [self.toController willFinishTransitionAnimation];
        [self completeTransitionAnimation];
    }];
}

- (void)popTransitionAnimation {
    
    if (self.containerView.modalTouchView) {
        [self.containerView.modalTouchView removeFromSuperview];
        self.containerView.modalTouchView = nil;
    }
    
    CGFloat width = self.fromView.width_mn;
    
    self.fromView.left_mn = width/2.f;
    self.fromView.layer.anchorPoint = CGPointMake(1.f, .5f);
    
    self.toView.left_mn = width;
    
    CATransform3D identity = CATransform3DIdentity;
    identity.m34 = -1.f/1000.f;
    CATransform3D rotateTransform = CATransform3DRotate(identity, -M_PI_2, 0, 1, 0);
    CATransform3D translateTransform = CATransform3DMakeTranslation(-width, 0.f, 0.f);
    
    [UIView animateWithDuration:self.duration animations:^{
        self.toView.left_mn = 0.f;
        self.containerView.backgroundColor = [UIColor clearColor];
        self.fromView.layer.transform = CATransform3DConcat(rotateTransform, translateTransform);
    } completion:^(BOOL finished) {
        self.fromView.layer.anchorPoint = CGPointMake(.5f, .5f);
        self.fromView.layer.transform = CATransform3DIdentity;
        self.fromView.right_mn = 0.f;
        [self.toController willFinishTransitionAnimation];
        [self completeTransitionAnimation];
    }];
}

@end
