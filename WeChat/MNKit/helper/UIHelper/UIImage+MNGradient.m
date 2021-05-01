//
//  UIImage+MNGradient.m
//  MNKit
//
//  Created by Vincent on 2018/12/6.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UIImage+MNGradient.h"

@implementation UIImage (MNGradient)

+ (UIImage *)gradientImageWithSize:(CGSize)size
                       orientation:(MNGradientOrientation)orientation
                            colors:(NSArray <UIColor *>*)colors
{
    if (CGSizeEqualToSize(size, CGSizeZero)) return nil;
    NSMutableArray *cgColors = [NSMutableArray arrayWithCapacity:colors.count];
    for (UIColor *color in colors) {
        [cgColors addObject:(id)[color CGColor]];
    }
    if (orientation == MNGradientOrientationRadial) {
        UIGraphicsBeginImageContextWithOptions(size,NO, [[UIScreen mainScreen] scale]);
        CGFloat locations[2] = {0.f, 1.f};
        //Default to the RGB Colorspace
        CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
        CFArrayRef arrayRef = (__bridge CFArrayRef)cgColors;
        //Create our Fradient
        CGGradientRef myGradient = CGGradientCreateWithColors(myColorspace, arrayRef, locations);
        // Normalise the 0-1 ranged inputs to the width of the image
        CGPoint myCentrePoint = CGPointMake(.5f*size.width, .5f*size.height);
        float myRadius = MIN(size.width, size.height)*.5f;
        // Draw our Gradient
        CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, myCentrePoint,
                                     0, myCentrePoint, myRadius,
                                     kCGGradientDrawsAfterEndLocation);
        
        // Grab it as an Image
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        // Clean up
        CGColorSpaceRelease(myColorspace); // Necessary?
        CGGradientRelease(myGradient); // Necessary?
        UIGraphicsEndImageContext();
        return image;
    }
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = (CGRect){0.f, 0.f, size};
    layer.contentsScale = [[UIScreen mainScreen] scale];
    layer.colors = cgColors;
    switch (orientation) {
        case MNGradientOrientationHorizontal:
        {
            [layer setStartPoint:CGPointMake(0.f, .5f)];
            [layer setEndPoint:CGPointMake(1.f, .5f)];
        } break;
        case MNGradientOrientationVertical:
        {
            [layer setStartPoint:CGPointMake(.5f, 0.f)];
            [layer setEndPoint:CGPointMake(.5f, 1.f)];
        } break;
        case MNGradientOrientationIncline:
        {
            [layer setStartPoint:CGPointMake(0.f, 1.f)];
            [layer setEndPoint:CGPointMake(1.f, 0.f)];
        } break;
        case MNGradientOrientationSlant:
        {
            [layer setStartPoint:CGPointMake(0.f, 0.f)];
            [layer setEndPoint:CGPointMake(1.f, 1.f)];
        } break;
        default:
            break;
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
