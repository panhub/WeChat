//
//  MNURLUploadRequest.m
//  MNKit
//
//  Created by Vincent on 2018/11/18.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNURLUploadRequest.h"
#import "MNURLSessionManager.h"

@implementation MNURLUploadRequest

- (void)uploadData:(MNURLRequestStartCallback)startCallback
          filePath:(MNURLRequestUploadPathCallback)filePathCallback
          progress:(MNURLRequestProgressCallback)progressCallback
        completion:(MNURLRequestFinishCallback)finishCallback
{
    if (self.isLoading) return;
    self.startCallback = startCallback;
    self.uploadPathCallback = filePathCallback;
    self.progressCallback = progressCallback;
    self.finishCallback = finishCallback;
    [[MNURLSessionManager defaultManager] loadRequest:self];
}

- (NSURLSessionUploadTask *)uploadTask {
    return (NSURLSessionUploadTask *)(self.task);
}

- (void)didLoadFinishWithResponseObject:(id)responseObject error:(NSError *)error {
    MNURLResponse *response;
    if (error) {
        response = [MNURLResponse responseWithError:error];
        [response setValue:self forKey:@"request"];
    } else {
        response = [MNURLResponse succeedResponseWithData:responseObject];
        [response setValue:self forKey:@"request"];
        /**根据项目需求定制自己的状态码*/
        [self didLoadFinishWithResponse:response];
        if (self.confirmResponseCallback) {
            self.confirmResponseCallback(response);
        }
    }
    /**保存response实例*/
    [self setValue:response forKey:@"response"];
    /**解析数据*/
    if (response.code == MNURLResponseCodeSucceed) {
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
    if (self.isLoading) return;
    [self uploadData:self.startCallback
            filePath:self.uploadPathCallback
            progress:self.progressCallback
          completion:self.finishCallback];
}

- (void)cancel {
    if (!self.isLoading) return;
    [[MNURLSessionManager defaultManager] cancelRequest:self];
}

@end
