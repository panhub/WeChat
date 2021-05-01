//
//  MNCapturePhoto.h
//  MNKit
//
//  Created by Vicent on 2021/3/6.
//  Copyright © 2021 Vincent. All rights reserved.
//  拍摄照片封装

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNCapturePhoto : NSObject

/**图片实例*/
@property (nonatomic, strong, nullable) UIImage *image;

/**图片数据流*/
@property (nonatomic, strong, nullable) NSData *imageData;

/**是否是LivePhoto*/
@property (nonatomic, readonly) BOOL isLivePhoto;

/**
 图片实例化方式
 @param image 图片
 @return 拍摄照片实例
 */
+ (nullable instancetype)photoWithImage:(UIImage *)image;

/**
 图片实例化方式<推荐使用>
 @param imageData 图像数据流
 @return 拍摄照片实例
 */
+ (nullable instancetype)photoWithImageData:(NSData *)imageData;

#if __has_include(<CoreMedia/CMSampleBuffer.h>)
/**
 图片实例化方式<内部转换NSData>
 @param dataBuffer 图片缓冲帧
 @return 拍摄照片实例
 */
+ (nullable instancetype)photoWithDataBuffer:(CMSampleBufferRef)dataBuffer;

/**
 图片实例化方式<内部转换UIImage>
 @param imageSampleBuffer 图片缓冲帧
 @return 拍摄照片实例
 */
+ (nullable instancetype)photoWithSampleBuffer:(CMSampleBufferRef)imageSampleBuffer;
#endif

@end



@interface MNCaptureLivePhoto : MNCapturePhoto

/**时长*/
@property (nonatomic) CMTime duration;

/**图片所在时间*/
@property (nonatomic) CMTime photoDisplayTime;

/**LivePhoto的视频位置*/
@property (nonatomic, copy, nullable) NSURL *videoURL;

/**
 转换MNCapturePhoto为MNCaptureLivePhoto
 @param photo 照片实例
 @return LivePhoto实例
 */
+ (nullable MNCaptureLivePhoto *)liveWithPhoto:(MNCapturePhoto *)photo;

@end

NS_ASSUME_NONNULL_END
