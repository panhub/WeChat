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
    
    //[self bindTapRecognizerIfNeeded];
    
    self.toView.top_mn = 0.f;
    self.toView.right_mn = 0.f;
    [self.containerView addSubview:self.toView];
    
    self.containerView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:self.duration animations:^{
        self.toView.left_mn = 0.f;
        self.fromView.left_mn = self.toView.width_mn;
        self.containerView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.07f];
    } completion:^(BOOL finished) {
        [self.toController mn_transition_viewWillAppear];
        [self completeTransitionAnimation];
    }];
}

- (void)popTransitionAnimation {
    [UIView animateWithDuration:self.duration animations:^{
        self.toView.left_mn = 0.f;
        self.fromView.right_mn = 0.f;
        self.containerView.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self.toController mn_transition_viewWillAppear];
        [self completeTransitionAnimation];
    }];
}

- (void)bindTapRecognizerIfNeeded {
    NSMutableArray <UIGestureRecognizer *>*gestureRecognizers = [NSMutableArray arrayWithArray:self.containerView.gestureRecognizers];
    [gestureRecognizers enumerateObjectsUsingBlock:^(UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.containerView removeGestureRecognizer:obj];
    }];
    if ([self.toController respondsToSelector:@selector(dismiss)]) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] init];
        recognizer.numberOfTapsRequired = 1;
        [recognizer addTarget:self.toController action:@selector(dismiss)];
        [self.containerView addGestureRecognizer:recognizer];
    }
}

@end
