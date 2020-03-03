//
//  MNURLSessionManager.h
//  MNKit
//
//  Created by Vincent on 2018/11/6.
//  Copyright © 2018年 小斯. All rights reserved.
//  请求管理者

#import <Foundation/Foundation.h>
@class MNURLRequest, MNURLDownloadRequest;

@interface MNURLSessionManager : NSObject

/**
 唯一实例化方法
 @return SessionManager实例
 */
+ (MNURLSessionManager *)defaultManager;

/**
 开始请求
 @param request 请求体
 */
- (void)loadRequest:(__kindof MNURLRequest *)request;

/**
 可恢复的取消下载任务
 @param downloadRequest 下载请求体
 @param completion 相关信息回调, 非实际数据, 是已经下载好的数据相关信息:文件名, 存储位置, 已经下载好的数据的长度等
 */
- (void)suspendDownloadWithRequest:(__kindof MNURLDownloadRequest *)downloadRequest
                           completion:(void (^)(NSData *resumeData))completion;

/**
 重新开启下载任务
 @param downloadRequest 下载请求体
 */
- (void)resumeDownloadWithRequest:(__kindof MNURLDownloadRequest *)downloadRequest;

/**
 取消请求<不可恢复>
 @param request 请求体
 */
- (void)cancelRequest:(__kindof MNURLRequest *)request;

#pragma mark Cache
/**
 获取数据缓存
 @param url 链接
 @return 缓存
 */
- (id<NSCoding>)cacheForUrl:(NSString *)url;

/**
 插入缓存数据
 @param cache 缓存
 @param url 链接
 */
- (void)setCache:(id<NSCoding>)cache forUrl:(NSString *)url;


@end

