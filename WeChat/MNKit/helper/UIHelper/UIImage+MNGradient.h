//
//  UIImage+MNGradient.h
//  MNKit
//
//  Created by Vincent on 2018/12/6.
//  Copyright © 2018年 小斯. All rights reserved.
//  梯度图片
//  两种颜色, 中间点渐变
//

#import <UIKit/UIKit.h>

/**
 梯度图渐变方向
 - MNGradientOrientationHorizontal: -
 - MNGradientOrientationVertical: |
 - MNGradientOrientationIncline: /
 - MNGradientOrientationSlant: \
 - MNGradientOrientationRadial: O
 */
typedef NS_ENUM(NSInteger, MNGradientOrientation) {
    MNGradientOrientationHorizontal = 0,
    MNGradientOrientationVertical,
    MNGradientOrientationIncline,
    MNGradientOrientationSlant,
    MNGradientOrientationRadial
};

@interface UIImage (MNGradient)

+ (UIImage *)gradientImageWithSize:(CGSize)size
                       orientation:(MNGradientOrientation)orientation
                            colors:(NSArray <UIColor *>*)colors;

@end
