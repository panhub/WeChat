//
//  MNLivePhoto.h
//  MNKit
//
//  Created by Vincent on 2019/12/14.
//  Copyright © 2019 Vincent. All rights reserved.
//  视频转LivePhoto解决方案

#import <Foundation/Foundation.h>
#if __has_include(<Photos/PHLivePhoto.h>)

@interface MNLivePhoto : NSObject
/**
 mov路径
 */
@property (nonatomic, copy, readonly) NSString *videoPath;
/**
 jpeg图片路径
 */
@property (nonatomic, copy, readonly) NSString *imagePath;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_1
/**
 LivePhoto
 */
@property (nonatomic, strong, readonly) id content;

/**
 生成LivePhoto<MNLivePhoto>
 @param videoPath 视频路径
 @param completionHandler 完成回调
 */
+ (void)requestLivePhotoWithVideoResourceOfPath:(NSString *)videoPath
                              completionHandler:(void(^)(MNLivePhoto *livePhoto))completionHandler;

/**
 生成LivePhoto<MNLivePhoto><进度>
 @param videoPath 视频路径
 @param progressHandler 进度回调
 @param completionHandler 完成回调
*/
+ (void)requestLivePhotoWithVideoResourceOfPath:(NSString *)videoPath
                                progressHandler:(void(^)(float  progress))progressHandler
                              completionHandler:(void(^)(MNLivePhoto *livePhoto))completionHandler;
#endif

/**
 生成LivePhoto<本地路径>
 @param videoPath 视频路径
 @param completionHandler 完成回调
 */
+ (void)requestLivePhotoWithVideoPath:(NSString *)videoPath
                    completionHandler:(void(^)(NSString *jpgPath, NSString *movPath))completionHandler;

/**
 生成LivePhoto<本地路径><进度>
 @param videoPath 视频路径
 @param progressHandler 进度回调
 @param completionHandler 完成回调
*/
+ (void)requestLivePhotoWithVideoPath:(NSString *)videoPath
                      progressHandler:(void(^)(float  progress))progressHandler
                    completionHandler:(void(^)(NSString *jpgPath, NSString *movPath))completionHandler;

/**
 删除本地文件
 */
- (void)removeContents;

@end
#endif

