//
//  MNAssetExporter+ExportHelper.h
//  MNKit
//
//  Created by Vincent on 2019/12/16.
//  Copyright © 2019 Vincent. All rights reserved.
//  资源输出

#import "MNAssetExporter.h"

typedef NSString * MNFileType NS_EXTENSIBLE_STRING_ENUM;
FOUNDATION_EXTERN MNFileType const MNFileTypeMOV;
FOUNDATION_EXTERN MNFileType const MNFileTypeM4A;
FOUNDATION_EXTERN MNFileType const MNFileTypeM4V;
FOUNDATION_EXTERN MNFileType const MNFileTypeMPEG3;
FOUNDATION_EXTERN MNFileType const MNFileTypeMPEG4;

typedef NSString * MNMetadataKey NS_EXTENSIBLE_STRING_ENUM;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyTitle;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyArtist;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyAlbumName;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeyArtwork;
FOUNDATION_EXTERN MNMetadataKey const MNMetadataKeySize;
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
+ (NSTimeInterval)exportDurationWithAssetAtPath:(NSString *)filePath;

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
+ (UIImage *)exportThumbnailOfVideoAtPath:(NSString *)filePath;

/**
 获取视频图像
 @param filePath 视频路径
 @param seconds 指定秒
 @return 视频图像
 */
+ (UIImage *)exportThumbnailOfVideoAtPath:(NSString *)filePath atSeconds:(NSTimeInterval)seconds;

/**
 获取视频图像
 @param filePath 视频路径
 @param progress 指定进度
 @return 视频图像
 */
+ (UIImage *)exportThumbnailOfVideoAtPath:(NSString *)filePath atProgress:(float)progress;

/**
 获取视频图像
 @param filePath 视频路径
 @param seconds 指定秒
 @param maximumSize 最大尺寸
*/
+ (UIImage *)exportThumbnailOfVideoAtPath:(NSString *)filePath atSeconds:(NSTimeInterval)seconds maximumSize:(CGSize)maximumSize;

/**
 获取媒体文件元数据
 @param filePath 媒体文件路径
 @return 媒体文件元数据
 */
+ (NSDictionary<MNMetadataKey, id>*)exportMediaMetadataWithContentsOfPath:(NSString *)filePath;

/**
 获取媒体文件元数据
 @param URL 媒体文件URL
 @return 媒体文件元数据
 */
+ (NSDictionary<MNMetadataKey, id>*)exportMediaMetadataWithContentsOfURL:(NSURL *)URL;

/**
 获取视频旋转弧度
 @param filePath 视频路径
 @return 旋转弧度
 */
+ (CGFloat)exportRadianOfVideoAtPath:(NSString *)filePath;

/**
 获取视频旋转弧度
 @param URL 视频URL
 @return 旋转弧度
 */
+ (CGFloat)exportRadianOfVideoAtURL:(NSURL *)URL;

@end
