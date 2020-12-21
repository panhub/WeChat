//
//  MNURLDownloadRequest.h
//  MNKit
//
//  Created by Vincent on 2018/11/18.
//  Copyright © 2018年 小斯. All rights reserved.
//  下载请求

#import "MNURLRequest.h"


NS_ASSUME_NONNULL_BEGIN

/**获取下载地址*/
typedef id _Nonnull(^MNURLRequestDownloadPathCallback)(NSURLResponse *_Nonnull response, NSURL *_Nonnull location);

@interface MNURLDownloadRequest : MNURLRequest
/**
 断点下载使用;
 不是下载数据本身, 而是已经下载好的数据相关信息;
 如: 文件名, 存储位置, 已经下载好的数据的长度等.
 */
@property (nonatomic, strong, readonly, nullable) NSData *resumeData;
/**
 返回下载后数据保存位置
 */
@property (nonatomic, copy, nullable) MNURLRequestDownloadPathCallback downloadPathCallback;
/**
 下载事件回调
 */
@property (nonatomic, weak, nullable) id<MNURLDownloadDelegate> delegate;
/**
 下载实例
 */
@property (nonatomic, readonly, nullable) NSURLSessionDownloadTask *downloadTask;

/**
 开始下载任务
 @param startCallback 开始下载回调
 @param filePath 返回下载数据保存路径
 @param progressCallback 进度回调
 @param finishCallback 下载结束回调
 */
- (void)downloadData:(MNURLRequestStartCallback _Nullable)startCallback
            filePath:(MNURLRequestDownloadPathCallback)filePath
            progress:(MNURLRequestProgressCallback _Nullable)progressCallback
          completion:(MNURLRequestFinishCallback _Nullable)finishCallback;

/**
 暂停 <相当于 cancelByProducingResumeData:nil>
 */
- (void)suspend;

/**
 可恢复的取消下载任务
 使用"<session>: downloadTaskWithResumeData:"新建下载请求, 恢复下载任务
 使用"resume"恢复下载任务
 @param completion 取消完成回调, 返回下载好的数据相关信息
 */
- (void)cancelByProducingResumeData:(void (^_Nullable)(NSData *_Nullable resumeData))completion;

/**
 用当前的数据标记开始下载
 @return 是否成功开启
 */
- (BOOL)resumeDownloading;

@end

NS_ASSUME_NONNULL_END
