//
//  MNIndicatorView.m
//  MNKit
//
//  Created by Vincent on 2020/1/28.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNIndicatorView.h"
#import "CALayer+MNAnimation.h"

#define MNIndicatorAnimationKey         @"com.mn.indicator.animation.key"
#define MNIndicatorAnimationDuration  .2f

@interface MNIndicatorView ()
/**背景轨迹*/
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
/**动画轨迹*/
@property (nonatomic, strong) CAShapeLayer *animationLayer;
@end

@implementation MNIndicatorView
- (instancetype)init {
    return [self initWithFrame:CGRectMake(0.f, 0.f, 60.f, 60.f)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialization];
        [self makeLayer];
    }
    return self;
}

- (void)initialization {
    _lineWidth = .8f;
    _progress = .25f;
    _duration = 1.1f;
    _hidesUseAnimation = NO;
    _color = [UIColor colorWithRed:248.f/255.f green:248.f/255.f blue:255.f/255.f alpha:1.f];
    _lineColor = [UIColor colorWithRed:87.f/255.f green:106.f/255.f blue:149.f/255.f alpha:1.f];
}

- (void)makeLayer {
    
    CAShapeLayer *backgroundLayer = CAShapeLayer.layer;
    backgroundLayer.fillColor = UIColor.clearColor.CGColor;
    backgroundLayer.strokeStart = 0.f;
    backgroundLayer.strokeEnd = 1.f;
    backgroundLayer.lineCap = kCALineCapButt;
    [self.layer addSublayer:backgroundLayer];
    self.backgroundLayer = backgroundLayer;
    
    CAShapeLayer *animationLayer = CAShapeLayer.layer;
    animationLayer.fillColor = UIColor.clearColor.CGColor;
    animationLayer.strokeStart = 0.f;
    animationLayer.lineCap = kCALineCapButt;
    [animationLayer addAnimation:self.rotationAnimation forKey:MNIndicatorAnimationKey];
    [animationLayer pauseAnimation];
    
    [self.layer addSublayer:animationLayer];
    self.animationLayer = animationLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height);
    
    self.backgroundLayer.path = [UIBezierPath bezierPathWithArcCenter:self.bounds_center radius:(radius - self.lineWidth)/2.f startAngle:0.f endAngle:M_PI*2.f clockwise:YES].CGPath;
    self.backgroundLayer.size_mn = CGSizeMake(radius, radius);
    self.backgroundLayer.center_mn = self.bounds_center;
    self.backgroundLayer.lineWidth = self.lineWidth;
    self.backgroundLayer.strokeColor = self.color.CGColor;
    
    self.animationLayer.path = [UIBezierPath bezierPathWithArcCenter:self.bounds_center radius:(radius - self.lineWidth)/2.f startAngle:-M_PI_2 endAngle:M_PI_2*3.f clockwise:YES].CGPath;
    self.animationLayer.frame = self.backgroundLayer.frame;
    self.animationLayer.strokeColor = self.lineColor.CGColor;
    self.animationLayer.lineWidth = self.lineWidth;
    self.animationLayer.strokeEnd = self.progress;
}

- (void)startAnimating {
    if (self.isAnimating) return;
    [self makeAnimating:YES completion:nil];
}

- (void)stopAnimating {
    [self stopAnimatingWithHandler:nil];
}

- (void)stopAnimatingWithHandler:(void (^)(void))endHandler {
    if (!self.isAnimating) return;
    [self makeAnimating:NO completion:endHandler];
}

- (void)makeAnimating:(BOOL)isAnimating completion:(void(^)(void))completion {
    if (isAnimating) {
        [self.animationLayer resumeAnimation];
    } else if (!self.isHidesWhenStopped || !self.isHidesUseAnimation) {
        [self.animationLayer pauseAnimation];
    }
    if (!self.isHidesWhenStopped) return;
    BOOL alpha = isAnimating ? 1.f : 0.f;
    if (self.isHidesUseAnimation) {
        [UIView animateWithDuration:MNIndicatorAnimationDuration animations:^{
            self.alpha = alpha;
        } completion:^(BOOL finished) {
            if (!isAnimating) [self.animationLayer pauseAnimation];
            if (completion) completion();
        }];
    } else {
        self.alpha = alpha;
        if (completion) completion();
    }
}

#pragma mark - Setter
- (void)setLineWidth:(CGFloat)lineWidth {
    lineWidth = MAX(lineWidth, .5f);
    if (lineWidth == _lineWidth) return;
    _lineWidth = lineWidth;
    [self setNeedsLayout];
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor.copy;
    [self setNeedsLayout];
}

- (void)setProgress:(float)progress {
    progress = MAX(MIN(progress, 1.f), 0.f);
    if (progress == _progress) return;
    _progress = progress;
    [self setNeedsLayout];
}

- (void)setColor:(UIColor *)color {
    _color = color.copy;
    [self setNeedsLayout];
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
    _hidesWhenStopped = hidesWhenStopped;
    if (hidesWhenStopped) self.alpha = self.isAnimating ? 1.f : 0.f;
}

#pragma mark - Getter
- (BOOL)isAnimating {
    return self.animationLayer.speed == 1.f;
}

- (CABasicAnimation *)rotationAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.duration = MAX(self.duration, CGFLOAT_MIN);
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
