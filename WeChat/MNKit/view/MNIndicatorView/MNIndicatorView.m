//
//  MNIndicatorView.m
//  MNKit
//
//  Created by Vincent on 2020/1/28.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNIndicatorView.h"
#import "UIView+MNLayout.h"
#import "CALayer+MNLayout.h"
#import "CALayer+MNAnimation.h"

#define MNIndicatorAnimationDuration  .2f
#define MNIndicatorAnimationKey  @"com.mn.indicator.animation.key"

@interface MNIndicatorView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAShapeLayer *animationLayer;
@end

@implementation MNIndicatorView
- (instancetype)init {
    return [self initWithFrame:CGRectMake(0.f, 0.f, 50.f, 50.f)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialized];
        [self createView];
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void)initialized {
    _lineWidth = .8f;
    _progress = .25f;
    _duration = 1.1f;
    _hidesUseAnimation = NO;
    _color = [UIColor colorWithRed:248.f/255.f green:248.f/255.f blue:255.f/255.f alpha:1.f];
    _lineColor = [UIColor colorWithRed:87.f/255.f green:106.f/255.f blue:149.f/255.f alpha:1.f];
}

- (void)createView {
    
    UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
    contentView.backgroundColor = UIColor.clearColor;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    CAShapeLayer *shapeLayer = CAShapeLayer.layer;
    shapeLayer.strokeEnd = 1.f;
    shapeLayer.strokeStart = 0.f;
    shapeLayer.lineCap = kCALineCapButt;
    shapeLayer.fillColor = UIColor.clearColor.CGColor;
    [contentView.layer addSublayer:shapeLayer];
    self.shapeLayer = shapeLayer;
    
    CAShapeLayer *animationLayer = CAShapeLayer.layer;
    animationLayer.fillColor = UIColor.clearColor.CGColor;
    animationLayer.strokeStart = 0.f;
    animationLayer.lineCap = kCALineCapButt;
    [animationLayer addAnimation:self.rotationAnimation forKey:MNIndicatorAnimationKey];
    [animationLayer pauseAnimation];
    
    [contentView.layer addSublayer:animationLayer];
    self.animationLayer = animationLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat radius = MIN(self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    
    self.shapeLayer.path = [UIBezierPath bezierPathWithArcCenter:self.contentView.bounds_center radius:(radius - self.lineWidth)/2.f startAngle:0.f endAngle:M_PI*2.f clockwise:YES].CGPath;
    self.shapeLayer.size_mn = CGSizeMake(radius, radius);
    self.shapeLayer.center_mn = self.contentView.bounds_center;
    self.shapeLayer.lineWidth = self.lineWidth;
    self.shapeLayer.strokeColor = self.color.CGColor;
    
    self.animationLayer.path = [UIBezierPath bezierPathWithArcCenter:self.contentView.bounds_center radius:(radius - self.lineWidth)/2.f startAngle:-M_PI_2 endAngle:M_PI_2*3.f clockwise:YES].CGPath;
    self.animationLayer.frame = self.shapeLayer.frame;
    self.animationLayer.strokeColor = self.lineColor.CGColor;
    self.animationLayer.lineWidth = self.lineWidth;
    self.animationLayer.strokeEnd = self.progress;
}

- (void)startAnimating {
    if (self.isAnimating) return;
    [self setAnimating:YES completion:nil];
}

- (void)stopAnimating {
    if (!self.isAnimating) return;
    [self setAnimating:NO completion:nil];
}

- (void)stopAnimatingWithHandler:(void (^)(void))endHandler {
    if (!self.isAnimating) return;
    [self setAnimating:NO completion:endHandler];
}

- (void)setAnimating:(BOOL)isAnimating completion:(void(^)(void))completion {
    if (isAnimating) [self.animationLayer resumeAnimation];
    CGFloat alpha = isAnimating ? 1.f : (self.isHidesWhenStopped ? 0.f : self.contentView.alpha);
    if (self.contentView.alpha == alpha) {
        if (!isAnimating) [self.animationLayer pauseAnimation];
        if (completion) completion();
        return;
    }
    if (self.isHidesUseAnimation) {
        [UIView animateWithDuration:MNIndicatorAnimationDuration animations:^{
            self.contentView.alpha = alpha;
        } completion:^(BOOL finished) {
            if (!isAnimating) [self.animationLayer pauseAnimation];
            if (completion) completion();
        }];
    } else {
        self.contentView.alpha = alpha;
        if (!isAnimating) [self.animationLayer pauseAnimation];
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
    if (hidesWhenStopped && !self.isAnimating) self.contentView.alpha = 0.f;
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
