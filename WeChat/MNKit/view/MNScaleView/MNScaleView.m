//
//  MNScaleView.m
//  MNKit
//
//  Created by Vincent on 2019/5/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNScaleView.h"

@interface MNScaleView ()
/// 所需弧度
@property (nonatomic) CGFloat angle;
/// 外环半径
@property (nonatomic) CGFloat outRadius;
/// 内环半径
@property (nonatomic) CGFloat innerRadius;
/// 刻度半径
@property (nonatomic) CGFloat scaleRadius;

@end

@implementation MNScaleView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _startAngle = 0.f;
        _endAngle = M_PI*2.f;
        _divide = 10;
        _subdivide = 10;
        _lineWidth = 1.f;
        _innerInterval = 5.f;
        _scaleInterval = 10.f;
        _scaleLinePer = 6;
        _scaleLineMinWidth = 4.f;
        _scaleLineMaxWidth = 12.f;
        _fillColor = [UIColor clearColor];
        _strokeColor = [UIColor whiteColor];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    /// 已经刻画刻度, 或者自身大小为0
    if (_angle > 0.f || self.width_mn + self.height_mn <= 0.f) return;
    [self createView];
}

- (void)createView {
    _angle = _endAngle - _startAngle;
    if (!_angle) return;
    _outRadius = (self.height_mn > self.width_mn ? (self.width_mn - self.lineWidth)/2.f : (self.height_mn - self.lineWidth)/2.f);
    _innerRadius = _outRadius - _innerInterval;
    _scaleRadius = _outRadius - _scaleInterval;
    
    /// 内外环
    UIBezierPath *outPath = [UIBezierPath bezierPathWithArcCenter:self.bounds_center
                                                           radius:_outRadius
                                                       startAngle:_startAngle
                                                         endAngle:_endAngle
                                                        clockwise:YES];
    CAShapeLayer *outLayer = [CAShapeLayer layer];
    outLayer.lineWidth = _lineWidth;
    outLayer.fillColor = _fillColor.CGColor;
    outLayer.strokeColor = _strokeColor.CGColor;
    outLayer.path = outPath.CGPath;
    outLayer.lineCap = kCALineCapRound;
    //if (self.tintColor) outLayer.fillColor = self.tintColor.CGColor;
    [self.layer addSublayer:outLayer];
    
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithArcCenter:self.bounds_center
                                                             radius:_innerRadius
                                                         startAngle:_startAngle
                                                           endAngle:_endAngle
                                                          clockwise:YES];
    CAShapeLayer *innerLayer = [CAShapeLayer layer];
    innerLayer.lineWidth = _lineWidth;;
    innerLayer.fillColor = _fillColor.CGColor;
    innerLayer.strokeColor = _strokeColor.CGColor;
    innerLayer.path = innerPath.CGPath;
    innerLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:innerLayer];
    
    /// 刻度
    NSInteger divide = _divide*_subdivide;
    if (divide <= 0) return;
    CGFloat perAngle = _angle/divide;
    for (NSInteger i = 0; i <= divide; i++) {
        CGFloat startAngle = (_startAngle + perAngle*i - perAngle/_scaleLinePer/2.f);
        CGFloat endAngle   = startAngle + perAngle/_scaleLinePer;
        UIBezierPath *perPath = [UIBezierPath bezierPathWithArcCenter:self.bounds_center
                                                               radius:_scaleRadius
                                                           startAngle:startAngle
                                                             endAngle:endAngle
                                                            clockwise:YES];
        CAShapeLayer *perLayer = [CAShapeLayer layer];
        perLayer.fillColor = [UIColor clearColor].CGColor;
        perLayer.strokeColor = _strokeColor.CGColor;
        perLayer.lineWidth = i%_subdivide == 0 ? _scaleLineMaxWidth : _scaleLineMinWidth;
        perLayer.path = perPath.CGPath;
        [self.layer addSublayer:perLayer];
    }
    
    /// 描述
    if (!self.detailViewHandler) return;
    CGFloat viewAngle = _angle/_divide;
    for (NSUInteger i = 0; i <= _divide; i++) {
        UIView *view;
        if (self.detailViewHandler) view = self.detailViewHandler(i);
        if (view) {
            CGPoint point = [self calculateLabelPositonWithAngle:-(_startAngle + viewAngle*i)];
            point.x -= view.width_mn/2.f;
            point.y -= view.height_mn/2.f;
            view.origin_mn = point;
            [self addSubview:view];
        }
    }
}

/// 默认计算半径
- (CGPoint)calculateLabelPositonWithAngle:(CGFloat)angel {
    CGFloat x = (_scaleRadius - _scaleLineMaxWidth - 2.f)*cosf(angel);
    CGFloat y = (_scaleRadius - _scaleLineMaxWidth - 2.f)*sinf(angel);
    CGPoint center = self.bounds_center;
    return CGPointMake(center.x + x, center.y - y);
}


@end
