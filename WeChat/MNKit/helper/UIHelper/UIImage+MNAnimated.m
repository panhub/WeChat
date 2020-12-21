//
//  UIImage+MNAnimated.m
//  MNKit
//
//  Created by Vincent on 2019/9/14.
//  Copyright © 2019 小斯. All rights reserved.
//

#import "UIImage+MNAnimated.h"
#import <ImageIO/ImageIO.h>
#import <objc/runtime.h>

static NSString * MNAnimatedImageLoopCountKey = @"key.mn.animated.image.loop.count";

@implementation UIImage (MNAnimated)

+ (UIImage *)imageWithBlurryData:(NSData *)imageData {
    if (imageData.length <= 0) return nil;
    NSMutableDictionary<NSString *, id> *options = @{}.mutableCopy;
    options[(__bridge NSString *)kCGImageSourceShouldCache] = @(YES);
    options[(__bridge NSString *)kCGImageSourceTypeIdentifierHint] = (__bridge NSString *)kUTTypeGIF;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, (__bridge CFDictionaryRef)options);
    if (!imageSource) return nil;
    size_t count = CGImageSourceGetCount(imageSource);
    if (count <= 0) return nil;
    if (count == 1) return [UIImage imageWithData:imageData];
    return [self animatedImageWithData:imageData scale:0.f];
}

+ (UIImage *)animatedImageWithData:(NSData *)imageData {
    return [UIImage animatedImageWithData:imageData scale:0.f];
}

+ (UIImage *)animatedImageWithData:(NSData *)imageData scale:(CGFloat)scale {
    if (imageData.length <= 0) return nil;
    NSMutableDictionary<NSString *, id> *options = @{}.mutableCopy;
    options[(__bridge NSString *)kCGImageSourceShouldCache] = @(YES);
    options[(__bridge NSString *)kCGImageSourceTypeIdentifierHint] = (__bridge NSString *)kUTTypeGIF;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, (__bridge CFDictionaryRef)options);
    if (!imageSource) return nil;
    
    size_t count = CGImageSourceGetCount(imageSource);
    if (count <= 1) return nil;
    
    NSTimeInterval duration = 0.f;
    if (scale <= 0.f) scale = 3.f;
    NSMutableArray<UIImage *> *images = [NSMutableArray arrayWithCapacity:count];
    for (size_t i = 0; i < count; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, (__bridge CFDictionaryRef)options);
        UIImage *image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        CGImageRelease(imageRef);
        if (!image) continue;
        [images addObject:image];
        NSDictionary *properties = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL);
        NSDictionary *gifProperties = properties[(__bridge NSString *)kCGImagePropertyGIFDictionary];
        NSNumber *delay = gifProperties[(__bridge NSString *)kCGImagePropertyGIFUnclampedDelayTime];
        if (!delay) {
            delay = gifProperties[(__bridge NSString *)kCGImagePropertyGIFDelayTime];
        }
        duration += delay.doubleValue;
    }
    
    //当loopCount  == 0时，表示无限循环
    NSUInteger loopCount = 0;
    NSDictionary *imageProperties = (__bridge_transfer NSDictionary *)CGImageSourceCopyProperties(imageSource, NULL);
    NSDictionary *gifProperties = [imageProperties objectForKey:(__bridge_transfer NSString *)kCGImagePropertyGIFDictionary];
    if (gifProperties) {
        loopCount = [[gifProperties objectForKey:(__bridge_transfer NSString *)kCGImagePropertyGIFLoopCount] unsignedIntegerValue];
    }
    CFRelease(imageSource);
    
    if (images.count <= 0) return nil;
    if (images.count == 1) return images.firstObject;
    UIImage *animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    animatedImage.loopCount = loopCount;
    return animatedImage;
}

+ (UIImage *)imageWithContentsAtFile:(NSString *)path {
    if (![NSFileManager.defaultManager fileExistsAtPath:path]) return nil;
    if ([path.pathExtension.lowercaseString isEqualToString:@"gif"]) return [UIImage imageWithBlurryData:[NSData dataWithContentsOfFile:path]];
    return [UIImage imageWithContentsOfFile:path];
}

#pragma mark - Setter
- (void)setLoopCount:(NSUInteger)loopCount {
    objc_setAssociatedObject(self, &MNAnimatedImageLoopCountKey, @(loopCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)loopCount {
    return [objc_getAssociatedObject(self, &MNAnimatedImageLoopCountKey) unsignedIntegerValue];
}

#pragma mark - Getter
- (BOOL)isAnimatedImage {
    return ([self isKindOfClass:NSClassFromString(@"_UIAnimatedImage")] && self.images.count > 1);
}

@end



@implementation NSData (MNAnimatedData)

+ (NSData *)dataWithImage:(UIImage *)image {
    if (!image) return nil;
    if (image.isAnimatedImage) return [NSData dataWithAnimatedImage:image duration:0.f loopCount:image.loopCount];
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!imageData || imageData.length <= 0) return UIImageJPEGRepresentation(image, 1.f);
    return imageData;
}

+ (NSData *)dataWithAnimatedImage:(UIImage *)image duration:(NSTimeInterval)duration loopCount:(NSUInteger)loopCount {
    if (!image || !image.isAnimatedImage) return nil;
    // 图片帧
    NSMutableArray <UIImage *>*images = @[].mutableCopy;
    [images addObjectsFromArray:image.images];
    if (images.count <= 0) [images addObject:image.copy];
    // 动画时间
    size_t frameCount = images.count;
    NSTimeInterval frameDuration = (duration <= 0.f ? image.duration/frameCount : duration/frameCount);
    //NSUInteger frameDelayCentiseconds = (NSUInteger)lrint(frameDuration*100.f);
    // 制作GIF数据
    NSDictionary<NSString *, id> *frameProperties = @{(__bridge NSString *)kCGImagePropertyGIFDictionary:@{
           (__bridge NSString *)kCGImagePropertyGIFDelayTime:@(frameDuration)
       }
    };
    NSMutableData *gifData = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)gifData, kUTTypeGIF, frameCount, NULL);
    NSDictionary<NSString *, id> *imageProperties = @{(__bridge NSString *)kCGImagePropertyGIFDictionary:@{
                                                            (__bridge NSString *)kCGImagePropertyGIFLoopCount: @(loopCount)
                                                        }
                                                     };
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)imageProperties);
    for (size_t idx = 0; idx < images.count; idx++) {
        CGImageRef _Nullable cgimage = [images[idx] CGImage];
        if (cgimage) {
            CGImageDestinationAddImage(destination, (CGImageRef _Nonnull)cgimage, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    BOOL success = CGImageDestinationFinalize(destination);
    CFRelease(destination);
    if (success && gifData.length) return [NSData dataWithData:gifData];
    return nil;
}

@end

NSData *UIImageGIFRepresentation(UIImage *image) {
    return [NSData dataWithImage:image];
}
