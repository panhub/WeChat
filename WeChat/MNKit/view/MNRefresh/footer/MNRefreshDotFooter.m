//
//  MNRefreshDotFooter.m
//  KPoint
//
//  Created by Vincent on 2019/8/28.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNRefreshDotFooter.h"

@interface MNRefreshDotFooter ()<CAAnimationDelegate>
{
    CGFloat _margin;
    CGFloat _animating;
}
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) CAAnimationGroup *leftGroupAnimation;
@property (nonatomic, strong) CAAnimationGroup *rightGroupAnimation;
@end

#define KPRefreshDotSize    10.5f
#define KPRefreshDotInset    2.f
#define KPRefreshAnimationDuration    .9f
#define KPRefreshAnimationKey    @"com.mn.refresh.animation.key"

@implementation MNRefreshDotFooter
- (instancetype)init {
    if (self = [super init]) {
        @weakify(self);
        self.didEndRefreshingCallback = ^{
            @strongify(self);
            self->_animating = NO;
            [self.leftView.layer removeAllAnimations];
            [self.rightView.layer removeAllAnimations];
            [self layoutViews];
        };
    }
    return self;
}

- (void)prepare
{
    [super prepare];
}

- (void)placeSubviews
{
    [super placeSubviews];
    [self layoutViews];
}

- (void)layoutViews {
    
    self.textLabel.hidden = self.state != MJRefreshStateNoMoreData;
    self.leftView.hidden = self.rightView.hidden = self.state == MJRefreshStateNoMoreData;
    
    UIView *leftView = self.leftView.left_mn <= self.rightView.left_mn ? self.leftView : self.rightView;
    UIView *rightView = leftView == self.leftView ? self.rightView : self.leftView;
    CGFloat x = (self.contentView.width_mn - leftView.width_mn - rightView.width_mn - KPRefreshDotInset)/2.f;
    
    leftView.left_mn = x;
    rightView.left_mn = leftView.right_mn + KPRefreshDotInset;
    
    leftView.centerY_mn = rightView.centerY_mn = self.contentView.height_mn/2.f;
    
    _margin = leftView.width_mn + KPRefreshDotInset;
    
    [self.contentView bringSubviewToFront:rightView];
}

#pragma mark - Setter
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    if (state == MJRefreshStateRefreshing && !_animating && self.textLabel.hidden) {
        /// 开始动画
        UIView *leftView = self.leftView.left_mn < self.rightView.left_mn ? self.leftView : self.rightView;
        UIView *rightView = leftView == self.leftView ? self.rightView : self.leftView;
        [self.contentView bringSubviewToFront:rightView];
        [leftView.layer addAnimation:self.rightGroupAnimation forKey:KPRefreshAnimationKey];
        [rightView.layer addAnimation:self.leftGroupAnimation forKey:KPRefreshAnimationKey];
    }
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
    [self.contentView bringSubviewToFront:rightView];
    [leftView.layer addAnimation:self.rightGroupAnimation forKey:KPRefreshAnimationKey];
    [rightView.layer addAnimation:self.leftGroupAnimation forKey:KPRefreshAnimationKey];
}

#pragma mark - Getter
- (UIView *)contentView {
    if (!_contentView) {
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        contentView.backgroundColor = [UIColor clearColor];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_contentView = contentView];
    }
    return _contentView;
}

- (UIView *)leftView {
    if (!_leftView) {
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, KPRefreshDotSize, KPRefreshDotSize)];
        leftView.backgroundColor = UIColorWithRGBA(252.f, 46.f, 83.f, .85f);
        leftView.layer.cornerRadius = KPRefreshDotSize/2.f;
        leftView.clipsToBounds = YES;
        [self.contentView addSubview:_leftView = leftView];
    }
    return _leftView;
}

- (UIView *)rightView {
    if (!_rightView) {
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, KPRefreshDotSize, KPRefreshDotSize)];
        rightView.backgroundColor = UIColorWithRGBA(35.f, 243.f, 237.f, .85f);
        rightView.layer.cornerRadius = KPRefreshDotSize/2.f;
        rightView.clipsToBounds = YES;
        [self.contentView addSubview:_rightView = rightView];
    }
    return _rightView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        UILabel *textLabel = [UILabel labelWithFrame:self.contentView.bounds text:@"~人家是有底线的~" alignment:NSTextAlignmentCenter textColor:UIColorWithSingleRGB(220.f) font:UIFontRegular(15.f)];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_textLabel = textLabel];
    }
    return _textLabel;
}

- (CAAnimationGroup *)leftGroupAnimation {
    if (!_leftGroupAnimation) {
        CAKeyframeAnimation *leftScale = [CAAnimation keyframeAnimationWithKeyPath:kCAScale duration:KPRefreshAnimationDuration values:@[@(1.f), @(1.3f), @(1.f)] keyTimes:@[@(0.f), @(KPRefreshAnimationDuration/2.f), @(KPRefreshAnimationDuration)]];
        leftScale.beginTime = 0.f;
        CAKeyframeAnimation *leftTranslation = [CAAnimation keyframeAnimationWithKeyPath:kCATranslationX duration:KPRefreshAnimationDuration values:@[@(0.f), @(-_margin)] keyTimes:@[@(0.f), @(KPRefreshAnimationDuration)]];
        leftTranslation.beginTime = 0.f;
        CAAnimationGroup *leftGroup = [CAAnimationGroup animation];
        leftGroup.repeatCount = 1.f;
        leftGroup.removedOnCompletion = NO;
        leftGroup.fillMode = kCAFillModeForwards;
        leftGroup.beginTime = 0.f;
        leftGroup.duration = KPRefreshAnimationDuration;
        leftGroup.delegate = self;
        leftGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        leftGroup.animations = @[leftScale, leftTranslation];
        _leftGroupAnimation = leftGroup;
    }
    return _leftGroupAnimation;
}

- (CAAnimationGroup *)rightGroupAnimation {
    if (!_rightGroupAnimation) {
        CAKeyframeAnimation *rightScale = [CAAnimation keyframeAnimationWithKeyPath:kCAScale duration:KPRefreshAnimationDuration values:@[@(1.f), @(.7f), @(1.f)] keyTimes:@[@(0.f), @(KPRefreshAnimationDuration/2.f), @(KPRefreshAnimationDuration)]];
        rightScale.beginTime = 0.f;
        CAKeyframeAnimation *rightTranslation = [CAAnimation keyframeAnimationWithKeyPath:kCATranslationX duration:KPRefreshAnimationDuration values:@[@(0.f), @(_margin)] keyTimes:@[@(0.f), @(KPRefreshAnimationDuration)]];
        rightTranslation.beginTime = 0.f;
        CAAnimationGroup *rightGroup = [CAAnimationGroup animation];
        rightGroup.repeatCount = 1.f;
        rightGroup.removedOnCompletion = NO;
        rightGroup.fillMode = kCAFillModeForwards;
        rightGroup.beginTime = 0.f;
        rightGroup.duration = KPRefreshAnimationDuration;
        rightGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        rightGroup.animations = @[rightScale, rightTranslation];
        _rightGroupAnimation = rightGroup;
    }
    return _rightGroupAnimation;
}

#pragma mark - dealloc
- (void)dealloc {
    _animating = NO;
    [_leftView.layer removeAllAnimations];
    [_rightView.layer removeAllAnimations];
}

@end
