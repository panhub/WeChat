//
//  MNURLDownloadRequest.h
//  MNKit
//
//  Created by Vincent on 2018/11/18.
//  Copyright © 2018年 小斯. All rights reserved.
//  下载请求

#import "MNURLRequest.h"

typedef NSURL * (^MNURLRequestDownloadPathCallback)(NSURLResponse *response, NSURL *location);

@interface MNURLDownloadRequest : MNURLRequest

/**
 断点下载使用;
 不是下载数据本身, 而是已经下载好的数据相关信息;
 如: 文件名, 存储位置, 已经下载好的数据的长度等.
 */
@property (nonatomic, strong, readonly) NSData *resumeData;

/**
 返回下载后数据保存位置
 */
@property (nonatomic, copy) MNURLRequestDownloadPathCallback downloadPathCallback;

/**
 下载实例
 */
@property (nonatomic, readonly) NSURLSessionDownloadTask *downloadTask;

/**
 开始下载任务
 @param startCallback 开始下载回调
 @param filePath 返回下载数据保存路径
 @param progressCallback 进度回调
 @param finishCallback 下载结束回调
 */
- (void)downloadData:(MNURLRequestStartCallback)startCallback
            filePath:(MNURLRequestDownloadPathCallback)filePath
            progress:(MNURLRequestProgressCallback)progressCallback
          completion:(MNURLRequestFinishCallback)finishCallback;

/**
 可恢复的取消下载任务
 使用"<session>: downloadTaskWithResumeData:"新建下载请求, 恢复下载任务
 使用"resume"恢复下载任务
 @param completion 取消完成回调, 返回下载好的数据相关信息
 */
- (void)cancelByProducingResumeData:(void (^)(NSData *resumeData))completion;


@end

