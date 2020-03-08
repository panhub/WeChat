//
//  MNAssetExportSession.m
//  MNFoundation
//
//  Created by Vincent on 2019/12/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetExportSession.h"
#if __has_include(<AVFoundation/AVFoundation.h>)
#import <AVFoundation/AVFoundation.h>
#import "AVAsset+MNExportMetadata.h"
#import "AVAssetTrack+MNExportMetadata.h"

static BOOL MNAssetExportSessionIsEmptySize (CGSize size) {
    return (isnan(size.width) || isnan(size.height) || size.width <= 0.f || size.height <= 0.f);
}

@interface MNAssetExportSession ()
/**错误信息*/
@property (nonatomic, copy) NSError *error;
/**输出状态*/
@property (nonatomic) AVAssetExportSessionStatus status;
/**资源合成器*/
@property (nonatomic, strong) AVMutableComposition *composition;
/**结束回调*/
@property (nonatomic, copy) MNAssetExportSessionCompletionHandler completionHandler;
@end

@implementation MNAssetExportSession
@synthesize renderSize = _renderSize;
- (instancetype)init {
    if (self = [super init]) {
        self.exportAudioTrack = YES;
        self.exportVideoTrack = YES;
        self.shouldOptimizeForNetworkUse = YES;
        self.composition = AVMutableComposition.composition;
    }
    return self;
}

- (instancetype)initWithAsset:(AVAsset *)asset {
    if (!asset) return nil;
    self = [self init];
    if (!self) return nil;
    [self appendAsset:asset];
    return self;
}

- (instancetype)initWithContentsOfFile:(NSString *)filePath {
    self = [self init];
    if (!self) return nil;
    self.filePath = filePath;
    return self;
}

- (instancetype)initWithContentsOfURL:(NSURL *)fileURL {
    return [self initWithContentsOfFile:fileURL.path];
}

#pragma mark - Export
- (void)exportAsynchronouslyWithCompletionHandler:(MNAssetExportSessionCompletionHandler)completionHandler {
    if (self.status == AVAssetExportSessionStatusWaiting || self.status == AVAssetExportSessionStatusExporting) return;
    self.error = nil;
    self.completionHandler = completionHandler;
    self.status = AVAssetExportSessionStatusUnknown;
    
    /*
    // 检查输出参数
    if (self.exportVideoTrack && MNAssetExportSessionIsEmptySize(self.outputRect.size)) {
        [self finishExportWithError:[NSError errorWithDomain:AVFoundationErrorDomain
                                                        code:AVErrorExportFailed
                                                    userInfo:@{NSLocalizedDescriptionKey:@"output rect error"}]];
        return;
    }
    */
    
    // 检查输出目录
    if (self.outputPath.length <= 0 || ![NSFileManager.defaultManager createDirectoryAtPath:[self.outputPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil]) {
        [self finishExportWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                        code:NSURLErrorCannotCreateFile
                                                    userInfo:@{NSLocalizedDescriptionKey:@"create output directory failed"}]];
        return;
    }
    
    // 检查媒体文件
    if (self.composition.tracks.count <= 0) {
        [self finishExportWithError:[NSError errorWithDomain:AVFoundationErrorDomain
                                                        code:AVErrorInvalidSourceMedia
                                                    userInfo:@{NSLocalizedDescriptionKey:@"not media track input"}]];
        return;
    }
    
    // 标记错误信息
    NSError *error = nil;
    
    // 获取视/音素材
    AVAssetTrack *videoTrack = [self.composition trackWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *audioTrack = [self.composition trackWithMediaType:AVMediaTypeAudio];
    AVMutableComposition *composition = AVMutableComposition.composition;
    if (videoTrack && self.isExportVideoTrack) {
        CMTimeRange timeRange = CMTIMERANGE_IS_VALID(self.timeRange) ? self.timeRange : CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration);
        AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionTrack insertTimeRange:timeRange
                                  ofTrack:videoTrack
                                   atTime:kCMTimeZero
                                    error:&error];
        compositionTrack.preferredTransform = videoTrack.preferredTransform;
        if (error) {
            [self finishExportWithError:error];
            return;
        }
        NSLog(@"add video track.");
    }
    if (audioTrack && self.isExportAudioTrack) {
        CMTimeRange timeRange = CMTIMERANGE_IS_VALID(self.timeRange) ? self.timeRange : CMTimeRangeMake(kCMTimeZero, audioTrack.timeRange.duration);
        AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionTrack insertTimeRange:timeRange
                                  ofTrack:audioTrack
                                   atTime:kCMTimeZero
                                    error:&error];
        if (error) {
            [self finishExportWithError:error];
            return;
        }
        NSLog(@"add audio track.");
    }
    
    // 检查输入输出选项
    if (composition.tracks.count <= 0) {
        [self finishExportWithError:[NSError errorWithDomain:AVFoundationErrorDomain
                                                        code:AVErrorInvalidSourceMedia
                                                    userInfo:@{NSLocalizedDescriptionKey:@"not find asset track"}]];
        return;
    }
    
    // 删除本地文件<若存在>
    [NSFileManager.defaultManager removeItemAtPath:self.outputPath error:nil];
    
    // 开始输出
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition.copy presetName:[self presetCompatibleWithAsset:composition.copy]];
    exporter.outputFileType = self.outputFileType ? : ((videoTrack && self.isExportVideoTrack) ? AVFileTypeMPEG4 : AVFileTypeAppleM4A);
    exporter.outputURL = [NSURL fileURLWithPath:self.outputPath];
    exporter.shouldOptimizeForNetworkUse = self.shouldOptimizeForNetworkUse;
    [self setVideoCompositionForExportSession:exporter];
    __weak typeof(exporter) weakexporter = exporter;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = weakexporter.status;
        self.status = status;
        self.error = weakexporter.error;
        if (status == AVAssetExportSessionStatusCompleted || status == AVAssetExportSessionStatusFailed || status == AVAssetExportSessionStatusCancelled) {
            if (status != AVAssetExportSessionStatusCompleted) [NSFileManager.defaultManager removeItemAtPath:self.outputPath error:nil];
            if (self.completionHandler) self.completionHandler(self.status, self.error);
        }
    }];
}

- (void)setVideoCompositionForExportSession:(AVAssetExportSession *)exporter {
    
    if (MNAssetExportSessionIsEmptySize(self.outputRect.size)) return;
    
    AVAssetTrack *videoTrack = [exporter.asset trackWithMediaType:AVMediaTypeVideo];
    if (!videoTrack || CMTIME_IS_INVALID(videoTrack.timeRange.duration)) return;
    
    if (MNAssetExportSessionIsEmptySize(videoTrack.naturalSizeOfVideo)) return;
    
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [videoLayerInstruction setOpacity:1.f atTime:kCMTimeZero];
    [videoLayerInstruction setTransform:[videoTrack naturalTransformWithRect:self.outputRect renderSize:self.renderSize] atTime:kCMTimeZero];
    
    AVMutableVideoCompositionInstruction *videoInstruction = AVMutableVideoCompositionInstruction.videoCompositionInstruction;
    videoInstruction.layerInstructions = @[videoLayerInstruction];
    videoInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, exporter.asset.duration);
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:exporter.asset];
    videoComposition.renderSize = self.renderSize;
    videoComposition.instructions = @[videoInstruction];
    videoComposition.frameDuration = CMTimeMake(1, videoTrack.nominalFrameRate);

    exporter.videoComposition = videoComposition;
}

- (NSString *)presetCompatibleWithAsset:(AVAsset *)asset {
    NSArray <NSString *>*presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if (self.presetName && [presets containsObject:self.presetName]) return self.presetName;
    AVAssetTrack *videoTrack = [asset trackWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *audioTrack = [asset trackWithMediaType:AVMediaTypeAudio];
    NSMutableArray <NSString *>*presetNames = @[].mutableCopy;
    if (videoTrack && self.isExportVideoTrack) {
        [presetNames addObject:AVAssetExportPresetHighestQuality];
        [presetNames addObject:AVAssetExportPresetMediumQuality];
        [presetNames addObject:AVAssetExportPreset1280x720];
        [presetNames addObject:AVAssetExportPresetLowQuality];
    }
    if (audioTrack && self.isExportAudioTrack) {
        [presetNames addObject:AVAssetExportPresetAppleM4A];
    }
    __block NSString *presetName = nil;
    [presetNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([presets containsObject:obj]) {
            presetName = obj;
            *stop = YES;
        }
    }];
    return presetName ? : AVAssetExportPresetPassthrough;
}

- (void)finishExportWithError:(NSError *)error {
    self.error = error;
    self.status = AVAssetExportSessionStatusFailed;
    if (self.completionHandler) {
        self.completionHandler(self.status, self.error);
    }
}

#pragma mark - Getter
- (AVAsset *)asset {
    return self.composition.copy;
}

- (CGSize)renderSize {
    if (MNAssetExportSessionIsEmptySize(_renderSize)) {
        self.renderSize = self.outputRect.size;
    }
    return _renderSize;
}
/*
- (CGRect)outputRect {
    if (CGRectIsEmpty(_outputRect)) {
        CGSize naturalSize = [[self.composition trackWithMediaType:AVMediaTypeVideo] naturalSizeOfVideo];
        _outputRect = (CGRect){CGPointZero, naturalSize};
    }
    return _outputRect;
}
*/

#pragma mark - Setter
- (void)setFilePath:(NSString *)filePath {
    if (_filePath.length > 0) return;
    _filePath = filePath.copy;
    [self appendAsset:[AVAsset assetWithContentsOfPath:filePath]];
}

- (void)setRenderSize:(CGSize)renderSize {
    //使用MPEG-2和MPEG-4(和其他基于DCT的编解码器), 压缩被应用于16×16像素宏块的网格, 使用MPEG-4第10部分(AVC/H.264), 4和8的倍数也是有效的, 但16是最有效的;
    renderSize.width = floor(ceil(renderSize.width)/16.f)*16.f;
    renderSize.height = floor(ceil(renderSize.height)/16.f)*16.f;
    _renderSize = renderSize;
}

#pragma mark - TimeRange
- (CMTimeRange)timeRangeWithSeconds:(NSRange)range {
    return [self timeRangeFromSeconds:range.location toSeconds:NSMaxRange(range)];
}

- (CMTimeRange)timeRangeFromProgress:(float)fromProgress toProgress:(float)toProgress {
    if (!self.composition) return kCMTimeRangeZero;
    NSTimeInterval duration = CMTimeGetSeconds(self.composition.duration);
    fromProgress = MIN(.99f, MAX(0.f, fromProgress));
    toProgress = MAX(.01f, MIN(1.f, toProgress));
    return [self timeRangeFromSeconds:fromProgress*duration toSeconds:toProgress*duration];
}

- (CMTimeRange)timeRangeFromSeconds:(NSTimeInterval)fromSeconds toSeconds:(NSTimeInterval)toSeconds {
    if (!self.composition) return kCMTimeRangeZero;
    CMTime time = self.composition.duration;
    NSTimeInterval duration = CMTimeGetSeconds(time);
    fromSeconds = MIN(duration - 1.f, MAX(0.f, fromSeconds));
    toSeconds = MAX(1.f, MIN(duration, toSeconds));
    CMTimeRange timeRange = kCMTimeRangeZero;
    timeRange.start = CMTimeAdd(kCMTimeZero, CMTimeMakeWithSeconds(fromSeconds, time.timescale));
    timeRange.duration = CMTimeAdd(kCMTimeZero, CMTimeMakeWithSeconds(toSeconds - fromSeconds, time.timescale));
    return timeRange;
}

#pragma mark - Append
- (void)appendAssetWithContentsOfFile:(NSString *)filePath {
    [self appendAsset:[AVAsset assetWithContentsOfPath:filePath]];
}

- (void)appendAsset:(AVAsset *)asset {
    [self appendAssetTrack:[asset trackWithMediaType:AVMediaTypeVideo]];
    [self appendAssetTrack:[asset trackWithMediaType:AVMediaTypeAudio]];
}

- (void)appendAssetTrack:(AVAssetTrack *)assetTrack {
    [self appendAssetTrack:assetTrack toComposition:self.composition];
}

- (BOOL)appendAssetTrack:(AVAssetTrack *)assetTrack toComposition:(AVMutableComposition *)composition {
    if (!CMTIMERANGE_IS_VALID(assetTrack.timeRange)) return NO;
    NSError *error;
    if ([assetTrack.mediaType isEqualToString:AVMediaTypeVideo]) {
        AVMutableCompositionTrack *videoTrack = [self trackOfComposition:composition mediaType:AVMediaTypeVideo];
        CMTime time = CMTIMERANGE_IS_VALID(videoTrack.timeRange) ? videoTrack.timeRange.duration : kCMTimeZero;
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetTrack.timeRange.duration)
                                  ofTrack:assetTrack
                                   atTime:time
                                    error:&error];
        videoTrack.preferredTransform = assetTrack.preferredTransform;
        if (error) NSLog(@"add video track error: %@", error);
        return error == nil;
    } else if ([assetTrack.mediaType isEqualToString:AVMediaTypeAudio]) {
        AVMutableCompositionTrack *audioTrack = [self trackOfComposition:composition mediaType:AVMediaTypeAudio];
        CMTime time = CMTIMERANGE_IS_VALID(audioTrack.timeRange) ? audioTrack.timeRange.duration : kCMTimeZero;
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetTrack.timeRange.duration)
                                  ofTrack:assetTrack
                                   atTime:time
                                    error:nil];
        if (error) NSLog(@"add audio track error: %@", error);
        return error == nil;
    }
    return NO;
}

- (AVMutableCompositionTrack *)trackOfComposition:(AVMutableComposition *)composition mediaType:(AVMediaType)mediaType {
    AVMutableCompositionTrack *compositionTrack = (AVMutableCompositionTrack *)[composition trackWithMediaType:mediaType];
    if (!compositionTrack) {
        compositionTrack = [composition addMutableTrackWithMediaType:mediaType preferredTrackID:kCMPersistentTrackID_Invalid];
    }
    return compositionTrack;
}

#pragma mark - dealloc
- (void)dealloc {
    MNDeallocLog;
    self.completionHandler = nil;
}

@end
#endif
