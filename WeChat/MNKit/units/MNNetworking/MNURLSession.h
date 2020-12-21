//
//  MNURLSession.h
//  MNKit
//
//  Created by Vincent on 2018/11/7.
//  Copyright © 2018年 小斯. All rights reserved.
//  数据请求回调

#import <Foundation/Foundation.h>
#import "MNURLRequestSerializer.h"
#import "MNURLResponseSerializer.h"
#import "MNSSLPolicy.h"

#pragma mark Public Callback

/**
 请求进度回调
 @param progress 进度信息
 */
typedef void(^MNURLSessionTaskProgressCallback)(NSProgress *progress);

/**
 请求结束回调
 @param response 响应者
 @param responseObject 请求数据<下载请求为文件路径>
 @param error 错误信息
 */
typedef void(^MNURLSessionTaskCompleteCallback)(NSURLResponse *response, id responseObject,  NSError *error);

/**
 询问文件存储位置
 @param response 响应者
 @param location 缓存位置
 @return 存储位置<NSString, NSURL>
 */
typedef id (^MNURLSessionDownloadPathCallback)(NSURLResponse *response, NSURL *location);

/**
 上传的内容<NSString, NSURL, NSData>
 */
typedef id (^MNURLSessionUploadBodyCallback)(void);

#pragma mark - NSURLSessionDelegate Callback
/**Session即将无效回调*/
typedef void (^MNURLSessionDidBecomeInvalidCallback)(NSURLSession *session, NSError *error);
/**Session级别HTTPS认证挑战回调*/
typedef NSURLSessionAuthChallengeDisposition (^MNURLSessionDidReceiveChallengeCallback)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential);
/**发送完最后一条消息回调*/
typedef void (^MNURLSessionDidFinishEventsForBackgroundCallback) (NSURLSession *session);

#pragma mark - NSURLSessionTaskDelegate Callback
/**重定向回调*/
typedef NSURLRequest * (^MNURLSessionTaskWillPerformHTTPRedirectionCallback)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request);
/**Task级别HTTPS认证挑战回调*/
typedef NSURLSessionAuthChallengeDisposition (^MNURLSessionTaskDidReceiveChallengeCallback)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential);
/**Task需要请求体碎片*/
typedef NSInputStream * (^MNURLSessionTaskNeedNewBodyStreamCallback) (NSURLSession *session, NSURLSessionTask *task);
/**已发送数据回调*/
typedef void (^MNURLSessionTaskDidSendBodyDataCallback)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
/**Task结束回调*/
typedef void (^MNURLSessionTaskDidCompleteCallback)(NSURLSession *session, NSURLSessionTask *task, NSError *error);

#pragma mark - NSURLSessionDataDelegate Callback
/**第一次响应回调*/
typedef NSURLSessionResponseDisposition (^MNURLSessionDataTaskDidReceiveResponseCallback)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response);
/**转变为下载请求回调*/
typedef void (^MNURLSessionDataTaskDidBecomeDownloadTaskCallback)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask);
/**接受数据回调*/
typedef void (^MNURLSessionDataTaskDidReceiveDataCallback)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data);
/**准备缓存响应者回调*/
typedef NSCachedURLResponse * (^MNURLSessionDataTaskWillCacheResponseCallback)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse);

#pragma mark - NSURLSessionDownloadDelegate Callback
/**下载结束回调, 返回地址, 存储数据*/
typedef NSURL * (^MNURLSessionDownloadTaskDidFinishDownloadingCallback)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location);
/**下载请求写入数据回调*/
typedef void (^MNURLSessionDownloadTaskDidWriteDataCallback)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
/**开始继续下载回调*/
typedef void (^MNURLSessionDownloadTaskDidResumeCallback)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes);
/**下载结束后根据提供的路径移动资源失败回调*/
typedef void (^MNURLSessionDownloadTaskMoveFileFailedCallback)(NSURLSessionDownloadTask *downloadTask, NSURL *location, NSError *error);

@interface MNURLSession : NSObject
#pragma mark -  Attribute
/**内部请求会话管理者*/
@property (readonly, nonatomic, strong) NSURLSession *session;
/**会话管理配置*/
@property (readonly, nonatomic, strong) NSURLSessionConfiguration *configuration;
/**结束回调的队列*/
@property (readwrite, nonatomic, strong) dispatch_queue_t completionQueue;
/**结束回调组*/
@property (readwrite, nonatomic, strong) dispatch_group_t completionGroup;
/**响应HTTPS SSL 挑战策略*/
@property (readonly, nonatomic, strong) MNSSLPolicy *SSLPolicy;

#pragma mark - NSURLSessionDelegate Callback Attribute
@property (readwrite, nonatomic, copy) MNURLSessionDidBecomeInvalidCallback didBecomeInvalidCallback;
@property (readwrite, nonatomic, copy) MNURLSessionDidReceiveChallengeCallback didReceiveChallengeCallback;
@property (readwrite, nonatomic, copy) MNURLSessionDidFinishEventsForBackgroundCallback didFinishEventsForBackgroundCallback;

#pragma mark - NSURLSessionTaskDelegate Callback Attribute
@property (readwrite, nonatomic, copy) MNURLSessionTaskWillPerformHTTPRedirectionCallback taskWillPerformHTTPRedirection;
@property (readwrite, nonatomic, copy) MNURLSessionTaskDidReceiveChallengeCallback taskDidReceiveChallengeCallback;
@property (readwrite, nonatomic, copy) MNURLSessionTaskNeedNewBodyStreamCallback taskNeedNewBodyStreamCallback;
@property (readwrite, nonatomic, copy) MNURLSessionTaskDidSendBodyDataCallback taskDidSendBodyDataCallback;
@property (readwrite, nonatomic, copy) MNURLSessionTaskDidCompleteCallback taskDidCompleteCallback;

#pragma mark - NSURLSessionDataDelegate Callback Attribute
@property (readwrite, nonatomic, copy) MNURLSessionDataTaskDidReceiveResponseCallback dataTaskDidReceiveResponseCallback;
@property (readwrite, nonatomic, copy) MNURLSessionDataTaskDidBecomeDownloadTaskCallback dataTaskDidBecomeDownloadTaskCallback;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
@property (readwrite, nonatomic, copy) void (^dataTaskDidBecomeStreamTaskCallback)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionStreamTask *streamTask);
#pragma clang diagnostic pop
#endif
@property (readwrite, nonatomic, copy) MNURLSessionDataTaskDidReceiveDataCallback dataTaskDidReceiveDataCallback;
@property (readwrite, nonatomic, copy) MNURLSessionDataTaskWillCacheResponseCallback dataTaskWillCacheResponseCallback;

#pragma mark - NSURLSessionDownloadDelegate Callback Attribute
@property (readwrite, nonatomic, copy) MNURLSessionDownloadTaskDidFinishDownloadingCallback downloadTaskDidFinishDownloadingCallback;
@property (readwrite, nonatomic, copy) MNURLSessionDownloadTaskMoveFileFailedCallback downloadTaskMoveFileFailedCallback;
@property (readwrite, nonatomic, copy) MNURLSessionDownloadTaskDidWriteDataCallback downloadTaskDidWriteDataCallback;
@property (readwrite, nonatomic, copy) MNURLSessionDownloadTaskDidResumeCallback downloadTaskDidResumeCallback;

#pragma mark ---- Method

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;

/**
 默认请求会话
 @return 请求会话实例
 */
+ (instancetype)defaultSession;

/**
 请求实例化会话入口
 @param configuration 会话配置
 @return 请求会话实例
 */
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;

#pragma mark - GET
/**
 GET请求
 @param url 请求地址
 @param downloadProgress 进度回调
 @param completion 完成回调
 @return 数据请求任务实例
 */
- (NSURLSessionDataTask *)GET:(NSString *)url
                     progress:(MNURLSessionTaskProgressCallback)downloadProgress
                   completion:(MNURLSessionTaskCompleteCallback)completion;

/**
 GET请求
 @param url 请求地址
 @param requestSerializer 请求序列化器
 @param responseSerializer 解析序列化器
 @param downloadProgress 进度回调
 @param completion 完成回调
 @return 数据请求任务实例
 */
- (NSURLSessionDataTask *)GET:(NSString *)url
            requestSerializer:(MNURLRequestSerializer *)requestSerializer
           responseSerializer:(MNURLResponseSerializer *)responseSerializer
                     progress:(MNURLSessionTaskProgressCallback)downloadProgress
                   completion:(MNURLSessionTaskCompleteCallback)completion;

#pragma mark - POST
/**
 POST请求
 @param url 请求地址
 @param uploadProgress 进度回调
 @param completion 完成回调
 @return 数据请求任务实例
 */
- (NSURLSessionDataTask *)POST:(NSString *)url
                      progress:(MNURLSessionTaskProgressCallback)uploadProgress
                    completion:(MNURLSessionTaskCompleteCallback)completion;

/**
 POST请求
 @param url 请求地址
 @param requestSerializer 请求序列化器
 @param responseSerializer 解析序列化器
 @param uploadProgress 进度回调
 @param completion 完成回调
 @return 数据请求任务实例
 */
- (NSURLSessionDataTask *)POST:(NSString *)url
                     requestSerializer:(MNURLRequestSerializer *)requestSerializer
                responseSerializer:(MNURLResponseSerializer *)responseSerializer
                      progress:(MNURLSessionTaskProgressCallback)uploadProgress
                    completion:(MNURLSessionTaskCompleteCallback)completion;

#pragma mark - Upload
/**
 上传请求
 @param url 请求地址
 @param requestSerializer 请求序列化器
 @param responseSerializer 解析序列化器
 @param uploadBody 上传体请求回调
 @param uploadProgress 进度回调
 @param completion 完成回调
 @return 上传请求任务实例
 */
- (NSURLSessionUploadTask *)uploadTaskWithUrl:(NSString *)url
                                    requestSerializer:(MNURLRequestSerializer *)requestSerializer
                           responseSerializer:(MNURLResponseSerializer *)responseSerializer
                                   body:(MNURLSessionUploadBodyCallback)uploadBody
                                     progress:(MNURLSessionTaskProgressCallback)uploadProgress
                                   completion:(MNURLSessionTaskCompleteCallback)completion;

/**
 上传请求
 @param url 请求地址
 @param fileURL 上传体请求文件路径
 @param requestSerializer 请求序列化器
 @param responseSerializer 解析序列化器
 @param uploadProgress 进度回调
 @param completion 完成回调
 @return 上传请求任务实例
 */
- (NSURLSessionUploadTask *)uploadTaskWithUrl:(NSString *)url
                                          URL:(NSURL *)fileURL
                                requestSerializer:(MNURLRequestSerializer *)requestSerializer
                            responseSerializer:(MNURLResponseSerializer *)responseSerializer
                                     progress:(MNURLSessionTaskProgressCallback)uploadProgress
                                   completion:(MNURLSessionTaskCompleteCallback)completion;

/**
 上传请求
 @param url 请求地址
 @param bodyData 上传数据
 @param requestSerializer 请求序列化器
 @param responseSerializer 解析序列化器
 @param uploadProgress 进度回调
 @param completion 完成回调
 @return 上传请求任务实例
 */
- (NSURLSessionUploadTask *)uploadTaskWithUrl:(NSString *)url
                                     data:(NSData *)bodyData
                                requestSerializer:(MNURLRequestSerializer *)requestSerializer
                            responseSerializer:(MNURLResponseSerializer *)responseSerializer
                                     progress:(MNURLSessionTaskProgressCallback)uploadProgress
                                   completion:(MNURLSessionTaskCompleteCallback)completion;

#pragma mark - DownloadTask
/**
 下载请求
 @param url 请求地址
 @param requestSerializer 请求序列化器
 @param responseSerializer 解析序列化器
 @param downloadPath 下载路径回调
 @param downloadProgress 进度回调
 @param completion 完成回调
 @return 下载请求任务实例
 */
- (NSURLSessionDownloadTask *)downloadTaskWithUrl:(NSString *)url
                                            requestSerializer:(MNURLRequestSerializer *)requestSerializer
                                responseSerializer:(MNURLResponseSerializer *)responseSerializer
                                             path:(MNURLSessionDownloadPathCallback)downloadPath
                                         progress:(MNURLSessionTaskProgressCallback)downloadProgress
                                  completion:(MNURLSessionTaskCompleteCallback)completion;

/**
 断点下载支持
 @param resumeData 暂停下载的数据
 @param responseSerializer 解析序列化器
 @param downloadPath 下载路径回调
 @param downloadProgress 进度回调
 @param completion 完成回调
 @return 下载请求任务实例
 */
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                            responseSerializer:(MNURLResponseSerializer *)responseSerializer
                                                    path:(MNURLSessionDownloadPathCallback)downloadPath
                                                progress:(MNURLSessionTaskProgressCallback)downloadProgress
                                              completion:(MNURLSessionTaskCompleteCallback)completion;

#pragma mark - Progress
/**
 获取上传进度
 @param task 请求任务实例
 @return 进度信息
 */
- (NSProgress *)uploadProgressForTask:(NSURLSessionTask *)task;

/**
 获取下载进度
 @param task 请求任务实例
 @return 进度信息
 */
- (NSProgress *)downloadProgressForTask:(NSURLSessionTask *)task;

@end


