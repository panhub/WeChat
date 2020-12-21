//
//  MNCompleteDialog.m
//  MNKit
//
//  Created by Vincent on 2018/8/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNCompleteDialog.h"

#define kMNCompletedLineWidth      2.5f

@interface MNCompleteDialog ()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@end

@implementation MNCompleteDialog
- (void)createView {
    [super createView];
    
    self.containerView.size_mn = CGSizeMake(55.f, 31.f);
    [self.contentView addSubview:self.containerView];
    
    [self.contentView addSubview:self.textLabel];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(self.containerView.width_mn/6.f + kMNCompletedLineWidth/2.f, self.containerView.height_mn/3.f + kMNCompletedLineWidth/2.f)];
    [bezierPath addLineToPoint:CGPointMake(self.containerView.width_mn/2.f, self.containerView.height_mn - kMNCompletedLineWidth/2.f)];
    [bezierPath addLineToPoint:CGPointMake(self.containerView.width_mn - kMNCompletedLineWidth/2.f, kMNCompletedLineWidth/2.f)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.fillColor = UIColor.clearColor.CGColor;
    shapeLayer.strokeColor = MNLoadDialogContentColor().CGColor;
    shapeLayer.lineWidth = kMNCompletedLineWidth;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.strokeEnd = 0.f;
    [self.containerView.layer addSublayer:shapeLayer];
    self.shapeLayer = shapeLayer;
    
    [self layoutSubviewIfNeeded];
}

- (void)dismiss {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopAnimation) object:nil];
    [self.shapeLayer removeAllAnimations];
    [self removeFromSuperview];
}

- (void)startAnimation {
    CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeAnimation.duration = .5f;
    strokeAnimation.fromValue = @(0.f);
    strokeAnimation.toValue = @(1.f);
    //这两个属性设定保证在动画执行之后不自动还原
    strokeAnimation.fillMode = kCAFillModeForwards;
    strokeAnimation.removedOnCompletion = NO;
    strokeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [_shapeLayer addAnimation:strokeAnimation forKey:MNLoadDialogAnimationKey];
    [self performSelector:@selector(stopAnimation) withObject:nil afterDelay:1.5f];
}

- (void)stopAnimation {
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:.2f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakself.contentView.alpha = 0.f;
        weakself.contentView.transform = CGAffineTransformMakeScale(0.95f, 0.95f);
    } completion:^(BOOL finished) {
        [weakself removeFromSuperview];
    }];
}

@end
