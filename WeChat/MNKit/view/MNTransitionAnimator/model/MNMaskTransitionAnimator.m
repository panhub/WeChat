//
//  MNMaskTransitionAnimator.m
//  MNKit
//
//  Created by Vincent on 2018/1/10.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNMaskTransitionAnimator.h"

#define kMaskAnimatorPathKey         @"mask.animation.path.key"
#define kMaskAnimatorPathValue       @"mask.animation.path.value"
@interface MNMaskTransitionAnimator ()<CAAnimationDelegate>
{
    __weak UIView *_maskSnapshot;
    __weak UIView *_fromViewSnapshot;
    __weak UIView *_toViewSnapshot;
}
@end
@implementation MNMaskTransitionAnimator
+ (instancetype)animatorWithMaskRect:(CGRect)rect {
    if (CGRectEqualToRect(rect, CGRectZero)) {return nil;}
    MNMaskTransitionAnimator *animator = [MNMaskTransitionAnimator new];
    animator.rect = rect;
    return animator;
}

- (NSTimeInterval)duration {
    return .76f;
}

- (void)pushTransitionAnimation {
    [super pushTransitionAnimation];
    
    /**先添加控制器*/
    [self.toView setHidden:NO];
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    [self.containerView insertSubview:self.toView belowSubview:self.fromView];
    
    UIView *fromViewSnapshot = [self.fromView transitionSnapshotView];
    if (self.fromView.tabBar_) [fromViewSnapshot addSubview:self.fromView.tabBar_];
    [self.containerView insertSubview:fromViewSnapshot aboveSubview:self.fromView];
    _fromViewSnapshot = fromViewSnapshot;
    
    UIView *maskSnapshot = [self.fromView snapshotImageViewWithRect:_rect];
    [maskSnapshot.layer setMaskRadius:MEAN(maskSnapshot.width_mn)];
    [self.containerView insertSubview:maskSnapshot aboveSubview:fromViewSnapshot];
    _maskSnapshot = maskSnapshot;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //设置遮罩
        CGPoint center = CGPointMake(CGRectGetMidX(_rect), CGRectGetMidY(_rect));
        CGFloat paddingX = MAX(center.x, self.toView.width_mn - center.x);
        CGFloat paddingY = MAX(center.y, self.toView.height_mn - center.y);
        
        CGFloat distance = sqrtf((paddingX*paddingX) + (paddingY*paddingY));
        UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:_rect];
        UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(_rect, -(distance - CGRectGetWidth(_rect)/2.f), -(distance - CGRectGetHeight(_rect)/2.f))];
        
        CAShapeLayer *toViewMaskLayer = [CAShapeLayer layer];
        toViewMaskLayer.path = startPath.CGPath;
        
        UIView *toViewSnapshot = [self.toView transitionSnapshotView];
        toViewSnapshot.layer.mask = toViewMaskLayer;
        [self.containerView insertSubview:toViewSnapshot belowSubview:maskSnapshot];
        _toViewSnapshot = toViewSnapshot;
        
        UIImage *toViewMaskImage = [UIImage imageWithLayer:self.toView.layer rect:_rect];
        //内容
        CABasicAnimation *contentsAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
        contentsAnimation.toValue = (id)toViewMaskImage.CGImage;
        contentsAnimation.duration = .4f;
        contentsAnimation.fillMode = kCAFillModeForwards;
        contentsAnimation.removedOnCompletion = NO;
        contentsAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        contentsAnimation.beginTime = CACurrentMediaTime();
        [maskSnapshot.layer addAnimation:contentsAnimation forKey:@"mask.snapshot.contents"];
        
        //Path
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.duration = (self.duration - .26f);
        pathAnimation.delegate = self;
        pathAnimation.toValue = (__bridge id)endPath.CGPath;
        pathAnimation.fillMode = kCAFillModeForwards;
        pathAnimation.removedOnCompletion = NO;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        pathAnimation.beginTime = CACurrentMediaTime();
        [pathAnimation setValue:kMaskAnimatorPathValue forKey:kMaskAnimatorPathKey];
        [toViewMaskLayer addAnimation:pathAnimation forKey:@"to.view.snapshot.path"];
    });
}

- (void)popTransitionAnimation {
    [super popTransitionAnimation];
    
    /**先添加控制器*/
    [self.toView setHidden:NO];
    self.toView.frame = [self.transitionContext finalFrameForViewController:self.toController];
    [self.containerView insertSubview:self.toView belowSubview:self.fromView];
    
    //设置遮罩
    CGPoint center = CGPointMake(CGRectGetMidX(_rect), CGRectGetMidY(_rect));
    CGFloat paddingX = MAX(center.x, self.fromView.width_mn - center.x);
    CGFloat paddingY = MAX(center.y, self.fromView.height_mn - center.y);
    
    CGFloat distance = sqrtf((paddingX*paddingX) + (paddingY*paddingY));
    UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(_rect, -(distance - CGRectGetWidth(_rect)/2.f), -(distance - CGRectGetHeight(_rect)/2.f))];
    UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:_rect];
    
    CAShapeLayer *fromViewMaskLayer = [CAShapeLayer layer];
    fromViewMaskLayer.path = startPath.CGPath;
    
    UIView *fromViewSnapshot = [self.fromView transitionSnapshotView];
    fromViewSnapshot.layer.mask = fromViewMaskLayer;
    [self.containerView insertSubview:fromViewSnapshot aboveSubview:self.fromView];
    _fromViewSnapshot = fromViewSnapshot;
    
    UIView *maskSnapshot = [self.fromView snapshotImageViewWithRect:_rect];
    [maskSnapshot.layer setMaskRadius:MEAN(maskSnapshot.width_mn)];
    [self.containerView insertSubview:maskSnapshot aboveSubview:fromViewSnapshot];
    _maskSnapshot = maskSnapshot;
    
    [self.fromView setHidden:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *toViewSnapshot = [self.toView transitionSnapshotView];
        [self.containerView insertSubview:toViewSnapshot belowSubview:self.fromView];
        _toViewSnapshot = toViewSnapshot;
        
        UIImage *toViewMaskImage = [UIImage imageWithLayer:self.toView.layer rect:_rect];
        
        //内容
        CABasicAnimation *contentsAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
        contentsAnimation.toValue = (id)toViewMaskImage.CGImage;
        contentsAnimation.duration = (self.duration - .26f);
        contentsAnimation.fillMode = kCAFillModeForwards;
        contentsAnimation.removedOnCompletion = NO;
        contentsAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        contentsAnimation.beginTime = CACurrentMediaTime();
        [maskSnapshot.layer addAnimation:contentsAnimation forKey:@"mask.snapshot.contents"];
        
        //Path
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.duration = (self.duration - .26f);
        pathAnimation.delegate = self;
        pathAnimation.toValue = (__bridge id)endPath.CGPath;
        pathAnimation.fillMode = kCAFillModeForwards;
        pathAnimation.removedOnCompletion = NO;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        pathAnimation.beginTime = CACurrentMediaTime();
        [pathAnimation setValue:kMaskAnimatorPathValue forKey:kMaskAnimatorPathKey];
        [fromViewMaskLayer addAnimation:pathAnimation forKey:@"to.view.snapshot.path"];
    });
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!flag) return;
    if ([[anim valueForKey:kMaskAnimatorPathKey] isEqualToString:kMaskAnimatorPathValue] ) {
        [_maskSnapshot removeFromSuperview];
        if (self.transitionOperation == MNControllerTransitionOperationPush) {
            [self restoreTabBarTransitionSnapshot];
        } else {
            [self finishTabBarTransitionAnimation];
        }
        [_fromViewSnapshot removeFromSuperview];
        [self.fromView removeFromSuperview];
        [self.toController mn_transition_viewWillAppear];
        [UIView animateWithDuration:.25f animations:^{
            _toViewSnapshot.alpha = 0.f;
        } completion:^(BOOL finished) {
            [_toViewSnapshot removeFromSuperview];
            [self completeTransitionAnimation];
        }];
    }
}


@end
