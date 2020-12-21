//
//  AVAsset+MNExportMetadata.m
//  MNKit
//
//  Created by Vincent on 2019/12/31.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "AVAsset+MNExportMetadata.h"
#if __has_include(<AVFoundation/AVFoundation.h>)

@implementation AVAsset (MNExportMetadata)
#pragma mark - 资源时长
- (Float64)seconds {
    return CMTimeGetSeconds(self.duration);
}

#pragma mark - 获取本地资源
+ (AVURLAsset *)assetWithMediaAtPath:(NSString *)filePath {
    if (!filePath || filePath.length <= 0) return nil;
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

#pragma mark - TimeRange
- (CMTimeRange)timeRangeWithSeconds:(NSRange)range {
    return [self timeRangeFromSeconds:range.location toSeconds:NSMaxRange(range)];
}

- (CMTimeRange)timeRangeFromProgress:(float)fromProgress toProgress:(float)toProgress {
    CMTime time = self.duration;
    NSTimeInterval duration = CMTimeGetSeconds(time);
    fromProgress = MIN(.99f, MAX(0.f, fromProgress));
    toProgress = MAX(.01f, MIN(1.f, toProgress));
    if (duration <= 0.f || fromProgress >= toProgress) return kCMTimeRangeZero;
    CMTimeRange timeRange = kCMTimeRangeZero;
    timeRange.start = CMTimeAdd(kCMTimeZero, CMTimeMakeWithSeconds(fromProgress*duration, time.timescale));
    timeRange.duration = CMTimeAdd(kCMTimeZero, CMTimeMakeWithSeconds(toProgress*duration, time.timescale));
    return timeRange;
}

- (CMTimeRange)timeRangeFromSeconds:(NSTimeInterval)fromSeconds toSeconds:(NSTimeInterval)toSeconds {
    CMTime time = self.duration;
    NSTimeInterval duration = CMTimeGetSeconds(time);
    fromSeconds = MIN(duration - 1.f, MAX(0.f, fromSeconds));
    toSeconds = MAX(1.f, MIN(duration, toSeconds));
    if (duration <= 0.f || fromSeconds >= toSeconds) return kCMTimeRangeZero;
    CMTimeRange timeRange = kCMTimeRangeZero;
    timeRange.start = CMTimeAdd(kCMTimeZero, CMTimeMakeWithSeconds(fromSeconds, time.timescale));
    timeRange.duration = CMTimeAdd(kCMTimeZero, CMTimeMakeWithSeconds(toSeconds - fromSeconds, time.timescale));
    return timeRange;
}

@end


@implementation AVMutableComposition (MNExportMetadata)

- (AVMutableCompositionTrack *)compositionTrackWithMediaType:(AVMediaType)mediaType {
    AVMutableCompositionTrack *compositionTrack = (AVMutableCompositionTrack *)[self trackWithMediaType:mediaType];
    if (!compositionTrack) {
        compositionTrack = [self addMutableTrackWithMediaType:mediaType preferredTrackID:kCMPersistentTrackID_Invalid];
    }
    return compositionTrack;
}

- (void)removeTrackWithMediaType:(AVMediaType)mediaType {
    NSArray <AVAssetTrack *>*tracks = [self tracksWithMediaType:mediaType];
    [tracks enumerateObjectsUsingBlock:^(AVAssetTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.mediaType == mediaType && [obj isKindOfClass:AVCompositionTrack.class]) {
            [self removeTrack:(AVCompositionTrack *)obj];
        }
    }];
}

- (void)removeAllTracks {
    NSArray <AVMediaType>*types = @[AVMediaTypeVideo, AVMediaTypeAudio];
    [types enumerateObjectsUsingBlock:^(AVMediaType  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTrackWithMediaType:obj];
    }];
}

@end
#endif
