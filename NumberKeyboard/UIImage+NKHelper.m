//
//  UIImage+NKHelper.m
//  NumberKeyboard
//
//  Created by Vicent on 2020/3/7.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "UIImage+NKHelper.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation UIImage (NKHelper)

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake([[UIScreen mainScreen] scale], [[UIScreen mainScreen] scale])];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0.f || size.height <= 0.f) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, (CGRect){0.f, 0.f, size});
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
