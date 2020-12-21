//
//  UIColor+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2017/11/10.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "UIColor+MNHelper.h"
#import "UIImage+MNHelper.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation UIColor (MNHelper)
#pragma mark - 获取颜色图片
- (UIImage *)image {
    return [UIImage imageWithColor:self];
}

#pragma mark - 随机颜色
+ (UIColor *)randomColor {
    int R = arc4random_uniform(256);
    int G = arc4random_uniform(256);
    int B = arc4random_uniform(256);
    return [UIColor colorWithRed:(R/255.f) green:(G/255.f) blue:(B/255.f) alpha:1.f];
}

UIColor * UIColorRandom (void) {
    return [UIColor randomColor];
}

#pragma mark - 16进制颜色值(字符串)转换为UIColor
+ (UIColor *)colorWithHex:( NSString *)hexColor {
    NSString *cString = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float)r/255.f) green:((float)g/255.0f) blue:((float)b/255.f) alpha:1.f];
}

UIColor * UIColorWithHex (NSString *hexString) {
    return [UIColor colorWithHex:hexString];
}

#pragma mark - UIColor转换16进制颜色值(字符串)
+ (NSString *)hexFromColor:(UIColor *)color {
    if (!color) return nil;
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

- (NSString *)hexString {
    return [UIColor hexFromColor:self];
}

NSString * UIColorHexString (UIColor *color) {
    return [UIColor hexFromColor:color];
}

#pragma mark - 比较两个颜色值是否相等
- (BOOL)isEqualToColor:(UIColor *)color {
    if (!color) return NO;
    return CGColorEqualToColor(self.CGColor, color.CGColor);
}

BOOL UIColorEqualToColor (UIColor *color1, UIColor *color2) {
    return [color1 isEqualToColor:color2];
}

#pragma mark - 获取指定颜色值的color
inline UIColor * UIColorWithRGB (CGFloat r, CGFloat g, CGFloat b) {
    return UIColorWithRGBA(r, g, b, 1.f);
}

inline UIColor * UIColorWithRGBA (CGFloat r, CGFloat g, CGFloat b, CGFloat a) {
    return [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a];
}

inline UIColor * UIColorWithSingleRGB (CGFloat rgb) {
    return UIColorWithRGBA(rgb, rgb, rgb, 1.f);
}

inline UIColor * UIColorWithAlpha (UIColor *color, CGFloat alpha) {
    return [color colorWithAlphaComponent:alpha];
}

#pragma mark - 取图片某一点颜色
+ (UIColor *)colorFromImage:(UIImage *)image atPoint:(CGPoint)point {
    if (!image || !CGRectContainsPoint((CGRect){0.f, 0.f, image.size}, point)) return nil;
    //Encapsulate our image
    CGImageRef imageRef = image.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    //Specify the colorspace we're in
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //Extract the data we need
    unsigned char *rawData = calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow,
                                                 colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    //Release colorspace
    CGColorSpaceRelease(colorSpace);
    
    //Draw and release image
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    //rawData now contains the image data in RGBA8888
    NSInteger byteIndex = (bytesPerRow * point.y) + (point.x * bytesPerPixel);
    
    //Define our RGBA values
    CGFloat red = (rawData[byteIndex] * 1.f) / 255.f;
    CGFloat green = (rawData[byteIndex + 1] * 1.f) / 255.f;
    CGFloat blue = (rawData[byteIndex + 2] * 1.f) / 255.f;
    CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.f;
    
    //Free our rawData
    free(rawData);
    
    //Return color
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

UIColor * UIColorFromImageAtPoint (UIImage *image, CGPoint point) {
    return [UIColor colorFromImage:image atPoint:point];
}

#pragma mark - 细线颜色
inline UIColor * UIColorShadowColor (void) {
    return [[UIColor darkTextColor] colorWithAlphaComponent:.2f];
}

@end
