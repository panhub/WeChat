//
//  MNErrorDialog.m
//  MNChat
//
//  Created by Vincent on 2020/1/13.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNErrorDialog.h"

#define kMNErrorLineWidth    2.f

@interface MNErrorDialog ()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@end

@implementation MNErrorDialog
- (void)createView {
    [super createView];
    
    self.containerView.size_mn = CGSizeMake(35.f, 35.f);
    [self.contentView addSubview:self.containerView];
    
    [self.contentView addSubview:self.textLabel];
    
    CGRect rect = UIEdgeInsetsInsetRect(self.containerView.bounds, UIEdgeInsetsMake(kMNErrorLineWidth/2.f, kMNErrorLineWidth/2.f, kMNErrorLineWidth/2.f, kMNErrorLineWidth/2.f));
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))];
    [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.fillColor = UIColor.clearColor.CGColor;
    shapeLayer.strokeColor = MNLoadDialogContentColor().CGColor;
    shapeLayer.lineWidth = kMNErrorLineWidth;
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
    [self performSelector:@selector(stopAnimation) withObject:nil afterDelay:1.f];
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
