//
//  MNRefreshFooter.m
//  WeChat
//
//  Created by Vicent on 2021/3/29.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "MNRefreshFooter.h"
#import "UIView+MNLayout.h"
#import "CALayer+MNAnimation.h"

#define radians(angle) ((angle)/180.f*M_PI)
#define WeChatRefreshFooterHeight  50.f
#define WeChatRefreshFooterMargin  MN_TAB_SAFE_HEIGHT

@interface MNRefreshFooter ()
@property (nonatomic, strong) CALayer *indicator;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *indicatorView;
@end

@implementation MNRefreshFooter
- (instancetype)init {
    return [self initWithType:MNRefreshFooterTypeMargin];
}

- (instancetype)initWithType:(MNRefreshFooterType)type {
    if (self = [super init]) {
        self.type = type;
        __weak typeof(self) weakself = self;
        self.endRefreshingCompletionBlock = ^{
            [weakself.indicator pauseAnimation];
        };
    }
    return self;
}

- (void)prepare {
    [super prepare];
    
    self.height_mn = MJRefreshFooterHeight + MN_TAB_SAFE_HEIGHT;
}

- (void)placeSubviews {
    
    self.textLabel.centerX_mn = self.width_mn/2.f;
    self.contentView.centerX_mn = self.width_mn/2.f;
    if (MN_TAB_SAFE_HEIGHT > 0.f) {
        self.textLabel.bottom_mn = self.height_mn - MN_TAB_SAFE_HEIGHT;
        self.contentView.bottom_mn = self.height_mn - MN_TAB_SAFE_HEIGHT;
    } else {
        self.textLabel.centerY_mn = self.height_mn/2.f;
        self.contentView.centerY_mn = self.height_mn/2.f;
    }
    
    [super placeSubviews];
}

#pragma mark - Super
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    self.textLabel.hidden = state != MJRefreshStateNoMoreData;
    self.contentView.hidden = !self.textLabel.isHidden;
    if (state == MJRefreshStateRefreshing) [self.indicator resumeAnimation];
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];
    if (!self.contentView.isHidden && self.state <= MJRefreshStatePulling && _scrollView.isDragging) {
        CGFloat offsetY = [change[NSKeyValueChangeNewKey] CGPointValue].y;
        CGFloat oldOffsetY = [change[NSKeyValueChangeOldKey] CGPointValue].y;
        self.indicatorView.transform = CGAffineTransformRotate(self.indicatorView.transform, radians(offsetY - oldOffsetY));
    }
}

#pragma mark - Setter
- (void)setText:(NSString *)text {
    self.textLabel.text = text;
    [self.textLabel sizeToFit];
}

#pragma mark - Getter
- (UIView *)contentView {
    if (!_contentView) {
        
        UIView *contentView = [UIView new];
        contentView.backgroundColor = UIColor.clearColor;
        contentView.size_mn = CGSizeMake(19.f, 19.f);
        [self addSubview:contentView];
        _contentView = contentView;
        
        UIView *indicatorView = [[UIView alloc] initWithFrame:contentView.bounds];
        indicatorView.backgroundColor = UIColor.clearColor;
        [contentView addSubview:indicatorView];
        _indicatorView = indicatorView;
        
        CALayer *indicator = CALayer.new;
        indicator.frame = indicatorView.bounds;
        indicator.contents = (__bridge id)[[MNBundle imageForResource:@"loading_mask" inDirectory:@"loading"] CGImage];
        [indicatorView.layer addSublayer:indicator];
        self.indicator = indicator;
        
        CGFloat lineWidth = 1.3f;
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:indicatorView.bounds_center
                                                            radius:(indicatorView.width_mn - lineWidth)/2.f
                                                        startAngle:(M_PI*3.f/2.f)
                                                          endAngle:(-M_PI_2)
                                                         clockwise:NO];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = indicatorView.bounds;
        maskLayer.contentsScale = UIScreen.mainScreen.scale;
        maskLayer.fillColor = UIColor.clearColor.CGColor;
        maskLayer.strokeColor = UIColor.blackColor.CGColor;
        maskLayer.lineWidth = lineWidth;
        maskLayer.lineCap = kCALineCapRound;
        maskLayer.lineJoin = kCALineJoinRound;
        maskLayer.path = bezierPath.CGPath;
        maskLayer.strokeStart = 0.05f;
        maskLayer.strokeEnd = .95f;
        
        indicator.mask = maskLayer;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.duration = .9f;
        animation.fromValue = @(0.f);
        animation.toValue = @(M_PI*2.f);
        animation.autoreverses = NO;
        animation.repeatCount = INFINITY;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.beginTime = CACurrentMediaTime();
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [indicator addAnimation:animation forKey:nil];
        
        [indicator pauseAnimation];
    }
    return _contentView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.hidden = YES;
        textLabel.text = @"暂无更多内容";
        textLabel.font = [UIFont systemFontOfSize:14.f];
        textLabel.textColor = [UIColor.darkGrayColor colorWithAlphaComponent:.7f];
        [textLabel sizeToFit];
        textLabel.hidden = self.state != MJRefreshStateNoMoreData;
        [self addSubview:textLabel];
        _textLabel = textLabel;
    }
    return _textLabel;
}

- (NSString *)text {
    return self.textLabel.text;
}

@end
