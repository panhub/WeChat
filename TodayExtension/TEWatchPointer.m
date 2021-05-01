//
//  WXWatchPointer.m
//  WeChat
//
//  Created by Vincent on 2019/5/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "TEWatchPointer.h"
#import "UIView+MNLayout.h"

@implementation TEWatchPointer

- (void)setType:(TEWatchPointerType)type {
    _type = type;
    [self createMaskLayer];
}

- (void)createMaskLayer {
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(self.width_mn/2.f, 0.f)];
    if (_type == TEWatchPointerHour) {
        [bezierPath addLineToPoint:CGPointMake(0.f, self.height_mn/3.f)];
        [bezierPath addLineToPoint:CGPointMake(2.5f, self.height_mn/3.f - 2.5f)];
        [bezierPath addQuadCurveToPoint:CGPointMake(2.5f, self.height_mn) controlPoint:CGPointMake(0.f, self.height_mn/3.f*2.f)];
        [bezierPath moveToPoint:CGPointMake(self.width_mn - 2.5f, self.height_mn)];
        [bezierPath addQuadCurveToPoint:CGPointMake(self.width_mn - 2.5f, self.height_mn/3.f - 2.5f) controlPoint:CGPointMake(self.width_mn, self.height_mn/3.f*2.f)];
        [bezierPath addLineToPoint:CGPointMake(self.width_mn, self.height_mn/3.f)];
        [bezierPath addLineToPoint:CGPointMake(self.width_mn/2.f, 0.f)];
    } else {
        [bezierPath addQuadCurveToPoint:CGPointMake(2.5f, self.height_mn) controlPoint:CGPointMake(0.f, self.height_mn/3.f*2.f)];
        [bezierPath addLineToPoint:CGPointMake(self.width_mn - 2.5f, self.height_mn)];
        [bezierPath addQuadCurveToPoint:CGPointMake(self.width_mn/2.f, 0.f) controlPoint:CGPointMake(self.width_mn, self.height_mn/3.f*2.f)];
    }
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = bezierPath.CGPath;
    maskLayer.fillColor = [[UIColor whiteColor] CGColor];
    self.layer.mask = maskLayer;
}

@end
