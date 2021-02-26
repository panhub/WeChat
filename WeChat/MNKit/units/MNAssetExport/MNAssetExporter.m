//
//  MNAssetExporter.m
//  MNKit
//
//  Created by Vincent on 2019/12/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetExporter.h"
#if __has_include(<AVFoundation/AVFoundation.h>)
#import <AVFoundation/AVFoundation.h>
#import "AVAsset+MNExportMetadata.h"
#import "AVAssetTrack+MNExportMetadata.h"

#define MNAssetExportPreset240P MNAssetExportPresetProgressive(MNAssetExportPreset360x240)
#define MNAssetExportPreset360P MNAssetExportPresetProgressive(MNAssetExportPreset640x360)
#define MNAssetExportPreset480P MNAssetExportPresetProgressive(MNAssetExportPreset640x480)
#define MNAssetExportPreset540P MNAssetExportPresetProgressive(MNAssetExportPreset960x540)
#define MNAssetExportPreset576P MNAssetExportPresetProgressive(MNAssetExportPreset1024x576)
#define MNAssetExportPreset720P MNAssetExportPresetProgressive(MNAssetExportPreset1280x720)
#define MNAssetExportPreset1080P MNAssetExportPresetProgressive(MNAssetExportPreset1920x1080)
#define MNAssetExportPreset2160P MNAssetExportPresetProgressive(MNAssetExportPreset3840x2160)

MNAssetExportPresetName const MNAssetExportPresetLowQuality = @"com.mn.asset.export.low";
MNAssetExportPresetName const MNAssetExportPresetMediumQuality = @"com.mn.asset.export.medium";
MNAssetExportPresetName const MNAssetExportPresetHighestQuality = @"com.mn.asset.export.highest";
MNAssetExportPresetName const MNAssetExportPreset360x240 = @"com.mn.asset.export.360x240";
MNAssetExportPresetName const MNAssetExportPreset240x360 = @"com.mn.asset.export.240x360";
MNAssetExportPresetName const MNAssetExportPreset640x360 = @"com.mn.asset.export.640x360";
MNAssetExportPresetName const MNAssetExportPreset360x640 = @"com.mn.asset.export.360x640";
MNAssetExportPresetName const MNAssetExportPreset640x480 = @"com.mn.asset.export.640x480";
MNAssetExportPresetName const MNAssetExportPreset480x640 = @"com.mn.asset.export.480x640";
MNAssetExportPresetName const MNAssetExportPreset800x600 = @"com.mn.asset.export.800x600";
MNAssetExportPresetName const MNAssetExportPreset600x800 = @"com.mn.asset.export.600x800";
MNAssetExportPresetName const MNAssetExportPreset960x540 = @"com.mn.asset.export.960x540";
MNAssetExportPresetName const MNAssetExportPreset540x960 = @"com.mn.asset.export.540x960";
MNAssetExportPresetName const MNAssetExportPreset1024x576 = @"com.mn.asset.export.1024x576";
MNAssetExportPresetName const MNAssetExportPreset576x1024 = @"com.mn.asset.export.576x1024";
MNAssetExportPresetName const MNAssetExportPreset1024x768 = @"com.mn.asset.export.1024x768";
MNAssetExportPresetName const MNAssetExportPreset768x1024 = @"com.mn.asset.export.768x1024";
MNAssetExportPresetName const MNAssetExportPreset1280x960 = @"com.mn.asset.export.1280x960";
MNAssetExportPresetName const MNAssetExportPreset960x1280 = @"com.mn.asset.export.960x1280";
MNAssetExportPresetName const MNAssetExportPreset1152x864 = @"com.mn.asset.export.1152x864";
MNAssetExportPresetName const MNAssetExportPreset864x1152 = @"com.mn.asset.export.864x1152";
MNAssetExportPresetName const MNAssetExportPreset1280x720 = @"com.mn.asset.export.1280x720";
MNAssetExportPresetName const MNAssetExportPreset720x1280 = @"com.mn.asset.export.720x1280";
MNAssetExportPresetName const MNAssetExportPreset1440x1080 = @"com.mn.asset.export.1440x1080";
MNAssetExportPresetName const MNAssetExportPreset1080x1440 = @"com.mn.asset.export.1080x1440";
MNAssetExportPresetName const MNAssetExportPreset1920x1080 = @"com.mn.asset.export.1920x1080";
MNAssetExportPresetName const MNAssetExportPreset1080x1920 = @"com.mn.asset.export.1080x1920";
MNAssetExportPresetName const MNAssetExportPreset3840x2160 = @"com.mn.asset.export.3840x2160";
MNAssetExportPresetName const MNAssetExportPreset2160x3840 = @"com.mn.asset.export.2160x3840";
MNAssetExportPresetName const MNAssetExportPreset1080x1080 = @"com.mn.asset.export.1080x1080";
MNAssetExportPresetName const MNAssetExportPreset1024x1024 = @"com.mn.asset.export.1024x1024";
MNAssetExportPresetName const MNAssetExportPreset800x800 = @"com.mn.asset.export.800x800";
MNAssetExportPresetName const MNAssetExportPreset600x600 = @"com.mn.asset.export.600x600";

BOOL MNAssetExportIsEmptySize (CGSize size) {
    return (isnan(size.width) || isnan(size.height) || size.width <= 0.f || size.height <= 0.f);
}

static CGSize MNAssetExportPresetSize (MNAssetExportPresetName presetName) {
    if (!presetName || ![presetName hasPrefix:@"com.mn.asset.export."]) return CGSizeZero;
    if (![presetName containsString:@"x"]) return CGSizeZero;
    NSArray <NSString *>*components = [[presetName stringByReplacingOccurrencesOfString:@"com.mn.asset.export." withString:@""] componentsSeparatedByString:@"x"];
    if (components.count != 2) return CGSizeZero;
    return CGSizeMake(components.firstObject.floatValue, components.lastObject.floatValue);
}

static float MNAssetExportPresetProgressive (MNAssetExportPresetName presetName) {
    CGSize presetSize = MNAssetExportPresetSize(presetName);
    return MIN(presetSize.width, presetSize.height);
}

@interface MNAssetExporter ()
/**进度信息*/
@property (nonatomic, assign) float progress;
/**错误信息*/
@property (nonatomic, strong) NSError *error;
/**状态标记*/
@property (nonatomic, assign) MNAssetExportStatus status;
/**视频输入*/
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
/**音频输入*/
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
/**视频输出*/
@property (nonatomic, strong) AVAssetReaderOutput *videoOutput;
/**音频输出*/
@property (nonatomic, strong) AVAssetReaderOutput *audioOutput;
/**资源合成器<拼接>*/
@property (nonatomic, strong) AVMutableComposition *composition;
/**进度回调*/
@property (nonatomic, copy) MNAssetExportProgressHandler progressHandler;
/**结束回调*/
@property (nonatomic, copy) MNAssetExportCompletionHandler completionHandler;
@end

@implementation MNAssetExporter
@synthesize renderSize = _renderSize;
- (instancetype)init {
    if (self = [super init]) {
        self.frameRate = 30;
        self.exportAudioTrack = YES;
        self.exportVideoTrack = YES;
        self.usingHighBitRateExporting = YES;
        self.shouldOptimizeForNetworkUse = NO;
        self.presetName = MNAssetExportPresetHighestQuality;
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
- (void)exportAsynchronouslyWithCompletionHandler:(MNAssetExportCompletionHandler)completionHandler {
    [self exportAsynchronouslyWithProgressHandler:nil completionHandler:completionHandler];
}

- (void)exportAsynchronouslyWithProgressHandler:(MNAssetExportProgressHandler)progressHandler
                              completionHandler:(MNAssetExportCompletionHandler)completionHandler
{
    if (self.status == MNAssetExportStatusExporting) return;
    self.error = nil;
    _progress = 0.f;
    self.status = MNAssetExportStatusExporting;
    self.progressHandler = progressHandler;
    self.completionHandler = completionHandler;
    dispatch_async(dispatch_queue_create("com.mn.asset.generate.export.queue", DISPATCH_QUEUE_SERIAL), ^{
        [self exporting];
    });
}

- (void)exporting {
    
    // 检查输出参数
    if (self.exportVideoTrack && MNAssetExportIsEmptySize(self.outputRect.size)) {
        [self finishExportWithError:[NSError errorWithDomain:AVFoundationErrorDomain
                                                        code:AVErrorExportFailed
                                                    userInfo:@{NSLocalizedDescriptionKey:@"output rect error"}]];
        return;
    }
    
    // 检查输入目录
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
    
    // 检查素材完整性
    if (composition.tracks.count <= 0) {
        [self finishExportWithError:[NSError errorWithDomain:AVFoundationErrorDomain
                                                        code:AVErrorInvalidSourceMedia
                                                    userInfo:@{NSLocalizedDescriptionKey:@"not find asset track"}]];
        return;
    }
    
    // 资源读取者
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:composition error:&error];
    assetReader.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration);
    if (error) {
        [self finishExportWithError:error];
        return;
    }
    
    // 资源写入者
    AVFileType fileType = (videoTrack && self.isExportVideoTrack) ? AVFileTypeMPEG4 : AVFileTypeAppleM4A;
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:self.outputPath] fileType:fileType error:&error];
    if (error) {
        [self finishExportWithError:error];
        return;
    }
    
    // 添加视频
    if (videoTrack && self.isExportVideoTrack) {
        [self addVideoOutputForReader:assetReader];
        [self addVideoInputForWriter:assetWriter];
    }
    
    // 添加音频
    if (audioTrack && self.isExportAudioTrack) {
        [self addAudioOutputForReader:assetReader];
        [self addAudioInputForWriter:assetWriter];
    }
    
    // 检查输入输出选项
    if (assetReader.outputs.count != assetWriter.inputs.count || assetReader.outputs.count == 0) {
        [self finishExportWithError:[NSError errorWithDomain:AVFoundationErrorDomain
                                                        code:AVErrorInvalidSourceMedia
                                                    userInfo:@{NSLocalizedDescriptionKey:@"metadata error"}]];
        return;
    }
    
    // 删除输出文件
    [NSFileManager.defaultManager removeItemAtPath:self.outputPath error:nil];
    
    // 开始输出
    if (![assetReader startReading]) {
        [self finishExportWithError:[NSError errorWithDomain:AVFoundationErrorDomain
                                                        code:AVErrorExportFailed
                                                    userInfo:@{NSLocalizedDescriptionKey:@"can not start reading"}]];
        return;
    }
    if (![assetWriter startWriting]) {
        [assetReader cancelReading];
        [self finishExportWithError:[NSError errorWithDomain:AVFoundationErrorDomain
                                                        code:AVErrorExportFailed
                                                    userInfo:@{NSLocalizedDescriptionKey:@"can not start writing"}]];
        return;
    }
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    // group组为了等待结果回调, 读写队列为串行队列是为了避免数据错乱
    dispatch_group_t group = dispatch_group_create();
    // 视频数据转化
    if (self.videoInput && self.videoOutput) {
        dispatch_group_enter(group);
        [self.videoInput requestMediaDataWhenReadyOnQueue:dispatch_queue_create("com.mn.asset.video.export.queue", DISPATCH_QUEUE_SERIAL) usingBlock:^{
            while (self.videoInput.isReadyForMoreMediaData) {
                CMSampleBufferRef nextSampleBuffer = [self.videoOutput copyNextSampleBuffer];
                if (self.status == MNAssetExportStatusExporting && nextSampleBuffer != NULL) {
                    if ([self.videoInput appendSampleBuffer:nextSampleBuffer]) {
                        CMTime time = CMSampleBufferGetPresentationTimeStamp(nextSampleBuffer);
                        float progress = CMTimeGetSeconds(time)/CMTimeGetSeconds(assetReader.asset.duration);
                        self.progress = progress;
                    } else {
                        [assetReader cancelReading];
                        self.status = MNAssetExportStatusFailed;
                        NSLog(@"video write fail");
                    }
                    CFRelease(nextSampleBuffer);
                } else {
                    if (nextSampleBuffer) CFRelease(nextSampleBuffer);
                    [self.videoInput markAsFinished];
                    NSLog(@"video write finish");
                    dispatch_group_leave(group);
                    break;
                }
            }
        }];
    }
    
    // 音频数据转化
    BOOL allowsAudioRequestCallback = !(self.videoInput && self.videoOutput);
    if (self.audioInput && self.audioOutput) {
        dispatch_group_enter(group);
        [self.audioInput requestMediaDataWhenReadyOnQueue:dispatch_queue_create("com.mn.asset.audio.export.queue", DISPATCH_QUEUE_SERIAL) usingBlock:^{
            while (self.audioInput.readyForMoreMediaData) {
                CMSampleBufferRef nextSampleBuffer = [self.audioOutput copyNextSampleBuffer];
                if (self.status == MNAssetExportStatusExporting && nextSampleBuffer != NULL) {
                    if ([self.audioInput appendSampleBuffer:nextSampleBuffer]) {
                        if (allowsAudioRequestCallback) {
                            CMTime time = CMSampleBufferGetPresentationTimeStamp(nextSampleBuffer);
                            CGFloat progress = CMTimeGetSeconds(time)/CMTimeGetSeconds(assetReader.asset.duration);
                            self.progress = progress;
                        }
                    } else {
                        [assetReader cancelReading];
                        self.status = MNAssetExportStatusFailed;
                        NSLog(@"audio write fail");
                    }
                    CFRelease(nextSampleBuffer);
                } else {
                    if (nextSampleBuffer) CFRelease(nextSampleBuffer);
                    [self.audioInput markAsFinished];
                    NSLog(@"audio write finish");
                    dispatch_group_leave(group);
                    break;
                }
            }
        }];
    }
    
    // 回调结果
    dispatch_group_notify(group, dispatch_queue_create("com.mn.asset.finish.queue", DISPATCH_QUEUE_SERIAL), ^{
        if (assetReader.status == AVAssetReaderStatusReading) [assetReader cancelReading];
        [assetWriter finishWritingWithCompletionHandler:^{
            if (assetWriter.error) {
                self.error = assetWriter.error;
                if (self.status == MNAssetExportStatusExporting) self.status = MNAssetExportStatusFailed;
            }
            if (![NSFileManager.defaultManager fileExistsAtPath:self.outputPath]) {
                if (!self.error) self.error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorExportFailed userInfo:@{NSLocalizedDescriptionKey:@"export failed"}];
                if (self.status != MNAssetExportStatusCancelled) self.status = MNAssetExportStatusFailed;
            } else if (self.status == MNAssetExportStatusExporting) {
                self.status = MNAssetExportStatusCompleted;
            }
            if (self.status == MNAssetExportStatusCancelled || self.status == MNAssetExportStatusFailed) {
                [NSFileManager.defaultManager removeItemAtPath:self.outputPath error:nil];
            }
            if (self.status == MNAssetExportStatusCompleted && self.progress < 1.f) self.progress = 1.f;
            self.audioInput = self.videoInput = nil;
            self.audioOutput = self.videoOutput = nil;
            if (self.completionHandler) self.completionHandler(self.status, self.error);
        }];
    });
}

- (void)finishExportWithError:(NSError *)error {
    self.error = error;
    self.status = MNAssetExportStatusFailed;
    if (self.completionHandler) self.completionHandler(self.status, self.error);
}

#pragma mark - Cancel
- (void)cancel {
    if (self.status != MNAssetExportStatusExporting) return;
    self.status = MNAssetExportStatusCancelled;
}

#pragma mark - Video
- (void)addVideoOutputForReader:(AVAssetReader *)assetReader {
    AVAssetTrack *videoTrack = [assetReader.asset trackWithMediaType:AVMediaTypeVideo];
    
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [videoLayerInstruction setOpacity:1.f atTime:kCMTimeZero];
    [videoLayerInstruction setTransform:[videoTrack transformWithRect:self.outputRect renderSize:self.renderSize] atTime:kCMTimeZero];
    
    AVMutableVideoCompositionInstruction *videoInstruction = AVMutableVideoCompositionInstruction.videoCompositionInstruction;
    videoInstruction.layerInstructions = @[videoLayerInstruction];
    videoInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, assetReader.asset.duration);
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:assetReader.asset];
    videoComposition.renderSize = self.renderSize;
    videoComposition.instructions = @[videoInstruction];
    videoComposition.frameDuration = CMTimeMake(1, videoTrack.nominalFrameRate);
    
    AVAssetReaderVideoCompositionOutput *videoOutput = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:[assetReader.asset tracksWithMediaType:AVMediaTypeVideo] videoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]}];
    videoOutput.alwaysCopiesSampleData = NO;
    if ([assetReader canAddOutput:videoOutput]) {
        [assetReader addOutput:videoOutput];
        videoOutput.videoComposition = videoComposition;
        self.videoOutput = videoOutput;
    }
}

- (void)addVideoInputForWriter:(AVAssetWriter *)assetWriter {
    NSUInteger width = self.renderSize.width;
    NSUInteger height = self.renderSize.height;
    //AVVideoMaxKeyFrameIntervalKey:@(100),
    NSDictionary *videoInputSettings = @{AVVideoWidthKey:@(width),
                                         AVVideoHeightKey:@(height),
                                         AVVideoCodecKey:AVVideoCodecH264,
                                         AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
                                         AVVideoCompressionPropertiesKey:@{
                                                 AVVideoAverageBitRateKey:[NSNumber numberWithFloat:self.averageBitRate],
                                                 AVVideoProfileLevelKey:self.profileLevel,
                                                 AVVideoExpectedSourceFrameRateKey:[NSNumber numberWithInt:self.frameRate],
                                                 AVVideoMaxKeyFrameIntervalKey:[NSNumber numberWithInt:self.frameRate],
                                                 AVVideoCleanApertureKey:@{
                                                         AVVideoCleanApertureWidthKey:@(width),
                                                         AVVideoCleanApertureHeightKey:@(height),
                                                         AVVideoCleanApertureHorizontalOffsetKey:@(10),
                                                         AVVideoCleanApertureVerticalOffsetKey:@(10)},
                                                 AVVideoPixelAspectRatioKey:@{
                                                         AVVideoPixelAspectRatioHorizontalSpacingKey:@(1),
                                                         AVVideoPixelAspectRatioVerticalSpacingKey:@(1)}}};
    AVAssetWriterInput *videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoInputSettings];
    if ([assetWriter canAddInput:videoWriterInput]) {
        [assetWriter addInput:videoWriterInput];
        self.videoInput = videoWriterInput;
    }
}

#pragma mark - Audio
- (void)addAudioOutputForReader:(AVAssetReader *)assetReader {
    AVAssetReaderAudioMixOutput *audioMixOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:[assetReader.asset tracksWithMediaType:AVMediaTypeAudio] audioSettings:@{AVFormatIDKey:[NSNumber numberWithInt:kAudioFormatLinearPCM]}];
    audioMixOutput.alwaysCopiesSampleData = NO;
    if ([assetReader canAddOutput:audioMixOutput]) {
        [assetReader addOutput:audioMixOutput];
        self.audioOutput = audioMixOutput;
    }
}

- (void)addAudioInputForWriter:(AVAssetWriter *)assetWriter {
    AudioChannelLayout channelLayout = {
        .mChannelLayoutTag = kAudioChannelLayoutTag_Stereo,
        .mChannelBitmap = kAudioChannelBit_Left,
        .mNumberChannelDescriptions = 0
    };
    NSData *channelLayoutData = [NSData dataWithBytes:&channelLayout length:offsetof(AudioChannelLayout, mChannelDescriptions)];
    NSDictionary *audioInputSettings = @{
                                         AVFormatIDKey:@(kAudioFormatMPEG4AAC),
                                         AVSampleRateKey:@(44100),
                                         AVNumberOfChannelsKey:@(2),
                                         AVChannelLayoutKey:channelLayoutData};
    AVAssetWriterInput *audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioInputSettings];
    if ([assetWriter canAddInput:audioWriterInput]) {
        [assetWriter addInput:audioWriterInput];
        self.audioInput = audioWriterInput;
    }
}

#pragma mark - Getter
- (AVAsset *)asset {
    return self.composition.copy;
}

- (CGSize)renderSize {
    if (MNAssetExportIsEmptySize(_renderSize)) {
        CGSize presetSize = MNAssetExportPresetSize(self.presetName);
        // 计算出合格的分辨率参数值
        self.renderSize = MNAssetExportIsEmptySize(presetSize) ? self.outputRect.size : presetSize;
    }
    return _renderSize;
}

- (CGRect)outputRect {
    if (CGRectIsEmpty(_outputRect)) {
        CGSize naturalSize = [[self.composition trackWithMediaType:AVMediaTypeVideo] naturalSizeOfVideo];
        _outputRect = (CGRect){CGPointZero, naturalSize};
    }
    return _outputRect;
}

- (NSString *)profileLevel {
    // 网络传输使用基础级别
    if (self.shouldOptimizeForNetworkUse) return AVVideoProfileLevelH264BaselineAutoLevel;
    MNAssetExportPresetName presetName = self.presetName;
    CGSize presetSize = MNAssetExportPresetSize(presetName);
    if (!MNAssetExportIsEmptySize(presetSize)) {
        if (MIN(presetSize.width, presetSize.height) >= MNAssetExportPreset1080P) return AVVideoProfileLevelH264HighAutoLevel;
        if (MAX(presetSize.width, presetSize.height) <= MNAssetExportPreset480P) return AVVideoProfileLevelH264BaselineAutoLevel;
        return AVVideoProfileLevelH264MainAutoLevel;
    }
    if ([presetName isEqualToString:MNAssetExportPresetHighestQuality]) return AVVideoProfileLevelH264HighAutoLevel;
    if ([presetName isEqualToString:MNAssetExportPresetMediumQuality]) return AVVideoProfileLevelH264MainAutoLevel;
    return AVVideoProfileLevelH264BaselineAutoLevel;
}

- (float)averageBitRate {
    CGFloat width = self.renderSize.width;
    CGFloat height = self.renderSize.height;
    if (self.usingHighBitRateExporting && !self.shouldOptimizeForNetworkUse) {
        CGFloat bitsPerPixel = width*height < (640.f*480.f) ? 4.05f : 10.1f;
        return width*height*bitsPerPixel;
    }
    AVAssetTrack *audioTrack = [self.composition trackWithMediaType:AVMediaTypeAudio];
    AVAssetTrack *videoTrack = [self.composition trackWithMediaType:AVMediaTypeVideo];
    float audioDataRate = audioTrack.estimatedDataRate;
    float videoDataRate = videoTrack.estimatedDataRate;
    float estimatedDataRate = audioDataRate + videoDataRate;
    if (isnan(estimatedDataRate) || estimatedDataRate <= 0.f) {
        estimatedDataRate = width*height*self.frameRate;
    }
    if (self.shouldOptimizeForNetworkUse) estimatedDataRate = estimatedDataRate/2.f;
    return estimatedDataRate;
}

#pragma mark - Setter
- (void)setStatus:(MNAssetExportStatus)status {
    @synchronized (self) {
        _status = status;
    }
}

- (void)setFilePath:(NSString *)filePath {
    _filePath = nil;
    [self.composition removeAllTracks];
    _filePath = filePath.copy;
    [self appendAssetWithContentsOfFile:filePath];
}

- (void)setFrameRate:(int)frameRate {
    frameRate = MAX(15, MIN(frameRate, 60));
    _frameRate = frameRate;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    if (self.progressHandler) self.progressHandler(progress);
}

- (void)setRenderSize:(CGSize)renderSize {
    //使用MPEG-2和MPEG-4(和其他基于DCT的编解码器), 压缩被应用于16×16像素宏块的网格, 使用MPEG-4第10部分(AVC/H.264), 4和8的倍数也是有效的, 但16是最有效的;
    CGFloat width8 = floor(ceil(renderSize.width)/8.f)*8.f;
    CGFloat width16 = floor(ceil(renderSize.width)/16.f)*16.f;
    if (width8 != renderSize.width && width16 != renderSize.width) renderSize.width = width16;
    CGFloat height8 = floor(ceil(renderSize.height)/8.f)*8.f;
    CGFloat height16 = floor(ceil(renderSize.height)/16.f)*16.f;
    if (height8 != renderSize.height && height16 != renderSize.height) renderSize.height = height16;
    _renderSize = renderSize;
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
    NSLog(@"%@===dealloc", NSStringFromClass(self.class));
}

@end
#endif
