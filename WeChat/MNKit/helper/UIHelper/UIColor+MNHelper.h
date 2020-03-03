//
//  UIColor+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2017/11/10.
//  Copyright © 2017年 小斯. All rights reserved.
//  Color

#import <UIKit/UIKit.h>

#ifndef R_G_B
#define R_G_B(r, g, b)  UIColorWithRGB(r, g, b)
#endif

#ifndef R_G_B_A
#define R_G_B_A(r, g, b, a)  UIColorWithRGBA(r, g, b, a)
#endif

@interface UIColor (MNHelper)
/**
 随机颜色
 @return 随机颜色
 */
+ (UIColor *)randomColor;
UIColor * UIColorRandom (void);

/**
 @param hexColor 16进制颜色值
 @return UIColor
 */
+ (UIColor *)colorWithHex:( NSString *)hexColor;
UIColor * UIColorWithHex (NSString *hexString);

/**
 UIColor转换16进制颜色值(字符串)
 @param color UIColor
 @return 16进制颜色值
 */
+ (NSString *)hexStringWithColor:(UIColor *)color;
- (NSString *)hexString;
NSString * HexStringWithColor (UIColor *color);

/**
 比较两个颜色值是否相同
 @param color 与之比较的颜色
 @return 是否相同
 */
- (BOOL)isEqualToColor:(UIColor *)color;
BOOL UIColorEqualToColor (UIColor *color1, UIColor *color2);

/**
 获取RGB颜色值color
 @param r 红
 @param g 绿
 @param b 蓝
 @return 颜色
 */
UIColor * UIColorWithRGB (CGFloat r, CGFloat g, CGFloat b);
UIColor * UIColorWithRGBA (CGFloat r, CGFloat g, CGFloat b, CGFloat a);

/**
 获取单一颜色值颜色
 @param rgb 颜色值<RGB值>
 @return 颜色
 */
UIColor * UIColorWithSingleRGB (CGFloat rgb);

/**
 为颜色添加透明度
 @param color 颜色值
 @param alpha 透明度
 @return 颜色
 */
UIColor * UIColorWithAlpha (UIColor *color, CGFloat alpha);

/**
 获取图片上某一点颜色值
 @param image 图片对象
 @param point 点
 @return 对应点颜色值
 */
+ (UIColor *)colorFromImage:(UIImage *)image atPoint:(CGPoint)point;
UIColor * UIColorFromImageAtPoint (UIImage *image, CGPoint point);

/**
 导航, 标签栏细线的颜色
 @return 细线的颜色
 */
UIColor * UIColorShadowColor (void);

/**
 系统蓝色
 @return 蓝色
 */
UIColor * UIWindowTintColor (void);

@end
