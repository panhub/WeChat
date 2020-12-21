//
//  MNAssetProgressView.m
//  MNKit
//
//  Created by Vincent on 2019/6/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetProgressView.h"

@interface MNAssetProgressView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@end

@implementation MNAssetProgressView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.35f];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 38.f, 38.f)];
        contentView.center_mn = self.bounds_center;
        contentView.backgroundColor = [UIColor clearColor];
        contentView.layer.cornerRadius = contentView.width_mn/2.f;
        contentView.layer.borderWidth = 1.5f;
        contentView.layer.borderColor = [[[UIColor whiteColor] colorWithAlphaComponent:.7f] CGColor];
        contentView.clipsToBounds = YES;
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

- (void)setProgress:(double)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(double)progress animated:(BOOL)animated {
    _progress = progress;
    [CALayer animateWithDuration:(animated?.2f:0.f) animations:^{
        self.progressLayer.strokeEnd = progress;
    }];
}

#pragma mark - 阻挡交互传递
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

@end
