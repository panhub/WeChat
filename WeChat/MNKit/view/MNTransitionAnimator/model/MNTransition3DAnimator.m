//
//  MNTransition3DAnimator.m
//  MNKit
//
//  Created by Vincent on 2018/3/19.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNTransition3DAnimator.h"

@implementation MNTransition3DAnimator

- (void)pushTransitionAnimation {
    
    [[UIApplication sharedApplication].keyWindow setBackgroundColor:[UIColor blackColor]];
    
    self.toView.top_mn = self.containerView.height_mn;
    self.toView.left_mn = 0.f;
    [self.containerView addSubview:self.toView];
    
    self.fromView.layer.anchorPoint = CGPointMake(.5f, 0.f);
    self.fromView.layer.position = CGPointMake(self.fromView.width_mn/2.f, 0.f);
    
    CATransform3D transform3D = CATransform3DIdentity;
    transform3D.m34 = -1.f/600.f;
    transform3D = CATransform3DRotate(transform3D, -20.f*M_PI/180.f, 1, 0, 0);
    
    [UIView animateWithDuration:self.duration animations:^{
        self.toView.top_mn = self.containerView.height_mn - self.toView.height_mn;
        self.fromView.layer.transform = transform3D;
    } completion:^(BOOL finished) {
        [self.toController mn_transition_viewWillAppear];
        [self completeTransitionAnimation];
    }];
}

- (void)popTransitionAnimation {
    [UIView animateWithDuration:self.duration animations:^{
        self.fromView.top_mn = self.containerView.height_mn;
        self.toView.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        [self.toController mn_transition_viewWillAppear];
        [self completeTransitionAnimation];
    }];
}

@end
