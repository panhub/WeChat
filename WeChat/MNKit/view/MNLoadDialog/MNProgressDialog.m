//
//  MNProgressDialog.m
//  SQB_ScreenShot
//
//  Created by Vincent on 2019/2/19.
//  Copyright © 2019年 AiZhe. All rights reserved.
//

#import "MNProgressDialog.h"

#define kMNProgressLineWidth  2.f

@interface MNProgressDialog ()
@property (nonatomic, strong) UILabel *containerLabel;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *completeLayer;
@end

@implementation MNProgressDialog
- (void)createView {
    [super createView];
    
    self.containerView.size_mn = CGSizeMake(48.f, 48.f);
    [self.contentView addSubview:self.containerView];
    
    [self.contentView addSubview:self.textLabel];
    
    UILabel *containerLabel = [[UILabel alloc]initWithFrame:self.containerView.bounds];
    containerLabel.font = UIFontRegular(11.f);
    containerLabel.textColor = MNLoadDialogContentColor();
    containerLabel.textAlignment = NSTextAlignmentCenter;
    containerLabel.text = @"0%";
    [self.containerView addSubview:containerLabel];
    self.containerLabel = containerLabel;
    
    UIBezierPath *trackPath = [UIBezierPath bezierPathWithArcCenter:containerLabel.bounds_center
                                                             radius:(containerLabel.width_mn - kMNProgressLineWidth)/2.f
                                                         startAngle:0.f
                                                           endAngle:M_PI*2.f
                                                          clockwise:YES];
    CAShapeLayer *trackLayer = [CAShapeLayer layer];
    trackLayer.frame = containerLabel.bounds;
    trackLayer.path = [trackPath CGPath];
    trackLayer.fillColor = [[UIColor clearColor] CGColor];
    trackLayer.strokeColor = [[UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:.25f] CGColor];
    trackLayer.lineWidth = kMNProgressLineWidth;
    trackLayer.lineCap = kCALineCapButt;
    trackLayer.strokeEnd = 1.f;
    [containerLabel.layer addSublayer:trackLayer];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:containerLabel.bounds_center
                                                        radius:(containerLabel.width_mn - kMNProgressLineWidth)/2.f
                                                    startAngle:-M_PI_2
                                                      endAngle:M_PI + M_PI_2
                                                     clockwise:YES];
    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    progressLayer.frame = containerLabel.bounds;
    progressLayer.path = [path CGPath];
    progressLayer.fillColor = [[UIColor clearColor] CGColor];
    progressLayer.strokeColor = [MNLoadDialogContentColor() CGColor];
    progressLayer.lineWidth = kMNProgressLineWidth;
    progressLayer.lineCap = kCALineCapRound;
    progressLayer.strokeEnd = 0.f;
    [containerLabel.layer addSublayer:progressLayer];
    self.progressLayer = progressLayer;
    
    CGRect rect = UIEdgeInsetsInsetRect(containerLabel.bounds, UIEdgeInsetsMake(15.f, 10.f, 13.f, 10.f));
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(rect.origin.x, rect.origin.y + 9.f)];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))];
    
    CAShapeLayer *completeLayer = [CAShapeLayer layer];
    completeLayer.path = bezierPath.CGPath;
    completeLayer.fillColor = [UIColor clearColor].CGColor;
    completeLayer.strokeColor = [MNLoadDialogContentColor() CGColor];
    completeLayer.lineWidth = kMNProgressLineWidth;
    completeLayer.lineCap = kCALineCapRound;
    completeLayer.lineJoin = kCALineJoinRound;
    completeLayer.strokeEnd = 0.f;
    completeLayer.hidden = YES;
    [containerLabel.layer addSublayer:completeLayer];
    self.completeLayer = completeLayer;
    
    [self layoutSubviewIfNeeded];
}

- (BOOL)updateProgress:(float)progress {
    if (!self.superview || !_completeLayer.hidden) return NO;
    progress = MIN(MAX(progress, 0.f), 1.f);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _progressLayer.strokeEnd = progress;
    [CATransaction commit];
    _containerLabel.text = [NSString stringWithFormat:@"%@%%", [NSNumber numberWithUnsignedInteger:progress*100]];
    if (progress >= 1.f) {
        _completeLayer.hidden = NO;
        [self performSelector:@selector(performCompleteAnimation) withObject:nil afterDelay:.5f];
    }
    return YES;
}

- (void)dismiss {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(performCompleteAnimation) object:nil];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopAnimation) object:nil];
    [_progressLayer removeAllAnimations];
    [_completeLayer removeAllAnimations];
    [self removeFromSuperview];
}

- (void)performCompleteAnimation {
    _containerLabel.text = @"";
    if (self.message.length > 0) {
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@"完成"];
        [attributedText addAttributes:[self attributes] range: NSMakeRange(0, attributedText.length)];
        self.textLabel.attributedText = attributedText;
    }
    CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeAnimation.duration = .5f;
    strokeAnimation.fromValue = @(0.f);
    strokeAnimation.toValue = @(1.f);
    //这两个属性设定保证在动画执行之后不自动还原
    strokeAnimation.fillMode = kCAFillModeForwards;
    strokeAnimation.removedOnCompletion = NO;
    strokeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [_completeLayer addAnimation:strokeAnimation forKey:MNLoadDialogAnimationKey];
    [self performSelector:@selector(stopAnimation) withObject:nil afterDelay:1.f];
}

- (void)stopAnimation {
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:.2f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakself.contentView.alpha = 0.f;
        weakself.contentView.transform = CGAffineTransformMakeScale(0.95f, 0.95f);
    } completion:^(BOOL finished) {
         [weakself dismiss];
    }];
}

@end
