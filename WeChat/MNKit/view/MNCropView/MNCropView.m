//
//  MNCropView.m
//  MNKit
//
//  Created by Vincent on 2019/11/11.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNCropView.h"

typedef NS_OPTIONS(NSInteger, MNCropBorder) {
    MNCropBorderNone = 0,
    MNCropBorderTop = 1 << 1,
    MNCropBorderBottom = 1 << 2,
    MNCropBorderLeft = 1 << 3,
    MNCropBorderRight = 1 << 4,
    MNCropBorderCenter = 1 << 5
};

#define MNCropTouchEdge 40.f

@interface MNCropView ()
@property (nonatomic) CGRect cropRect;
@property (nonatomic) CGFloat cornerWidth;
@property (nonatomic) MNCropBorder cropBorder;
@end

@implementation MNCropView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.scale = 0.f;
        self.borderWidth = 1.f;
        self.cropBorder = MNCropBorderNone;
        self.borderColor = UIColor.whiteColor;
        self.cornerColor = UIColor.whiteColor;
        self.fillColor = UIColor.clearColor;
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (CGRectIsEmpty(_cropRect)) return;
    
    // 填充边框区域颜色
    [self.fillColor setFill];
    UIRectFill(UIEdgeInsetsInsetRect(_cropRect, UIEdgeInsetWith(_borderWidth)));
    
    // 上下文设置
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
    
    // 边框
    CGContextSetLineWidth(context, _borderWidth);
    CGContextAddRect(context, UIEdgeInsetsInsetRect(_cropRect, UIEdgeInsetWith(_borderWidth/2.f)));
    CGContextStrokePath(context);
    
    // 边角
    CGContextSetStrokeColorWithColor(context, _cornerColor.CGColor);
    CGContextSetLineWidth(context, _cornerWidth);
    
    //左上
    CGContextMoveToPoint(context, _cropRect.origin.x + _cornerWidth/2.f + MNCropTouchEdge/2.f, _cropRect.origin.y + _cornerWidth/2.f);
    CGContextAddLineToPoint(context, _cropRect.origin.x + _cornerWidth/2.f, _cropRect.origin.y + _cornerWidth/2.f);
    CGContextAddLineToPoint(context, _cropRect.origin.x + _cornerWidth/2.f, _cropRect.origin.y + _cornerWidth/2.f + MNCropTouchEdge/2.f);
    //右上
    CGContextMoveToPoint(context, CGRectGetMaxX(_cropRect) - _cornerWidth/2.f - MNCropTouchEdge/2.f, _cropRect.origin.y + _cornerWidth/2.f);
    CGContextAddLineToPoint(context, CGRectGetMaxX(_cropRect) - _cornerWidth/2.f, _cropRect.origin.y + _cornerWidth/2.f);
    CGContextAddLineToPoint(context, CGRectGetMaxX(_cropRect) - _cornerWidth/2.f, _cropRect.origin.y + _cornerWidth/2.f + MNCropTouchEdge/2.f);
    //右下
    CGContextMoveToPoint(context, CGRectGetMaxX(_cropRect) - _cornerWidth/2.f, CGRectGetMaxY(_cropRect) - _cornerWidth/2.f - MNCropTouchEdge/2.f);
    CGContextAddLineToPoint(context, CGRectGetMaxX(_cropRect) - _cornerWidth/2.f, CGRectGetMaxY(_cropRect) - _cornerWidth/2.f);
    CGContextAddLineToPoint(context, CGRectGetMaxX(_cropRect) - _cornerWidth/2.f - MNCropTouchEdge/2.f, CGRectGetMaxY(_cropRect) - _cornerWidth/2.f);
    //左下
    CGContextMoveToPoint(context, _cropRect.origin.x + _cornerWidth/2.f + MNCropTouchEdge/2.f, CGRectGetMaxY(_cropRect) - _cornerWidth/2.f);
    CGContextAddLineToPoint(context, _cropRect.origin.x + _cornerWidth/2.f, CGRectGetMaxY(_cropRect) - _cornerWidth/2.f);
    CGContextAddLineToPoint(context, _cropRect.origin.x + _cornerWidth/2.f, CGRectGetMaxY(_cropRect) - _cornerWidth/2.f - MNCropTouchEdge/2.f);
    CGContextStrokePath(context);
    
    // 框内细线
    CGFloat lineWidth = _borderWidth/2.f;
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
    CGRect borderRect = UIEdgeInsetsInsetRect(_cropRect, UIEdgeInsetWith(_borderWidth/2.f));
    for (int i = 1; i < 3; i++) {
        CGFloat x = borderRect.origin.x + _borderWidth/2.f + (CGRectGetWidth(borderRect) - _borderWidth)/3.f*i;
        CGFloat y = borderRect.origin.y + _borderWidth/2.f + (CGRectGetHeight(borderRect) - _borderWidth)/3.f*i;
        CGContextMoveToPoint(context, x - lineWidth/2.f, borderRect.origin.y + _borderWidth/2.f);
        CGContextAddLineToPoint(context, x - lineWidth/2.f, CGRectGetMaxY(borderRect) - _borderWidth/2.f);
        CGContextMoveToPoint(context, borderRect.origin.x + _borderWidth/2.f, y - lineWidth/2.f);
        CGContextAddLineToPoint(context, CGRectGetMaxX(borderRect) - _borderWidth/2.f, y - lineWidth/2.f);
    }
    CGContextStrokePath(context);
    
    /*
     // 虚线
     CGFloat dottedLineWidth = _borderWidth/3.f*2.f;
     CGContextSetLineWidth(context, dottedLineWidth);
     CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
     for (int i = 1; i < 3; i++) {
     CGFloat x = borderRect.origin.x + _borderWidth/2.f + (CGRectGetWidth(borderRect) - _borderWidth)/3.f*i;
     CGFloat y = borderRect.origin.y + _borderWidth/2.f + (CGRectGetHeight(borderRect) - _borderWidth)/3.f*i;
     CGContextMoveToPoint(context, x - dottedLineWidth/2.f, borderRect.origin.y + _borderWidth/2.f);
     CGContextAddLineToPoint(context, x - dottedLineWidth/2.f, CGRectGetMaxY(borderRect) - _borderWidth/2.f);
     CGContextMoveToPoint(context, borderRect.origin.x + _borderWidth/2.f, y - dottedLineWidth/2.f);
     CGContextAddLineToPoint(context, CGRectGetMaxX(borderRect) - _borderWidth/2.f, y - dottedLineWidth/2.f);
     }
     CGFloat phase[] = {7, 7};
     CGContextSetLineDash(context, 0, phase, 2);
     CGContextDrawPath(context, kCGPathStroke);
     */
}

#pragma mark - Super
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 确定修改哪个边角
    CGPoint location = [touches.anyObject locationInView:self];
    if (CGRectIsEmpty(_cropRect) || CGRectContainsPoint(UIEdgeInsetsInsetRect(_cropRect, UIEdgeInsetWith(-MNCropTouchEdge/2.f)), location) == NO) {
        self.cropBorder = MNCropBorderNone;
    } /*else if (CGRectContainsPoint(UIEdgeInsetsInsetRect(_cropRect, UIEdgeInsetWith(MNCropTouchEdge/2.f)), location)) {
       self.cropBorder = MNCropBorderCenter;
       } */else if (CGRectContainsPoint(CGRectCenterSide(_cropRect.origin, MNCropTouchEdge), location)) {
           self.cropBorder = MNCropBorderTop|MNCropBorderLeft;
       } else if (CGRectContainsPoint(CGRectCenterSide(CGPointMake(CGRectGetMaxX(_cropRect), CGRectGetMinY(_cropRect)), MNCropTouchEdge), location)) {
           self.cropBorder = MNCropBorderTop|MNCropBorderRight;
       } else if (CGRectContainsPoint(CGRectCenterSide(CGPointMake(CGRectGetMaxX(_cropRect), CGRectGetMaxY(_cropRect)), MNCropTouchEdge), location)) {
           self.cropBorder = MNCropBorderBottom|MNCropBorderRight;
       } else if (CGRectContainsPoint(CGRectCenterSide(CGPointMake(CGRectGetMinX(_cropRect), CGRectGetMaxY(_cropRect)), MNCropTouchEdge), location)) {
           self.cropBorder = MNCropBorderBottom|MNCropBorderLeft;
       } else {
           self.cropBorder = MNCropBorderCenter;
       }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint location = [touch locationInView:self];
    CGPoint previous = [touch previousLocationInView:self];
    if (self.cropBorder == MNCropBorderNone || CGPointEqualToPoint(location, previous)) return;
    // 移动描述
    CGPoint translation = CGPointMake(location.x - previous.x, location.y - previous.y);
    // 位置移动
    if (self.cropBorder & MNCropBorderCenter) {
        _cropRect.origin.x += translation.x;
        _cropRect.origin.y += translation.y;
        if (_cropRect.origin.x <= 0.f) {
            _cropRect.origin.x = 0.f;
        } else if (CGRectGetMaxX(_cropRect) >= self.width_mn) {
            _cropRect.origin.x = self.width_mn - CGRectGetWidth(_cropRect);
        }
        if (_cropRect.origin.y <= 0.f) {
            _cropRect.origin.y = 0.f;
        } else if (CGRectGetMaxY(_cropRect) >= self.height_mn) {
            _cropRect.origin.y = self.height_mn - CGRectGetHeight(_cropRect);
        }
        [self setNeedsDisplay];
        return;
    }
    // 尺寸变化
    CGRect cropRect = _cropRect;
    CGFloat minInterval = MNCropTouchEdge + _cornerWidth;
    if (self.scale > 0.f) {
        // 按照比例裁剪
        CGFloat x = cropRect.origin.x;
        CGFloat y = cropRect.origin.y;
        CGFloat w = cropRect.size.width;
        CGFloat h = cropRect.size.height;
        if ((self.cropBorder & MNCropBorderTop) && (self.cropBorder & MNCropBorderLeft)) {
            // 左上角
            x += translation.x;
            w =  CGRectGetMaxX(cropRect) - x;
            if (translation.x != 0.f) {
                CGFloat diff = translation.x/self.scale;
                y += diff;
                h = CGRectGetMaxY(cropRect) - y;
            }
            if (x < 0.f) {
                x = 0.f;
                w = CGRectGetMaxX(cropRect);
                h = w/self.scale;
                y = CGRectGetMaxY(cropRect) - h;
            }
            if (y < 0.f) {
                y = 0.f;
                h = CGRectGetMaxY(cropRect);
                w = h*self.scale;
                x = CGRectGetMaxX(cropRect) - w;
            }
            if (x > (CGRectGetMaxX(cropRect) - minInterval) || y > (CGRectGetMaxY(cropRect) - minInterval)) return;
        } else if ((self.cropBorder & MNCropBorderBottom) && (self.cropBorder & MNCropBorderLeft)) {
            // 左下角
            x += translation.x;
            w =  CGRectGetMaxX(cropRect) - x;
            if (translation.x != 0.f) {
                h = w/self.scale;
            }
            if (x < 0.f) {
                x = 0.f;
                w =  CGRectGetMaxX(cropRect) - x;
                h = w/self.scale;
            }
            if ((y + h) > self.height_mn) {
                h = self.height_mn - y;
                w = h*self.scale;
                x = CGRectGetMaxX(cropRect) - w;
            }
            if (x > (CGRectGetMaxX(cropRect) - minInterval) || h < minInterval) return;
        } else if ((self.cropBorder & MNCropBorderTop) && (self.cropBorder & MNCropBorderRight)) {
            // 右上角
            w = w + translation.x;
            if (translation.x != 0.f) {
                CGFloat diff = translation.x/self.scale;
                y -= diff;
                h = CGRectGetMaxY(cropRect) - y;
            }
            if ((x + w) > self.width_mn) {
                w = self.width_mn - x;
                h = w/self.scale;
                y = CGRectGetMaxY(cropRect) - h;
            }
            if (y < 0.f) {
                y = 0.f;
                h = CGRectGetMaxY(cropRect);
                w = h*self.scale;
            }
            if (w < minInterval || y > (CGRectGetMaxY(cropRect) - minInterval)) return;
        } else {
            // 右下角
            w = w + translation.x;
            if (translation.x != 0.f) {
                h = w/self.scale;
            }
            if ((x + w) > self.width_mn) {
                w = self.width_mn - x;
                h = w/self.scale;
            }
            if ((y + h) > self.height_mn) {
                h = self.height_mn - y;
                w = h*self.scale;
            }
            if (w < minInterval || h < minInterval) return;
        }
        cropRect = CGRectMake(x, y, w, h);
    } else {
        // 自由裁剪
        if (self.cropBorder & MNCropBorderLeft) {
            cropRect.origin.x = MAX(MIN(CGRectGetMaxX(_cropRect) - minInterval, location.x), 0.f);
            cropRect.size.width = CGRectGetMaxX(_cropRect) - cropRect.origin.x;
        } else if (self.cropBorder & MNCropBorderRight) {
            cropRect.size.width = MIN(MAX(location.x - _cropRect.origin.x, minInterval), self.width_mn - _cropRect.origin.x);
        }
        if (self.cropBorder & MNCropBorderTop) {
            cropRect.origin.y = MAX(MIN(CGRectGetMaxY(_cropRect) - minInterval, location.y), 0.f);
            cropRect.size.height = CGRectGetMaxY(_cropRect) - cropRect.origin.y;
        } else if (self.cropBorder & MNCropBorderBottom) {
            cropRect.size.height = MIN(MAX(location.y - _cropRect.origin.y, minInterval), self.height_mn - _cropRect.origin.y);
        }
    }
    _cropRect = cropRect;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.cropBorder = MNCropBorderNone;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.cropBorder = MNCropBorderNone;
}

#pragma mark - Setter
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (CGRectIsEmpty(self.cropRect) && self.scale == 0.f) {
        self.cropRect = self.bounds;
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = MAX(borderWidth, 1.f);
    _cornerWidth = _borderWidth*2.f;
    [self setNeedsDisplay];
}

- (void)setBorderColor:(UIColor *)borderColor {
    if (!borderColor) borderColor = UIColor.clearColor;
    _borderColor = borderColor.copy;
    [self setNeedsDisplay];
}

- (void)setCornerColor:(UIColor *)cornerColor {
    if (!cornerColor) cornerColor = UIColor.clearColor;
    _cornerColor = cornerColor.copy;
    [self setNeedsDisplay];
}

- (void)setFillColor:(UIColor *)fillColor {
    if (!fillColor) fillColor = UIColor.clearColor;
    _fillColor = fillColor.copy;
    [self setNeedsDisplay];
}

- (void)setScale:(CGFloat)scale {
    if (self.width_mn <= 0.f || self.height_mn <= 0.f || isnan(scale)) return;
    scale = MAX(0.f, scale);
    _scale = scale;
    if (_scale == 0.f) {
        _cropRect = self.bounds;
    } else {
        CGSize size = CGSizeMake(scale, 1.f);
        if (self.width_mn >= self.height_mn) {
            size = CGSizeMultiplyToHeight(size, self.height_mn);
            if (size.width > self.width_mn) {
                size = CGSizeMultiplyToWidth(size, self.width_mn);
            }
        } else {
            size = CGSizeMultiplyToWidth(size, self.width_mn);
            if (size.height > self.height_mn) {
                size = CGSizeMultiplyToHeight(size, self.height_mn);
            }
        }
        _cropRect = CGRectCenterSize(self.bounds_center, size);
    }
    [self setNeedsDisplay];
}

@end
