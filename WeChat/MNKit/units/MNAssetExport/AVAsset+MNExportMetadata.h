//
//  AVAsset+MNExportMetadata.h
//  MNKit
//
//  Created by Vincent on 2019/12/31.
//  Copyright © 2019 Vincent. All rights reserved.
//  资源获取

#import <AVFoundation/AVFoundation.h>
#if __has_include(<AVFoundation/AVFoundation.h>)

NS_ASSUME_NONNULL_BEGIN

@interface AVAsset (MNExportMetadata)

/**资源文件时长*/
@property (nonatomic, readonly) Float64 seconds;

/**
 获取本地媒体资源
 @param filePath 媒体资源路径
 @return 媒体资源文件
 */
+ (AVURLAsset *_Nullable)assetWithMediaAtPath:(NSString *)filePath;

/**
 获取本地媒体资源
 @param URL 媒体资源URL
 @return 媒体资源文件
 */
+ (AVURLAsset *_Nullable)assetWithMediaOfURL:(NSURL *)URL;

/**
 获取资源轨道
 @param mediaType 媒体资源类型
 @return 资源轨道
 */
- (AVAssetTrack *_Nullable)trackWithMediaType:(AVMediaType)mediaType;

/**
 获取媒体音/视素材
 @param filePath 媒体路径
 @param mediaType 素材类型
 @return 音/视素材
 */
+ (AVAssetTrack *_Nullable)trackWithMediaAtPath:(NSString *)filePath mediaType:(AVMediaType)mediaType;

/**
 获取时间范围
 @param range 秒数范围
 @return 时间范围
 */
- (CMTimeRange)timeRangeWithSeconds:(NSRange)range;

/**
 获取时间范围
 @param fromProgress 起始进度
 @param toProgress 截止进度
 @return 时间范围
 */
- (CMTimeRange)timeRangeFromProgress:(float)fromProgress toProgress:(float)toProgress;

/**
 获取时间范围
 @param fromSeconds 起始秒数
 @param toSeconds 截止秒数
 @return 时间范围
 */
- (CMTimeRange)timeRangeFromSeconds:(NSTimeInterval)fromSeconds toSeconds:(NSTimeInterval)toSeconds;

@end


@interface AVMutableComposition (MNExportMetadata)

/**
 获取媒体音/视可变素材
 @param mediaType 素材类型
 @return 音/视可变素材
 */
- (AVMutableCompositionTrack *)compositionTrackWithMediaType:(AVMediaType)mediaType;

/**
 删除指定类型的素材
 @param mediaType 指定类型
 */
- (void)removeTrackWithMediaType:(AVMediaType)mediaType;

/**
 删除所有素材
 */
- (void)removeAllTracks;

@end

NS_ASSUME_NONNULL_END
#endif
