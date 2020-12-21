//
//  CALayer+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/3/8.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "CALayer+MNHelper.h"
#import "CALayer+MNLayout.h"

@implementation CALayer (MNHelper)

#pragma mark - 设置锚点<不改变相对位置>
- (void)setAnchorsite:(CGPoint)anchorsite {
    anchorsite.x = MIN(MAX(0.f, anchorsite.x), 1.f);
    anchorsite.y = MIN(MAX(0.f, anchorsite.y), 1.f);
    CGRect frame = self.frame;
    CGPoint point = self.anchorPoint;
    CGFloat xMargin = anchorsite.x - point.x;
    CGFloat yMargin = anchorsite.y - point.y;
    self.anchorPoint = anchorsite;
    CGPoint position = self.position;
    position.x += xMargin*frame.size.width;
    position.y += yMargin*frame.size.height;
    self.position = position;
}

- (CGPoint)anchorsite {
    return self.anchorPoint;
}

#pragma mark - 设置背景图片
- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (!backgroundImage) {
        self.contents = nil;
        return;
    }
    self.contents = (__bridge id)[backgroundImage CGImage];
}

- (UIImage *)backgroundImage {
    id contents = self.contents;
    if (!contents) return nil;
    return [UIImage imageWithCGImage:(__bridge CGImageRef)contents];
}

#pragma mark - 快速实例化
+ (CALayer *)layerWithFrame:(CGRect)frame image:(UIImage *)image {
    CALayer *layer = [self layer];
    layer.frame = frame;
    layer.contentsScale = [[UIScreen mainScreen] scale];
    if (!image) return layer;
    layer.contentsGravity = kCAGravityResizeAspect;
    layer.contents = (__bridge id)image.CGImage;
    layer.masksToBounds = YES;
    return layer;
}

#pragma mark - 设置圆角
- (void)setMaskRadius:(CGFloat)radius {
    [self setMaskRadius:radius byCorners:UIRectCornerAllCorners];
}

void CALayerSetMaskRadius (CALayer *layer, CGFloat radius) {
    [layer setMaskRadius:radius];
}

- (void)setMaskRadius:(CGFloat)radius byCorners:(UIRectCorner)corners {
    radius = MAX(radius, 0.f);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    self.mask = maskLayer;
}

#pragma mark - 边框颜色, 宽度
- (void)setBorderColor:(UIColor *)color width:(CGFloat)width {
    self.borderColor = color.CGColor;
    self.borderWidth = width;
}

void CALayerSetBorderColor (CALayer *layer, CGFloat width, UIColor *color) {
    [layer setBorderColor:color width:width];
}

#pragma mark - 获取边框
- (CAShapeLayer *)borderLayerWithLineWidth:(CGFloat)lineWidth byEdges:(UIRectEdge)edges {
    if (edges == UIRectEdgeNone) return nil;
    UIBezierPath *bezierPath;
    if (edges == UIRectEdgeAll) {
        bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(lineWidth/2.f, lineWidth/2.f, self.width_mn - lineWidth, self.height_mn - lineWidth)];
    } else {
        bezierPath = [UIBezierPath bezierPath];
        if ((edges & UIRectEdgeTop)) {
            [bezierPath moveToPoint:CGPointMake(0.f, lineWidth/2.f)];
            [bezierPath addLineToPoint:CGPointMake(self.width_mn, lineWidth/2.f)];
        }
        if ((edges & UIRectEdgeRight)) {
            [bezierPath moveToPoint:CGPointMake(self.width_mn - lineWidth/2.f, 0.f)];
            [bezierPath addLineToPoint:CGPointMake(self.width_mn - lineWidth/2.f, self.height_mn)];
        }
        if ((edges & UIRectEdgeBottom)) {
            [bezierPath moveToPoint:CGPointMake(self.width_mn, self.height_mn - lineWidth/2.f)];
            [bezierPath addLineToPoint:CGPointMake(0.f, self.height_mn - lineWidth/2.f)];
        }
        if ((edges & UIRectEdgeLeft)) {
            [bezierPath moveToPoint:CGPointMake(lineWidth/2.f, self.height_mn)];
            [bezierPath addLineToPoint:CGPointMake(lineWidth/2.f, 0.f)];
        }
    }
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = bezierPath.CGPath;
    layer.lineWidth = lineWidth;
    layer.fillColor = [[UIColor clearColor] CGColor];
    return layer;
}

#pragma mark - 删除所有子视图
- (void)removeAllSublayers {
    while (self.sublayers.count) {
        [self.sublayers.lastObject removeFromSuperlayer];
    }
}

@end
