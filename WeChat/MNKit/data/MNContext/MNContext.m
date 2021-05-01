//
//  MNContext.m
//  MNKit
//
//  Created by Vincent on 2019/8/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNContext.h"

@implementation MNContext
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithContext:(CGContextRef)context {
    return [self initWithContext:context config:nil];
}

- (instancetype)initWithConfig:(MNContextConfig *)config {
    return [self initWithContext:NULL config:config];
}

- (instancetype)initWithContext:(CGContextRef)context config:(MNContextConfig *)config {
    if (self = [self init]) {
        self.config = config;
        self.context = context;
    }
    return self;
}

- (void)useConfig:(MNContextConfig *)config {
    [self useConfig:config update:NO];
}

- (void)useConfig:(MNContextConfig *)config update:(BOOL)update {
    if (!config) return;
    if (update) self.config = config;
    CGContextSetLineWidth(_context, config.lineWidth);
    CGContextSetLineCap(_context, config.lineCap);
    CGContextSetLineJoin(_context, config.lineJoin);
    CGContextSetFillColorWithColor(_context, config.fillColor.CGColor);
    CGContextSetStrokeColorWithColor(_context, config.strokeColor.CGColor);
    CGContextSetLineDash(_context, config.phase, config.lengths, config.count);
}

- (void)moveToPoint:(CGPoint)point {
    CGContextMoveToPoint(_context, point.x, point.y);
}

- (void)addLineToPoint:(CGPoint)point {
    CGContextAddLineToPoint(_context, point.x, point.y);
}

- (void)addLinePoints:(NSArray <NSValue *>*)points {
    [points enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint point = obj.CGPointValue;
        if (idx == 0) {
            CGContextMoveToPoint(_context, point.x, point.y);
        } else {
            CGContextAddLineToPoint(_context, point.x, point.y);
        }
    }];
}

- (void)addQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint {
    CGContextAddQuadCurveToPoint(_context, controlPoint.x, controlPoint.y, endPoint.x, endPoint.y);
}

- (void)addCurveToPoint:(CGPoint)endPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2 {
    CGContextAddCurveToPoint(_context, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, endPoint.x, endPoint.y);
}

- (void)addRect:(CGRect)rect {
    CGContextAddRect(_context, rect);
}

- (void)addArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise {
    CGContextAddArc(_context, center.x, center.y, radius, startAngle, endAngle, clockwise);
}

- (void)drawStrokePathWithHandler:(MNContextDrawHandler)handler {
    [self drawStrokePathUseConfig:nil handler:handler];
}

- (void)drawStrokePathUseConfig:(MNContextConfig *)config handler:(MNContextDrawHandler)handler {
    if (!config) config = self.config;
    [self useConfig:config update:NO];
    [self beginPath];
    if (handler) {
        __weak typeof(self) weakself = self;
        handler(weakself);
    }
    [self strokePath];
}

- (void)drawFillPathWithHandler:(MNContextDrawHandler)handler {
    [self drawStrokePathUseConfig:self.config handler:handler];
}

- (void)drawFillPathUseConfig:(MNContextConfig *)config handler:(MNContextDrawHandler)handler {
    if (!config) config = self.config;
    [self useConfig:config update:NO];
    [self beginPath];
    if (handler) {
        __weak typeof(self) weakself = self;
        handler(weakself);
    }
    [self fillPath];
}

- (void)drawPathWithMode:(CGPathDrawingMode)drawingMode {
    CGContextDrawPath(_context, drawingMode);
}

- (void)drawString:(NSString *)string atPoint:(CGPoint)point withAttributes:(NSDictionary *)attributes {
    [string drawAtPoint:point withAttributes:attributes];
}

- (void)drawString:(NSString *)string inRect:(CGRect)rect withAttributes:(NSDictionary *)attributes {
    [string drawInRect:rect withAttributes:attributes];
}

- (void)drawAttributedString:(NSAttributedString *)string atPoint:(CGPoint)point {
    [string drawAtPoint:point];
}

- (void)drawAttributedString:(NSAttributedString *)string inRect:(CGRect)rect {
    [string drawInRect:rect];
}

- (void)drawImage:(UIImage *)image atPoint:(CGPoint)point {
    [image drawAtPoint:point];
}

- (void)drawImage:(UIImage *)image atPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha {
    [image drawAtPoint:point blendMode:blendMode alpha:alpha];
}

- (void)drawImage:(UIImage *)image inRect:(CGRect)rect {
    [image drawInRect:rect];
}

- (void)drawImage:(UIImage *)image inRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha {
    [image drawInRect:rect blendMode:blendMode alpha:alpha];
}

- (void)drawImage:(UIImage *)image asPatternInRect:(CGRect)rect {
    [image drawAsPatternInRect:rect];
}

- (void)setAlpha:(CGFloat)alpha {
    CGContextSetAlpha(_context, alpha);
}

- (void)setFillColor:(UIColor *)color inRect:(CGRect)rect {
    [color setFill];
    UIRectFill(rect);
}

- (void)beginPath {
    CGContextBeginPath(_context);
}

- (void)closePath {
    CGContextClosePath(_context);
}

- (void)strokePath {
    CGContextStrokePath(_context);
}

- (void)fillPath {
    CGContextFillPath(_context);
}

- (void)saveGState {
    CGContextSaveGState(_context);
}

- (void)restoreGState {
    CGContextRestoreGState(_context);
}

@end
