//
//  MNMaskDialog.m
//  MNKit
//
//  Created by Vincent on 2020/1/11.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNMaskDialog.h"

#define kMNMaskLineWidth   2.f

@interface MNMaskDialog ()
@property (nonatomic, strong) CALayer *gradientLayer;
@end

@implementation MNMaskDialog
- (void)createView {
    [super createView];
    
    self.containerView.top_mn = MNLoadDialogMargin;
    self.containerView.size_mn = CGSizeMake(43.f, 43.f);
    [self.contentView addSubview:self.containerView];
    
    [self.contentView addSubview:self.textLabel];

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:self.containerView.bounds_center
                                                        radius:(self.containerView.width_mn - kMNMaskLineWidth)/2.f
                                                    startAngle:(M_PI*3.f/2.f)
                                                      endAngle:(-M_PI_2)
                                                     clockwise:NO];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.containerView.bounds;
    shapeLayer.contentsScale = UIScreen.mainScreen.scale;
    shapeLayer.fillColor = UIColor.clearColor.CGColor;
    shapeLayer.strokeColor = MNLoadDialogContentColor().CGColor;
    shapeLayer.lineWidth = kMNMaskLineWidth;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.strokeStart = .4f;
    shapeLayer.strokeEnd = 1.f;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.containerView.bounds;
    gradientLayer.startPoint = CGPointMake(.5f, 0.f);
    gradientLayer.endPoint = CGPointMake(.5f, 1.f);
    gradientLayer.colors = [NSArray arrayWithObjects:
                                               (id)[MNLoadDialogContentColor() colorWithAlphaComponent:0.f].CGColor,
                                               (id)[MNLoadDialogContentColor() colorWithAlphaComponent:.5f].CGColor,
                                               (id)MNLoadDialogContentColor().CGColor,
                                               nil];
    gradientLayer.locations = [NSArray arrayWithObjects:@(.25f), @(.5f), @(1.f), nil];
    gradientLayer.mask = shapeLayer;
    [self.containerView.layer addSublayer:gradientLayer];
    self.gradientLayer = gradientLayer;
    
    [self layoutSubviewIfNeeded];
}

- (void)startAnimation {
    [self.gradientLayer addAnimation:[self rotationAnimation] forKey:MNLoadDialogAnimationKey];
}

- (void)dismiss {
    [self.gradientLayer removeAllAnimations];
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
