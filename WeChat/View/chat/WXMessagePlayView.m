//
//  WXMessagePlayView.m
//  MNChat
//
//  Created by Vincent on 2019/6/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMessagePlayView.h"

@interface WXMessagePlayView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *playView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@end

@implementation WXMessagePlayView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = self.width_mn/2.f;
        self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;
        
        UIImageView *playView = [UIImageView imageViewWithFrame:self.bounds image:[UIImage imageNamed:@"wx_video_play"]];
        playView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:playView];
        self.playView = playView;
        
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        contentView.layer.cornerRadius = contentView.width_mn/2.f;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.08f];
        contentView.layer.borderWidth = 2.f;
        contentView.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:.7f] CGColor];
        contentView.clipsToBounds = YES;
        contentView.alpha = 0.f;
        [self addSubview:contentView];
        self.contentView = contentView;
        
        CGFloat diameter = (contentView.width_mn - contentView.layer.borderWidth*2.f)/2.f;
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:contentView.bounds_center radius:diameter/2.f startAngle:-M_PI_2 endAngle:(M_PI + M_PI_2) clockwise:YES];
        CAShapeLayer *progressLayer = [CAShapeLayer layer];
        progressLayer.path = bezierPath.CGPath;
        progressLayer.fillColor = [[UIColor clearColor] CGColor];
        progressLayer.strokeColor = contentView.layer.borderColor;
        progressLayer.lineWidth = diameter;
        progressLayer.strokeEnd = 0.f;
        [contentView.layer addSublayer:progressLayer];
        self.progressLayer = progressLayer;
    }
    return self;
}

- (void)setType:(WXMessagePlayViewType)type {
    [self setType:type animated:YES];
}

- (void)setType:(WXMessagePlayViewType)type animated:(BOOL)animated {
    if (type == _type) return;
    _type = type;
    [UIView animateWithDuration:(animated ? .3f : 0.f) animations:^{
        self.contentView.alpha = type;
        self.playView.alpha = (1.f - type);
    }];
}

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    progress = MAX(0.f, MIN(progress, 1.f));
    _progress = progress;
    [CALayer animateWithDuration:(animated?.2f:0.f) animations:^{
        self.progressLayer.strokeEnd = progress;
    }];
    if (progress >= 1.f) {
        dispatch_after_main(.3f, ^{
            self.type = WXMessagePlayViewNormal;
        });
    }
}

@end
