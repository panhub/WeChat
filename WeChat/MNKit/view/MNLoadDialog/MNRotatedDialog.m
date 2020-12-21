//
//  MNRotatedDialog.m
//  MNKit
//
//  Created by Vincent on 2019/1/7.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNRotatedDialog.h"

#define kMNRotatedLineWidth    2.f

@interface MNRotatedDialog ()
@property (nonatomic, strong) CALayer *rotateLayer;
@end

@implementation MNRotatedDialog
- (void)createView {
    [super createView];

    self.containerView.size_mn = CGSizeMake(43.f, 43.f);
    [self.contentView addSubview:self.containerView];
    
    [self.contentView addSubview:self.textLabel];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.containerView.bounds_center
                                                        radius:(self.containerView.width_mn - kMNRotatedLineWidth)/2.f
                                                    startAngle:0
                                                      endAngle:M_PI*2.f
                                                     clockwise:YES];
    
    CAShapeLayer *rotateLayer = [CAShapeLayer layer];
    rotateLayer.frame = self.containerView.bounds;
    rotateLayer.path = [path CGPath];
    rotateLayer.fillColor = [[UIColor clearColor] CGColor];
    rotateLayer.strokeColor = [MNLoadDialogContentColor() CGColor];
    rotateLayer.lineWidth = kMNRotatedLineWidth;
    rotateLayer.lineCap = kCALineCapRound;
    rotateLayer.strokeStart = 0.f;
    rotateLayer.strokeEnd = .9f;
    [self.containerView.layer addSublayer:rotateLayer];
    self.rotateLayer = rotateLayer;
    
    [self layoutSubviewIfNeeded];
}

- (void)startAnimation {
    [self.rotateLayer addAnimation:[self rotationAnimation] forKey:MNLoadDialogAnimationKey];
}

- (void)dismiss {
    [self.rotateLayer removeAllAnimations];
    [self removeFromSuperview];
}

- (CABasicAnimation *)rotationAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.duration = 1.f;
    animation.fromValue = @(0.f);
    animation.toValue = @(M_PI*2.f);
    animation.autoreverses = NO;
    animation.repeatCount = INFINITY;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.beginTime = CACurrentMediaTime();
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    return animation;
}

@end
