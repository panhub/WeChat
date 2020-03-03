//
//  AVAsset+MNExportMetadata.h
//  MNKit
//
//  Created by Vincent on 2019/12/31.
//  Copyright © 2019 Vincent. All rights reserved.
//  资源获取

#import <AVFoundation/AVFoundation.h>

@interface AVAsset (MNExportMetadata)
/**资源文件时长*/
@property (nonatomic, readonly) Float64 seconds;

/**
 获取本地媒体资源
 @param filePath 媒体资源路径
 @return 媒体资源文件
 */
+ (AVURLAsset *)assetWithContentsOfPath:(NSString *)filePath;

/**
 获取本地媒体资源
 @param URL 媒体资源URL
 @return 媒体资源文件
 */
+ (AVURLAsset *)assetWithContentsOfURL:(NSURL *)URL;

/**
 获取资源轨道
 @param mediaType 媒体资源类型
 @return 资源轨道
 */
- (AVAssetTrack *)trackWithMediaType:(AVMediaType)mediaType;

/**
 获取媒体音/视素材
 @param filePath 媒体路径
 @param mediaType 素材类型
 @return 音/视素材
 */
+ (AVAssetTrack *)trackWithMediaAtPath:(NSString *)filePath mediaType:(AVMediaType)mediaType;

@end

