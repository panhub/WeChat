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
MNMetadataKey const MNMetadataKeyType = @"type";
MNMetadataKey const MNMetadataKeyAuthor = @"author";
MNMetadataKey const MNMetadataKeyFilePath = @"filePath";
MNMetadataKey const MNMetadataKeyCreationDate = @"creationDate";
MNMetadataKey const MNMetadataKeyNaturalSize = @"naturalSize";
MNMetadataKey const MNMetadataKeyThumbnail = @"thumbnail";
MNMetadataKey const MNMetadataKeyDuration = @"duration";

@implementation MNAssetExporter (MNExportMetadata)
#pragma mark - 获取媒体资源时长
+ (NSTimeInterval)exportDurationWithMediaAtPath:(NSString *)filePath {
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
    return [self exportThumbnailOfVideoAtPath:filePath atSeconds:.1f];
}

+ (UIImage *)exportThumbnailOfVideoAtPath:(NSString *)filePath atProgress:(float)progress {
    progress = MIN(.99f, MAX(.01f, progress));
    NSTimeInterval duration = [self exportDurationWithMediaAtPath:filePath];
    return [self exportThumbnailOfVideoAtPath:filePath atSeconds:duration*progress];
}

+ (UIImage *)exportThumbnailOfVideoAtPath:(NSString *)filePath atSeconds:(NSTimeInterval)seconds {
    return [self exportThumbnailOfVideoAtPath:filePath atSeconds:seconds maximumSize:CGSizeZero];
}

+ (UIImage *)exportThumbnailOfVideoAtPath:(NSString *)filePath atSeconds:(NSTimeInterval)seconds maximumSize:(CGSize)maximumSize {
    if (![NSFileManager.defaultManager fileExistsAtPath:filePath]) return nil;
    if (MNAssetExportIsEmptySize(maximumSize)) maximumSize = [self exportNaturalSizeOfVideoAtPath:filePath];
    if (MNAssetExportIsEmptySize(maximumSize)) maximumSize = CGSizeMake(3000.f, 3000.f);
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

+ (NSArray <UIImage *>*)exportThumbnailOfVideoAtPath:(NSString *)filePath count:(NSInteger)count {
    if (![NSFileManager.defaultManager fileExistsAtPath:filePath] || count <= 0) return nil;
    CGSize maximumSize = [self exportNaturalSizeOfVideoAtPath:filePath];
    if (MNAssetExportIsEmptySize(maximumSize)) maximumSize = CGSizeMake(3000.f, 3000.f);
    AVAsset *videoAsset = [AVAsset assetWithMediaAtPath:filePath];
    NSTimeInterval duration = CMTimeGetSeconds(videoAsset.duration);
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:videoAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.maximumSize = maximumSize;
    if (duration <= 0.f) return nil;
    NSMutableArray <UIImage *>*images = @[].mutableCopy;
    for (NSInteger idx = 0; idx < count; idx++) {
        float pro = 1.f/(CGFloat)count*(CGFloat)idx;
        CMTime time = CMTimeMakeWithSeconds(pro*duration, videoAsset.duration.timescale);
        CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:NULL error:NULL];
        if (imageRef != NULL) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            if (image) [images addObject:image];
        }
    }
    return images.count ? images.copy : nil;
}

+ (NSArray <UIImage *>*)exportThumbnailOfVideoAtPath:(NSString *)filePath frameRate:(NSInteger)frameRate {
    NSTimeInterval duration = [MNAssetExporter exportDurationWithMediaAtPath:filePath];
    return [self exportThumbnailOfVideoAtPath:filePath count:ceil(duration*frameRate)];
}

+ (void)exportThumbnailAsynchronouslyOfVideoAtPath:(NSString *)filePath frameRate:(NSInteger)frameRate progressHandler:(void(^)(NSInteger numberOfImage, NSInteger currentIndex))progressHandler completionHandler:(void(^)(NSArray <UIImage *>*))completionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSTimeInterval duration = [self exportDurationWithMediaAtPath:filePath];
        if (duration <= 0.f || frameRate <= 0) {
            if (completionHandler) completionHandler(nil);
            return;
        }
        CGSize maximumSize = [self exportNaturalSizeOfVideoAtPath:filePath];
        if (MNAssetExportIsEmptySize(maximumSize)) maximumSize = CGSizeMake(3000.f, 3000.f);
        NSInteger count = ceil(duration*frameRate);
        NSMutableArray <UIImage *>*images = @[].mutableCopy;
        AVAsset *videoAsset = [AVAsset assetWithMediaAtPath:filePath];
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:videoAsset];
        generator.appliesPreferredTrackTransform = YES;
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        generator.maximumSize = maximumSize;
        for (NSInteger idx = 0; idx < count; idx++) {
            if (progressHandler) progressHandler(count, idx);
            float pro = 1.f/(CGFloat)count*(CGFloat)idx;
            CMTime time = CMTimeMakeWithSeconds(pro*duration, videoAsset.duration.timescale);
            CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:NULL error:NULL];
            if (imageRef != NULL) {
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                if (image) [images addObject:image];
            }
        }
        if (completionHandler) completionHandler(images.count ? images.copy : nil);
    });
}

#pragma mark - 获取媒体文件元数据
+ (NSDictionary<MNMetadataKey, id>*)exportMetadataWithMediaAtPath:(NSString *)filePath {
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory] || isDirectory) return nil;
    AVAsset *asset = [AVAsset assetWithMediaAtPath:filePath];
    AVAssetTrack *videoTrack = [asset trackWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *audioTrack = [asset trackWithMediaType:AVMediaTypeAudio];
    if (!videoTrack && !audioTrack) return nil;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:5];
    [dictionary setObject:filePath forKey:MNMetadataKeyFilePath];
    NSTimeInterval duration = [self exportDurationWithMediaAtPath:filePath];
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
                    if ([value isKindOfClass:NSData.class]) {
                        [dictionary setObject:[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] forKey:MNMetadataKeyTitle];
                    } else if ([value isKindOfClass:NSString.class]) {
                        [dictionary setObject:value forKey:MNMetadataKeyTitle];
                    }
                } else if ([key isEqualToString:AVMetadataCommonKeyArtist]){
                    if ([value isKindOfClass:NSData.class]) {
                        [dictionary setObject:[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] forKey:MNMetadataKeyArtist];
                    } else if ([value isKindOfClass:NSString.class]) {
                        [dictionary setObject:value forKey:MNMetadataKeyArtist];
                    }
                } else if ([key isEqualToString:AVMetadataCommonKeyAuthor]) {
                    if ([value isKindOfClass:NSData.class]) {
                        [dictionary setObject:[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] forKey:MNMetadataKeyAuthor];
                    } else if ([value isKindOfClass:NSString.class]) {
                        [dictionary setObject:value forKey:MNMetadataKeyAuthor];
                    }
                } else if ([key isEqualToString:AVMetadataCommonKeyAlbumName]) {
                    if ([value isKindOfClass:NSData.class]) {
                        [dictionary setObject:[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] forKey:MNMetadataKeyAlbumName];
                    } else if ([value isKindOfClass:NSString.class]) {
                        [dictionary setObject:value forKey:MNMetadataKeyAlbumName];
                    }
                } else if ([key isEqualToString:AVMetadataCommonKeyCreationDate]) {
                    if ([value isKindOfClass:NSData.class]) {
                        [dictionary setObject:[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding] forKey:MNMetadataKeyCreationDate];
                    } else if ([value isKindOfClass:NSString.class]) {
                        [dictionary setObject:value forKey:MNMetadataKeyCreationDate];
                    }
                } else if ([key isEqualToString:AVMetadataCommonKeyArtwork]) {
                    if ([value isKindOfClass:NSData.class]) {
                        UIImage *image = [UIImage imageWithData:value];
                        if (image) [dictionary setObject:image forKey:MNMetadataKeyArtwork];
                    }
                }
            }];
        }];
    }
    return dictionary.copy;
}

+ (NSDictionary<MNMetadataKey, id>*)exportMetadataWithMediaOfURL:(NSURL *)URL {
    return [self exportMetadataWithMediaAtPath:URL.path];
}

+ (UIImage *)exportArtworkWithMediaAtPath:(NSString *)filePath {
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory] || isDirectory) return nil;
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    NSArray <AVMetadataFormat>*formats = [asset availableMetadataFormats];
    UIImage *artwork;
    for (AVMetadataFormat format in formats) {
        NSArray <AVMetadataItem *>*metadataItems = [asset metadataForFormat:format];
        if (metadataItems.count <= 0) continue;
        for (AVMetadataItem *item in metadataItems) {
            if (![item.commonKey isEqualToString:AVMetadataCommonKeyArtwork]) continue;
            id value = item.value;
            if (value && [value isKindOfClass:NSData.class]) {
                artwork = [UIImage imageWithData:(NSData *)value];
            }
            break;
        }
    }
    return artwork;
}

#pragma mark - 获取视频旋转弧度
+ (CGFloat)exportRadianOfVideoAtPath:(NSString *)filePath {
    AVAssetTrack *videoTrack = [AVAsset trackWithMediaAtPath:filePath mediaType:AVMediaTypeVideo];
    if (!videoTrack) return 0.f;
    return videoTrack.rotateRadian;
}

@end
