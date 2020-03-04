//
//  CALayer+MNFrame.h
//  MNKit
//
//  Created by Vincent on 2018/7/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (MNLayout)

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

@end
