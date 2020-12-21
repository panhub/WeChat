//
//  MNURLUploadRequest.h
//  MNKit
//
//  Created by Vincent on 2018/11/18.
//  Copyright © 2018年 小斯. All rights reserved.
//  上传请求

#import "MNURLRequest.h"
#import "MNURLBodyAdaptor.h"

NS_ASSUME_NONNULL_BEGIN

/**获取上传内容<NSString, NSURL, NSData>*/
typedef id _Nonnull (^MNURLRequestUploadBodyCallback)(void);

@interface MNURLUploadRequest : MNURLRequest
/**
 上传请求的文件内容边界值
 */
@property (nonatomic, copy, nullable) NSString *boundary;
/**
 上传实例
 */
@property (nonatomic, readonly, nullable) NSURLSessionUploadTask *uploadTask;
/**
 上传的数据
 */
@property (nonatomic, copy, nullable) MNURLRequestUploadBodyCallback bodyCallback;
/**
 上传事件回调
 */
@property (nonatomic, weak, nullable) id<MNURLUploadDelegate> delegate;


/**
 开启上传请求
 @param startCallback 请求开始回调
 @param bodyCallback 上传内容回调
 @param progressCallback 进度回调
 @param finishCallback 请求结束回调
 */
- (void)uploadData:(MNURLRequestStartCallback _Nullable)startCallback
          body:(MNURLRequestUploadBodyCallback)bodyCallback
          progress:(MNURLRequestProgressCallback _Nullable)progressCallback
        completion:(MNURLRequestFinishCallback _Nullable)finishCallback;

/**
 利用适配者上传数据
 @param bodyAdaptor 数据体适配者
 @param startCallback 请求开始回调
 @param progressCallback 进度回调
 @param finishCallback 请求结束回调
 */
- (void)uploadUsingAdaptor:(MNURLBodyAdaptor *)bodyAdaptor
                     start:(MNURLRequestStartCallback _Nullable)startCallback
                  progress:(MNURLRequestProgressCallback _Nullable)progressCallback
                completion:(MNURLRequestFinishCallback _Nullable)finishCallback;

@end

NS_ASSUME_NONNULL_END
