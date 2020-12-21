//
//  MNAssetExporter+ExportHelper.h
//  MNKit
//
//  Created by Vincent on 2019/12/16.
//  Copyright © 2019 Vincent. All rights reserved.
//  资源输出

#import "MNAssetExporter.h"
#if __has_include(<AVFoundation/AVFoundation.h>)

NS_ASSUME_NONNULL_BEGIN

typedef NSString * _Nonnull MNFileType NS_EXTENSIBLE_STRING_ENUM;
FOUNDATION_EXTERN MNFileType const MNFileTypeMOV;
FOUNDATION_EXTERN MNFileType const MNFileTypeM4A;
FOUNDATION_EXTERN MNFileType const MNFileTypeM4V;
FOUNDATION_EXTERN MNFileType const MNFileTypeMPEG3;
FOUNDATION_EXTERN MNFileType const MNFileTypeMPEG4;

typedef NSString * _Nonnull MNMetadataKey NS_EXTENSIBLE_STRING_ENUM;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyTitle;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyArtist;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyAlbumName;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyArtwork;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyType;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyAuthor;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyFilePath;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyCreationDate;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyNaturalSize;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyThumbnail;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyDuration;

@interface MNAssetExporter (MNExportMetadata)
/**
 获取媒体资源时长
 @param filePath 媒体资源路径
 @return 媒体资源时长
 */
+ (NSTimeInterval)exportDurationWithMediaAtPath:(NSString *)filePath;

/**
 获取视频尺寸
 @param filePath 视频路径
 @return 视频尺寸
 */
+ (CGSize)exportNaturalSizeOfVideoAtPath:(NSString *)filePath;

/**
 获取视频图像
 @param filePath 视频路径
 @return 视频图像
 */
+ (UIImage *_Nullable)exportThumbnailOfVideoAtPath:(NSString *)filePath;

/**
 获取视频图像
 @param filePath 视频路径
 @param seconds 指定秒
 @return 视频图像
 */
+ (UIImage *_Nullable)exportThumbnailOfVideoAtPath:(NSString *)filePath atSeconds:(NSTimeInterval)seconds;

/**
 获取视频图像
 @param filePath 视频路径
 @param progress 指定进度
 @return 视频图像
 */
+ (UIImage *_Nullable)exportThumbnailOfVideoAtPath:(NSString *)filePath atProgress:(float)progress;

/**
 获取视频图像
 @param filePath 视频路径
 @param seconds 指定秒
 @param maximumSize 最大尺寸
*/
+ (UIImage *_Nullable)exportThumbnailOfVideoAtPath:(NSString *)filePath atSeconds:(NSTimeInterval)seconds maximumSize:(CGSize)maximumSize;

/**
 获取视频图像
 @param filePath 视频路径
 @param count 图像数量
 @return 视频图像数组
 */
+ (NSArray <UIImage *>*_Nullable)exportThumbnailOfVideoAtPath:(NSString *)filePath count:(NSInteger)count;

/**
 获取视频图像
 @param filePath 视频路径
 @param frameRate 帧率
 @return 视频图像数组
 */
+ (NSArray <UIImage *>*_Nullable)exportThumbnailOfVideoAtPath:(NSString *)filePath frameRate:(NSInteger)frameRate;

/**
 异步输出截图
 @param filePath 视频路径
 @param frameRate 帧率
 @param progressHandler 进度回调
 @param completionHandler 完成回调
 */
+ (void)exportThumbnailAsynchronouslyOfVideoAtPath:(NSString *)filePath frameRate:(NSInteger)frameRate progressHandler:(void(^_Nullable)(NSInteger totalCount, NSInteger currentIndex))progressHandler completionHandler:(void(^_Nullable)(NSArray <UIImage *>*_Nullable))completionHandler;

/**
 获取媒体文件元数据
 @param filePath 媒体文件路径
 @return 媒体文件元数据
 */
+ (NSDictionary<MNMetadataKey, id>*_Nullable)exportMetadataWithMediaAtPath:(NSString *)filePath;

/**
 获取媒体文件元数据
 @param URL 媒体文件URL
 @return 媒体文件元数据
 */
+ (NSDictionary<MNMetadataKey, id>*_Nullable)exportMetadataWithMediaOfURL:(NSURL *)URL;

/**
 获取音频封面插图
 @param filePath 文件路径
 @return 音频封面插图
 */
+ (UIImage *_Nullable)exportArtworkWithMediaAtPath:(NSString *)filePath;

/**
 获取视频旋转弧度
 @param filePath 视频路径
 @return 旋转弧度
 */
+ (CGFloat)exportRadianOfVideoAtPath:(NSString *)filePath;

@end
NS_ASSUME_NONNULL_END
#endif
