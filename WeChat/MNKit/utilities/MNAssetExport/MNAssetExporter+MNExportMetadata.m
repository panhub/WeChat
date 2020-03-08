//
//  MNAssetExporter+ExportHelper.m
//  MNKit
//
//  Created by Vincent on 2019/12/16.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetExporter+MNExportMetadata.h"
#import "AVAsset+MNExportMetadata.h"
#import "AVAssetTrack+MNExportMetadata.h"

MNFileType const MNFileTypeMOV = @"mov";
MNFileType const MNFileTypeM4A = @"m4a";
MNFileType const MNFileTypeM4V = @"m4v";
MNFileType const MNFileTypeMPEG3 = @"mp3";
MNFileType const MNFileTypeMPEG4 = @"mp4";

MNMetadataKey const MNMetadataKeyTitle = @"title";
MNMetadataKey const MNMetadataKeyArtist = @"artist";
MNMetadataKey const MNMetadataKeyAlbumName = @"albumName";
MNMetadataKey const MNMetadataKeyArtwork = @"artwork";
MNMetadataKey const MNMetadataKeySize = @"size";
MNMetadataKey const MNMetadataKeyType = @"type";
MNMetadataKey const MNMetadataKeyAuthor = @"author";
MNMetadataKey const MNMetadataKeyFilePath = @"filePath";
MNMetadataKey const MNMetadataKeyCreationDate = @"creationDate";
MNMetadataKey const MNMetadataKeyNaturalSize = @"naturalSize";
MNMetadataKey const MNMetadataKeyThumbnail = @"thumbnail";
MNMetadataKey const MNMetadataKeyDuration = @"duration";

@implementation MNAssetExporter (MNExportMetadata)
#pragma mark - 获取媒体资源时长
+ (NSTimeInterval)exportDurationWithAssetAtPath:(NSString *)filePath {
    AVURLAsset *asset = [AVAsset assetWithMediaAtPath:filePath];
    if (!asset) return 0.f;
    return asset.seconds;
}

#pragma mark - 获取视频分辨率
+ (CGSize)exportNaturalSizeOfVideoAtPath:(NSString *)filePath {
    AVAssetTrack *videoTrack = [AVAsset trackWithMediaAtPath:filePath mediaType:AVMediaTypeVideo];
    if (!videoTrack) return CGSizeZero;
    return videoTrack.naturalSizeOfVideo;
}

#pragma mark - 获取视频缩略图
+ (UIImage *)exportThumbnailOfVideoAtPath:(NSString *)filePath {
    return [self exportThumbnailOfVideoAtPath:filePath atSeconds:0.1];
}

+ (UIImage *)exportThumbnailOfVideoAtPath:(NSString *)filePath atProgress:(float)progress {
    progress = MIN(.99f, MAX(.01f, progress));
    NSTimeInterval duration = [self exportDurationWithAssetAtPath:filePath];
    return [self exportThumbnailOfVideoAtPath:filePath atSeconds:duration*progress];
}

+ (UIImage *)exportThumbnailOfVideoAtPath:(NSString *)filePath atSeconds:(NSTimeInterval)seconds {
    return [self exportThumbnailOfVideoAtPath:filePath atSeconds:seconds maximumSize:CGSizeZero];
}

+ (UIImage *)exportThumbnailOfVideoAtPath:(NSString *)filePath atSeconds:(NSTimeInterval)seconds maximumSize:(CGSize)maximumSize {
    if (MNAssetExportIsEmptySize(maximumSize)) {
        CGSize naturalSize = [self exportNaturalSizeOfVideoAtPath:filePath];
        maximumSize = MNAssetExportIsEmptySize(naturalSize) ? CGSizeMake(500.f, 500.f) : naturalSize;
    }
    AVAsset *videoAsset = [AVAsset assetWithMediaAtPath:filePath];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:videoAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.maximumSize = maximumSize;
    CMTime time = videoAsset.duration;
    time.value = time.timescale*seconds;
    CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:NULL error:NULL];
    if (imageRef == NULL) return nil;
    return [UIImage imageWithCGImage:imageRef];
}

#pragma mark - 获取媒体文件元数据
+ (NSDictionary<MNMetadataKey, id>*)exportMediaMetadataWithContentsOfPath:(NSString *)filePath {
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory] || isDirectory) return nil;
    AVAsset *asset = [AVAsset assetWithMediaAtPath:filePath];
    AVAssetTrack *videoTrack = [asset trackWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *audioTrack = [asset trackWithMediaType:AVMediaTypeAudio];
    if (!videoTrack && !audioTrack) return nil;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:5];
    [dictionary setObject:filePath forKey:MNMetadataKeyFilePath];
    CGFloat itemSize = [MNFileManager itemSizeAtPath:filePath];
    [dictionary setObject:[NSString stringWithFormat:@"%@", @(itemSize)] forKey:MNMetadataKeySize];
    NSTimeInterval duration = [self exportDurationWithAssetAtPath:filePath];
    [dictionary setObject:[NSString stringWithFormat:@"%@", @(duration)] forKey:MNMetadataKeyDuration];
    if (videoTrack) {
        [dictionary setObject:videoTrack.mediaType forKey:MNMetadataKeyType];
        CGSize naturalSize = [self exportNaturalSizeOfVideoAtPath:filePath];
        [dictionary setObject:[NSValue valueWithCGSize:naturalSize] forKey:MNMetadataKeyNaturalSize];
        UIImage *thumbnail = [self exportThumbnailOfVideoAtPath:filePath];
        if (thumbnail) [dictionary setObject:thumbnail forKey:MNMetadataKeyThumbnail];
    } else {
        [dictionary setObject:audioTrack.mediaType forKey:MNMetadataKeyType];
        NSArray <AVMetadataFormat>*metadataFormats = [asset availableMetadataFormats];
        [metadataFormats enumerateObjectsUsingBlock:^(AVMetadataFormat  _Nonnull format, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray <AVMetadataItem *>*metadataItems = [asset metadataForFormat:format];
            [metadataItems enumerateObjectsUsingBlock:^(AVMetadataItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                AVMetadataKey key = item.commonKey;
                id value = item.value;
                if ([key isEqualToString:AVMetadataCommonKeyTitle]){
                    //NSString *title = (NSString *)value;
                    [dictionary setObject:value forKey:MNMetadataKeyTitle];
                } else if ([key isEqualToString:AVMetadataCommonKeyArtist]){
                    //NSString *artist = (NSString *)value;
                    [dictionary setObject:value forKey:MNMetadataKeyArtist];
                } else if ([key isEqualToString:AVMetadataCommonKeyAuthor]) {
                    //NSString *author = (NSString *)value;
                    [dictionary setObject:value forKey:MNMetadataKeyAuthor];
                } else if ([key isEqualToString:AVMetadataCommonKeyAlbumName]) {
                    //NSString *albumName = (NSString *)value;
                    [dictionary setObject:value forKey:MNMetadataKeyAlbumName];
                } else if ([key isEqualToString:AVMetadataCommonKeyCreationDate]) {
                    [dictionary setObject:value forKey:MNMetadataKeyCreationDate];
                } else if ([key isEqualToString:AVMetadataCommonKeyArtwork]) {
                    NSDictionary *artwork = (NSDictionary *)value;
                    NSData *data = [artwork objectForKey:@"data"];
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) [dictionary setObject:image forKey:MNMetadataKeyArtwork];
                }
            }];
        }];
    }
    return dictionary.copy;
}

+ (NSDictionary<MNMetadataKey, id>*)exportMediaMetadataWithContentsOfURL:(NSURL *)URL {
    return [self exportMediaMetadataWithContentsOfPath:URL.path];
}

#pragma mark - 获取视频旋转弧度
+ (CGFloat)exportRadianOfVideoAtPath:(NSString *)filePath {
    AVAssetTrack *videoTrack = [AVAsset trackWithMediaAtPath:filePath mediaType:AVMediaTypeVideo];
    if (!videoTrack) return 0.f;
    return videoTrack.rotateRadian;
}

+ (CGFloat)exportRadianOfVideoAtURL:(NSURL *)URL {
    return [self exportRadianOfVideoAtPath:URL.path];
}

@end
