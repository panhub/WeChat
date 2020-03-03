//
//  UIView+MNFrame.m
//  MNKit
//
//  Created by Vincent on 2017/10/19.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "UIView+TEFrame.h"

@implementation UIView (TEFrame)
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

- (void)setAnchorsite:(CGPoint)anchorsite {
    anchorsite.x = MIN(MAX(0.f, anchorsite.x), 1.f);
    anchorsite.y = MIN(MAX(0.f, anchorsite.y), 1.f);
    CGRect frame = self.frame;
    CGPoint point = self.layer.anchorPoint;
    CGFloat xMargin = anchorsite.x - point.x;
    CGFloat yMargin = anchorsite.y - point.y;
    self.layer.anchorPoint = anchorsite;
    CGPoint position = self.layer.position;
    position.x += xMargin*frame.size.width;
    position.y += yMargin*frame.size.height;
    self.layer.position = position;
}

- (CGPoint)anchorsite {
    return CGPointZero;
}

@end
