//
//  UIImage+MNResizing.m
//  MNKit
//
//  Created by Vicent on 2021/2/27.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "UIImage+MNResizing.h"

@implementation UIImage (MNResizing)
#pragma mark - 拉伸图像
+ (UIImage *)resizableImage:(NSString *)imgName {
    UIImage *image = [UIImage imageNamed:imgName];
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height*.5f, image.size.width*.5f, image.size.height*.5f, image.size.width*.5f)];
}

+ (UIImage *)resizableImage:(NSString *)imgName capInsets:(UIEdgeInsets)capInsets {
    return [[UIImage imageNamed:imgName] resizableImageWithCapInsets:capInsets];
}

#pragma mark - 图片圆角处理
- (UIImage *)maskRadius:(CGFloat)radius {
    if (radius <= 0.f) return self;
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    if (width <= 0.f || height <= 0.f) return self;
    CGFloat _radius = MIN(width, height)/2.f;
    radius = MIN(_radius, radius);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4*width, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0.f, 0.f, width, height);
    
    CGContextBeginPath(context);
    
    CGFloat fw, fh;
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, radius, radius);
    fw = CGRectGetWidth(rect)/radius;
    fh = CGRectGetHeight(rect)/radius;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
    
    CGContextClosePath(context);
    
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageMasked];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    return image;
}

#pragma mark - 截取当前image对象rect区域内的图像
- (UIImage *)cropInRect:(CGRect)rect {
    rect.origin.x = floor(rect.origin.x);
    rect.origin.y = floor(rect.origin.y);
    rect.size.width = floor(rect.size.width);
    rect.size.height = floor(rect.size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

- (UIImage *)cropByRect:(CGRect)rect {
    rect.origin.x *= self.scale;
    rect.origin.y *= self.scale;
    rect.size.width *= self.scale;
    rect.size.height *= self.scale;
    if (rect.size.width <= 0.f || rect.size.height <= 0.f) return nil;
    rect.origin.x = floor(rect.origin.x);
    rect.origin.y = floor(rect.origin.y);
    rect.size.width = floor(rect.size.width);
    rect.size.height = floor(rect.size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return image;
}

#pragma mark - 获得灰度图
- (UIImage *)grayImage {
    int width = self.size.width;
    int height = self.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil,width,height,8,0,colorSpace,kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) return nil;
    
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), self.CGImage);
    CGImageRef contextRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:contextRef];
    CGContextRelease(context);
    CGImageRelease(contextRef);
    
    return grayImage;
}

#pragma mark - 纠正图片的方向
- (UIImage *)resizingOrientation {
    //UIImageOrientation imageOrientation = self.imageOrientation;
    //if (self.imageOrientation == UIImageOrientationUp) return self;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return image;
}

#pragma mark - 按给定的方向旋转图片
- (UIImage*)rotateToOrientation:(UIImageOrientation)orient {
    CGRect bnds = CGRectZero;
    UIImage* copy = nil;
    CGContextRef ctxt = nil;
    CGImageRef imag = self.CGImage;
    CGRect rect = CGRectZero;
    CGAffineTransform tran = CGAffineTransformIdentity;
    
    rect.size.width = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
            return self;
            
        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width,
                                                    rect.size.height);
            tran = CGAffineTransformRotate(tran, M_PI);
            break;
            
        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeft:
            bnds = CGRectChangeWidthHeight(bnds);
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeftMirrored:
            bnds = CGRectChangeWidthHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height,
                                                    rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:
            bnds = CGRectChangeWidthHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:
            bnds = CGRectChangeWidthHeight(bnds);
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        default:
            return self;
    }
    
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctxt, -1.0, 1.0);
            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
            break;
            
        default:
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            break;
    }
    
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copy;
}

#pragma mark - 交换宽高
static CGRect CGRectChangeWidthHeight(CGRect rect) {
    CGFloat swap = rect.size.width;
    rect.size.width = rect.size.height;
    rect.size.height = swap;
    return rect;
}

#pragma mark - 垂直翻转
- (UIImage *)verticalFlipImage {
    return [self rotateToOrientation:UIImageOrientationDownMirrored];
}

#pragma mark - 水平翻转
- (UIImage *)horizontalFlipImage {
    return [self rotateToOrientation:UIImageOrientationUpMirrored];
}

#pragma mark - 将图片旋转指定弧度
- (UIImage *)rotateToRadians:(CGFloat)radians {
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2.0, rotatedSize.height/2.0);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, radians);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.f, -1.f);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width/2.f, -self.size.height/2.f, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - 将图片旋转角度
- (UIImage *)rotateToDegrees:(CGFloat)degrees {
    return [self rotateToRadians:(M_PI*(degrees )/180.f)];
}

#pragma mark - 指定大小生成一个平铺的图片
- (UIImage *)imageWithTiledSize:(CGSize)size {
    UIView *tempView = [[UIView alloc] init];
    tempView.bounds = (CGRect){CGPointZero, size};
    tempView.backgroundColor = [UIColor colorWithPatternImage:self];
    UIGraphicsBeginImageContext(size);
    [tempView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - 将两个图片生成一张图片
+ (UIImage*)mergeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    CGImageRef firstImageRef = firstImage.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    CGImageRef secondImageRef = secondImage.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    UIGraphicsBeginImageContext(mergedSize);
    [firstImage drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [secondImage drawInRect:CGRectMake(0, 0, secondWidth, secondHeight)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageWithMergeImage:(UIImage *)image {
    return [UIImage mergeImage:self withImage:image];
}

@end

@implementation UIImage (MNCompress)
#pragma mark - 压缩图片
- (UIImage *)compressImage {
    UIImage *image = self.images.count > 1 ? self.images.firstObject : self;
    CGSize size = [image compressSize];
    image = [image resizingToSize:size];
    NSData *imageData = UIImageJPEGRepresentation(image, .5f);
    if (!imageData || imageData.length <= 0) return image;
    return [UIImage imageWithData:imageData];
}

- (CGSize)compressSize {
    CGFloat width = self.size.width*self.scale;
    CGFloat height = self.size.height*self.scale;
    CGFloat boundary = 1280.f;
    if (width <= boundary && height <= boundary) return CGSizeMake(width, height);
    BOOL isSquare = width == height;
    if (MAX(width, height)/MIN(width, height) <= 2.f) {
        CGFloat ratio = MAX(width, height)/boundary;
        if (width >= height) {
            width = boundary;
            height = height/ratio;
        } else {
            height = boundary;
            width = width/ratio;
        }
    } else {
        if (MIN(width, height) >= boundary) {
            CGFloat ratio = MIN(width, height)/boundary;
            if (width <= height) {
                width = boundary;
                height = height/ratio;
            } else {
                height = boundary;
                width = width/ratio;
            }
        }
    }
    width = floor(width);
    height = floor(height);
    if (isSquare) width = height = MIN(width, height);
    return CGSizeMake(width, height);
}

#pragma mark - 压缩图片至指定像素
- (UIImage *)resizingToPix:(NSUInteger)pix {
    if (pix <= 0) return self;
    CGSize size = CGSizeMake(self.size.width*self.scale, self.size.height*self.scale);
    if (isnan(size.width) || size.width <= 0.f || isnan(size.height) || size.height <= 0.f) return self;
    if (size.width*size.height <= pix) return self;
    CGFloat multiple = pix/(size.width*size.height);
    return [self resizingToSize:CGSizeMake(floor(size.width*multiple), floor(size.height*multiple))];
}

- (UIImage *)resizingToMaxPix:(NSUInteger)pix {
    if (pix <= 0) return self;
    CGSize size = self.size;
    size = CGSizeMake(size.width*self.scale, size.height*self.scale);
    if (isnan(size.width) || size.width <= 0.f || isnan(size.height) || size.height <= 0.f) return self;
    if (MAX(size.width, size.height) <= pix) return self;
    if (size.width >= size.height) {
        size.height = pix/size.width*size.height;
        size.width = pix;
    } else {
        size.width = pix/size.height*size.width;
        size.height = pix;
    }
    return [self resizingToSize:CGSizeMake(floor(size.width), floor(size.height))];
}

#pragma mark - 压缩图片至指定尺寸
- (UIImage *)resizingToSize:(CGSize)size {
    if (isnan(size.width) || size.width <= 0.f || isnan(size.height) || size.height <= 0.f) return nil;
    size.width = floor(size.width);
    size.height = floor(size.height);
    UIGraphicsBeginImageContext(size);
    [self drawInRect:(CGRect){CGPointZero, size}];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSData *)dataWithQuality:(CGFloat)representation {
    NSUInteger length = fabs(floor(representation)*1024.f);
    if (length <= 0) return nil;
    NSData *imageData = UIImageJPEGRepresentation(self, 1.f);
    NSUInteger dataLength = imageData.length;
    // 小于指定大小或相差1K左右就返回
    if (dataLength <= length || (dataLength - length) <= 1024) return imageData;
    CGFloat m = [NSString stringWithFormat:@"%.2f", length*1.f/dataLength].floatValue;
    m = MAX(m, 0.01);
    return UIImageJPEGRepresentation(self, m);
}

- (UIImage *)resizingToQuality:(CGFloat)representation {
    NSData *imageData = [self dataWithQuality:representation];
    if (imageData.length) return [UIImage imageWithData:imageData];
    return nil;
}

- (UIImage *)resizingToPix:(NSUInteger)pix quality:(CGFloat)representation {
    return [[self resizingToPix:pix] resizingToQuality:representation];
}

- (UIImage *)resizingToMaxPix:(NSUInteger)pix quality:(CGFloat)representation {
    return [[self resizingToMaxPix:pix] resizingToQuality:representation];
}

@end
