//
//  MNMediaDownloader.m
//  MNKit
//
//  Created by Vincent on 2018/11/30.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNMediaDownloader.h"
#import "MNMediaCacheWorker.h"
#import "MNMediaSeekAction.h"
#import "MNMediaCacheWorker.h"
#import "MNMediaCacheManager.h"
#import "MNMediaCacheConfiguration.h"
#import <CoreServices/UTType.h>

static NSOperationQueue *MNMediaDownloadSessionDelegateQueue (void) {
    static NSOperationQueue *mediaDownloadSessionDelegateQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediaDownloadSessionDelegateQueue = [[NSOperationQueue alloc] init];
        mediaDownloadSessionDelegateQueue.name = @"com.media.download.session.delegate.queue";
    });
    return mediaDownloadSessionDelegateQueue;
}

#pragma mark - Class MNMediaDownloadSessionDelegate
@protocol MNMediaDownloadDataDelegate <NSObject>
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler;
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler;
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error;
@end

static NSInteger MNMediaDownloadBufferSize = 10*1024;
@interface MNMediaDownloadSessionDelegate : NSObject<NSURLSessionDelegate>
@property (nonatomic, weak) id<MNMediaDownloadDataDelegate> delegate;
@property (nonatomic, strong) NSMutableData *bufferData;
- (instancetype)initWithDelegate:(id<MNMediaDownloadDataDelegate>)delegate;
@end

@implementation MNMediaDownloadSessionDelegate
- (instancetype)init {
    if (self = [super init]) {
        self.bufferData = [NSMutableData data];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<MNMediaDownloadDataDelegate>)delegate {
    self = [self init];
    if (!self) return nil;
    self.delegate = delegate;
    return self;
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    [self.delegate URLSession:session didReceiveChallenge:challenge completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    [self.delegate URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    @synchronized (self.bufferData) {
        [self.bufferData appendData:data];
        if (self.bufferData.length > MNMediaDownloadBufferSize) {
            NSRange chunkRange = NSMakeRange(0, self.bufferData.length);
            NSData *chunkData = [self.bufferData subdataWithRange:chunkRange];
            [self.bufferData replaceBytesInRange:chunkRange withBytes:NULL length:0];
            [self.delegate URLSession:session dataTask:dataTask didReceiveData:chunkData];
        }
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionDataTask *)task
        didCompleteWithError:(nullable NSError *)error {
    @synchronized (self.bufferData) {
        if (self.bufferData.length > 0 && !error) {
            NSRange chunkRange = NSMakeRange(0, self.bufferData.length);
            NSData *chunkData = [self.bufferData subdataWithRange:chunkRange];
            [self.bufferData replaceBytesInRange:chunkRange withBytes:NULL length:0];
            [self.delegate URLSession:session dataTask:task didReceiveData:chunkData];
        }
    }
    [self.delegate URLSession:session task:task didCompleteWithError:error];
}

@end

#pragma mark - Class MNMediaSeekWorker
@class MNMediaSeekWorker;
@protocol MNMediaSeekWorkerDelegate <NSObject>
- (void)seekWorker:(MNMediaSeekWorker *)seekWorker didReceiveResponse:(NSURLResponse *)response;
- (void)seekWorker:(MNMediaSeekWorker *)seekWorker didReceiveData:(NSData *)data isLocal:(BOOL)isLocal;
- (void)seekWorker:(MNMediaSeekWorker *)seekWorker didFinishWithError:(NSError *)error;
@end

@interface MNMediaSeekWorker : NSObject<MNMediaDownloadDataDelegate>
@property (nonatomic, strong) NSMutableArray<MNMediaSeekAction *> *actions;
@property (nonatomic, assign) BOOL canSaveToCache;
@property (nonatomic, weak) id<MNMediaSeekWorkerDelegate> delegate;
@property (nonatomic, getter=isCancelled) BOOL cancelled;
@property (nonatomic, strong) MNMediaCacheWorker *cacheWorker;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) MNMediaDownloadSessionDelegate *sessionDelegate;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic) NSInteger startOffset;
@property (nonatomic) NSTimeInterval notifyTime;
- (instancetype)initWithActions:(NSArray<MNMediaSeekAction *> *)actions URL:(NSURL *)URL cacheWorker:(MNMediaCacheWorker *)cacheWorker;
- (void)start;
- (void)cancel;
@end

@implementation MNMediaSeekWorker
- (void)dealloc {
    [self cancel];
}

- (instancetype)initWithActions:(NSArray<MNMediaSeekAction *> *)actions URL:(NSURL *)URL cacheWorker:(MNMediaCacheWorker *)cacheWorker {
    self = [super init];
    if (self) {
        _canSaveToCache = YES;
        _actions = [actions mutableCopy];
        _cacheWorker = cacheWorker;
        _URL = URL;
    }
    return self;
}

- (MNMediaDownloadSessionDelegate *)sessionDelegate {
    if (!_sessionDelegate) {
        _sessionDelegate = [[MNMediaDownloadSessionDelegate alloc] initWithDelegate:self];
    }
    return _sessionDelegate;
}

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self.sessionDelegate delegateQueue:MNMediaDownloadSessionDelegateQueue()];
        _session = session;
    }
    return _session;
}

- (void)start {
    [self processActions];
}

- (void)cancel {
    if (_session) {
        [_session invalidateAndCancel];
    }
    self.cancelled = YES;
}

- (void)processActions {
    if (self.isCancelled) return;
    
    MNMediaSeekAction *action = [self.actions firstObject];
    if (!action) {
        if ([self.delegate respondsToSelector:@selector(seekWorker:didFinishWithError:)]) {
            [self.delegate seekWorker:self didFinishWithError:nil];
        }
        return;
    }
    [self.actions removeObjectAtIndex:0];
    
    if (action.type == MNMediaSeekActionLocal) {
        //本地
        NSError *error;
        NSData *data = [self.cacheWorker cacheDataForRange:action.range error:&error];
        if (error) {
            if ([self.delegate respondsToSelector:@selector(seekWorker:didFinishWithError:)]) {
                [self.delegate seekWorker:self didFinishWithError:error];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(seekWorker:didReceiveData:isLocal:)]) {
                [self.delegate seekWorker:self didReceiveData:data isLocal:YES];
            }
            [self processActions];
        }
    } else {
        //网络数据
        long long fromOffset = action.range.location;
        long long endOffset = action.range.location + action.range.length - 1;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-%lld", fromOffset, endOffset];
        [request setValue:range forHTTPHeaderField:@"Range"];
        self.startOffset = action.range.location;
        self.task = [self.session dataTaskWithRequest:request];
        [self.task resume];
    }
}

- (void)notifyDownloadProgressWithFlush:(BOOL)flush finished:(BOOL)finished {
    double currentTime = CFAbsoluteTimeGetCurrent();
    double interval = [MNMediaCacheManager cacheUpdateNotifyInterval];
    if ((self.notifyTime < currentTime - interval) || flush) {
        self.notifyTime = currentTime;
        MNMediaCacheConfiguration *configuration = [self.cacheWorker.configuration copy];
        [[NSNotificationCenter defaultCenter] postNotificationName:MNMediaCacheManagerDidUpdateCacheNotification
                                                            object:self
                                                          userInfo:@{
                                                                     MNMediaCacheConfigurationKey: configuration,
                                                                     }];
        
        if (finished && configuration.progress >= 1.0) {
            [self notifyDownloadFinishedWithError:nil];
        }
    }
}

- (void)notifyDownloadFinishedWithError:(NSError *)error {
    MNMediaCacheConfiguration *configuration = [self.cacheWorker.configuration copy];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:configuration forKey:MNMediaCacheConfigurationKey];
    [userInfo setValue:error forKey:MNMediaCacheFinishedErrorKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MNMediaCacheManagerDidFinishCacheNotification
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - VIURLSessionDelegateObjectDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,card);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSString *mimeType = response.MIMEType;
    // Only download video/audio data
    if ([mimeType rangeOfString:@"video/"].location == NSNotFound &&
        [mimeType rangeOfString:@"audio/"].location == NSNotFound &&
        [mimeType rangeOfString:@"application"].location == NSNotFound) {
        completionHandler(NSURLSessionResponseCancel);
    } else {
        if ([self.delegate respondsToSelector:@selector(seekWorker:didReceiveResponse:)]) {
            [self.delegate seekWorker:self didReceiveResponse:response];
        }
        if (self.canSaveToCache) {
            [self.cacheWorker startWritting];
        }
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (self.isCancelled) return;
    
    if (self.canSaveToCache) {
        NSRange range = NSMakeRange(self.startOffset, data.length);
        NSError *error;
        [self.cacheWorker cacheData:data forRange:range error:&error];
        if (error) {
            if ([self.delegate respondsToSelector:@selector(seekWorker:didFinishWithError:)]) {
                [self.delegate seekWorker:self didFinishWithError:error];
            }
            return;
        }
        [self.cacheWorker save];
    }
    
    self.startOffset += data.length;
    if ([self.delegate respondsToSelector:@selector(seekWorker:didReceiveData:isLocal:)]) {
        [self.delegate seekWorker:self didReceiveData:data isLocal:NO];
    }
    
    [self notifyDownloadProgressWithFlush:NO finished:NO];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (self.canSaveToCache) {
        [self.cacheWorker finishWritting];
        [self.cacheWorker save];
    }
    if (error) {
        if ([self.delegate respondsToSelector:@selector(seekWorker:didFinishWithError:)]) {
            [self.delegate seekWorker:self didFinishWithError:error];
        }
        [self notifyDownloadFinishedWithError:error];
    } else {
        [self notifyDownloadProgressWithFlush:YES finished:YES];
        [self processActions];
    }
}

@end

#pragma mark - Class: MNMediaDownloadContainer
@interface MNMediaDownloadContainer ()
@property (nonatomic, strong) NSMutableSet *downloadingURLS;
@end

@implementation MNMediaDownloadContainer
+ (instancetype)defaultContainer {
    static MNMediaDownloadContainer *mediaDownloadContainer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediaDownloadContainer = [[self alloc] init];
        mediaDownloadContainer.downloadingURLS = [NSMutableSet set];
    });
    return mediaDownloadContainer;
}

- (void)addURL:(NSURL *)url {
    @synchronized (self.downloadingURLS) {
        [self.downloadingURLS addObject:url];
    }
}

- (void)removeURL:(NSURL *)url {
    @synchronized (self.downloadingURLS) {
        [self.downloadingURLS removeObject:url];
    }
}

- (BOOL)containsURL:(NSURL *)url {
    @synchronized (self.downloadingURLS) {
        return [self.downloadingURLS containsObject:url];
    }
}

- (NSSet *)URLS {
    return [self.downloadingURLS copy];
}
@end

#pragma mark - Class: MNMediaDownloader

@interface MNMediaDownloader ()<MNMediaSeekWorkerDelegate>
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) MNMediaCacheWorker *cacheWorker;
@property (nonatomic, strong) MNMediaSeekWorker *seekWorker;
@property (nonatomic) BOOL downloadToEnd;
@end

@implementation MNMediaDownloader
- (void)dealloc {
    [[MNMediaDownloadContainer defaultContainer] removeURL:self.URL];
}

- (instancetype)initWithURL:(NSURL *)URL cacheWorker:(MNMediaCacheWorker *)cacheWorker {
    if (self = [super init]) {
        _saveToCache = YES;
        _URL = URL;
        _cacheWorker = cacheWorker;
        _info = _cacheWorker.configuration.mediaInfo;
        [[MNMediaDownloadContainer defaultContainer] addURL:_URL];
    }
    return self;
}

- (void)downloadTaskFromOffset:(unsigned long long)fromOffset
                        length:(NSUInteger)length
                         toEnd:(BOOL)toEnd
{
    NSRange range = NSMakeRange((NSUInteger)fromOffset, length);
    if (toEnd) {
        range.length = (NSUInteger)self.cacheWorker.configuration.mediaInfo.contentLength - range.location;
    }
    NSArray *actions = [self.cacheWorker cacheDataActionForRange:range];
    self.seekWorker = [[MNMediaSeekWorker alloc] initWithActions:actions URL:self.URL cacheWorker:self.cacheWorker];
    self.seekWorker.canSaveToCache = self.saveToCache;
    self.seekWorker.delegate = self;
    [self.seekWorker start];
}

- (void)downloadFromStartToEnd {
    // ---
    self.downloadToEnd = YES;
    NSRange range = NSMakeRange(0, 2);
    NSArray *actions = [self.cacheWorker cacheDataActionForRange:range];
    
    self.seekWorker = [[MNMediaSeekWorker alloc] initWithActions:actions URL:self.URL cacheWorker:self.cacheWorker];
    self.seekWorker.canSaveToCache = self.saveToCache;
    self.seekWorker.delegate = self;
    [self.seekWorker start];
}

- (void)cancel {
    self.seekWorker.delegate = nil;
    [[MNMediaDownloadContainer defaultContainer] removeURL:self.URL];
    [self.seekWorker cancel];
    self.seekWorker = nil;
}

#pragma mark - VIActionWorkerDelegate
- (void)seekWorker:(MNMediaSeekWorker *)seekWorker didReceiveResponse:(NSURLResponse *)response {
    if (!self.info) {
        MNMediaInfo *info = [MNMediaInfo new];
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
            NSString *acceptRange = HTTPURLResponse.allHeaderFields[@"Accept-Ranges"];
            info.byteRangeAccessSupported = [acceptRange isEqualToString:@"bytes"];
            info.contentLength = [[[HTTPURLResponse.allHeaderFields[@"Content-Range"] componentsSeparatedByString:@"/"] lastObject] longLongValue];
        }
        NSString *mimeType = response.MIMEType;
        CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
        info.contentType = CFBridgingRelease(contentType);
        self.info = info;
        
        NSError *error;
        [self.cacheWorker setMediaInfo:info error:&error];
        if (error) {
            if ([self.delegate respondsToSelector:@selector(mediaDownloader:didFinishWithError:)]) {
                [self.delegate mediaDownloader:self didFinishWithError:error];
            }
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(mediaDownloader:didReceiveResponse:)]) {
        [self.delegate mediaDownloader:self didReceiveResponse:response];
    }
}

- (void)seekWorker:(MNMediaSeekWorker *)seekWorker didReceiveData:(NSData *)data isLocal:(BOOL)isLocal {
    if ([self.delegate respondsToSelector:@selector(mediaDownloader:didReceiveData:)]) {
        [self.delegate mediaDownloader:self didReceiveData:data];
    }
}

- (void)seekWorker:(MNMediaSeekWorker *)seekWorker didFinishWithError:(NSError *)error {
    [[MNMediaDownloadContainer defaultContainer] removeURL:self.URL];
    
    if (!error && self.downloadToEnd) {
        self.downloadToEnd = NO;
        [self downloadTaskFromOffset:2 length:(NSUInteger)(self.cacheWorker.configuration.mediaInfo.contentLength - 2) toEnd:YES];
    } else {
        if ([self.delegate respondsToSelector:@selector(mediaDownloader:didFinishWithError:)]) {
            [self.delegate mediaDownloader:self didFinishWithError:error];
        }
    }
}

@end
