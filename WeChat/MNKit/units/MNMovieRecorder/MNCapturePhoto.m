//
//  MNCapturePhoto.m
//  MNKit
//
//  Created by Vicent on 2021/3/6.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "MNCapturePhoto.h"
#import "UIImage+MNResizing.h"
#if __has_include(<CoreMedia/CMSampleBuffer.h>)
#import <CoreMedia/CMSampleBuffer.h>
#endif

@implementation MNCapturePhoto

+ (instancetype)photoWithImage:(UIImage *)image {
    image = image.resizingOrientation;
    if (!image) return nil;
    MNCapturePhoto *photo = [[[self class] alloc] init];
    photo.image = image;
    return photo;
}

+ (instancetype)photoWithImageData:(NSData *)imageData {
    MNCapturePhoto *photo = [self photoWithImage:[UIImage imageWithData:imageData]];
    photo.imageData = imageData;
    return photo;
}

#if __has_include(<CoreMedia/CMSampleBuffer.h>)
+ (instancetype)photoWithDataBuffer:(CMSampleBufferRef)dataBuffer {
    if (dataBuffer == NULL) return nil;
    CMBlockBufferRef dataBufferRef = CMSampleBufferGetDataBuffer(dataBuffer);
    size_t length = CMBlockBufferGetDataLength(dataBufferRef);
    Byte buffer[length];
    CMBlockBufferCopyDataBytes(dataBufferRef, 0, length, buffer);
    NSData *imageData = [NSData dataWithBytes:buffer length:length];
    return [self photoWithImageData:imageData];
}

+ (instancetype)photoWithSampleBuffer:(CMSampleBufferRef)imageSampleBuffer {
    if (imageSampleBuffer == NULL) return nil;
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(imageSampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) return nil;
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    CGDataProviderRef dataProvider =
     CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    CGImageRef cgImage =
     CGImageCreate(width, height, 8, 32, bytesPerRow,
          colorSpace, kCGImageAlphaNoneSkipFirst|kCGBitmapByteOrder32Little,
          dataProvider, NULL, true, kCGRenderingIntentDefault);
     CGDataProviderRelease(dataProvider);
    /*
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 释放context和颜色空间
    CGContextRelease(context);
    */
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    CGColorSpaceRelease(colorSpace);
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    // 释放Quartz image对象
    CGImageRelease(cgImage);
    return [self photoWithImage:image];
}
#endif

- (BOOL)isLivePhoto {
    return [self isKindOfClass:MNCaptureLivePhoto.class];
}

@end



@implementation MNCaptureLivePhoto

+ (MNCaptureLivePhoto *)liveWithPhoto:(MNCapturePhoto *)photo {
    if (!photo) return nil;
    if (!photo.image && !photo.imageData) return nil;
    MNCaptureLivePhoto *livePhoto = MNCaptureLivePhoto.new;
    livePhoto.image = photo.image;
    livePhoto.imageData = photo.imageData;
    return livePhoto;
}

@end
