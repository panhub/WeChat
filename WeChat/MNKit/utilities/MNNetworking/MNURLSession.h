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
 下载结束询问存储位置回调
 @param response 响应者
 @param location 缓存位置
 @return 存储位置
 */
typedef NSURL * (^MNURLSessionDownloadPathCallback)(NSURLResponse *response, NSURL *location);

/**
 上传数据<二选一即可>
 @param URL 文件地址
 @param data 数据二进制
 */
typedef void(^MNURLSessionUploadPathCallback)(NSURL **URL, NSData **data);

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
@property (readonly, nonatomic, strong) NSURLSession *session;
@property (readonly, nonatomic, strong) NSURLSessionConfiguration *configuration;
@property (readwrite, nonatomic, strong) dispatch_queue_t completionQueue;
@property (readwrite, nonatomic, strong) dispatch_group_t completionGroup;

@property (readonly, nonatomic, strong) MNURLRequestSerializer *requestSerializer;
@property (readonly, nonatomic, strong) MNURLResponseSerializer *responseSerializer;
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

+ (instancetype)defaultSession;

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

#pragma mark - GET
- (NSURLSessionDataTask *)GET:(NSString *)url
                               parameter:(NSDictionary *)parameter
                         downloadProgress:(MNURLSessionTaskProgressCallback)downloadProgress
                                  completion:(MNURLSessionTaskCompleteCallback)completion;

#pragma mark - POST
- (NSURLSessionDataTask *)POST:(NSString *)url
                     parameter:(NSDictionary *)parameter
                uploadProgress:(MNURLSessionTaskProgressCallback)uploadProgress
                       completion:(MNURLSessionTaskCompleteCallback)completion;

#pragma mark - Upload
- (NSURLSessionUploadTask *)uploadTaskWithUrl:(NSString *)url
                                    parameter:(NSDictionary *)parameter
                                   uploadPath:(MNURLSessionUploadPathCallback)uploadPath
                               uploadProgress:(MNURLSessionTaskProgressCallback)uploadProgress
                                   completion:(MNURLSessionTaskCompleteCallback)completion;

- (NSURLSessionUploadTask *)uploadTaskWithUrl:(NSString *)url
                                    parameter:(NSDictionary *)parameter
                                      fromURL:(NSURL *)fileURL
                               uploadProgress:(MNURLSessionTaskProgressCallback)uploadProgress
                                      completion:(MNURLSessionTaskCompleteCallback)completion;

- (NSURLSessionUploadTask *)uploadTaskWithUrl:(NSString *)url
                                    parameter:(NSDictionary *)parameter
                                      fromData:(NSData *)bodyData
                               uploadProgress:(MNURLSessionTaskProgressCallback)uploadProgress
                                   completion:(MNURLSessionTaskCompleteCallback)completion;

#pragma mark - DownloadTask
- (NSURLSessionDownloadTask *)downloadTaskWithUrl:(NSString *)url
                                        parameter:(NSDictionary *)parameter
                            downloadPath:(MNURLSessionDownloadPathCallback)downloadPath
                              downloadProgress:(MNURLSessionTaskProgressCallback)downloadProgress
                                  completion:(MNURLSessionTaskCompleteCallback)completion;

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                            downloadPath:(MNURLSessionDownloadPathCallback)downloadPath
                                        downloadProgress:(MNURLSessionTaskProgressCallback)downloadProgress
                                              completion:(MNURLSessionTaskCompleteCallback)completion;

#pragma mark - Progress
- (NSProgress *)uploadProgressForTask:(NSURLSessionTask *)task;

- (NSProgress *)downloadProgressForTask:(NSURLSessionTask *)task;

@end


