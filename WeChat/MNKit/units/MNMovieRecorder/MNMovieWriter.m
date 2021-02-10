//
//  MNMovieWriter.m
//  WeChat
//
//  Created by Vicent on 2021/2/9.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "MNMovieWriter.h"
#import <AVFoundation/AVFoundation.h>

/**
 文件写入状态
 - MNMovieWriteStatusIdle: 闲置状态
 - MNMovieWriteStatusPreparing: 即将写入
 - MNMovieWriteStatusWriting: 正在写入
 - MNMovieWriteStatusWaiting: 等待结束
 - MNMovieWriteStatusFinish: 已结束
 */
typedef NS_ENUM(NSInteger, MNMovieWriteStatus) {
    MNMovieWriteStatusIdle = 0,
    MNMovieWriteStatusPreparing,
    MNMovieWriteStatusWriting,
    MNMovieWriteStatusWaiting,
    MNMovieWriteStatusFinish
};

@interface MNMovieWriter ()
@property (nonatomic) MNMovieWriteStatus status;
@property (nonatomic, strong) dispatch_queue_t writQueue;
@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@property (nonatomic) UIDeviceOrientation deviceOrientation;
@end

@implementation MNMovieWriter
- (instancetype)init {
    if (self = [super init]) {
        self.movieOrientation = AVCaptureVideoOrientationPortrait;
        self.writQueue = dispatch_queue_create("com.mn.movie.write.queue", DISPATCH_QUEUE_SERIAL);
        self.delegateQueue = dispatch_queue_create("com.mn.movie.delegate.queue", DISPATCH_QUEUE_SERIAL);
        self.deviceOrientation = UIDevice.currentDevice.orientation;
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationDidChangeNotification)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL delegate:(id<MNMovieWriteDelegate>)delegate queue:(dispatch_queue_t)queue {
    NSParameterAssert(URL != nil);
    NSParameterAssert(delegate != nil);
    if (self = [self init]) {
        self.URL = URL;
        self.delegate = delegate;
        if (queue) self.delegateQueue = queue;
    }
    return self;
}

- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer mediaType:(AVMediaType)mediaType {
    
    // 缓存为空 出错
    if (sampleBuffer == NULL) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"SampleBuffer is NULL!" userInfo:nil];
        return;
    }
    
    // 强引用缓存数据
    CFRetain(sampleBuffer);
    
    dispatch_async(self.writQueue, ^{
        
        @autoreleasepool {
            
            @synchronized (self) {
                if (self.status != MNMovieWriteStatusPreparing && self.status != MNMovieWriteStatusWriting) {
                    CFRelease(sampleBuffer);
                    return;
                }
            }
            
            if (mediaType == AVMediaTypeVideo) {
                if (!self.videoInput) {
                    if (![self addVideoTrackWithSourceFormatDescription:CMSampleBufferGetFormatDescription(sampleBuffer)]) {
                        @synchronized (self) {
                            [self setStatus:MNMovieWriteStatusFinish error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"Can not add video input"}]];
                        }
                    }
                }
                
                if (self.audioInput && self.videoInput) {
                    if (![self appendVideoSampleBuffer:sampleBuffer]) {
                        @synchronized (self) {
                            [self setStatus:MNMovieWriteStatusFinish error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"Can not append video sample buffer"}]];
                        }
                    }
                }
                
            } else if (mediaType == AVMediaTypeAudio) {
                
                if (!self.audioInput) {
                    if (![self addAudioTrackWithSourceFormatDescription:CMSampleBufferGetFormatDescription(sampleBuffer)]) {
                        @synchronized (self) {
                            [self setStatus:MNMovieWriteStatusFinish error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"Can not add audio input"}]];
                        }
                    }
                }
                
                if (self.audioInput && self.videoInput) {
                    if (![self appendAudioSampleBuffer:sampleBuffer]) {
                        @synchronized (self) {
                            [self setStatus:MNMovieWriteStatusFinish error:[NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"Can not append audio sample buffer"}]];
                        }
                    }
                }
            }
            
            if (self.status == MNMovieWriteStatusPreparing && self.writer.status == AVAssetWriterStatusWriting) {
                @synchronized (self) {
                    [self setStatus:MNMovieWriteStatusWaiting error:nil];
                }
            }
            
            CFRelease(sampleBuffer);
        }
    });
}

- (BOOL)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (self.writer.status == AVAssetWriterStatusUnknown) {
        if ([self.writer startWriting]) {
            [self.writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        } else return NO;
    }
    
    if (self.writer.status == AVAssetWriterStatusWriting) {
        
        // 未准备好则放弃
        if (self.videoInput.readyForMoreMediaData) {
            
            return [self.videoInput appendSampleBuffer:sampleBuffer];
        }
        
        return YES;
    }
    
    return NO;
}

- (BOOL)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    if (self.writer.status == AVAssetWriterStatusUnknown) {
        if ([self.writer startWriting]) {
            [self.writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        } else return NO;
    }
    
    if (self.writer.status == AVAssetWriterStatusWriting) {
        
        // 未准备好则放弃
        if (self.audioInput.readyForMoreMediaData) {
            
            return [self.audioInput appendSampleBuffer:sampleBuffer];
        }
        
        return YES;
    }
    
    return NO;
}

- (BOOL)addVideoTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription {
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
    NSUInteger numPixels = dimensions.width*dimensions.height;
    CGFloat bitsPerPixel = numPixels < (640*480) ? 4.05 : 11.0;
    NSDictionary *compression = @{AVVideoAverageBitRateKey: [NSNumber numberWithInteger:numPixels*bitsPerPixel],
                                  AVVideoMaxKeyFrameIntervalKey: [NSNumber numberWithInteger:self.frameRate]};
    NSDictionary *settings = @{AVVideoCodecKey:AVVideoCodecH264,
                               AVVideoWidthKey:[NSNumber numberWithInteger:dimensions.width],
                              AVVideoHeightKey:[NSNumber numberWithInteger:dimensions.height],
               AVVideoCompressionPropertiesKey:compression};
    if ([self.writer canApplyOutputSettings:settings forMediaType:AVMediaTypeVideo]) {
        AVAssetWriterInput *videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
        videoInput.expectsMediaDataInRealTime = YES;
        videoInput.transform = [self transformFromMovieOrientationTo:self.movieOrientation];
        if ([self.writer canAddInput:videoInput]){
            [self.writer addInput:videoInput];
            self.videoInput = videoInput;
            return YES;
        }
    }
    return NO;
}

- (BOOL)addAudioTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription {
    size_t aclSize = 0;
    const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription);
    const AudioChannelLayout *channelLayout = CMAudioFormatDescriptionGetChannelLayout(formatDescription, &aclSize);
    NSData *dataLayout = aclSize > 0 ? [NSData dataWithBytes:channelLayout length:aclSize] : [NSData data];
    NSDictionary *settings = @{AVFormatIDKey: [NSNumber numberWithInteger: kAudioFormatMPEG4AAC],
                             AVSampleRateKey: [NSNumber numberWithFloat: currentASBD->mSampleRate],
                          AVChannelLayoutKey: dataLayout,
                       AVNumberOfChannelsKey: [NSNumber numberWithInteger: currentASBD->mChannelsPerFrame]};
    // AVEncoderBitRatePerChannelKey: [NSNumber numberWithInt: 64000]
    if ([self.writer canApplyOutputSettings:settings forMediaType:AVMediaTypeAudio]){
        AVAssetWriterInput *audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:settings];
        audioInput.expectsMediaDataInRealTime = YES;
        if ([self.writer canAddInput:audioInput]){
            [self.writer addInput:audioInput];
            return YES;
        }
    }
    return NO;
}

- (void)prepareWriting {
    __weak typeof(self) weakself = self;
    dispatch_async(self.writQueue, ^{
        __strong typeof(self) self = weakself;
        @synchronized (self) {
            if (!self.URL) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unknow movie path!" userInfo:nil];
            }
            if (self.status == MNMovieWriteStatusPreparing) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Already prepared, cannot prepare again!" userInfo:nil];
            }
            if (self.status == MNMovieWriteStatusWriting) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Moive is writing!" userInfo:nil];
            }
        }
        [NSFileManager.defaultManager removeItemAtURL:self.URL error:nil];
        NSError *error;
        AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:self.URL fileType:AVFileTypeQuickTimeMovie error:&error];
        if (error || !writer) {
            @synchronized (self) {
                [self setStatus:MNMovieWriteStatusFinish error:error];
            }
        } else {
            @synchronized (self) {
                self.writer = writer;
                [self setStatus:MNMovieWriteStatusPreparing error:nil];
            }
        }
    });
}

- (void)finishWriting {
    @synchronized (self) {
        if (self.status != MNMovieWriteStatusWriting) {
            NSLog(@"Not recording");
            return;
        }
        [self setStatus:MNMovieWriteStatusWaiting error:nil];
    }
    __weak typeof(self) weakself = self;
    dispatch_async(self.writQueue, ^{
        if (weakself.status != MNMovieWriteStatusWaiting) {
            // 有可能是在写入视频时发生了错误, 改变了状态, 这里就不再操作
            return;
        }
        [weakself.writer finishWritingWithCompletionHandler:^{
            NSError *error = weakself.writer.error;
            __strong typeof(self) self = weakself;
            @synchronized (self) {
                [self setStatus:MNMovieWriteStatusFinish error:error];
            }
        }];
    });
}

#pragma mark - 修改状态
- (void)setStatus:(MNMovieWriteStatus)status error:(NSError *)error {
    
    BOOL shouldNotifyDelegate = NO;
    
    if (status != _status) {
        if (status == MNMovieWriteStatusWriting) {
            shouldNotifyDelegate = YES;
        } else if (status == MNMovieWriteStatusFinish) {
            shouldNotifyDelegate = YES;
            [self teardownAssetWriterAndInputs];
            if (error) [NSFileManager.defaultManager removeItemAtURL:self.URL error:nil];
        }
        _status = status;
    }
    
    if (shouldNotifyDelegate && self.delegate) {
        __weak typeof(self) weakself = self;
        dispatch_async(self.delegateQueue, ^{
            __strong typeof(self) self = weakself;
            if (status == MNMovieWriteStatusFinish) {
                if (error) {
                    if ([self.delegate respondsToSelector:@selector(movieWriter:didFailWithError:)]) {
                        [self.delegate movieWriter:self didFailWithError:error];
                    }
                } else {
                    if ([self.delegate respondsToSelector:@selector(movieWriterDidFinishWriting:)]) {
                        [self.delegate movieWriterDidFinishWriting:self];
                    }
                }
            } else if (status == MNMovieWriteStatusWriting && [self.delegate respondsToSelector:@selector(movieWriterDidStartWriting:)]) {
                [self.delegate movieWriterDidStartWriting:self];
            }
        });
    }
}

- (void)teardownAssetWriterAndInputs {
    _writer = nil;
    _videoInput = nil;
    _audioInput = nil;
}

#pragma mark - Notification
- (void)deviceOrientationDidChangeNotification {
    self.deviceOrientation = UIDevice.currentDevice.orientation;
}

#pragma mark - Tool
- (CGAffineTransform)transformFromMovieOrientationTo:(AVCaptureVideoOrientation)orientation {
    CGFloat orientationAngleOffset = [self angleFromPortraitOrientationTo:orientation];
    CGFloat videoOrientationAngleOffset = [self angleFromPortraitOrientationTo:self.handMovieOrientation];
    CGFloat angleOffset;
    if (self.devicePosition == AVCaptureDevicePositionBack) {
        angleOffset = videoOrientationAngleOffset - orientationAngleOffset + M_PI_2;
    } else {
        angleOffset = orientationAngleOffset - videoOrientationAngleOffset + M_PI_2;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleOffset);
    return transform;
}

- (CGFloat)angleFromPortraitOrientationTo:(AVCaptureVideoOrientation)orientation {
    CGFloat angle = 0.0;
    switch (orientation){
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
    }
    return angle;
}

- (AVCaptureVideoOrientation)handMovieOrientation {
    AVCaptureVideoOrientation orientation;
    switch (self.movieOrientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
}

- (void)setURL:(NSURL *)URL {
    if (!URL.isFileURL) return;
    [NSFileManager.defaultManager removeItemAtURL:URL error:nil];
    /// 只创建文件夹路径, 文件由数据写入时自行创建<踩坑总结>
    if ([NSFileManager.defaultManager createDirectoryAtPath:URL.path.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil]) {
        _URL = URL.copy;
    }
}

@end
