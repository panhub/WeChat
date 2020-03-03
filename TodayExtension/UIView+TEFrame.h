//
//  UIView+MNFrame.h
//  MNKit
//
//  Created by Vincent on 2017/10/19.
//  Copyright © 2017年 小斯. All rights reserved.
//  view.frame

#import <UIKit/UIKit.h>

@interface UIView (TEFrame)

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
@property (nonatomic) CGPoint anchorsite;
@property (nonatomic, readonly) CGPoint bounds_center;


@end
