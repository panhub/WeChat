//
//  UIImage+MNFont.m
//  MNKit
//
//  Created by Vincent on 2018/2/2.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UIImage+MNFont.h"
#import "UIFont+MNHelper.h"

@implementation UIImage (MNFont)

#pragma mark - 获取指定iconfont
+ (UIImage *)imageWithUnicode:(NSString *)unicode
                    color:(UIColor *)color
                     size:(CGFloat)size {
    return [self imageWithFontName:nil unicode:unicode color:color size:size];
}

UIImage * UIImageWithUnicode (NSString *unicode, UIColor *color, CGFloat size) {
    return [UIImage imageWithFontName:nil unicode:unicode color:color size:size];
}

+ (UIImage  *)imageWithFontName:(NSString *)fontName
                        unicode:(NSString *)unicode
                          color:(UIColor *)color
                           size:(CGFloat)size
{
    if (color == nil) color = [UIColor darkTextColor];
    if (fontName.length <= 0) fontName = MNFontNameIcon;
    size = size*[[UIScreen mainScreen] scale];
    UIFont *font = UIFontWithNameSize(fontName, size);
    if (!font) return nil;
    UIGraphicsBeginImageContext(CGSizeMake(size, size));
    [unicode drawAtPoint:CGPointZero withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: color}];
    UIImage *image = [UIImage imageWithCGImage:[UIGraphicsGetImageFromCurrentImageContext() CGImage]
                                         scale:[[UIScreen mainScreen] scale]
                                   orientation:UIImageOrientationUp];
    UIGraphicsEndImageContext();
    return image;
}

@end
