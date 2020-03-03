//
//  UIView+MNFrame.h
//  MNKit
//
//  Created by Vincent on 2017/10/19.
//  Copyright © 2017年 小斯. All rights reserved.
//  view.frame

#import <UIKit/UIKit.h>

@interface UIView (SEFrame)
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
@end

/**
 缩放到指定宽度的比例尺寸
 @param size 指定尺寸
 @param width 指定宽度
 @return 比例尺寸
 */
UIKIT_STATIC_INLINE CGSize CGSizeMultiplyToWidth (CGSize size, CGFloat width) {
    if (width <= 0.f) return CGSizeZero;
    return CGSizeMake(width, size.height/(size.width/width));
}

/**
 缩放到指定高度的比例尺寸
 @param size 指定尺寸
 @param height 指定高度
 @return 比例尺寸
 */
UIKIT_STATIC_INLINE CGSize CGSizeMultiplyToHeight (CGSize size, CGFloat height) {
    if (height <= 0.f) return CGSizeZero;
    return CGSizeMake(size.width/(size.height/height), height);
}
