//
//  MNMovieWriter.m
//  WeChat
//
//  Created by Vicent on 2021/2/9.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "MNMovieWriter.h"
#import <AVFoundation/AVFoundation.h>

@interface MNMovieWriter ()
@property (nonatomic) MNMovieWriteStatus status;
@property (nonatomic, strong) dispatch_queue_t writQueue;
@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@end

@implementation MNMovieWriter
- (instancetype)init {
    if (self = [super init]) {
        self.writQueue = dispatch_queue_create("com.mn.movie.write.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL delegate:(id<MNMovieWriteDelegate>)delegate queue:(dispatch_queue_t)queue {
    NSParameterAssert(URL != nil);
    NSParameterAssert(delegate != nil);
    if (self = [self init]) {
        self.URL = URL;
        self.delegate = delegate;
        self.delegateQueue = queue;
    }
    return self;
}

- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer mediaType:(AVMediaType)mediaType {

    if (sampleBuffer == NULL) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"SampleBuffer is NULL!" userInfo:nil];
        return;
    }
    
    CFRetain(sampleBuffer);
    
    dispatch_async(self.writQueue, ^{
        @autoreleasepool {
            
            @synchronized (self) {
                if (self.status != MNMovieWriteStatusPreparing && self.status != MNMovieWriteStatusWriting) {
                    CFRelease(sampleBuffer);
                    return;
                }
            }
            
            if (!self.writer) {
                CFRelease(sampleBuffer);
                return;
            }
            
            if ([mediaType isEqualToString:AVMediaTypeVideo]) {
                if (!self.videoInput) {
                    [self addVideoTrackWithSourceFormatDescription:CMSampleBufferGetFormatDescription(sampleBuffer)];
                }
                
                if (self.audioInput && self.videoInput) {
                    [self appendVideoSampleBuffer:sampleBuffer];
                }
            } else if ([mediaType isEqualToString:AVMediaTypeAudio]) {
                
                if (!self.audioInput) {
                    [self addAudioTrackWithSourceFormatDescription:CMSampleBufferGetFormatDescription(sampleBuffer)];
                }
                
                if (self.audioInput && self.videoInput) {
                    [self appendAudioSampleBuffer:sampleBuffer];
                }
            }
            CFRelease(sampleBuffer);
        }
    });
}

- (void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}

- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}

- (void)addVideoTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription {
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
    NSUInteger numPixels = dimensions.width*dimensions.height;
    CGFloat bitsPerPixel = numPixels < (640*480) ? 4.05 : 11.0;
    
}

- (void)addAudioTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription {
    
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
    
    if (shouldNotifyDelegate) {
        __weak typeof(self) weakself = self;
        dispatch_async(self.delegateQueue ? : dispatch_get_main_queue(), ^{
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

@end
