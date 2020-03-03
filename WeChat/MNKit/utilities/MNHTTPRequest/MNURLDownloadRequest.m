//
//  MNURLDownloadRequest.m
//  MNKit
//
//  Created by Vincent on 2018/11/18.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNURLDownloadRequest.h"
#import "MNURLSessionManager.h"

@interface MNURLDownloadRequest ()
@property (nonatomic, strong, readwrite) NSData *resumeData;
@end
@implementation MNURLDownloadRequest

- (void)initialized {
    [super initialized];
    self.serializationType = MNURLRequestSerializationUnknown;
}

- (NSURLSessionDownloadTask *)downloadTask {
    return (NSURLSessionDownloadTask *)(self.task);
}

- (void)downloadData:(MNURLRequestStartCallback)startCallback
            filePath:(MNURLRequestDownloadPathCallback)filePath
            progress:(MNURLRequestProgressCallback)progressCallback
          completion:(MNURLRequestFinishCallback)finishCallback
{
    if (self.isLoading) return;
    self.startCallback = startCallback;
    self.progressCallback = progressCallback;
    self.downloadPathCallback = filePath;
    self.finishCallback = finishCallback;
    [[MNURLSessionManager defaultManager] loadRequest:self];
}

- (void)didLoadFinishWithResponseObject:(id)responseObject error:(NSError *)error {
    MNURLResponse *response;
    if (error) {
        response = [MNURLResponse responseWithError:error];
        [response setValue:self forKey:@"request"];
    } else {
        if (responseObject) {
            response = [MNURLResponse succeedResponseWithData:responseObject];
            [response setValue:self forKey:@"request"];
            /**根据项目需求定制自己的状态码*/
            [self didLoadFinishWithResponse:response];
            if (self.confirmResponseCallback) {
                self.confirmResponseCallback(response);
            }
        } else {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                 code:MNURLResponseCodeDataEmpty
                                             userInfo:@{@"MNURLDownloadRequestFilePathError":@"下载路径为空"}];
            response = [MNURLResponse responseWithCode:MNURLResponseCodeDataEmpty
                                                  data:nil
                                               message:@"下载出错, 文件保存失败"
                                                 error:error];
            [response setValue:self forKey:@"request"];
        }
    }
    /**保存response实例*/
    [self setValue:response forKey:@"response"];
    /**根据下载路径do some thing */
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
    [self cancelByProducingResumeData:nil];
}

- (void)resume {
    if (self.resumeData) {
        [[MNURLSessionManager defaultManager] resumeDownloadWithRequest:self];
    }
}

- (void)cancel {
    if (!self.isLoading) return;
    [[MNURLSessionManager defaultManager] cancelRequest:self];
}

- (void)cancelByProducingResumeData:(void (^)(NSData *resumeData))completion {
    if (!self.isLoading) return;
    [[MNURLSessionManager defaultManager] suspendDownloadWithRequest:self completion:completion];
}

- (void)cleanCallback {
    [super cleanCallback];
    self.downloadPathCallback = nil;
}

- (void)dealloc {
    self.downloadPathCallback = nil;
    self.resumeData = nil;
}

@end
