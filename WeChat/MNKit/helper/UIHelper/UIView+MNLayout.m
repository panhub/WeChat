//
//  UIView+MNFrame.m
//  MNKit
//
//  Created by Vincent on 2017/10/19.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "UIView+MNLayout.h"

@implementation UIView (MNLayout)
- (CGPoint)origin_mn {
    return self.frame.origin;
}

- (void)setOrigin_mn:(CGPoint)origin_mn {
    CGRect frame = self.frame;
    frame.origin.x = origin_mn.x;
    frame.origin.y = origin_mn.y;
    [self setFrame:frame];
}

- (CGSize)size_mn {
    return self.frame.size;
}

- (void)setSize_mn:(CGSize)size_mn {
    CGRect frame = self.frame;
    frame.size.width = size_mn.width;
    frame.size.height = size_mn.height;
    [self setFrame:frame];
}

- (CGFloat)width_mn {
    return CGRectGetWidth(self.frame);
}

- (void)setWidth_mn:(CGFloat)width_mn {
    CGRect frame = self.frame;
    frame.size.width = width_mn;
    [self setFrame:frame];
}

- (CGFloat)height_mn {
    return CGRectGetHeight(self.frame);
}

- (void)setHeight_mn:(CGFloat)height_mn {
    CGRect frame = self.frame;
    frame.size.height = height_mn;
    [self setFrame:frame];
}

- (CGFloat)left_mn {
    return CGRectGetMinX(self.frame);
}

- (void)setLeft_mn:(CGFloat)left_mn {
    CGRect frame = self.frame;
    frame.origin.x = left_mn;
    [self setFrame:frame];
}

- (CGFloat)right_mn {
    return CGRectGetMaxX(self.frame);
}

- (void)setRight_mn:(CGFloat)right_mn {
    CGRect frame = self.frame;
    frame.origin.x = right_mn - CGRectGetWidth(frame);
    [self setFrame:frame];
}

- (CGFloat)top_mn {
    return CGRectGetMinY(self.frame);
}

- (void)setTop_mn:(CGFloat)top_mn {
    CGRect frame = self.frame;
    frame.origin.y = top_mn;
    [self setFrame:frame];
}

- (CGFloat)bottom_mn {
    return CGRectGetMaxY(self.frame);
}

- (void)setBottom_mn:(CGFloat)bottom_mn {
    CGRect frame = self.frame;
    frame.origin.y = bottom_mn - CGRectGetHeight(frame);
    [self setFrame:frame];
}

- (CGPoint)center_mn {
    return self.center;
}

- (void)setCenter_mn:(CGPoint)center_mn {
    [self setCenter:center_mn];
}

- (CGFloat)centerX_mn {
    return self.center_mn.x;
}

- (void)setCenterX_mn:(CGFloat)centerX_mn {
    CGPoint center = self.center;
    center.x = centerX_mn;
    [self setCenter:center];
}

- (CGFloat)centerY_mn {
    return self.center_mn.y;
}

- (void)setCenterY_mn:(CGFloat)centerY_mn {
    CGPoint center = self.center;
    center.y = centerY_mn;
    [self setCenter:center];
}

- (CGPoint)bounds_center {
    return CGPointMake((self.bounds.origin.x + self.bounds.size.width)/2.f, (self.bounds.origin.y +  self.bounds.size.height)/2.f);
}

#pragma mark - UIView & CALayer
inline CGFloat CGRectMinX(id obj) {
    if ([obj isKindOfClass:[UIView class]]) {
        return MinX((UIView *)obj);
    } else if ([obj isKindOfClass:[CALayer class]]) {
        return MinX((CALayer *)obj);
    }
    return 0.f;
}

inline CGFloat CGRectMinY(id obj) {
    if ([obj isKindOfClass:[UIView class]]) {
        return MinY((UIView *)obj);
    } else if ([obj isKindOfClass:[CALayer class]]) {
        return MinY((CALayer *)obj);
    }
    return 0.f;
}

inline CGFloat CGRectMaxX(id obj) {
    if ([obj isKindOfClass:[UIView class]]) {
        return MaxX((UIView *)obj);
    } else if ([obj isKindOfClass:[CALayer class]]) {
        return MaxX((CALayer *)obj);
    }
    return 0.f;
}

inline CGFloat CGRectMaxY(id obj) {
    if ([obj isKindOfClass:[UIView class]]) {
        return MaxY((UIView *)obj);
    } else if ([obj isKindOfClass:[CALayer class]]) {
        return MaxY((CALayer *)obj);
    }
    return 0.f;
}

inline CGFloat CGRectMidX(id obj) {
    if ([obj isKindOfClass:[UIView class]]) {
        return MidX((UIView *)obj);
    } else if ([obj isKindOfClass:[CALayer class]]) {
        return MidX((CALayer *)obj);
    }
    return 0.f;
}

inline CGFloat CGRectMidY(id obj) {
    if ([obj isKindOfClass:[UIView class]]) {
        return MidY((UIView *)obj);
    } else if ([obj isKindOfClass:[CALayer class]]) {
        return MidY((CALayer *)obj);
    }
    return 0.f;
}

inline CGFloat CGRectWidth(id obj) {
    if ([obj isKindOfClass:[UIView class]]) {
        return Width((UIView *)obj);
    } else if ([obj isKindOfClass:[CALayer class]]) {
        return Width((CALayer *)obj);
    }
    return 0.f;
}

inline CGFloat CGRectHeight(id obj) {
    if ([obj isKindOfClass:[UIView class]]) {
        return Height((UIView *)obj);
    } else if ([obj isKindOfClass:[CALayer class]]) {
        return Height((CALayer *)obj);
    }
    return 0.f;
}

inline CGFloat CGRectMidWidth(id obj) {
    if ([obj isKindOfClass:[UIView class]]) {
        return MidW((UIView *)obj);
    } else if ([obj isKindOfClass:[CALayer class]]) {
        return MidW((CALayer *)obj);
    }
    return 0.f;
}

inline CGFloat CGRectMidHeight(id obj) {
    if ([obj isKindOfClass:[UIView class]]) {
        return MidH((UIView *)obj);
    } else if ([obj isKindOfClass:[CALayer class]]) {
        return MidH((CALayer *)obj);
    }
    return 0.f;
}

@end
