//
//  MNMediaResourceLoader.m
//  MNKit
//
//  Created by Vincent on 2018/11/30.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNMediaResourceLoader.h"
#import "MNMediaDownloader.h"
#import "MNMediaCacheWorker.h"
#import "MNMediaLoadRequestWorker.h"

NSString * const MNMediaResourceLoaderErrorDomain = @"MNMediaResourceLoaderErrorDomain";

@interface MNMediaResourceLoader ()<MNMediaLoadRequestWorkerDelegate>
@property (nonatomic, strong, readwrite) NSURL *URL;
@property (nonatomic, strong) MNMediaCacheWorker *cacheWorker;
@property (nonatomic, strong) MNMediaDownloader *downloader;
@property (nonatomic, strong) NSMutableArray<MNMediaLoadRequestWorker *> *requestWorkers;
@property (nonatomic, getter=isCancelled) BOOL cancelled;
@end

@implementation MNMediaResourceLoader
- (void)dealloc {
    [_downloader cancel];
}

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    if (!self) return nil;
    _URL = URL;
    MNMediaCacheWorker *cacheWorker = [[MNMediaCacheWorker alloc] initWithURL:URL];
    self.cacheWorker = cacheWorker;
    self.downloader = [[MNMediaDownloader alloc] initWithURL:URL cacheWorker:cacheWorker];
    self.requestWorkers = [NSMutableArray arrayWithCapacity:0];
    return self;
}

- (void)addRequest:(AVAssetResourceLoadingRequest *)request {
    if (self.requestWorkers.count > 0) {
        [self startNoCacheWorkerWithRequest:request];
    } else {
        [self startWorkerWithRequest:request];
    }
}

- (void)startNoCacheWorkerWithRequest:(AVAssetResourceLoadingRequest *)request {
    [[MNMediaDownloadContainer defaultContainer] addURL:self.URL];
    MNMediaDownloader *mediaDownloader = [[MNMediaDownloader alloc] initWithURL:self.URL cacheWorker:self.cacheWorker];
    MNMediaLoadRequestWorker *requestWorker = [[MNMediaLoadRequestWorker alloc] initWithMediaDownloader:mediaDownloader loadingRequest:request];
    [self.requestWorkers addObject:requestWorker];
    requestWorker.delegate = self;
    [requestWorker startWork];
}

- (void)startWorkerWithRequest:(AVAssetResourceLoadingRequest *)request {
    [[MNMediaDownloadContainer defaultContainer] addURL:self.URL];
    MNMediaLoadRequestWorker *requestWorker = [[MNMediaLoadRequestWorker alloc] initWithMediaDownloader:self.downloader loadingRequest:request];
    [self.requestWorkers addObject:requestWorker];
    requestWorker.delegate = self;
    [requestWorker startWork];
}

- (NSError *)loaderCancelledError {
    NSError *error = [[NSError alloc] initWithDomain:MNMediaResourceLoaderErrorDomain
                                                code:-3
                                            userInfo:@{NSLocalizedDescriptionKey:@"Resource loader cancelled"}];
    return error;
}

- (void)removeRequest:(AVAssetResourceLoadingRequest *)request {
    __block MNMediaLoadRequestWorker *requestWorker = nil;
    [self.requestWorkers enumerateObjectsUsingBlock:^(MNMediaLoadRequestWorker *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.request == request) {
            requestWorker = obj;
            *stop = YES;
        }
    }];
    if (requestWorker) {
        [requestWorker finish];
        [self.requestWorkers removeObject:requestWorker];
    }
}

- (void)cancel {
    [self.downloader cancel];
    [self.requestWorkers removeAllObjects];
    [[MNMediaDownloadContainer defaultContainer] removeURL:self.URL];
}

#pragma mark - MNMediaLoadRequestWorkerDelegate
- (void)mediaLoadRequestWorker:(MNMediaLoadRequestWorker *)requestWorker didCompleteWithError:(NSError *)error {
    [self removeRequest:requestWorker.request];
    if (error && [self.delegate respondsToSelector:@selector(mediaResourceLoader:didFailWithError:)]) {
        [self.delegate mediaResourceLoader:self didFailWithError:error];
    }
    if (self.requestWorkers.count == 0) {
        [[MNMediaDownloadContainer defaultContainer] removeURL:self.URL];
    }
}

@end
