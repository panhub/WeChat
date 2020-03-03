//
//  MNMediaLoadRequestWorker.m
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNMediaLoadRequestWorker.h"
#import "MNMediaDownloader.h"
#import "MNMediaInfo.h"

@interface MNMediaLoadRequestWorker ()<MNMediaDownloaderDelegate>
@property (nonatomic, strong, readwrite) AVAssetResourceLoadingRequest *request;
@property (nonatomic, strong) MNMediaDownloader *mediaDownloader;
@end

@implementation MNMediaLoadRequestWorker
- (instancetype)initWithMediaDownloader:(MNMediaDownloader *)mediaDownloader loadingRequest:(AVAssetResourceLoadingRequest *)request {
    self = [super init];
    if (self) {
        _mediaDownloader = mediaDownloader;
        _mediaDownloader.delegate = self;
        _request = request;
        
        [self fullfillMediaInfo];
    }
    return self;
}

- (void)startWork {
    AVAssetResourceLoadingDataRequest *dataRequest = self.request.dataRequest;
    
    long long offset = dataRequest.requestedOffset;
    NSInteger length = dataRequest.requestedLength;
    if (dataRequest.currentOffset != 0) {
        offset = dataRequest.currentOffset;
    }
    
    BOOL toEnd = NO;
    if (@available(iOS 9.0, *)) {
        if (dataRequest.requestsAllDataToEndOfResource) {
            toEnd = YES;
        }
    }
    [self.mediaDownloader downloadTaskFromOffset:offset length:length toEnd:toEnd];
}

- (void)cancel {
    [self.mediaDownloader cancel];
}

- (void)finish {
    if (!self.request.isFinished) {
        [self.request finishLoadingWithError:[self loaderCancelledError]];
    }
}

- (NSError *)loaderCancelledError{
    NSError *error = [[NSError alloc] initWithDomain:@"com.resourceloader"
                                                code:-3
                                            userInfo:@{NSLocalizedDescriptionKey:@"Resource loader cancelled"}];
    return error;
}

- (void)fullfillMediaInfo {
    AVAssetResourceLoadingContentInformationRequest *contentInformationRequest = self.request.contentInformationRequest;
    if (self.mediaDownloader.info && !contentInformationRequest.contentType) {
        // Fullfill content information
        contentInformationRequest.contentType = self.mediaDownloader.info.contentType;
        contentInformationRequest.contentLength = self.mediaDownloader.info.contentLength;
        contentInformationRequest.byteRangeAccessSupported = self.mediaDownloader.info.byteRangeAccessSupported;
    }
}

#pragma mark - VIMediaDownloaderDelegate
- (void)mediaDownloader:(MNMediaDownloader *)downloader didReceiveResponse:(NSURLResponse *)response {
    [self fullfillMediaInfo];
}

- (void)mediaDownloader:(MNMediaDownloader *)downloader didReceiveData:(NSData *)data {
    [self.request.dataRequest respondWithData:data];
}

- (void)mediaDownloader:(MNMediaDownloader *)downloader didFinishWithError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) return;
    if (!error) {
        [self.request finishLoading];
    } else {
        [self.request finishLoadingWithError:error];
    }
    if ([self.delegate respondsToSelector:@selector(mediaLoadRequestWorker:didCompleteWithError:)]) {
        [self.delegate mediaLoadRequestWorker:self didCompleteWithError:error];
    }
}

@end
