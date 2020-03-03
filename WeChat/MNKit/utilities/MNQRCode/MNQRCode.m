//
//  MNQRCode.m
//  MNKit
//
//  Created by Vincent on 2018/7/4.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNQRCode.h"
#import <CoreImage/CoreImage.h>

@implementation MNQRCode

#pragma mark - 制作二维码
+ (UIImage *)createQRCodeWithMetadata:(NSData *)metadata pixel:(CGFloat)pixel {
    if (!metadata || pixel <= 0.f) return nil;
    //创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //恢复滤镜的默认属性
    [filter setDefaults];
    //通过KVC设置滤镜inputMessage数据
    [filter setValue:metadata forKeyPath:@"inputMessage"];
    //此时image相对来说比较模糊
    CIImage *outputImage = [filter outputImage];
    //处理高清图片返回
    return [self createImageFromCIImage:outputImage pixel:pixel];
}

+ (void)createQRCodeWithMetadata:(NSData *)metadata
                                   pixel:(CGFloat)pixel
                              completion:(void(^)(UIImage *image))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self createQRCodeWithMetadata:metadata pixel:pixel];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(image);
            }
        });
    });
}

+ (UIImage *)createImageFromCIImage:(CIImage *)image pixel:(CGFloat)pixel {
    if (image == nil) return nil;
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(pixel/CGRectGetWidth(extent), pixel/CGRectGetHeight(extent));
    if (scale <= 0.f) return nil;
    
    //创建bitmap
    size_t width = CGRectGetWidth(extent)*scale;
    size_t height = CGRectGetHeight(extent)*scale;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    //保存bitmap到图片
    CGImageRef imageRef = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:imageRef];
}

+ (UIImage *)createQRCodeWithMetadata:(NSData *)metadata color:(UIColor *)color pixel:(CGFloat)pixel {
    UIImage *image = [self createQRCodeWithMetadata:metadata pixel:pixel];
    if (color) image = [self changeQRCode:image withColor:color];
    return image;
}

+ (void)createQRCodeWithMetadata:(NSData *)metadata color:(UIColor *)color pixel:(CGFloat)pixel completion:(void(^)(UIImage *image))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self createQRCodeWithMetadata:metadata color:color pixel:pixel];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(image);
            }
        });
    });
}

#pragma mark - 优化
+ (UIImage *)changeQRCode:(UIImage *)image withColor:(UIColor *)color {
    if (!image) return nil;
    if (!color) return image;
    
    CGFloat R, G, B;
    CGColorRef colorRef = [color CGColor];
    size_t numComponents = CGColorGetNumberOfComponents(colorRef);
    if (numComponents != 4) return image;
    const CGFloat *components = CGColorGetComponents(colorRef);
    R = components[0];
    G = components[1];
    B = components[2];
    
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth*4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow*imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0.f, 0.f, imageWidth, imageHeight), image.CGImage);
    // traverse pixe
    int pixelNum = imageWidth*imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = R*255; //0~255
            ptr[2] = G*255;
            ptr[1] = B*255;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // context to image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow*imageHeight, NULL);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

+ (void)changeQRCode:(UIImage *)img withColor:(UIColor *)color completion:(void(^)(UIImage *, UIColor *))completion {
    if (!color) {
        if (completion) {
            completion(img, nil);
        }
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self changeQRCode:img withColor:color];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(image, color);
            }
        });
    });
}

+ (UIImage *)insertImageToQRCodeAtFront:(UIImage *)QRCodeImage image:(UIImage *)image size:(CGSize)size {
    if (!QRCodeImage) return nil;
    if (!image) return QRCodeImage;
    if (size.width <= 0 || size.height <= 0) {
        size = image.size;
    } else {
        image = [self fixImage:image toSize:size];
    }
    UIGraphicsBeginImageContextWithOptions(QRCodeImage.size, NO, 1.f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0, QRCodeImage.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextSetFillColorWithColor(context, UIColor.whiteColor.CGColor);
    CGContextFillPath(context);
    CGContextDrawImage(context, (CGRect){CGPointZero, QRCodeImage.size}, QRCodeImage.CGImage);
    CGRect rect = (CGRect){(QRCodeImage.size.width - size.width)/2.f, (QRCodeImage.size.height - size.height)/2.f, size};
    CGContextDrawImage(context, rect, image.CGImage);
    CGContextRestoreGState(context);
    UIImage *newQRCodeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newQRCodeImage;
}

+ (UIImage *)fixImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0.f, 0.f, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (void)insertImageToQRCodeAtFront:(UIImage *)QRCodeImage image:(UIImage *)image size:(CGSize)size completion:(void(^)(UIImage *))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *qrImage = [MNQRCode insertImageToQRCodeAtFront:QRCodeImage image:image size:size];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(qrImage);
            }
        });
    });
}

@end
