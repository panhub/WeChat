//
//  MNRotationGestureRecognizer.m
//  MNKit
//
//  Created by Vincent on 2019/7/2.
//  Copyright © 2019 AiZhe. All rights reserved.
//

#import "MNRotationGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation MNRotationGestureRecognizer
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([[event touchesForGestureRecognizer:self] count] == 1) {
        self.state = UIGestureRecognizerStateBegan;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIView *view = self.view;
    CGPoint center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    UITouch *touch = touches.anyObject;
    CGPoint currentPoint = [touch locationInView:view];
    CGPoint previousPoint = [touch previousLocationInView:view];
    CGFloat currentRotation = atan2f((currentPoint.y - center.y), (currentPoint.x - center.x));
    CGFloat previousRotation = atan2f((previousPoint.y - center.y), (previousPoint.x - center.x));
    self.rotation = currentRotation - previousRotation;
    self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.state == UIGestureRecognizerStateChanged) {
        self.state = UIGestureRecognizerStateEnded;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.state == UIGestureRecognizerStateChanged) {
        self.state = UIGestureRecognizerStateCancelled;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

@end
