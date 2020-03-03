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
    self.cacheOutInterval = 3.f;
    self.method = MNURLHTTPMethodGet; 
    self.dataSource = MNURLDataSourceNetwork;
    self.cachePolicy = MNURLDataCacheNever;
}

- (void)loadData:(MNURLRequestStartCallback)startCallback
            completion:(MNURLRequestFinishCallback)finishCallback
{
    if (self.isLoading) return;
    self.startCallback = startCallback;
    self.finishCallback = finishCallback;
    [[MNURLSessionManager defaultManager] loadRequest:self];
}

- (NSURLSessionDataTask *)dataTask {
    return (NSURLSessionDataTask *)(self.task);
}

- (void)didLoadFinishWithResponseObject:(id)responseObject error:(NSError *)error {
    MNURLResponse *response;
    if (responseObject) {
        response = [MNURLResponse succeedResponseWithData:responseObject];
        [response setValue:self forKey:@"request"];
        /**根据项目需求定制自己的状态码*/
        [self didLoadFinishWithResponse:response];
        if (self.confirmResponseCallback) {
            self.confirmResponseCallback(response);
        }
    } else {
        if (error) {
            response = [MNURLResponse responseWithError:error];
        } else {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                 code:MNURLResponseCodeDataEmpty
                                             userInfo:@{@"MNURLDataRequestDataError":@"Data Empty"}];
            response = [MNURLResponse responseWithCode:MNURLResponseCodeDataEmpty
                                                  data:nil
                                               message:@"暂无数据, 请稍后重试"
                                                 error:error];
        }
        [response setValue:self forKey:@"request"];
    }
    /**保存response实例*/
    [self setValue:response forKey:@"response"];
    /**缓存数据, 回调解析数据*/
    if (response.code == MNURLResponseCodeSucceed) {
        if (self.method == MNURLHTTPMethodGet && self.dataSource == MNURLDataSourceNetwork  && self.cachePolicy != MNURLDataCacheNever) {
            [[MNURLSessionManager defaultManager] setCache:responseObject forUrl:self.url];
        }
        [self didLoadSucceedWithResponseObject:responseObject];
        if (self.didLoadSucceedCallback) {
            self.didLoadSucceedCallback(responseObject);
        }
    }
    /**请求结束, 回调请求结果*/
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.finishCallback) {
            self.finishCallback(response);
        }
    });
}

- (void)suspend {
    [self cancel];
}

- (void)resume {
    /**重新加载请求*/
    [self loadData:self.startCallback completion:self.finishCallback];
}

- (void)cancel {
    [[MNURLSessionManager defaultManager] cancelRequest:self];
}


@end
