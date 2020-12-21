//
//  MNURLDataRequest.m
//  MNKit
//
//  Created by Vincent on 2018/11/7.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNURLDataRequest.h"
#import "MNURLSessionManager.h"

@interface MNURLDataRequest ()

@end

@implementation MNURLDataRequest
- (void)initialized {
    [super initialized];
    self.method = MNURLHTTPMethodGet; 
    self.dataSource = MNURLDataSourceNetwork;
    self.cacheTimeOutInterval = 60.f*60.f*24.f*3.f;
    self.cachePolicy = MNURLDataCachePolicyNever;
}

- (void)loadData:(MNURLRequestStartCallback)startCallback
            completion:(MNURLRequestFinishCallback)finishCallback
{
    self.startCallback = startCallback;
    self.finishCallback = finishCallback;
    [self resume];
}

#pragma mark - Super
- (void)didFinishWithResponseObject:(id)responseObject error:(NSError *)error {
    /**更新数据*/
    if (!responseObject && self.method == MNURLHTTPMethodGet && self.dataSource == MNURLDataSourceNetwork && self.cachePolicy == MNURLDataCachePolicyElseLoad) {
        id<NSCoding> cache = [MNURLSessionManager.defaultManager cacheForUrl:self.cacheForUrl timeoutInterval:self.cacheTimeOutInterval];
        if (cache) {
            error = nil;
            responseObject = cache;
            self.dataSource = MNURLDataSourceCache;
        }
    }
    MNURLResponse *response;
    if (responseObject) {
        response = [MNURLResponse succeedResponseWithData:responseObject];
        [response setValue:self forKey:MNURLPath(response.request)];
        /**根据项目需求定制自己的状态码*/
        [self didFinishWithSupposedResponse:response];
        if ([self.delegate respondsToSelector:@selector(didFinishRequesting:supposedResponse:)]) {
            [self.delegate didFinishRequesting:self supposedResponse:response];
        }
    } else {
        if (!error) {
            error = [NSError errorWithDomain:NSURLErrorDomain
                                        code:MNURLResponseCodeDataEmpty
                                    userInfo:@{NSLocalizedDescriptionKey:@"请求数据失败",
                                               NSLocalizedFailureReasonErrorKey: @"请求结果为空",
                                               NSURLErrorKey: @"response object is empty"}];
        }
        response = [MNURLResponse responseWithError:error];
        [response setValue:self forKey:MNURLPath(response.request)];
    }
    /**保存response实例*/
    [self setValue:response forKey:MNURLPath(self.response)];
    /**缓存数据, 回调解析数据*/
    if (response.code == MNURLResponseCodeSucceed) {
        if (self.method == MNURLHTTPMethodGet && self.dataSource == MNURLDataSourceNetwork && self.cachePolicy == MNURLDataCachePolicyElseLoad) {
            NSString *cacheUrl = self.cacheForUrl;
            if (cacheUrl && cacheUrl.length) [MNURLSessionManager.defaultManager setCache:responseObject forUrl:cacheUrl];
        }
        [self didSucceedWithResponseObject:responseObject];
        if ([self.delegate respondsToSelector:@selector(didSucceedRequesting:responseObject:)]) {
            [self.delegate didSucceedRequesting:self responseObject:responseObject];
        }
    }
    /**请求结束, 回调请求结果*/
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(didFinishRequesting:response:)]) {
            [self.delegate didFinishRequesting:self response:response];
        }
        if (self.finishCallback) self.finishCallback(response);
    });
}

#pragma mark - Setter
- (void)setRetryCount:(int)retryCount {
    _retryCount = MAX(0, retryCount);
}

- (void)setCurrentRequestCount:(int)currentRequestCount {
    _currentRequestCount = MAX(0, currentRequestCount);
}

#pragma mark - Getter
- (NSURLSessionDataTask *)dataTask {
    return (NSURLSessionDataTask *)(self.task);
}

- (NSString *)cacheForUrl {
    if (_cacheForUrl) return _cacheForUrl;
    if ([self.delegate respondsToSelector:@selector(requestCacheForUrl:)]) {
        return [self.delegate requestCacheForUrl:self];
    }
    return self.url;
}

#pragma mark - dealloc
- (void)dealloc {
    _delegate = nil;
}

@end
