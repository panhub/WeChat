//
//  MNLivePhoto.h
//  MNKit
//
//  Created by Vincent on 2019/12/14.
//  Copyright © 2019 Vincent. All rights reserved.
//  视频转LivePhoto解决方案

#import <Foundation/Foundation.h>
#if __has_include(<Photos/PHLivePhoto.h>)
@class PHLivePhoto;

@interface MNLivePhoto : NSObject
/**
 mov路径
 */
@property (nonatomic, copy, readonly) NSURL *videoURL;
/**
 jpeg图片路径
 */
@property (nonatomic, copy, readonly) NSURL *imageURL;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_1
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
/**
 LivePhoto
 */
@property (nonatomic, strong, readonly) PHLivePhoto *content;
#pragma clang diagnostic pop

/**
 生成LivePhoto<MNLivePhoto>
 @param videoPath 视频路径
 @param completionHandler 完成回调
 */
+ (void)requestLivePhotoWithVideoFileAtPath:(NSString *)videoPath
                              completionHandler:(void(^)(MNLivePhoto *livePhoto))completionHandler;

/**
 生成LivePhoto<MNLivePhoto><进度>
 @param videoPath 视频路径
 @param seconds 瞬时照片所在秒数
 @param duration 瞬时照片持续时长
 @param progressHandler 进度回调
 @param completionHandler 完成回调 Float64 stillDuration
*/
+ (void)requestLivePhotoWithVideoFileAtPath:(NSString *)videoPath
                               stillSeconds:(NSTimeInterval)seconds
                                    stillDuration:(Float64)duration
                            progressHandler:(void(^)(float  progress))progressHandler
                    completionHandler:(void(^)(MNLivePhoto *livePhoto))completionHandler;
#endif

/**
 生成LivePhoto<本地路径>
 @param videoPath 视频路径
 @param completionHandler 完成回调
 */
+ (void)requestLivePhotoWithVideoAtPath:(NSString *)videoPath
                    completionHandler:(void(^)(NSString *jpgPath, NSString *movPath))completionHandler;

/**
 生成LivePhoto<本地路径><进度>
 @param videoPath 视频路径
 @param seconds 瞬时照片所在秒数
 @param duration 瞬时照片持续时长
 @param progressHandler 进度回调
 @param completionHandler 完成回调
*/
+ (void)requestLivePhotoWithVideoAtPath:(NSString *)videoPath
                           stillSeconds:(NSTimeInterval)seconds
                                stillDuration:(Float64)duration
                      progressHandler:(void(^)(float  progress))progressHandler
                    completionHandler:(void(^)(NSString *jpgPath, NSString *movPath))completionHandler;

/**
 删除本地文件
 */
- (void)removeFiles;

@end
#endif

