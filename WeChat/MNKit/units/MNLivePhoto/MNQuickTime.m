//
//  MNQuickTime.m
//  MNKit
//
//  Created by Vincent on 2019/12/14.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNQuickTime.h"
#if __has_include(<AVFoundation/AVFoundation.h>)
#import <AVFoundation/AVFoundation.h>

#define kQuickTimeMetadataKey    @"mdta"
#define kQuickTimeStillImageKey    @"com.apple.quicktime.still-image-time"
#define kQuickTimeMetadataIdentifier    @"com.apple.quicktime.content.identifier"

@interface MNQuickTime ()
@property (nonatomic) float progress;
@property (nonatomic, copy) NSError *error;
@property (nonatomic) MNMovExportStatus status;
@property (nonatomic, strong) AVURLAsset *videoAsset;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@property (nonatomic, strong) AVAssetReaderTrackOutput *videoOutput;
@property (nonatomic, strong) AVAssetReaderTrackOutput *audioOutput;
@property (nonatomic, copy) MNMovExportProgressHandler progressHandler;
@property (nonatomic, copy) MNMovExportCompletionHandler completionHandler;
@end

@implementation MNQuickTime
- (instancetype)init {
    self = [super init];
    if (self) {
        self.frameRate = 30;
        self.identifier = [[NSNumber numberWithLongLong:NSDate.date.timeIntervalSince1970*1000] stringValue];
    }
    return self;
}

- (instancetype)initWithVideoAsset:(AVURLAsset *)videoAsset {
    if (self = [self init]) {
        self.videoAsset = videoAsset;
    }
    return self;
}

- (instancetype)initWithVideoURL:(NSURL *)URL {
    if (self = [self init]) {
        if ([NSFileManager.defaultManager fileExistsAtPath:URL.path]) {
            self.videoAsset = [AVURLAsset URLAssetWithURL:URL options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)}];
        }
    }
    return self;
}

- (instancetype)initWithVideoAtPath:(NSString *)videoPath {
    return [self initWithVideoURL:[NSURL fileURLWithPath:videoPath]];
}

- (void)exportAsynchronouslyWithCompletionHandler:(MNMovExportCompletionHandler)completionHandler
{
    [self exportAsynchronouslyWithProgressHandler:nil completionHandler:completionHandler];
}

- (void)exportAsynchronouslyWithProgressHandler:(MNMovExportProgressHandler)progressHandler
                              completionHandler:(MNMovExportCompletionHandler)completionHandler
{
    if (self.status == MNMovExportStatusExporting) return;
    self.error = nil;
    _progress = 0.f;
    self.status = MNMovExportStatusExporting;
    self.progressHandler = progressHandler;
    self.completionHandler = completionHandler;
    dispatch_queue_t queue = dispatch_queue_create("com.mn.mov.generate.export.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [self exporting];
    });
}

- (void)exporting {
    
    // 输出视频
    __block NSError *error;
    NSString *outputPath = self.outputPath;
    
    // 检查输入
    if (!self.videoAsset) {
        NSError *error = [NSError errorWithDomain:AVFoundationErrorDomain
                                             code:AVErrorExportFailed
                                         userInfo:@{NSLocalizedDescriptionKey:@"未发现视频源文件"}];
        [self finishExportWithError:error];
        return;
    }
    
    // 检查标识符
    if (!self.identifier || self.identifier.length <= 0) {
        NSError *error = [NSError errorWithDomain:AVFoundationErrorDomain
                                             code:AVErrorExportFailed
                                         userInfo:@{NSLocalizedDescriptionKey:@"标识符为空"}];
        [self finishExportWithError:error];
        return;
    }
    
    // 检查输入目录
    if ([NSFileManager.defaultManager fileExistsAtPath:outputPath]) [NSFileManager.defaultManager removeItemAtPath:outputPath error:nil];
    if (outputPath.length <= 0 || ![NSFileManager.defaultManager createDirectoryAtPath:[outputPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error]) {
        if (!error) error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotCreateFile userInfo:@{NSLocalizedDescriptionKey:@"创建文件失败"}];
        [self finishExportWithError:error];
        return;
    }
    
    // 获取视/音素材
    AVAssetTrack *videoTrack = [self trackWithMediaType:AVMediaTypeVideo];
    if (!videoTrack) {
        NSError *error = [NSError errorWithDomain:AVFoundationErrorDomain
                                             code:AVErrorExportFailed
                                         userInfo:@{NSLocalizedDescriptionKey:@"未发现视频轨道"}];
        [self finishExportWithError:error];
        return;
    }
    
    // 资源合成器
    AVMutableComposition *composition = AVMutableComposition.composition;
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration)
                              ofTrack:videoTrack
                               atTime:kCMTimeZero
                                error:&error];
    videoCompositionTrack.preferredTransform = videoTrack.preferredTransform;
    if (error) {
        [self finishExportWithError:error];
        return;
    }
    
    AVAssetTrack *audioTrack = [self trackWithMediaType:AVMediaTypeAudio];
    if (audioTrack) {
        AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioTrack.timeRange.duration)
                                  ofTrack:audioTrack
                                   atTime:kCMTimeZero
                                    error:&error];
        if (error) {
            [self finishExportWithError:error];
            return;
        }
    }
    
    // 输出者
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:composition error:&error];
    assetReader.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration);
    if (error) {
        [self finishExportWithError:error];
        return;
    }
    
    // 写入者
    AVAssetWriter *assetWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:outputPath] fileType:AVFileTypeQuickTimeMovie error:&error];
    assetWriter.metadata = @[[self metadataForIdentifier:self.identifier]];
    if (error) {
        [self finishExportWithError:error];
        return;
    }
    
    // 视频读写设置
    AVAssetReaderTrackOutput *videoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[[composition tracksWithMediaType:AVMediaTypeVideo] firstObject] outputSettings:@{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]}];
    if (![assetReader canAddOutput:videoOutput]) {
        NSError *error = [NSError errorWithDomain:AVFoundationErrorDomain
                                             code:AVErrorExportFailed
                                         userInfo:@{NSLocalizedDescriptionKey:@"视频输出失败"}];
        [self finishExportWithError:error];
        return;
    }
    [assetReader addOutput:videoOutput];
    self.videoOutput = videoOutput;
    
    AVAssetWriterInput *videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:self.videoSetting];
    videoInput.expectsMediaDataInRealTime = YES;
    videoInput.transform = videoTrack.preferredTransform;
    if (![assetWriter canAddInput:videoInput]) {
        NSError *error = [NSError errorWithDomain:AVFoundationErrorDomain
                                             code:AVErrorExportFailed
                                         userInfo:@{NSLocalizedDescriptionKey:@"视频写入失败"}];
        [self finishExportWithError:error];
        return;
    }
    [assetWriter addInput:videoInput];
    self.videoInput = videoInput;
    
    // 音频读写设置
    if (audioTrack) {
        AVAssetReaderTrackOutput *audioOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:[[composition tracksWithMediaType:AVMediaTypeAudio] firstObject] outputSettings:nil];
        if ([assetReader canAddOutput:audioOutput]) {
            [assetReader addOutput:audioOutput];
            self.audioOutput = audioOutput;
        }
        AVAssetWriterInput *audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:nil];
        audioInput.expectsMediaDataInRealTime = NO;
        if ([assetWriter canAddInput:audioInput]) {
            [assetWriter addInput:audioInput];
            self.audioInput = audioInput;
        }
    }
    
    // MOV属性设置<输入输出添加后再添加MOV设置>
    AVAssetWriterInputMetadataAdaptor *adapter = [self writerInputMetadataAdaptor];
    if (![assetWriter canAddInput:adapter.assetWriterInput]) {
        NSError *error = [NSError errorWithDomain:AVFoundationErrorDomain
                                             code:AVErrorExportFailed
                                         userInfo:@{NSLocalizedDescriptionKey:@"视频追加内容失败"}];
        [self finishExportWithError:error];
        return;
    }
    [assetWriter addInput:adapter.assetWriterInput];
    
    // 输出
    if (![assetWriter startWriting]) {
        NSError *error = [NSError errorWithDomain:AVFoundationErrorDomain
                                             code:AVErrorExportFailed
                                         userInfo:@{NSLocalizedDescriptionKey:@"视频写入失败"}];
        [self finishExportWithError:error];
        return;
    }
    if (![assetReader startReading]) {
        NSError *error = [NSError errorWithDomain:AVFoundationErrorDomain
                                             code:AVErrorExportFailed
                                         userInfo:@{NSLocalizedDescriptionKey:@"视频读取失败"}];
        [self finishExportWithError:error];
        return;
    }
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    // 开始后再追加
    AVTimedMetadataGroup *metadataGroup = [[AVTimedMetadataGroup alloc] initWithItems:@[[self metadataForStillImageTime]] timeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(1.f, videoTrack.timeRange.duration.timescale))];
    [adapter appendTimedMetadataGroup:metadataGroup];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [self.videoInput requestMediaDataWhenReadyOnQueue:dispatch_queue_create("com.mn.mov.video.export.queue", DISPATCH_QUEUE_SERIAL) usingBlock:^{
        while (self.videoInput.isReadyForMoreMediaData) {
            CMSampleBufferRef nextSampleBuffer = [self.videoOutput copyNextSampleBuffer];
            if (nextSampleBuffer && self.status == MNMovExportStatusExporting) {
                if ([self.videoInput appendSampleBuffer:nextSampleBuffer]) {
                    CMTime time = CMSampleBufferGetPresentationTimeStamp(nextSampleBuffer);
                    CGFloat progress = CMTimeGetSeconds(time)/CMTimeGetSeconds(assetReader.asset.duration);
                    self.progress = progress;
                } else {
                    [assetReader cancelReading];
                }
                CFRelease(nextSampleBuffer);
            } else {
                if (nextSampleBuffer) CFRelease(nextSampleBuffer);
                [self.videoInput markAsFinished];
                dispatch_group_leave(group);
                break;
            }
        }
    }];
    
    if (self.audioInput && self.audioOutput) {
        dispatch_group_enter(group);
        [self.audioInput requestMediaDataWhenReadyOnQueue:dispatch_queue_create("com.mn.mov.audio.export.queue", DISPATCH_QUEUE_SERIAL) usingBlock:^{
            while (self.audioInput.readyForMoreMediaData) {
                CMSampleBufferRef nextSampleBuffer = [self.audioOutput copyNextSampleBuffer];
                if (nextSampleBuffer && self.status == MNMovExportStatusExporting) {
                    if (![self.audioInput appendSampleBuffer:nextSampleBuffer]) {
                        [assetReader cancelReading];
                    }
                    CFRelease(nextSampleBuffer);
                } else {
                    if (nextSampleBuffer) CFRelease(nextSampleBuffer);
                    [self.audioInput markAsFinished];
                    dispatch_group_leave(group);
                    break;
                }
            }
        }];
    }

    // 等待结果
    dispatch_group_notify(group, dispatch_queue_create("com.mn.mov.finish.queue", DISPATCH_QUEUE_SERIAL), ^{
        [assetReader cancelReading];
        [assetWriter finishWritingWithCompletionHandler:^{
            if (assetWriter.error) {
                self.error = assetWriter.error;
                if (self.status == MNMovExportStatusExporting) self.status = MNMovExportStatusFailed;
                [NSFileManager.defaultManager removeItemAtPath:outputPath error:nil];
            }
            if (![NSFileManager.defaultManager fileExistsAtPath:outputPath]) {
                if (!self.error) self.error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorExportFailed userInfo:@{NSLocalizedDescriptionKey:@"视频生成失败"}];
                if (self.status != MNMovExportStatusCancelled) self.status = MNMovExportStatusFailed;
            } else if (self.status == MNMovExportStatusExporting) {
                self.status = MNMovExportStatusCompleted;
            }
            if (self.status == MNMovExportStatusCancelled || self.status == MNMovExportStatusFailed) {
                [NSFileManager.defaultManager removeItemAtPath:outputPath error:nil];
            }
            if (self.status == MNMovExportStatusCompleted && self.progress != 1.f) self.progress = 1.f;
            if (self.completionHandler) self.completionHandler(self.status, self.error);
        }];
    });
}

- (void)finishExportWithError:(NSError *)error {
    self.error = error;
    if (self.status == MNMovExportStatusExporting) self.status = MNMovExportStatusFailed;
    if (self.completionHandler) self.completionHandler(self.status, self.error);
}

#pragma mark - Cancel
- (void)cancel {
    if (self.status != MNMovExportStatusExporting) return;
    self.status = MNMovExportStatusCancelled;
}

#pragma mark - Setter
- (void)setProgress:(float)progress {
    _progress = progress;
    if (self.progressHandler) self.progressHandler(progress);
}

- (void)setFrameRate:(int)frameRate {
    frameRate = MAX(15, MIN(frameRate, 60));
    _frameRate = frameRate;
}

#pragma mark - Getter
- (AVAssetTrack *)trackWithMediaType:(AVMediaType)mediaType {
    NSArray <AVAssetTrack *>*tracks = [self.videoAsset tracksWithMediaType:mediaType];
    if (tracks.count <= 0) return nil;
    return tracks.firstObject;
}

- (AVMetadataItem *)metadataForIdentifier:(NSString *)assetIdentifier {
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = kQuickTimeMetadataIdentifier;
    item.keySpace = kQuickTimeMetadataKey;
    item.value = assetIdentifier;
    item.dataType = @"com.apple.metadata.datatype.UTF-8";
    return item;
}

- (AVMetadataItem *)metadataForStillImageTime {
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = kQuickTimeStillImageKey;
    item.keySpace = kQuickTimeMetadataKey;
    item.value = @(0);
    item.dataType = @"com.apple.metadata.datatype.int8";
    return item;
}

- (NSDictionary *)audioSettings {
    AudioChannelLayout channelLayout = {
        .mChannelLayoutTag = kAudioChannelLayoutTag_Stereo,
        .mChannelBitmap = kAudioChannelBit_Left,
        .mNumberChannelDescriptions = 0
    };
    NSData *channelLayoutData = [NSData dataWithBytes:&channelLayout length:offsetof(AudioChannelLayout, mChannelDescriptions)];
    NSDictionary *settings = @{
                                         AVFormatIDKey:@(kAudioFormatMPEG4AAC),
                                         AVSampleRateKey:@(44100),
                                         AVNumberOfChannelsKey:@(2),
                                         AVChannelLayoutKey:channelLayoutData};
    return settings;
}

- (NSDictionary *)videoSetting {
    AVAssetTrack *videoTrack = [self trackWithMediaType:AVMediaTypeVideo];
    CGSize naturalSize = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
    naturalSize = CGSizeMake(fabs(naturalSize.width), fabs(naturalSize.height));
    float estimatedDataRate = videoTrack.estimatedDataRate;
    if (isnan(estimatedDataRate) || estimatedDataRate <= 0.f) {
        estimatedDataRate = naturalSize.width*naturalSize.height*self.frameRate;
    }
    NSDictionary *videoSetting = @{AVVideoCodecKey:AVVideoCodecH264,
                                    AVVideoWidthKey:@(naturalSize.width),
                                    AVVideoHeightKey:@(naturalSize.height),
                                    AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
                        AVVideoCompressionPropertiesKey:@{AVVideoAverageBitRateKey:@(estimatedDataRate), AVVideoProfileLevelKey:AVVideoProfileLevelH264MainAutoLevel, AVVideoExpectedSourceFrameRateKey:@(self.frameRate)}};
    return videoSetting;
}

- (AVAssetWriterInputMetadataAdaptor *)writerInputMetadataAdaptor {
    NSDictionary *spec = @{
                           (__bridge NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier:[NSString stringWithFormat:@"%@/%@",kQuickTimeMetadataKey,kQuickTimeStillImageKey],
                           (__bridge NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType:@"com.apple.metadata.datatype.int8"
                           };
    CMFormatDescriptionRef desc = nil;
    CMMetadataFormatDescriptionCreateWithMetadataSpecifications(kCFAllocatorDefault, kCMMetadataFormatType_Boxed, (__bridge CFArrayRef)@[spec], &desc);
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeMetadata outputSettings:nil sourceFormatHint:desc];
    return [AVAssetWriterInputMetadataAdaptor assetWriterInputMetadataAdaptorWithAssetWriterInput:input];
}

#pragma mark - dealloc
- (void)dealloc {
    NSLog(@"%@===dealloc", NSStringFromClass(self.class));
}

@end
#endif
