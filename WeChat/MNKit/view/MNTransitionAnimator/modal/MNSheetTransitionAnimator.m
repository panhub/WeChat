//
//  MNSheetTransitionAnimator.m
//  MNKit
//
//  Created by Vicent on 2020/9/28.
//

#import "MNSheetTransitionAnimator.h"

@implementation MNSheetTransitionAnimator
- (NSTimeInterval)duration {
    return .33f;
}

- (void)pushTransitionAnimation {

    if ([self.toController respondsToSelector:@selector(beginDismissTransitionAnimation)]) {
        UIView *modalTouchView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        modalTouchView.height_mn = self.containerView.height_mn - self.toView.height_mn;
        modalTouchView.backgroundColor = UIColor.clearColor;
        [self.containerView addSubview:modalTouchView];
        self.containerView.modalTouchView = modalTouchView;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.toController action:@selector(beginDismissTransitionAnimation)];
        recognizer.numberOfTapsRequired = 1;
        [modalTouchView addGestureRecognizer:recognizer];
    }

    self.toView.top_mn = self.containerView.height_mn;
    self.toView.centerX_mn = self.containerView.width_mn/2.f;
    [self.containerView addSubview:self.toView];
    
    self.containerView.backgroundColor = UIColor.clearColor;
    [UIView animateWithDuration:self.duration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.toView.bottom_mn = self.containerView.height_mn;
        self.containerView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:.4f];
    } completion:^(BOOL finished) {
        [self.toController willFinishTransitionAnimation];
        [self completeTransitionAnimation];
    }];
}

- (void)popTransitionAnimation {
    
    if (self.containerView.modalTouchView) {
        [self.containerView.modalTouchView removeFromSuperview];
        self.containerView.modalTouchView = nil;
    }
    
    [UIView animateWithDuration:self.duration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.fromView.top_mn = self.containerView.height_mn;
        self.containerView.backgroundColor = UIColor.clearColor;
    } completion:^(BOOL finished) {
        [self.toController willFinishTransitionAnimation];
        [self completeTransitionAnimation];
    }];
}

@end
