//
//  MNURLUploadRequest.h
//  MNKit
//
//  Created by Vincent on 2018/11/18.
//  Copyright © 2018年 小斯. All rights reserved.
//  上传请求

#import "MNURLRequest.h"

typedef void(^MNURLRequestUploadPathCallback)(NSURL **URL, NSData **data);

@interface MNURLUploadRequest : MNURLRequest

/**
 上传实例
 */
@property (nonatomic, readonly) NSURLSessionUploadTask *uploadTask;

/**
 上传的数据
 */
@property (nonatomic, copy) MNURLRequestUploadPathCallback uploadPathCallback;


/**
 开启上传请求
 @param startCallback 请求开始回调
 @param filePathCallback 文件地址回调
 @param progressCallback 进度回调
 @param finishCallback 请求结束回调
 */
- (void)uploadData:(MNURLRequestStartCallback)startCallback
          filePath:(MNURLRequestUploadPathCallback)filePathCallback
          progress:(MNURLRequestProgressCallback)progressCallback
        completion:(MNURLRequestFinishCallback)finishCallback;

@end

