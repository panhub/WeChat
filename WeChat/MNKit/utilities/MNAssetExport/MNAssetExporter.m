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
    if (![presetName hasPrefix:@"com.mn.asset.export."]) return CGSizeZero;
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
/**资源写入*/
@property (nonatomic, strong) AVAssetWriter *assetWriter;
/**资源读取*/
@property (nonatomic, strong) AVAssetReader *assetReader;
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
        self.exportAudioTrack = YES;
        self.exportVideoTrack = YES;
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
    self.progress = 0.f;
    self.progressHandler = progressHandler;
    self.completionHandler = completionHandler;
    
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
    self.assetWriter = assetWriter;
    self.assetReader = assetReader;
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
    dispatch_queue_t queue = dispatch_queue_create("com.mn.asset.export.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t rwqueue = dispatch_queue_create("com.mn.asset.rw.queue", DISPATCH_QUEUE_SERIAL);
    
    // 视频数据转化
    if (self.videoInput && self.videoOutput) {
        self.status = MNAssetExportStatusExporting;
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [self.videoInput requestMediaDataWhenReadyOnQueue:rwqueue usingBlock:^{
                while (self.videoInput.isReadyForMoreMediaData) {
                    CMSampleBufferRef nextSampleBuffer = [self.videoOutput copyNextSampleBuffer];
                    if (nextSampleBuffer && assetReader.status == AVAssetReaderStatusReading) {
                        if ([self.videoInput appendSampleBuffer:nextSampleBuffer]) {
                            CMTime time = CMSampleBufferGetPresentationTimeStamp(nextSampleBuffer);
                            CGFloat progress = CMTimeGetSeconds(time)/CMTimeGetSeconds(assetReader.asset.duration);
                            [self changeProgress:progress];
                        } else {
                            self.status = MNAssetExportStatusFailed;
                            [assetReader cancelReading];
                            NSLog(@"cannot write video buffer: %@", assetWriter.error);
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
        });
    }
    
    // 音频数据转化
    BOOL allowsAudioRequestCallback = !(self.videoInput && self.videoOutput);
    if (self.audioInput && self.audioOutput) {
        self.status = MNAssetExportStatusExporting;
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [self.audioInput requestMediaDataWhenReadyOnQueue:rwqueue usingBlock:^{
                while (self.audioInput.readyForMoreMediaData) {
                    CMSampleBufferRef nextSampleBuffer = [self.audioOutput copyNextSampleBuffer];
                    if (nextSampleBuffer && assetReader.status == AVAssetReaderStatusReading) {
                        if ([self.audioInput appendSampleBuffer:nextSampleBuffer]) {
                            if (allowsAudioRequestCallback) {
                                CMTime time = CMSampleBufferGetPresentationTimeStamp(nextSampleBuffer);
                                CGFloat progress = CMTimeGetSeconds(time)/CMTimeGetSeconds(assetReader.asset.duration);
                                [self changeProgress:progress];
                            }
                        } else {
                            self.status = MNAssetExportStatusFailed;
                            [assetReader cancelReading];
                            NSLog(@"cannot write audio buffer: %@", assetWriter.error);
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
        });
    }
    
    // 回调结果
    dispatch_group_notify(group, queue, ^{
        [self.assetReader cancelReading];
        [self.assetWriter finishWritingWithCompletionHandler:^{
            if (self.assetWriter.error) {
                self.error = self.assetWriter.error;
                self.status = MNAssetExportStatusFailed;
            }
            if (![NSFileManager.defaultManager fileExistsAtPath:self.outputPath]) {
                if (self.status != MNAssetExportStatusCancelled) self.status = MNAssetExportStatusFailed;
            } else if (self.status == MNAssetExportStatusExporting) {
                self.status = MNAssetExportStatusCompleted;
            }
            if (self.status == MNAssetExportStatusCancelled || self.status == MNAssetExportStatusFailed) {
                [NSFileManager.defaultManager removeItemAtPath:self.outputPath error:nil];
            }
            if (self.status == MNAssetExportStatusCompleted && self.progress != 1.f) [self changeProgress:1.f];
            if (self.completionHandler) self.completionHandler(self.status, self.error);
        }];
    });
}

- (void)finishExportWithError:(NSError *)error {
    self.error = error;
    self.status = MNAssetExportStatusFailed;
    if (self.completionHandler) {
        self.completionHandler(self.status, self.error);
    }
}

- (void)changeProgress:(float)progress {
    self.progress = progress;
    if (self.progressHandler) self.progressHandler(progress);
}

#pragma mark - Cancel
- (void)cancel {
    if (self.status != MNAssetExportStatusExporting) return;
    self.status = MNAssetExportStatusCancelled;
    [self.assetReader cancelReading];
}

#pragma mark - Video
- (void)addVideoOutputForReader:(AVAssetReader *)assetReader {
    AVAssetTrack *videoTrack = [assetReader.asset trackWithMediaType:AVMediaTypeVideo];
    
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [videoLayerInstruction setOpacity:1.f atTime:kCMTimeZero];
    [videoLayerInstruction setTransform:[videoTrack naturalTransformWithRect:self.outputRect renderSize:self.renderSize] atTime:kCMTimeZero];
    
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
    CGFloat width = self.renderSize.width;
    CGFloat height = self.renderSize.height;
    AVAssetTrack *videoTrack = [self.composition trackWithMediaType:AVMediaTypeVideo];
    float nominalFrameRate = MIN(MAX(videoTrack.nominalFrameRate, 20.f), 30.f);
    //AVVideoMaxKeyFrameIntervalKey:@(100),
    NSDictionary *videoInputSettings = @{AVVideoWidthKey:@(width),
                                         AVVideoHeightKey:@(height),
                                         AVVideoCodecKey:AVVideoCodecH264,
                                         AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
                                         AVVideoCompressionPropertiesKey:@{
                                                 AVVideoAverageBitRateKey:@(self.videoBitRate),
                                                 AVVideoProfileLevelKey:self.videoProfileLevel,
                                                 AVVideoExpectedSourceFrameRateKey:@(nominalFrameRate),
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
        _renderSize = MNAssetExportIsEmptySize(presetSize) ? self.outputRect.size : presetSize;
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

- (NSString *)videoProfileLevel {
    // 默认高清画质
    if (self.shouldOptimizeForNetworkUse) return AVVideoProfileLevelH264BaselineAutoLevel;
    MNAssetExportPresetName presetName = self.presetName;
    CGSize presetSize = MNAssetExportPresetSize(presetName);
    if (!MNAssetExportIsEmptySize(presetSize)) {
        if (MIN(presetSize.width, presetSize.height) >= MNAssetExportPreset1080P) return AVVideoProfileLevelH264HighAutoLevel;
    }
    return [presetName isEqualToString:MNAssetExportPresetHighestQuality] ? AVVideoProfileLevelH264HighAutoLevel : AVVideoProfileLevelH264MainAutoLevel;
}

- (float)videoBitRate {
    // 默认最大支持1080p, 最小支持240p
    //float bitRate = 0.f;
    //float minWH = MIN(self.renderSize.width, self.renderSize.height);
    CGSize presetSize = MNAssetExportPresetSize(self.presetName);
    float bitRate = MNAssetExportIsEmptySize(presetSize) ? self.renderSize.width*self.renderSize.height : presetSize.width*presetSize.height;
    /*
    if (!MNAssetExportIsEmptySize(presetSize)) {
        bitRate = presetSize.width*presetSize.height;
    } else if (minWH >= MNAssetExportPreset1080P) {
        bitRate = 1080.f*1920.f;
    } else if (minWH >= MNAssetExportPreset720P) {
        bitRate = minWH*1280.f;
    } else if (minWH >= MNAssetExportPreset576P) {
        bitRate = minWH*1024.f;
    } else if (minWH >= MNAssetExportPreset540P) {
        bitRate = minWH*960.f;
    } else if (minWH >= MNAssetExportPreset480P) {
        bitRate = minWH*640.f;
    } else if (minWH >= MNAssetExportPreset360P) {
        bitRate = minWH*640.f;
    } else if (minWH >= MNAssetExportPreset240P) {
        bitRate = minWH*360.f;
    } else {
        presetSize = MNAssetExportPresetSize(MNAssetExportPreset360x240);
        bitRate = presetSize.width*presetSize.height;
    }
    */
    return self.videoBitRateRatio*bitRate;
}

- (float)videoBitRateRatio {
    float bitRateRatio = 3.7f;
    MNAssetExportPresetName presetName = self.presetName;
    CGSize presetSize = MNAssetExportPresetSize(presetName);
    if (!MNAssetExportIsEmptySize(presetSize)) {
        if (MIN(presetSize.width, presetSize.height) <= MNAssetExportPreset720P) bitRateRatio = 3.3f;
    } else if ([presetName isEqualToString:MNAssetExportPresetLowQuality]) {
        bitRateRatio = 2.5f;
    } else if ([presetName isEqualToString:MNAssetExportPresetMediumQuality]) {
        bitRateRatio = 3.f;
    }
    return bitRateRatio;
}

#pragma mark - Setter
- (void)setFilePath:(NSString *)filePath {
    if (_filePath.length > 0) return;
    _filePath = filePath.copy;
    [self appendAsset:[AVAsset assetWithMediaAtPath:filePath]];
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
    [self appendAsset:[AVAsset assetWithMediaAtPath:filePath]];
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
    self.progressHandler = nil;
    self.completionHandler = nil;
}

@end
#endif
