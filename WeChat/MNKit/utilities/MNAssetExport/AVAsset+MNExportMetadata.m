//
//  AVAsset+MNExportMetadata.m
//  MNKit
//
//  Created by Vincent on 2019/12/31.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "AVAsset+MNExportMetadata.h"

@implementation AVAsset (MNExportMetadata)
#pragma mark - 资源时长
- (Float64)seconds {
    return CMTimeGetSeconds(self.duration);
}

#pragma mark - 获取本地资源
+ (AVURLAsset *)assetWithMediaAtPath:(NSString *)filePath {
    if ([filePath hasPrefix:@"http"]) {
        return [self assetWithMediaOfURL:[NSURL URLWithString:filePath]];
    } else {
        return [self assetWithMediaOfURL:[NSURL fileURLWithPath:filePath]];
    }
}

+ (AVURLAsset *)assetWithMediaOfURL:(NSURL *)URL {
    if (!URL) return nil;
    if (URL.isFileURL && ![NSFileManager.defaultManager fileExistsAtPath:URL.path]) return nil;
    return [AVURLAsset URLAssetWithURL:URL options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)}];
}

#pragma mark - 获取媒体音/视素材
- (AVAssetTrack *)trackWithMediaType:(AVMediaType)mediaType {
    NSArray <AVAssetTrack *>*tracks = [self tracksWithMediaType:mediaType];
    if (tracks.count <= 0) return nil;
    return tracks.firstObject;
}

+ (AVAssetTrack *)trackWithMediaAtPath:(NSString *)filePath mediaType:(AVMediaType)mediaType {
    return [[self assetWithMediaAtPath:filePath] trackWithMediaType:mediaType];
}

@end
