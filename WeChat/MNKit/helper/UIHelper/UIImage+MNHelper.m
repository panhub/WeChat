//
//  UIImage+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2017/10/10.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "UIImage+MNHelper.h"
#import "UIImage+MNResizing.h"
#import "UIColor+MNHelper.h"
#import "CALayer+MNHelper.h"
#import <Accounts/Accounts.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#if __has_include("SDWebImageManager.h")
#import "SDWebImageManager.h"
#endif
#if __has_include(<SDWebImage/SDWebImageManager.h>)
#import <SDWebImage/SDWebImageManager.h>
#endif

@implementation UIImage (MNHelper)
#pragma mark - 图案颜色
- (UIColor *)patternColor {
    return [UIColor colorWithPatternImage:self];
}

#pragma mark - 图片大小
- (CGSize)imageSize {
    return CGSizeMake(self.size.width*self.scale, self.size.height*self.scale);
}

#pragma mark - 获取Assets图片
UIImage * UIImageNamed (NSString *name) {
    return [UIImage imageNamed:name];
}

#pragma mark - 获取纯色图
+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1.f, 1.f)];
}

UIImage* UIImageWithColor (UIColor *color) {
    return [UIImage imageWithColor:color];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0.f || size.height <= 0.f) return nil;
    size.width = floor(size.width);
    size.height = floor(size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, (CGRect){0.f, 0.f, size});
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - 取图片某一点颜色
- (UIColor *)colorAtPoint:(CGPoint)point {
    if (!CGRectContainsPoint((CGRect){0.f, 0.f, self.size}, point)) return nil;
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel*1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY- (CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

UIColor * UIColorAtImagePoint (UIImage *image, CGPoint point) {
    return [image colorAtPoint:point];
}

#pragma mark - layer转换为image
+ (UIImage *)imageWithLayer:(CALayer *)layer {
    if (!layer) return nil; 
    UIGraphicsBeginImageContextWithOptions(layer.bounds.size, NO, layer.contentsScale);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithLayer:(CALayer *)layer rect:(CGRect)rect {
    if (!layer || CGRectEqualToRect(rect, CGRectZero)) return nil;
    UIImage *image = [self imageWithLayer:layer];
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) return nil;
    CGFloat width = CGImageGetWidth(imageRef);
    CGFloat ratio = width/layer.frame.size.width;
    rect = CGRectMake(floor(rect.origin.x*ratio), floor(rect.origin.y*ratio), floor(rect.size.width*ratio), floor(rect.size.height*ratio));
    return [UIImage imageWithCGImage:CGImageCreateWithImageInRect(imageRef, rect) scale:image.scale orientation:image.imageOrientation];
}

#pragma mark - UIView转化为UIImage
+ (UIImage *)imageWithView:(UIView *)view afterScreenUpdates:(BOOL)afterScreenUpdates {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:afterScreenUpdates];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - 原图,避免着色
- (UIImage *)originalImage {
    return [self imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

#pragma mark - 模板图
- (UIImage *)templateImage {
    return [self imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

#pragma mark - 获取image
+ (UIImage *)imageWithObject:(id)obj {
    if (!obj) return nil;
    UIImage *image;
    if ([obj isKindOfClass:[NSString class]]) {
        if ([NSFileManager.defaultManager fileExistsAtPath:obj]) {
            image = [UIImage imageWithContentsOfFile:(NSString *)obj];
        } else if ([(NSString *)obj hasPrefix:@"http://"] || [(NSString *)obj hasPrefix:@"https://"]) {
#if __has_include("SDWebImageManager.h") || __has_include(<SDWebImage/SDWebImageManager.h>)
            image = [SDWebImageManager.sharedManager.imageCache imageFromCacheForKey:nil];
#endif
            if (!image) {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:(NSString *)obj]];
                if (data.length) image = [UIImage imageWithData:data];
            }
        } else {
            image = [UIImage imageNamed:(NSString *)obj];
        }
    } else if ([obj isKindOfClass:[NSURL class]]) {
        NSURL *URL = (NSURL *)obj;
        image = [self imageWithObject:URL.isFileURL ? URL.path : URL.absoluteString];
    } else if ([obj isKindOfClass:[UIImage class]]) {
        image = (UIImage *)obj;
    }
    return image;
}

#pragma mark - 获取LogoImage
+ (UIImage *)logoImage {
    static UIImage *_logoImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *name = [[[[NSBundle mainBundle] infoDictionary] valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
        _logoImage = [UIImage imageNamed:name];
    });
    return _logoImage;
}

#pragma mark - 获取LaunchImage
+ (UIImage *)launchImage {
    static UIImage *launchImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *orientation = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? @"Portrait" : @"Landscape";
        NSString *imageName;
        CGSize screen_size = [[UIScreen mainScreen] bounds].size;
        NSArray *array = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
        for(NSDictionary *dic in array) {
            CGSize size = CGSizeFromString(dic[@"UILaunchImageSize"]);
            if ([orientation isEqualToString:dic[@"UILaunchImageOrientation"]] && (CGSizeEqualToSize(size, screen_size) || (size.width == screen_size.height && size.height == screen_size.width))) {
                imageName = dic[@"UILaunchImageName"];
                launchImage = [UIImage imageNamed:imageName];
            }
        }
    });
    return launchImage;
}

#pragma mark - 获取图片尺寸
+ (CGSize)imageSizeWithUrl:(NSString *)url animated:(BOOL *)animated {
    if (url.length <= 0) return CGSizeZero;
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
        return [self imageSizeWithURL:[NSURL URLWithString:url] animated:animated];
    } else if ([url hasPrefix:@"file://"]) {
        if (animated) *animated = [[url pathExtension] isEqualToString:@"gif"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:url]];
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                return image.size;
            }
        }
    } else {
        if (animated) *animated = NO;
        UIImage *image = [UIImage imageNamed:url];
        if (image) {
            return image.size;
        }
    }
    return CGSizeZero;
}

+ (CGSize)imageSizeWithURL:(NSURL *)URL animated:(BOOL *)animated {
    if (!URL) return CGSizeZero;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    NSString* pathExtendsion = [URL.pathExtension lowercaseString];
    CGSize size = CGSizeZero;
    BOOL isAnimated = NO;
    if ([pathExtendsion isEqualToString:@"png"]) {
        size = [self PNGImageSizeWithRequest:request];
    } else if ([pathExtendsion isEqual:@"gif"]) {
        isAnimated = YES;
        size = [self GIFImageSizeWithRequest:request];
    } else {
        size = [self JPGImageSizeWithRequest:request];
    }
    if (CGSizeEqualToSize(CGSizeZero, size)) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:URL]];
        if (image) {
            size = image.size;
        }
    }
    if (animated) {
        *animated = isAnimated;
    }
    return size;
}

+ (CGSize)PNGImageSizeWithRequest:(NSMutableURLRequest*)request {
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data.length == 8) {
        int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        [data getBytes:&w3 range:NSMakeRange(2, 1)];
        [data getBytes:&w4 range:NSMakeRange(3, 1)];
        int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
        int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
        [data getBytes:&h1 range:NSMakeRange(4, 1)];
        [data getBytes:&h2 range:NSMakeRange(5, 1)];
        [data getBytes:&h3 range:NSMakeRange(6, 1)];
        [data getBytes:&h4 range:NSMakeRange(7, 1)];
        int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}

+ (CGSize)GIFImageSizeWithRequest:(NSMutableURLRequest*)request {
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data.length == 4) {
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        short w = w1 + (w2 << 8);
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(2, 1)];
        [data getBytes:&h2 range:NSMakeRange(3, 1)];
        short h = h1 + (h2 << 8);
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}

+ (CGSize)JPGImageSizeWithRequest:(NSMutableURLRequest*)request {
    [request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if ([data length] <= 0x58) return CGSizeZero;
    if ([data length] < 210) {
        // 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else {
                // 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        }
    }
    return CGSizeZero;
}

@end


@implementation UIImage (MNCoding)
#pragma mark - 获取Data图片
- (NSData *)JPEGData {
    return UIImageJPEGRepresentation(self, 1.f);
}

- (NSData *)PNGData {
    return UIImagePNGRepresentation(self);
}

#pragma mark - UIImage转NSString
- (NSString *)JPEGBase64Encoding {
    NSData *data = UIImageJPEGRepresentation(self, 1.f);
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (NSString *)PNGBase64Encoding {
    NSData *data = UIImagePNGRepresentation(self);
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

#pragma mark - NSString转UIImage
+ (UIImage *)imageWithBase64EncodedString:(NSString *)base64String {
    if (base64String.length <= 0) return nil;
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (data.length <= 0) return nil;
    return [UIImage imageWithData:data];
}

@end
