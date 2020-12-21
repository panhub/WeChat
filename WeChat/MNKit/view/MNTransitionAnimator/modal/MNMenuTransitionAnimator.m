//
//  MNMenuTransitionAnimator.m
//  MNKit
//
//  Created by Vincent on 2018/3/19.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNMenuTransitionAnimator.h"

@implementation MNMenuTransitionAnimator
- (NSTimeInterval)duration {
    return .35f;
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
    
    self.toView.top_mn = 0.f;
    self.toView.right_mn = 0.f;
    [self.containerView addSubview:self.toView];
    
    self.containerView.backgroundColor = UIColor.clearColor;
    [UIView animateWithDuration:self.duration animations:^{
        self.toView.left_mn = 0.f;
        self.fromView.left_mn = self.toView.right_mn;
        self.containerView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.07f];
    } completion:^(BOOL finished) {
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
    
    [UIView animateWithDuration:self.duration animations:^{
        self.toView.left_mn = 0.f;
        self.fromView.right_mn = 0.f;
        self.containerView.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self.toController willFinishTransitionAnimation];
        [self completeTransitionAnimation];
    }];
}

@end
