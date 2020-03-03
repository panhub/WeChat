//
//  UIImage+MNBlurEffect.h
//  MNKit
//
//  Created by Vincent on 2018/8/4.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MNBlurEffect)

- (UIImage *)lightEffect;

- (UIImage *)extraLightEffect;

- (UIImage *)darkEffect;

- (UIImage *)tintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)blurEffectWithRadius:(CGFloat)blurRadius
                           tintColor:(UIColor *)tintColor
               saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                           maskImage:(UIImage *)maskImage;

@end
