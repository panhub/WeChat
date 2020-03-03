//
//  MNQuickTime.m
//  MNKit
//
//  Created by Vincent on 2019/12/14.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNQuickTime.h"

#define kQuickTimeMetadataKey    @"mdta"
#define kQuickTimeStillImageKey    @"com.apple.quicktime.still-image-time"
#define kQuickTimeMetadataIdentifier    @"com.apple.quicktime.content.identifier"

@interface MNQuickTime ()
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@property (nonatomic, strong) AVAssetReaderTrackOutput *videoOutput;
@property (nonatomic, strong) AVAssetReaderTrackOutput *audioOutput;
@end

@implementation MNQuickTime
- (instancetype)initWithVideoAsset:(AVURLAsset *)videoAsset {
    if (!videoAsset) return nil;
    self = [super init];
    if (!self) return nil;
    self.videoAsset = videoAsset;
    return self;
}

- (instancetype)initWithVideoOfURL:(NSURL *)URL {
    return [self initWithVideoAsset:[AVURLAsset URLAssetWithURL:URL options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)}]];
}

- (instancetype)initWithVideoOfFile:(NSString *)videoPath {
    return [self initWithVideoOfURL:[NSURL fileURLWithPath:videoPath]];
}

- (void)writeToFileAsynchronously:(NSString *)path
                   withIdentifier:(NSString *)identifier
                completionHandler:(void(^)(BOOL succeed))completionHandler
{
    [self writeToFileAsynchronously:path
                     withIdentifier:identifier
                    progressHandler:nil
                  completionHandler:completionHandler];
}

- (void)writeToFileAsynchronously:(NSString *)outputPath
                   withIdentifier:(NSString *)identifier
                  progressHandler:(void(^)(float  progress))progressHandler
                completionHandler:(void(^)(BOOL succeed))completionHandler
{
    // 检查输入
    if (!self.videoAsset || outputPath.length <= 0 || identifier.length <= 0) {
        if (completionHandler) completionHandler(NO);
        return;
    }
    
    //检查输出设置
    if (![NSFileManager.defaultManager createDirectoryAtPath:outputPath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSLog(@"mov output path error");
        if (completionHandler) completionHandler(NO);
        return;
    }
    
    // 获取视/音素材
    AVAssetTrack *videoTrack = [self trackWithMediaType:AVMediaTypeVideo];
    if (!videoTrack) {
        NSLog(@"not find video track to convert mov");
        if (completionHandler) completionHandler(NO);
        return;
    }
    
    // 标记错误信息
    NSError *error = nil;
    
    // 资源合成器
    AVMutableComposition *composition = AVMutableComposition.composition;
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration)
                              ofTrack:videoTrack
                               atTime:kCMTimeZero
                                error:&error];
    videoCompositionTrack.preferredTransform = videoTrack.preferredTransform;
    if (error) {
        NSLog(@"add video track error:%@", error);
        if (completionHandler) completionHandler(NO);
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
            NSLog(@"add audio track error:%@", error);
            if (completionHandler) completionHandler(NO);
            return;
        }
    }
    
    // 输出者
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:composition error:&error];
    assetReader.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration);
    if (error) {
        NSLog(@"create asset reader error:%@", error);
        if (completionHandler) completionHandler(NO);
        return;
    }
    
    // 写入者
    AVAssetWriter *assetWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:outputPath] fileType:AVFileTypeQuickTimeMovie error:&error];
    assetWriter.metadata = @[[self metadataForIdentifier:identifier]];
    if (error) {
        NSLog(@"create asset writer error:%@", error);
        if (completionHandler) completionHandler(NO);
        return;
    }
    
    // 视频读写设置
    AVAssetReaderTrackOutput *videoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[[composition tracksWithMediaType:AVMediaTypeVideo] firstObject] outputSettings:@{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]}];
    if ([assetReader canAddOutput:videoOutput]) {
        [assetReader addOutput:videoOutput];
        self.videoOutput = videoOutput;
    } else {
        NSLog(@"add video output failed");
        if (completionHandler) completionHandler(NO);
        return;
    }
    
    AVAssetWriterInput *videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:self.videoSettings];
    videoInput.expectsMediaDataInRealTime = YES;
    videoInput.transform = videoTrack.preferredTransform;
    if ([assetWriter canAddInput:videoInput]) {
        [assetWriter addInput:videoInput];
        self.videoInput = videoInput;
    } else {
        NSLog(@"add video input failed");
        if (completionHandler) completionHandler(NO);
        return;
    }
    
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
    if ([assetWriter canAddInput:adapter.assetWriterInput]) {
        [assetWriter addInput:adapter.assetWriterInput];
    } else {
        NSLog(@"can not add mov adapter");
        if (completionHandler) completionHandler(NO);
        return;
    }
    
    // 删除输出文件
    [NSFileManager.defaultManager removeItemAtPath:outputPath error:nil];
    
    // 输出
    if (![assetWriter startWriting]) {
        NSLog(@"can not start writing");
        if (completionHandler) completionHandler(NO);
        return;
    }
    if (![assetReader startReading]) {
        NSLog(@"can not start reading");
        if (completionHandler) completionHandler(NO);
        return;
    }
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    // 开始后再追加
    AVTimedMetadataGroup *metadataGroup = [[AVTimedMetadataGroup alloc] initWithItems:@[[self metadataForStillImageTime]] timeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(1.f, videoTrack.timeRange.duration.timescale))];
    [adapter appendTimedMetadataGroup:metadataGroup];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.mn.mov.export.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t rwqueue = dispatch_queue_create("com.mn.mov.rw.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        [self.videoInput requestMediaDataWhenReadyOnQueue:rwqueue usingBlock:^{
            while (self.videoInput.isReadyForMoreMediaData) {
                CMSampleBufferRef nextSampleBuffer = [self.videoOutput copyNextSampleBuffer];
                if (nextSampleBuffer && assetReader.status == AVAssetReaderStatusReading) {
                    if ([self.videoInput appendSampleBuffer:nextSampleBuffer]) {
                        CMTime time = CMSampleBufferGetPresentationTimeStamp(nextSampleBuffer);
                        CGFloat progress = CMTimeGetSeconds(time)/CMTimeGetSeconds(assetReader.asset.duration);
                        if (progressHandler) progressHandler(progress);
                    } else {
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
    
    if (self.audioInput && self.audioOutput) {
        dispatch_group_enter(group);
        dispatch_group_async(group, rwqueue, ^{
            [self.audioInput requestMediaDataWhenReadyOnQueue:rwqueue usingBlock:^{
                while (self.audioInput.readyForMoreMediaData) {
                    CMSampleBufferRef nextSampleBuffer = [self.audioOutput copyNextSampleBuffer];
                    if (nextSampleBuffer && assetReader.status == AVAssetReaderStatusReading) {
                        if (![self.audioInput appendSampleBuffer:nextSampleBuffer]) {
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

    // 等待结果
    dispatch_group_notify(group, queue, ^{
        [assetWriter finishWritingWithCompletionHandler:^{
            if (assetWriter.error) {
                NSLog(@"cannot write mov: %@", assetWriter.error);
                [NSFileManager.defaultManager removeItemAtPath:outputPath error:nil];
                if (completionHandler) completionHandler(NO);
            } else if ([NSFileManager.defaultManager fileExistsAtPath:outputPath]) {
                if (progressHandler) progressHandler(1.f);
                if (completionHandler) completionHandler(YES);
            } else {
                if (completionHandler) completionHandler(NO);
            }
        }];
    });
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

- (NSDictionary *)videoSettings {
    AVAssetTrack *videoTrack = [self trackWithMediaType:AVMediaTypeVideo];
    CGSize naturalSize = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
    naturalSize = CGSizeMake(fabs(naturalSize.width), fabs(naturalSize.height));
    float bitsPerSecond = naturalSize.width*naturalSize.height*3.5f;
    float nominalFrameRate = MIN(MAX(videoTrack.nominalFrameRate, 20.f), 30.f);
    NSDictionary *videoSettings = @{AVVideoCodecKey:AVVideoCodecH264,
                                    AVVideoWidthKey:@(naturalSize.width),
                                    AVVideoHeightKey:@(naturalSize.height),
                                    AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
                        AVVideoCompressionPropertiesKey:@{AVVideoAverageBitRateKey:@(bitsPerSecond), AVVideoProfileLevelKey:AVVideoProfileLevelH264MainAutoLevel, AVVideoExpectedSourceFrameRateKey:@(nominalFrameRate),}};
    return videoSettings;
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

- (void)dealloc {
    MNDeallocLog;
}

@end
