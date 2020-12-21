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
@property (nonatomic, strong) NSData *resumeData;
@end

@implementation MNURLDownloadRequest

- (void)initialized {
    [super initialized];
    self.serializationType = MNURLRequestSerializationTypeUnknown;
}

- (void)downloadData:(MNURLRequestStartCallback)startCallback
            filePath:(MNURLRequestDownloadPathCallback)filePath
            progress:(MNURLRequestProgressCallback)progressCallback
          completion:(MNURLRequestFinishCallback)finishCallback
{
    self.startCallback = startCallback;
    self.progressCallback = progressCallback;
    self.downloadPathCallback = filePath;
    self.finishCallback = finishCallback;
    [self resume];
}

- (void)suspend {
    [self cancelByProducingResumeData:nil];
}

#pragma mark - Super
- (void)didFinishWithResponseObject:(id)responseObject error:(NSError *)error {
    MNURLResponse *response;
    if (error) {
        response = [MNURLResponse responseWithError:error];
        [response setValue:self forKey:MNURLPath(response.request)];
    } else {
        if (responseObject) {
            response = [MNURLResponse succeedResponseWithData:responseObject];
            [response setValue:self forKey:MNURLPath(response.request)];
            /**根据项目需求定制自己的状态码*/
            [self didFinishWithSupposedResponse:response];
            if ([self.delegate respondsToSelector:@selector(didFinishRequesting:supposedResponse:)]) {
                [self.delegate didFinishRequesting:self supposedResponse:response];
            }
        } else {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                                 code:NSURLErrorCannotWriteToFile
                                             userInfo:@{NSFilePathErrorKey: @"file path error", NSLocalizedFailureReasonErrorKey: @"文件路径错误, 文件保存失败", NSLocalizedDescriptionKey: @"保存文件失败"}];
            response = [MNURLResponse responseWithError:error];
            [response setValue:self forKey:MNURLPath(response.request)];
        }
    }
    /**保存response实例*/
    [self setValue:response forKey:MNURLPath(self.response)];
    /**根据下载路径do some thing */
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

- (BOOL)resumeDownloading {
    return [[MNURLSessionManager defaultManager] resumeDownloadWithRequest:self];
}

- (void)cancelByProducingResumeData:(void (^)(NSData *resumeData))completion {
    [[MNURLSessionManager defaultManager] cancelByProducingResumeData:self completion:completion];
}

#pragma mark - Getter
- (MNURLRequestProgressCallback)progressCallback {
    MNURLRequestProgressCallback progressCallback = [super progressCallback];
    if (!progressCallback && self.delegate) {
        __weak typeof(self) weakself = self;
        progressCallback = ^(NSProgress *rogress){
            if ([weakself.delegate respondsToSelector:@selector(downloadRequest:didDownloading:)]) {
                [weakself.delegate downloadRequest:weakself didDownloading:rogress];
            }
        };
        [super setProgressCallback:[progressCallback copy]];
    }
    return progressCallback;
}

- (MNURLRequestDownloadPathCallback)downloadPathCallback {
    if (!_downloadPathCallback && self.delegate) {
        __weak typeof(self) weakself = self;
        MNURLRequestDownloadPathCallback downloadPathCallback = ^id _Nonnull(NSURLResponse *response, NSURL *location){
            id downloadPath;
            if ([weakself.delegate respondsToSelector:@selector(downloadRequest:didStopWithResponse:location:)]) {
                downloadPath = [weakself.delegate downloadRequest:weakself didStopWithResponse:response location:location];
            }
            return downloadPath;
        };
        _downloadPathCallback = [downloadPathCallback copy];
    }
    return _downloadPathCallback;
}

- (NSURLSessionDownloadTask *)downloadTask {
    return (NSURLSessionDownloadTask *)(self.task);
}

- (void)cleanCallback {
    [super cleanCallback];
    self.downloadPathCallback = nil;
}

- (void)dealloc {
    _delegate = nil;
    _resumeData = nil;
    _downloadPathCallback = nil;
}

@end
