//
//  UIImage+MNBlurEffect.h
//  MNKit
//
//  Created by Vincent on 2018/8/4.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIImage (MNBlurEffect)

- (UIImage *_Nullable)lightEffect;

- (UIImage *_Nullable)extraLightEffect;

- (UIImage *_Nullable)darkEffect;

- (UIImage *_Nullable)tintEffectWithColor:(UIColor *)tintColor;

- (UIImage *_Nullable)blurEffectWithRadius:(CGFloat)blurRadius
                           tintColor:(UIColor *)tintColor
               saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                           maskImage:(UIImage *)maskImage;

@end
NS_ASSUME_NONNULL_END
