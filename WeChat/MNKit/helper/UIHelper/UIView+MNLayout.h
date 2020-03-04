//
//  UIView+MNFrame.h
//  MNKit
//
//  Created by Vincent on 2017/10/19.
//  Copyright © 2017年 小斯. All rights reserved.
//  view.frame

#import <UIKit/UIKit.h>

#define MinX(v)                 CGRectGetMinX((v).frame)
#define MinY(v)                 CGRectGetMinY((v).frame)
#define MaxX(v)                CGRectGetMaxX((v).frame)
#define MaxY(v)                CGRectGetMaxY((v).frame)
#define MidX(v)                 CGRectGetMidX((v).frame)
#define MidY(v)                 CGRectGetMidY((v).frame)
#define Width(v)                CGRectGetWidth((v).frame)
#define Height(v)               CGRectGetHeight((v).frame)
#define MidW(v)                (Width(v)/2.f)
#define MidH(v)                 (Height(v)/2.f)

@interface UIView (MNLayout)

@property (nonatomic) CGFloat left_mn;
@property (nonatomic) CGFloat right_mn;
@property (nonatomic) CGFloat top_mn;
@property (nonatomic) CGFloat bottom_mn;
@property (nonatomic) CGPoint center_mn;
@property (nonatomic) CGFloat centerX_mn;
@property (nonatomic) CGFloat centerY_mn;
@property (nonatomic) CGFloat width_mn;
@property (nonatomic) CGFloat height_mn;
@property (nonatomic) CGPoint origin_mn;
@property (nonatomic) CGSize size_mn;

@property (nonatomic, readonly) CGPoint bounds_center;

CGFloat CGRectMinX(id obj);
CGFloat CGRectMinY(id obj);
CGFloat CGRectMaxX(id obj);
CGFloat CGRectMaxY(id obj);
CGFloat CGRectMidX(id obj);
CGFloat CGRectMidY(id obj);
CGFloat CGRectWidth(id obj);
CGFloat CGRectHeight(id obj);
CGFloat CGRectMidWidth(id obj);
CGFloat CGRectMidHeight(id obj);

@end
