//
//  UIColor+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2017/11/10.
//  Copyright © 2017年 小斯. All rights reserved.
//  Color

#import <UIKit/UIKit.h>
#import <Foundation/NSString.h>

#ifndef MN_R_G_B
#define MN_R_G_B(r, g, b)  UIColorWithRGB(r, g, b)
#endif

#ifndef MN_R_G_B_A
#define MN_R_G_B_A(r, g, b, a)  UIColorWithRGBA(r, g, b, a)
#endif

#ifndef MN_RGB
#define MN_RGB(a)  UIColorWithRGB(a, a, a)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (MNHelper)

/**获取颜色图片*/
@property (nonatomic, readonly) UIImage *image;

/**
 随机颜色
 @return 随机颜色
 */
+ (UIColor *)randomColor;
UIKIT_EXTERN UIColor *UIColorRandom (void);

/**
 @param hexColor 16进制颜色值
 @return UIColor
 */
+ (UIColor *)colorWithHex:( NSString *)hexColor;
UIKIT_EXTERN UIColor *UIColorWithHex (NSString *hexString);

/**
 UIColor转换16进制颜色值(字符串)
 @param color UIColor
 @return 16进制颜色值
 */
+ (NSString *)hexFromColor:(UIColor *)color;
- (NSString *)hexString;
UIKIT_EXTERN NSString *UIColorHexString (UIColor *color);

/**
 比较两个颜色值是否相同
 @param color 与之比较的颜色
 @return 是否相同
 */
- (BOOL)isEqualToColor:(UIColor *)color;
UIKIT_EXTERN BOOL UIColorEqualToColor (UIColor *color1, UIColor *color2);

/**
 获取RGB颜色值color
 @param r 红
 @param g 绿
 @param b 蓝
 @return 颜色
 */
UIKIT_EXTERN UIColor *UIColorWithRGB (CGFloat r, CGFloat g, CGFloat b);
UIKIT_EXTERN UIColor *UIColorWithRGBA (CGFloat r, CGFloat g, CGFloat b, CGFloat a);

/**
 获取单一颜色值颜色
 @param rgb 颜色值<RGB值>
 @return 颜色
 */
UIKIT_EXTERN UIColor *UIColorWithSingleRGB (CGFloat rgb);

/**
 为颜色添加透明度
 @param color 颜色值
 @param alpha 透明度
 @return 颜色
 */
UIKIT_EXTERN UIColor *UIColorWithAlpha (UIColor *color, CGFloat alpha);

/**
 获取图片上某一点颜色值
 @param image 图片对象
 @param point 点
 @return 对应点颜色值
 */
+ (UIColor *)colorFromImage:(UIImage *)image atPoint:(CGPoint)point;
UIKIT_EXTERN UIColor *UIColorFromImageAtPoint (UIImage *image, CGPoint point);

/**
 导航, 标签栏细线的颜色
 @return 细线的颜色
 */
UIKIT_EXTERN UIColor *UIColorShadowColor (void);

@end

NS_ASSUME_NONNULL_END
