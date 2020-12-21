//
//  MNShapeDialog.m
//  MNKit
//
//  Created by Vincent on 2018/7/31.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNShapeDialog.h"

#define kMNShapeLineWidth    2.f

@interface MNShapeDialog ()<CAAnimationDelegate>
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) UIBezierPath *nextPath;
@property (nonatomic, strong) CAShapeLayer *rotateLayer;
@property (nonatomic, strong) CAAnimationGroup *groupAnimation;
@end

@implementation MNShapeDialog
- (void)initialized {
    _index = 0;
}

- (void)createView {
    [super createView];
    
    self.containerView.size_mn = CGSizeMake(43.f, 43.f);
    [self.contentView addSubview:self.containerView];
    
    [self.contentView addSubview:self.textLabel];
    
    CAShapeLayer *rotateLayer = [CAShapeLayer layer];
    rotateLayer.path = [[self cyclePath] CGPath];
    rotateLayer.fillColor = [[UIColor clearColor] CGColor];
    rotateLayer.strokeColor = [MNLoadDialogContentColor() CGColor];
    rotateLayer.lineWidth = kMNShapeLineWidth;
    rotateLayer.lineCap = kCALineCapRound;
    rotateLayer.strokeStart = 0.f;
    rotateLayer.strokeEnd = 0.f;
    [self.containerView.layer addSublayer:rotateLayer];
    self.rotateLayer = rotateLayer;
    
    [self layoutSubviewIfNeeded];
}

- (UIBezierPath*)cyclePath {
    NSInteger index = _index%3;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.containerView.bounds_center
                                                        radius:(self.containerView.width_mn - kMNShapeLineWidth)/2.f
                                                    startAngle:index*(M_PI*2)/3
                                                      endAngle:index*(M_PI*2)/3 + 2*M_PI*4/3
                                                     clockwise:YES];
    return path;
}

- (void)startAnimation {
    [super startAnimation];
    [_rotateLayer addAnimation:self.groupAnimation forKey:MNLoadDialogAnimationKey];
}

- (void)dismiss {
    [super dismiss];
    _groupAnimation.delegate = nil;
    [_rotateLayer removeAllAnimations];
    [self removeFromSuperview];
}

- (void)didEnterBackgroundNotification {
    [_rotateLayer removeAllAnimations];
}

- (void)willEnterForegroundNotification {
    if (!self.superview) return;
    _index = 0;
    _rotateLayer.strokeStart = 0.f;
    _rotateLayer.strokeEnd = 0.f;
    [_rotateLayer addAnimation:self.groupAnimation forKey:MNLoadDialogAnimationKey];
}

#pragma mark - CA动画对象
- (CAAnimationGroup *)groupAnimation {
    if (!_groupAnimation) {
        CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        strokeStartAnimation.fromValue = @(0.f);
        strokeStartAnimation.toValue = @(1.f);
        strokeStartAnimation.fillMode          = kCAFillModeForwards;
        strokeStartAnimation.removedOnCompletion = NO;
        strokeStartAnimation.timingFunction    = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CABasicAnimation *strokeEndAnimation   = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnimation.fromValue = @(0.f);
        strokeEndAnimation.toValue = @(1.f);
        strokeEndAnimation.fillMode = kCAFillModeForwards;
        strokeEndAnimation.removedOnCompletion = NO;
        strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        strokeEndAnimation.duration = 1.3f;
        
        CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
        groupAnimation.animations = @[strokeEndAnimation,strokeStartAnimation];
        groupAnimation.duration = 2.3f;
        groupAnimation.delegate  = self;
        groupAnimation.fillMode  = kCAFillModeForwards;
        groupAnimation.removedOnCompletion = NO;
        groupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _groupAnimation = groupAnimation;
    }
    return _groupAnimation;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished {
    if (finished) {
        _index++;
        _rotateLayer.path = [[self cyclePath] CGPath];
        [self startAnimation];
    }
}

- (void)dealloc {
    /// 有异议, 可能重复删除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
