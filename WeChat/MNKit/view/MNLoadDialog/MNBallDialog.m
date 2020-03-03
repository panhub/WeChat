//
//  MNBallDialog.m
//  MNKit
//
//  Created by Vincent on 2018/8/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNBallDialog.h"

#define kMNLoadBallScale     1.4f
#define kMNLoadBallSize       7.f
#define kMNLoadBallAnimationDuration    2.8f

@interface MNBallDialog ()<CAAnimationDelegate>
@property (nonatomic, strong) UIView *leftBall;
@property (nonatomic, strong) UIView *rightBall;
@property (nonatomic, strong) UIView *centerBall;
@property (nonatomic, strong) CAKeyframeAnimation *leftAnimation;
@property (nonatomic, strong) CAKeyframeAnimation *rightAnimation;
@end

@implementation MNBallDialog
- (void)createView {
    
    self.containerView.size_mn = CGSizeMake(50.f, 50.f);
    [self.contentView addSubview:self.containerView];
    
    [self.contentView addSubview:self.textLabel];
    
    UIView *centerBall = [[UIView alloc] initWithFrame:CGRectMake((self.containerView.width_mn - kMNLoadBallSize)/2.f, (self.containerView.height_mn - kMNLoadBallSize)/2.f, kMNLoadBallSize, kMNLoadBallSize)];
    centerBall.layer.cornerRadius = kMNLoadBallSize/2.f;
    centerBall.backgroundColor = MNLoadDialogContentColor();
    [self.containerView addSubview:centerBall];
    _centerBall = centerBall;
    
    UIView *leftBall = [[UIView alloc]initWithFrame:CGRectMake(0.f, centerBall.top_mn, kMNLoadBallSize, kMNLoadBallSize)];
    leftBall.centerX_mn = kMNLoadBallSize*kMNLoadBallScale/2.f;
    leftBall.layer.cornerRadius = kMNLoadBallSize/2.f;
    leftBall.backgroundColor = MNLoadDialogContentColor();
    [self.containerView addSubview:leftBall];
    _leftBall = leftBall;
    
    UIView *rightBall = [[UIView alloc]initWithFrame:CGRectMake(self.containerView.width_mn - leftBall.right_mn, centerBall.top_mn, kMNLoadBallSize, kMNLoadBallSize)];
    rightBall.layer.cornerRadius = kMNLoadBallSize/2.f;
    rightBall.backgroundColor = MNLoadDialogContentColor();
    [self.containerView addSubview:rightBall];
    _rightBall = rightBall;
    
    [self layoutSubviewIfNeeded];
}

#pragma mark - 布局子视图
- (void)layoutSubviewIfNeeded {
    // layout textLabel
    self.containerView.top_mn = MNLoadDialogMargin;
    NSAttributedString *attributedString = self.attributedString;
    if ([self.textLabel.text isEqualToString:attributedString.string]) return;
    CGSize size = [attributedString sizeOfLimitWidth:MNLoadDialogMaxWidth - MNLoadDialogMargin*2.f];
    if (size.width <= 0.f) size.height = 0.f;
    CGFloat margin = size.width <= 0.f ? 0.f : 3.f;
    size.width = MAX(size.width, self.containerView.width_mn);
    self.textLabel.top_mn = self.containerView.bottom_mn + margin;
    self.textLabel.size_mn = size;
    self.textLabel.attributedText = attributedString;
    // layout contentView
    CGFloat width = size.width + MNLoadDialogMargin*2.f;
    CGFloat height = self.textLabel.bottom_mn + MNLoadDialogMargin;
    if (size.height < MNLoadDialogFontSize*2.f) width = MIN(MAX(width, height), MNLoadDialogMaxWidth);
    UIViewAutoresizing autoresizingMask = self.contentView.autoresizingMask;
    self.containerView.autoresizingMask = UIViewAutoresizingNone;
    self.contentView.frame = CGRectMake(0.f, 0.f, width, height);
    self.containerView.centerX_mn = self.textLabel.centerX_mn = self.contentView.width_mn/2.f;
    if (self.superview) self.contentView.center_mn = self.superview.layer.position;
    self.contentView.autoresizingMask = autoresizingMask;
}

- (void)startAnimation {
    [_leftBall.layer addAnimation:self.leftAnimation forKey:MNLoadDialogAnimationKey];
    [_rightBall.layer addAnimation:self.rightAnimation forKey:MNLoadDialogAnimationKey];
}

- (void)dismiss {
    _rightAnimation.delegate = nil;
    [_leftBall.layer removeAllAnimations];
    [_rightBall.layer removeAllAnimations];
    [_centerBall.layer removeAllAnimations];
    [self removeFromSuperview];
}

#pragma mark - CAKeyframeAnimation
- (CAKeyframeAnimation *)leftAnimation {
    if (!_leftAnimation) {
        CGFloat r = (kMNLoadBallSize*kMNLoadBallScale)/2.f; //小圆半径()
        CGFloat R = (self.containerView.width_mn/2.f + r)/2.f; //大圆半径
        //大圆运动路径
        UIBezierPath *leftPath = [UIBezierPath bezierPath];
        [leftPath moveToPoint:_leftBall.center_mn];
        [leftPath addArcWithCenter:CGPointMake(r + R, _leftBall.centerY_mn) radius:R startAngle:M_PI endAngle:M_PI*2.f clockwise:NO];
        //小圆运动路径
        UIBezierPath *leftPath_1 = [UIBezierPath bezierPath];
        [leftPath_1 addArcWithCenter:_centerBall.center_mn radius:r*2.f startAngle:M_PI*2.f endAngle:M_PI clockwise:NO];
        [leftPath appendPath:leftPath_1];
        [leftPath addLineToPoint:_leftBall.center_mn];
        //路径动画
        CAKeyframeAnimation *leftAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        leftAnimation.path = leftPath.CGPath;
        leftAnimation.removedOnCompletion = YES; //结束时回到原位, 位置本来就重叠
        leftAnimation.duration = kMNLoadBallAnimationDuration;
        leftAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _leftAnimation = leftAnimation;
    }
    return _leftAnimation;
}

- (CAKeyframeAnimation *)rightAnimation {
    if (!_rightAnimation) {
        CGFloat r = (kMNLoadBallSize*kMNLoadBallScale)/2.f; //小圆半径()
        CGFloat R = (self.containerView.width_mn/2.f + r)/2.f; //大圆半径
        //大圆运动路径
        UIBezierPath *rightPath = [UIBezierPath bezierPath];
        [rightPath moveToPoint:_rightBall.center_mn];
        [rightPath addArcWithCenter:CGPointMake(self.containerView.width_mn - (R + r), _rightBall.centerY_mn) radius:R startAngle:M_PI*2.f endAngle:M_PI clockwise:NO];
        //小圆运动路径
        UIBezierPath *rightPath_1 = [UIBezierPath bezierPath];
        [rightPath_1 addArcWithCenter:_centerBall.center_mn radius:r*2.f startAngle:M_PI endAngle:M_PI*2.f clockwise:NO];
        [rightPath appendPath:rightPath_1];
        [rightPath addLineToPoint:_rightBall.center_mn];
        //路径动画
        CAKeyframeAnimation *rightAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        rightAnimation.delegate = self;
        rightAnimation.path = rightPath.CGPath;
        rightAnimation.removedOnCompletion = YES; //结束时回到原位, 位置本来就重叠
        rightAnimation.duration = kMNLoadBallAnimationDuration;
        rightAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _rightAnimation = rightAnimation;
    }
    return _rightAnimation;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim {
    CGFloat delay = .5f;
    CGFloat duration = MEAN(kMNLoadBallAnimationDuration) - delay;
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseOut| UIViewAnimationOptionBeginFromCurrentState animations:^{
        _centerBall.transform = CGAffineTransformMakeScale(kMNLoadBallScale, kMNLoadBallScale);
        _leftBall.transform = CGAffineTransformMakeScale(kMNLoadBallScale, kMNLoadBallScale);
        _rightBall.transform = CGAffineTransformMakeScale(kMNLoadBallScale, kMNLoadBallScale);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut| UIViewAnimationOptionBeginFromCurrentState animations:^{
            _centerBall.transform = CGAffineTransformIdentity;
            _leftBall.transform = CGAffineTransformIdentity;
            _rightBall.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) [self startAnimation];
}

@end
