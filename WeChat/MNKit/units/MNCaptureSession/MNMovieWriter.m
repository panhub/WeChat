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
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@end

@implementation MNMovieWriter
- (instancetype)init {
    if (self = [super init]) {
        self.queue = dispatch_queue_create("com.mn.movie.write.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL delegate:(id<MNMovieWriteDelegate>)delegate {
    
    NSParameterAssert(URL != nil);
    NSParameterAssert(delegate != nil);

    if (self = [self init]) {

        self.URL = URL;
        
        self.delegate = delegate;
    }
    return self;
}

- (void)prepareWriting {
    
    __weak typeof(self) weakself = self;
    dispatch_async(self.queue, ^{
        __strong typeof(self) self = weakself;
        
        if (!self.URL) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unknow movie path!" userInfo:nil];
        }
        
        if (self.status == MNMovieWriteStatusPreparing) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Already prepared, cannot prepare again!" userInfo:nil];
        }
        
        if (self.status == MNMovieWriteStatusWriting) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Moive is writing!" userInfo:nil];
        }
        
        [NSFileManager.defaultManager removeItemAtURL:self.URL error:nil];
        
        NSError *error;
        AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:self.URL fileType:AVFileTypeQuickTimeMovie error:&error];
        if (error || !writer) {
            [self setStatus:MNMovieWriteStatusFinish error:error];
        } else {
            self.writer = writer;
            [self setStatus:MNMovieWriteStatusPreparing error:nil];
        }
    });
}

- (void)finishWriting {
    
}

#pragma mark - 修改状态
- (void)setStatus:(MNMovieWriteStatus)status error:(NSError *)error {
    __weak typeof(self) weakself = self;
    dispatch_async(self.queue, ^{
        __strong typeof(self) self = weakself;
        @synchronized (self) {
            _status = status;
            if (self.delegate && (status == MNMovieWriteStatusWriting || status == MNMovieWriteStatusFinish)) {
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
            }
        }
    });
}

@end
