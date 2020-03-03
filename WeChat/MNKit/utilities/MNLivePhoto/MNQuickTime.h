//
//  MNQuickTime.h
//  MNKit
//
//  Created by Vincent on 2019/12/14.
//  Copyright © 2019 Vincent. All rights reserved.
//  为LivePhoto解决Mov处理方案

#import <Foundation/Foundation.h>

@interface MNQuickTime : NSObject

/**视频Asset*/
@property (nonatomic, strong) AVURLAsset *videoAsset;

/**
 依据Asset实例化
 @param videoAsset 视频资源
 @return Mov处理实例
 */
- (instancetype)initWithVideoAsset:(AVURLAsset *)videoAsset;
/**
 依据视频URL实例化
 @param URL 视频URL
 @return Mov处理实例
 */
- (instancetype)initWithVideoOfURL:(NSURL *)URL;
/**
 依据视频路径实例化
 @param videoPath 视频路径
 @return Mov处理实例
 */
- (instancetype)initWithVideoOfFile:(NSString *)videoPath;

/**
将视频处理为mov格式
 @param path 指定输出路径
 @param identifier 唯一标识<配合JPEG>
 @param completionHandler 结束回调
 */
- (void)writeToFileAsynchronously:(NSString *)path
                   withIdentifier:(NSString *)identifier
                completionHandler:(void(^)(BOOL succeed))completionHandler;

/**
将视频处理为mov格式<带有进度>
 @param path 指定输出路径
 @param identifier 唯一标识<配合JPEG>
 @param progressHandler 进度值
 @param completionHandler 结束回调
 */
- (void)writeToFileAsynchronously:(NSString *)path
                   withIdentifier:(NSString *)identifier
                  progressHandler:(void(^)(float  progress))progressHandler
                completionHandler:(void(^)(BOOL succeed))completionHandler;

@end
