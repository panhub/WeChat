//
//  MNURLUploadRequest.m
//  MNKit
//
//  Created by Vincent on 2018/11/18.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNURLUploadRequest.h"

@implementation MNURLUploadRequest

- (void)uploadData:(MNURLRequestStartCallback)startCallback
          body:(MNURLRequestUploadBodyCallback)bodyCallback
          progress:(MNURLRequestProgressCallback)progressCallback
        completion:(MNURLRequestFinishCallback)finishCallback
{
    self.startCallback = startCallback;
    self.bodyCallback = bodyCallback;
    self.progressCallback = progressCallback;
    self.finishCallback = finishCallback;
    [self resume];
}

- (void)uploadUsingAdaptor:(MNURLBodyAdaptor *)bodyAdaptor
                     start:(MNURLRequestStartCallback _Nullable)startCallback
                  progress:(MNURLRequestProgressCallback _Nullable)progressCallback
                completion:(MNURLRequestFinishCallback _Nullable)finishCallback {
    [bodyAdaptor endAdapting];
    self.boundary = bodyAdaptor.boundary;
    NSData *uploadData = bodyAdaptor.data;
    [self uploadData:startCallback body:^id _Nonnull{
        return uploadData;
    } progress:progressCallback completion:finishCallback];
}

#pragma mark - Super
- (void)didFinishWithResponseObject:(id)responseObject error:(NSError *)error {
    MNURLResponse *response;
    if (error) {
        response = [MNURLResponse responseWithError:error];
        [response setValue:self forKey:MNURLPath(response.request)];
    } else {
        response = [MNURLResponse succeedResponseWithData:responseObject];
        [response setValue:self forKey:MNURLPath(response.request)];
        /**根据项目需求定制自己的状态码*/
        [self didFinishWithSupposedResponse:response];
        if ([self.delegate respondsToSelector:@selector(didFinishRequesting:supposedResponse:)]) {
            [self.delegate didFinishRequesting:self supposedResponse:response];
        }
    }
    /**保存response实例*/
    [self setValue:response forKey:MNURLPath(self.response)];
    /**解析数据*/
    if (response.code == MNURLResponseCodeSucceed) {
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

#pragma mark - Getter
- (MNURLRequestProgressCallback)progressCallback {
    MNURLRequestProgressCallback progressCallback = [super progressCallback];
    if (!progressCallback && self.delegate) {
        __weak typeof(self) weakself = self;
        progressCallback = ^(NSProgress *rogress){
            if ([weakself.delegate respondsToSelector:@selector(uploadRequest:didUploading:)]) {
                [weakself.delegate uploadRequest:weakself didUploading:rogress];
            }
        };
        [super setProgressCallback:[progressCallback copy]];
    }
    return progressCallback;
}

- (MNURLRequestUploadBodyCallback)bodyCallback {
    if (!_bodyCallback && self.delegate) {
        __weak typeof(self) weakself = self;
        MNURLRequestUploadBodyCallback bodyCallback = ^id _Nonnull{
            id body;
            if ([weakself.delegate respondsToSelector:@selector(uploadRequestBody:)]) {
                body = [weakself.delegate uploadRequestBody:weakself];
            }
            return body;
        };
        _bodyCallback = [bodyCallback copy];
    }
    return _bodyCallback;
}

- (NSURLSessionUploadTask *)uploadTask {
    return (NSURLSessionUploadTask *)(self.task);
}

#pragma mark - dealloc
- (void)dealloc {
    _delegate = nil;
}

@end
