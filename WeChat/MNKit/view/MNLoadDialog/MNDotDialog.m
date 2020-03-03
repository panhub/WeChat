//
//  MNDotDialog.m
//  MNKit
//
//  Created by Vincent on 2019/3/25.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNDotDialog.h"

#define kMNDotDialogInset  2.f
#define kMNDotDialogSize   10.5f
#define kMNDotDialogAnimationDuration  .9f

@interface MNDotDialog ()<CAAnimationDelegate>
{
    CGFloat _margin;
    CGFloat _animating;
}
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) CAAnimationGroup *leftGroupAnimation;
@property (nonatomic, strong) CAAnimationGroup *rightGroupAnimation;
@end

@implementation MNDotDialog
- (void)createView {
    [super createView];
    
    self.contentView.size_mn = CGSizeMake(30.f, 15.f);
    self.contentView.layer.cornerRadius = 0.f;
    
    self.containerView.frame = self.contentView.bounds;
    [self.contentView addSubview:self.containerView];
    
    CGFloat y = (self.containerView.height_mn - kMNDotDialogSize)/2.f;
    CGFloat x = (self.containerView.width_mn - kMNDotDialogSize*2.f - kMNDotDialogInset)/2.f;
    _margin = kMNDotDialogSize + kMNDotDialogInset;
    NSArray <UIColor *>*colors = @[UIColorWithRGBA(252.f, 46.f, 83.f, .85f), UIColorWithRGBA(35.f, 243.f, 237.f, .85f)];
    [colors enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake((kMNDotDialogSize + kMNDotDialogInset)*idx + x, y, kMNDotDialogSize, kMNDotDialogSize)];
        view.backgroundColor = color;
        view.layer.cornerRadius = view.height_mn/2.f;
        view.clipsToBounds = YES;
        [self.containerView addSubview:view];
        if (idx == 0) {
            self.leftView = view;
        } else {
            self.rightView = view;
        }
    }];
}

- (BOOL)updateMessage:(NSString *)message {
    return NO;
}

- (void)startAnimation {
    _animating = YES;
    [self.leftView.layer addAnimation:self.rightGroupAnimation forKey:MNLoadDialogAnimationKey];
    [self.rightView.layer addAnimation:self.leftGroupAnimation forKey:MNLoadDialogAnimationKey];
}

- (void)dismiss {
    _animating = NO;
    [self.leftView.layer removeAllAnimations];
    [self.rightView.layer removeAllAnimations];
    [self removeFromSuperview];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim {
    _animating = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!_animating) return;
    CGRect leftViewRect = self.leftView.frame;
    CGRect rightViewRect = self.rightView.frame;
    self.leftView.frame = rightViewRect;
    self.rightView.frame = leftViewRect;
    UIView *leftView = self.leftView.left_mn < self.rightView.left_mn ? self.leftView : self.rightView;
    UIView *rightView = leftView == self.leftView ? self.rightView : self.leftView;
    [self.containerView bringSubviewToFront:rightView];
    [leftView.layer addAnimation:self.rightGroupAnimation forKey:MNLoadDialogAnimationKey];
    [rightView.layer addAnimation:self.leftGroupAnimation forKey:MNLoadDialogAnimationKey];
}

#pragma mark - Getter
- (CAAnimationGroup *)leftGroupAnimation {
    if (!_leftGroupAnimation) {
        CAKeyframeAnimation *leftScale = [CAAnimation keyframeAnimationWithKeyPath:kCAScale duration:kMNDotDialogAnimationDuration values:@[@(1.f), @(1.3f), @(1.f)] keyTimes:@[@(0.f), @(kMNDotDialogAnimationDuration/2.f), @(kMNDotDialogAnimationDuration)]];
        leftScale.beginTime = 0.f;
        CAKeyframeAnimation *leftTranslation = [CAAnimation keyframeAnimationWithKeyPath:kCATranslationX duration:kMNDotDialogAnimationDuration values:@[@(0.f), @(-_margin)] keyTimes:@[@(0.f), @(kMNDotDialogAnimationDuration)]];
        leftTranslation.beginTime = 0.f;
        CAAnimationGroup *leftGroup = [CAAnimationGroup animation];
        leftGroup.repeatCount = 1.f;
        leftGroup.removedOnCompletion = NO;
        leftGroup.fillMode = kCAFillModeForwards;
        leftGroup.beginTime = 0.f;
        leftGroup.duration = kMNDotDialogAnimationDuration;
        leftGroup.delegate = self;
        leftGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        leftGroup.animations = @[leftScale, leftTranslation];
        _leftGroupAnimation = leftGroup;
    }
    return _leftGroupAnimation;
}

- (CAAnimationGroup *)rightGroupAnimation {
    if (!_rightGroupAnimation) {
        CAKeyframeAnimation *rightScale = [CAAnimation keyframeAnimationWithKeyPath:kCAScale duration:kMNDotDialogAnimationDuration values:@[@(1.f), @(.7f), @(1.f)] keyTimes:@[@(0.f), @(kMNDotDialogAnimationDuration/2.f), @(kMNDotDialogAnimationDuration)]];
        rightScale.beginTime = 0.f;
        CAKeyframeAnimation *rightTranslation = [CAAnimation keyframeAnimationWithKeyPath:kCATranslationX duration:kMNDotDialogAnimationDuration values:@[@(0.f), @(_margin)] keyTimes:@[@(0.f), @(kMNDotDialogAnimationDuration)]];
        rightTranslation.beginTime = 0.f;
        CAAnimationGroup *rightGroup = [CAAnimationGroup animation];
        rightGroup.repeatCount = 1.f;
        rightGroup.removedOnCompletion = NO;
        rightGroup.fillMode = kCAFillModeForwards;
        rightGroup.beginTime = 0.f;
        rightGroup.duration = kMNDotDialogAnimationDuration;
        rightGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        rightGroup.animations = @[rightScale, rightTranslation];
        _rightGroupAnimation = rightGroup;
    }
    return _rightGroupAnimation;
}

#pragma mark - rewrite
- (BOOL)blurEffectEnabled {
    return NO;
}

- (BOOL)motionEffectEnabled {
    return NO;
}

- (BOOL)interactionEnabled {
    return YES;
}

@end
