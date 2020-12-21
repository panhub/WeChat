//
//  MNAssetExportSession.m
//  MNKit
//
//  Created by Vincent on 2019/12/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetExportSession.h"
#if __has_include(<AVFoundation/AVFoundation.h>)
#import <AVFoundation/AVFoundation.h>
#import "AVAsset+MNExportMetadata.h"
#import "AVAssetTrack+MNExportMetadata.h"

#define MNAssetExportObserverKey    @"status"
static BOOL MNAssetExportSessionIsEmptySize (CGSize size) {
    return (isnan(size.width) || isnan(size.height) || size.width <= 0.f || size.height <= 0.f);
}

@interface MNAssetExportSession ()
/**进度信息*/
@property (nonatomic) float progress;
/**错误信息*/
@property (nonatomic, copy) NSError *error;
/**输出状态*/
@property (nonatomic) AVAssetExportSessionStatus status;
/**资源合成器*/
@property (nonatomic, strong) AVMutableComposition *composition;
/**查询进度值*/
@property (nonatomic, weak) CADisplayLink *displayLink;
/**资源输出会话*/
@property (nonatomic, weak) AVAssetExportSession *exportSession;
/**进度回调*/
@property (nonatomic, copy) MNAssetExportSessionProgressHandler progressHandler;
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

- (instancetype)initWithAsset:(AVURLAsset *)asset {
    if (asset.URL.path.length <= 0) return nil;
    return [self initWithAssetAtPath:asset.URL.path];
}

- (instancetype)initWithAssetAtPath:(NSString *)filePath {
    self = [self init];
    if (!self) return nil;
    self.filePath = filePath;
    return self;
}

- (instancetype)initWithAssetOfURL:(NSURL *)fileURL {
    return [self initWithAssetAtPath:fileURL.path];
}

#pragma mark - Export
- (void)exportAsynchronouslyWithCompletionHandler:(MNAssetExportSessionCompletionHandler)completionHandler {
    [self exportAsynchronouslyWithProgressHandler:nil completionHandler:completionHandler];
}

- (void)exportAsynchronouslyWithProgressHandler:(MNAssetExportSessionProgressHandler)progressHandler completionHandler:(MNAssetExportSessionCompletionHandler)completionHandler {
    if (self.status == AVAssetExportSessionStatusWaiting || self.status == AVAssetExportSessionStatusExporting) return;
    self.error = nil;
    _progress = 0.f;
    self.progressHandler = progressHandler;
    self.completionHandler = completionHandler;
    self.status = AVAssetExportSessionStatusUnknown;
    dispatch_async(dispatch_queue_create("com.mn.asset.generate.export.queue", DISPATCH_QUEUE_SERIAL), ^{
        [self exporting];
    });
}

- (void)exporting {
    
    /*
    // 检查输出参数
    if (self.exportVideoTrack && MNAssetExportSessionIsEmptySize(self.outputRect.size)) {
        [self finishExportWithError:[NSError errorWithDomain:AVFoundationErrorDomain
                                                        code:AVErrorExportFailed
                                                    userInfo:@{NSLocalizedDescriptionKey:@"output rect error"}]];
        return;
    }
    */
    
    // 检查媒体文件
    if (self.composition.tracks.count <= 0) {
        [self finishExportWithError:[NSError errorWithDomain:AVFoundationErrorDomain
                                                        code:AVErrorInvalidSourceMedia
                                                    userInfo:@{NSLocalizedDescriptionKey:@"not media track input"}]];
        return;
    }
    
    // 标记错误信息
    NSError *error = nil;
    
    // 这里重新提取素材便于裁剪 也避免与原素材冲突
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
    [exporter addObserver:self forKeyPath:MNAssetExportObserverKey options:NSKeyValueObservingOptionNew context:nil];
    self.exportSession = exporter;
    __weak typeof(exporter) weakexporter = exporter;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = weakexporter.status;
        self.status = status;
        self.error = weakexporter.error;
        self.exportSession = nil;
        self.displayLink.paused = YES;
        [weakexporter removeObserver:self forKeyPath:MNAssetExportObserverKey];
        if (status != AVAssetExportSessionStatusCompleted) [NSFileManager.defaultManager removeItemAtPath:self.outputPath error:nil];
        if (self.completionHandler) self.completionHandler(self.status, self.error);
    }];
}

- (void)finishExportWithError:(NSError *)error {
    self.error = error;
    self.status = AVAssetExportSessionStatusFailed;
    if (self.completionHandler) self.completionHandler(self.status, error);
}

- (void)cancel {
    if (!self.exportSession || self.exportSession.status != AVAssetExportSessionStatusExporting) return;
    [self.exportSession cancelExport];
}

#pragma mark - ObserveValue && DisplayLinkEvent
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:MNAssetExportObserverKey]) {
        NSNumber *value = change[NSKeyValueChangeNewKey];
        AVAssetExportSessionStatus status = value.integerValue;
        self.status = status;
        if (status == AVAssetExportSessionStatusExporting) {
            self.displayLink.paused = NO;
        } else if (status == AVAssetExportSessionStatusCompleted || status == AVAssetExportSessionStatusFailed || status == AVAssetExportSessionStatusCancelled) {
            self.displayLink.paused = YES;
            if (status == AVAssetExportSessionStatusCompleted && self.progress < 1.f) self.progress = 1.f;
        }
    }
}

- (void)tip:(CADisplayLink *)link {
    if (link.isPaused || !self.exportSession) return;
    float progress = MIN(self.exportSession.progress/2.f, .99f);
    self.progress = progress;
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

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:[MNWeakProxy proxyWithTarget:self] selector:@selector(tip:)];
        displayLink.paused = YES;
        [displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
        _displayLink = displayLink;
    }
    return _displayLink;
}

- (NSString *)presetCompatibleWithAsset:(AVAsset *)asset {
    NSArray <NSString *>*presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if (self.presetName && [presets containsObject:self.presetName]) return self.presetName;
    AVAssetTrack *videoTrack = [asset trackWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *audioTrack = [asset trackWithMediaType:AVMediaTypeAudio];
    NSMutableArray <NSString *>*presetNames = @[].mutableCopy;
    if (videoTrack && self.isExportVideoTrack) {
        [presetNames addObject:AVAssetExportPresetHighestQuality];
        [presetNames addObject:AVAssetExportPreset1280x720];
        [presetNames addObject:AVAssetExportPresetMediumQuality];
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

#pragma mark - Setter
- (void)setFilePath:(NSString *)filePath {
    _filePath = nil;
    [self.composition removeAllTracks];
    _filePath = filePath.copy;
    [self appendAssetWithContentsOfFile:filePath];
}

- (void)setProgress:(float)progress {
    // 系统返回的进度在0 - .5 之间
    _progress = progress;
    if (self.progressHandler) self.progressHandler(progress);
}

- (void)setRenderSize:(CGSize)renderSize {
    //使用MPEG-2和MPEG-4(和其他基于DCT的编解码器), 压缩被应用于16×16像素宏块的网格, 使用MPEG-4第10部分(AVC/H.264), 4和8的倍数也是有效的, 但16是最有效的;
    renderSize.width = floor(ceil(renderSize.width)/16.f)*16.f;
    renderSize.height = floor(ceil(renderSize.height)/16.f)*16.f;
    _renderSize = renderSize;
}

- (void)setVideoCompositionForExportSession:(AVAssetExportSession *)exporter {
    
    if (!self.isExportVideoTrack || MNAssetExportSessionIsEmptySize(self.outputRect.size)) return;
    
    AVAssetTrack *videoTrack = [exporter.asset trackWithMediaType:AVMediaTypeVideo];
    if (!videoTrack || CMTIME_IS_INVALID(videoTrack.timeRange.duration)) return;
    
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [videoLayerInstruction setOpacity:1.f atTime:kCMTimeZero];
    [videoLayerInstruction setTransform:[videoTrack transformWithRect:self.outputRect renderSize:self.renderSize] atTime:kCMTimeZero];
    
    AVMutableVideoCompositionInstruction *videoInstruction = AVMutableVideoCompositionInstruction.videoCompositionInstruction;
    videoInstruction.layerInstructions = @[videoLayerInstruction];
    videoInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, exporter.asset.duration);
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:exporter.asset];
    videoComposition.renderSize = self.renderSize;
    videoComposition.instructions = @[videoInstruction];
    videoComposition.frameDuration = CMTimeMake(1, videoTrack.nominalFrameRate);

    exporter.videoComposition = videoComposition;
}

#pragma mark - Append
- (BOOL)appendAsset:(AVAsset *)asset {
    BOOL result = YES;
    AVAssetTrack *videoTrack = [asset trackWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *audioTrack = [asset trackWithMediaType:AVMediaTypeAudio];
    if (videoTrack && ![self appendAssetTrack:videoTrack]) result = NO;
    if (audioTrack && ![self appendAssetTrack:audioTrack]) result = NO;
    return (result && (videoTrack || audioTrack));
}

- (BOOL)appendAssetWithContentsOfFile:(NSString *)filePath {
    return [self appendAsset:[AVAsset assetWithMediaAtPath:filePath]];
}

- (BOOL)appendAssetWithContentsOfFile:(NSString *)filePath mediaType:(AVMediaType)mediaType {
    return [self appendAssetTrack:[[AVAsset assetWithMediaAtPath:filePath] trackWithMediaType:mediaType]];
}

- (BOOL)appendAssetTrack:(AVAssetTrack *)assetTrack {
    if (!assetTrack || !CMTIMERANGE_IS_VALID(assetTrack.timeRange)) return NO;
    NSError *error;
    if ([assetTrack.mediaType isEqualToString:AVMediaTypeVideo]) {
        AVMutableCompositionTrack *videoTrack = [self.composition compositionTrackWithMediaType:AVMediaTypeVideo];
        CMTime time = CMTIMERANGE_IS_VALID(videoTrack.timeRange) ? videoTrack.timeRange.duration : kCMTimeZero;
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetTrack.timeRange.duration)
                                  ofTrack:assetTrack
                                   atTime:time
                                    error:&error];
        videoTrack.preferredTransform = assetTrack.preferredTransform;
        if (error) NSLog(@"add video track error: %@", error);
        return error == nil;
    } else if ([assetTrack.mediaType isEqualToString:AVMediaTypeAudio]) {
        AVMutableCompositionTrack *audioTrack = [self.composition compositionTrackWithMediaType:AVMediaTypeAudio];
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

#pragma mark - dealloc
- (void)dealloc {
    self.progressHandler = nil;
    self.completionHandler = nil;
    if (_displayLink) {
        _displayLink.paused = YES;
        [_displayLink removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
        [_displayLink invalidate];
    }
    NSLog(@"%@===dealloc", NSStringFromClass(self.class));
}

@end
#endif
