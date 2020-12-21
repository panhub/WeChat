//
//  MNURLSession.m
//  MNKit
//
//  Created by Vincent on 2018/11/7.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNURLSession.h"

static dispatch_queue_t mn_url_session_create_task_queue(void) {
    static dispatch_queue_t mn_url_session_task_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mn_url_session_task_queue = dispatch_queue_create("com.mn.networking.session.task.queue", DISPATCH_QUEUE_SERIAL);
    });
    return mn_url_session_task_queue;
}

static void mn_url_session_create_task_safely (dispatch_block_t block) {
    dispatch_sync(mn_url_session_create_task_queue(), block);
}

static dispatch_group_t mn_url_session_create_completion_group(void) {
    static dispatch_group_t mn_url_session_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mn_url_session_completion_group = dispatch_group_create();
    });
    return mn_url_session_completion_group;
}

static dispatch_queue_t mn_url_session_create_serialization_queue(void) {
    static dispatch_queue_t mn_url_session_serialization_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mn_url_session_serialization_queue = dispatch_queue_create("com.mn.networking.session.serialization.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return mn_url_session_serialization_queue;
}

@interface MNURLSessionTaskDelegate : NSObject
@property (nonatomic, copy) id downloadPath;
@property (nonatomic, weak) MNURLSession *session;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSProgress *uploadProgress;
@property (nonatomic, strong) NSProgress *downloadProgress;
@property (nonatomic, strong) MNURLResponseSerializer *responseSerializer;
@property (nonatomic, copy) MNURLSessionTaskProgressCallback uploadProgressCallback;
@property (nonatomic, copy) MNURLSessionTaskProgressCallback downloadProgressCallback;
@property (nonatomic, copy) MNURLSessionDownloadPathCallback downloadPathCallback;
@property (nonatomic, copy) MNURLSessionTaskCompleteCallback completionCallback;

- (instancetype)initWithTask:(NSURLSessionTask *)task;

@end

@implementation MNURLSessionTaskDelegate
- (instancetype)initWithTask:(NSURLSessionTask *)task {
    self = [super init];
    if (!self) return nil;
    
    self.mutableData = [NSMutableData data];
    self.uploadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    self.downloadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    
    __weak __typeof__(task) weakTask = task;
    for (NSProgress *progress in @[ _uploadProgress, _downloadProgress ])
    {
        progress.totalUnitCount = NSURLSessionTransferSizeUnknown;
        progress.cancellable = YES;
        progress.cancellationHandler = ^{
            [weakTask cancel];
        };
        progress.pausable = YES;
        progress.pausingHandler = ^{
            [weakTask suspend];
        };
        if (@available(iOS 9.0, *)) {
            if ([progress respondsToSelector:NSSelectorFromString(@"setResumingHandler:")]) {
                progress.resumingHandler = ^{
                    [weakTask resume];
                };
            }
        }
        [progress addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    }
    return self;
}

#pragma mark - dealloc
- (void)dealloc {
    self.completionCallback = nil;
    self.downloadPathCallback = nil;
    self.uploadProgressCallback = nil;
    self.downloadProgressCallback = nil;
    [self.uploadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    [self.downloadProgress removeObserver:self  forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
}

#pragma mark - NSProgress Tracking
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([object isEqual:self.downloadProgress]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.downloadProgressCallback) {
                self.downloadProgressCallback(object);
            }
        });
    } else if ([object isEqual:self.uploadProgress]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.uploadProgressCallback) {
                self.uploadProgressCallback(object);
            }
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(__unused NSURLSession *)URLSession
              task:(NSURLSessionTask *)task
        didCompleteWithError:(NSError *)error
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    //强引用self.session为了防止被提前释放
    __strong MNURLSession *session = self.session;
    __block id responseObject = nil;
    //接収二进制数据
    NSData *data = nil;
    if (self.mutableData) {
        data = [self.mutableData copy];
        self.mutableData = nil;
    }
    //错误就回调信息
    if (error) {
        dispatch_group_async(session.completionGroup ?: mn_url_session_create_completion_group(), session.completionQueue ?: dispatch_get_main_queue(), ^{
            if (self.completionCallback) {
                self.completionCallback(task.response, responseObject, error);
            }
        });
    } else {
        //解析数据<耗时操作, 使用并行队列解析>
        dispatch_async(mn_url_session_create_serialization_queue(), ^{
            NSError *serializationError = nil;
            //解析数据, 先解析再区分下载是为了分析response信息, 便于返回错误
            responseObject = [self.responseSerializer objectWithResponse:task.response data:data error:&serializationError];
            // 如果是下载文件, responseObject为下载的路径, 避免外部判断为空数据
            if (!responseObject && self.downloadPath) responseObject = self.downloadPath;
            //回调结果
            dispatch_group_async(session.completionGroup ?: mn_url_session_create_completion_group(), session.completionQueue ?: dispatch_get_main_queue(), ^{
                if (self.completionCallback) {
                    self.completionCallback(task.response, responseObject, serializationError);
                }
            });
        });
    }
#pragma clang diagnostic pop
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    self.downloadProgress.totalUnitCount = dataTask.countOfBytesExpectedToReceive;
    self.downloadProgress.completedUnitCount = dataTask.countOfBytesReceived;
    [self.mutableData appendData:data];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
    didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
    totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    self.uploadProgress.totalUnitCount = task.countOfBytesExpectedToSend;
    self.uploadProgress.completedUnitCount = task.countOfBytesSent;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
    totalBytesWritten:(int64_t)totalBytesWritten
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    self.downloadProgress.totalUnitCount = totalBytesExpectedToWrite;
    self.downloadProgress.completedUnitCount = totalBytesWritten;
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didResumeAtOffset:(int64_t)fileOffset
    expectedTotalBytes:(int64_t)expectedTotalBytes
{
    self.downloadProgress.totalUnitCount = expectedTotalBytes;
    self.downloadProgress.completedUnitCount = fileOffset;
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didFinishDownloadingToURL:(NSURL *)location
{
    self.downloadPath = nil;
    if (self.downloadPathCallback) {
        NSString *filePath;
        id downloadPath = self.downloadPathCallback(downloadTask.response, location);
        if ([downloadPath isKindOfClass:NSString.class]) {
            filePath = downloadPath;
        } else if ([downloadPath isKindOfClass:NSURL.class]) {
            filePath = ((NSURL *)downloadPath).path;
        }
        NSError *fileManagerError;
        if (filePath && filePath.length) {
            if (![NSFileManager.defaultManager fileExistsAtPath:filePath.stringByDeletingLastPathComponent]) {
                [NSFileManager.defaultManager createDirectoryAtPath:filePath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil];
            }
            if ([[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:&fileManagerError]) {
                self.downloadPath = downloadPath;
            }
            if (fileManagerError) NSLog(@"move file error:%@", fileManagerError);
        }
    }
}

@end

@interface MNURLSession ()<NSURLSessionDelegate>
@property (readwrite, nonatomic, strong) NSURLSession *session;
@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *configuration;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, strong) MNSSLPolicy *SSLPolicy;
@end

#define Lock()    dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock()    dispatch_semaphore_signal(self->_lock)

@implementation MNURLSession
{
    /**信号量锁*/
    dispatch_semaphore_t _lock;
    /**代理缓存容器*/
    CFMutableDictionaryRef _delegateContainerRef;
}

- (void)dealloc {
    CFDictionaryRemoveAllValues(_delegateContainerRef);
    CFRelease(_delegateContainerRef);
    _delegateContainerRef = NULL;
    [self.session invalidateAndCancel];
    self.session = nil;
    self.configuration = nil;
}

+ (instancetype)defaultSession {
    return [[self alloc] initWithSessionConfiguration:nil];
}

- (instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)configuration {
    self = [super init];
    if (!self) return nil;
    
    if (!configuration) configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.configuration = configuration;
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;
    
    self.session = [NSURLSession sessionWithConfiguration:self.configuration
                                                 delegate:self
                                            delegateQueue:self.operationQueue];
    
    self.SSLPolicy = [MNSSLPolicy defaultPolicy];
    
    _lock = dispatch_semaphore_create(1);
    _delegateContainerRef = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    /**防止重新初始化这个session*/
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        for (NSURLSessionDataTask *dataTask in dataTasks) {
            [self setDelegateForDataTask:dataTask responseSerializer:nil uploadProgress:nil downloadProgress:nil completion:nil];
        }
        for (NSURLSessionUploadTask *uploadTask in uploadTasks) {
            [self setDelegateForDataTask:uploadTask responseSerializer:nil uploadProgress:nil downloadProgress:nil completion:nil];
        }
        for (NSURLSessionDownloadTask *downloadTask in downloadTasks) {
            [self setDelegateForDownloadTask:downloadTask responseSerializer:nil downloadProgress:nil downloadPath:nil completion:nil];
        }
    }];
    
    return self;
}

#pragma mark - GET
- (NSURLSessionDataTask *)GET:(NSString *)url
                     progress:(MNURLSessionTaskProgressCallback)downloadProgress
                   completion:(MNURLSessionTaskCompleteCallback)completion
{
    return [self GET:url requestSerializer:nil responseSerializer:nil progress:downloadProgress completion:completion];
}

- (NSURLSessionDataTask *)GET:(NSString *)url
                        requestSerializer:(MNURLRequestSerializer *)requestSerializer
                responseSerializer:(MNURLResponseSerializer *)responseSerializer
                     progress:(MNURLSessionTaskProgressCallback)downloadProgress
                   completion:(MNURLSessionTaskCompleteCallback)completion {
    return [self dataTaskWithUrl:url method:MNURLRequestMethodGET requestSerializer:requestSerializer responseSerializer:responseSerializer uploadProgress:nil downloadProgress:downloadProgress completion:completion];
}

#pragma mark - POST
- (NSURLSessionDataTask *)POST:(NSString *)url
                      progress:(MNURLSessionTaskProgressCallback)uploadProgress
                    completion:(MNURLSessionTaskCompleteCallback)completion
{
    return [self POST:url requestSerializer:nil responseSerializer:nil progress:uploadProgress completion:completion];
}

- (NSURLSessionDataTask *)POST:(NSString *)url
                     requestSerializer:(MNURLRequestSerializer *)requestSerializer
                responseSerializer:(MNURLResponseSerializer *)responseSerializer
                      progress:(MNURLSessionTaskProgressCallback)uploadProgress
                    completion:(MNURLSessionTaskCompleteCallback)completion
{
    return [self dataTaskWithUrl:url method:MNURLRequestMethodPOST requestSerializer:requestSerializer responseSerializer:responseSerializer uploadProgress:uploadProgress downloadProgress:nil completion:completion];
}

#pragma mark - DataTask
- (NSURLSessionDataTask *)dataTaskWithUrl:(NSString *)url
                                   method:(NSString *)method
                               requestSerializer:(MNURLRequestSerializer *)requestSerializer
                       responseSerializer:(MNURLResponseSerializer *)responseSerializer
                        uploadProgress:(MNURLSessionTaskProgressCallback)uploadProgress
                         downloadProgress:(MNURLSessionTaskProgressCallback)downloadProgress
                              completion:(MNURLSessionTaskCompleteCallback)completion
{
    if (!requestSerializer) requestSerializer = MNURLRequestSerializer.serializer;
    if (!responseSerializer) responseSerializer = MNURLResponseSerializer.serializer;
    NSError *serializationError;
    NSURLRequest *request = [requestSerializer requestWithUrl:url method:method error:&serializationError];
    if (serializationError) {
        dispatch_async(self.completionQueue ? : dispatch_get_main_queue(), ^{
            if (completion) completion(nil, nil, serializationError);
        });
        return nil;
    }
    /**使用同步串行的方式创建DataTask来保证过程安全*/
    /**AF使用此方式解决在iOS7系统出现的bug*/
    __block NSURLSessionDataTask *dataTask = nil;
    mn_url_session_create_task_safely(^{
        dataTask = [self.session dataTaskWithRequest:request];
    });
    /**保存代理*/
    [self setDelegateForDataTask:dataTask responseSerializer:responseSerializer uploadProgress:uploadProgress downloadProgress:downloadProgress completion:completion];
    [dataTask resume];
    return dataTask;
}

#pragma mark - UploadTask
- (NSURLSessionUploadTask *)uploadTaskWithUrl:(NSString *)url
                                        requestSerializer:(MNURLRequestSerializer *)requestSerializer
                                responseSerializer:(MNURLResponseSerializer *)responseSerializer
                                         body:(MNURLSessionUploadBodyCallback)uploadBody
                                     progress:(MNURLSessionTaskProgressCallback)uploadProgress
                                   completion:(MNURLSessionTaskCompleteCallback)completion
{
    if (!requestSerializer) requestSerializer = MNURLRequestSerializer.serializer;
    if (!responseSerializer) responseSerializer = MNURLResponseSerializer.serializer;
    NSError *serializationError;
    NSURLRequest *request = [requestSerializer requestWithUrl:url method:MNURLRequestMethodPOST error:&serializationError];
    if (serializationError) {
        dispatch_async(self.completionQueue ? : dispatch_get_main_queue(), ^{
            if (completion) completion(nil, nil, serializationError);
        });
        return nil;
    }
    id body;
    if (uploadBody) body = uploadBody();
    __block NSURLSessionUploadTask *uploadTask = nil;
    if ([body isKindOfClass:NSString.class] && [NSFileManager.defaultManager fileExistsAtPath:(NSString *)body]) {
        mn_url_session_create_task_safely(^{
            uploadTask = [self.session uploadTaskWithRequest:request fromFile:[NSURL fileURLWithPath:(NSString *)body]];
        });
    } else if ([body isKindOfClass:NSURL.class] && [NSFileManager.defaultManager fileExistsAtPath:((NSURL *)body).path]) {
        mn_url_session_create_task_safely(^{
            uploadTask = [self.session uploadTaskWithRequest:request fromFile:(NSURL *)body];
        });
    } else if ([body isKindOfClass:NSData.class] && ((NSData *)body).length > 0) {
        mn_url_session_create_task_safely(^{
            uploadTask = [self.session uploadTaskWithRequest:request fromData:(NSData *)body];
        });
    }
    if (!uploadTask) {
        NSError *bodyError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorZeroByteResource userInfo:@{NSLocalizedDescriptionKey:@"未知数据体", NSLocalizedFailureReasonErrorKey:@"数据体为空", NSURLErrorKey:@"body is empty"}];
        dispatch_async(self.completionQueue ? : dispatch_get_main_queue(), ^{
            if (completion) completion(nil, nil, bodyError);
        });
        return nil;
    }
    /**保存代理*/
    [self setDelegateForDataTask:uploadTask responseSerializer:responseSerializer uploadProgress:uploadProgress downloadProgress:nil completion:completion];
    [uploadTask resume];
    return uploadTask;
}

- (NSURLSessionUploadTask *)uploadTaskWithUrl:(NSString *)url
                                          URL:(NSURL *)fileURL
                                requestSerializer:(MNURLRequestSerializer *)requestSerializer
                            responseSerializer:(MNURLResponseSerializer *)responseSerializer
                                     progress:(MNURLSessionTaskProgressCallback)uploadProgress
                                    completion:(MNURLSessionTaskCompleteCallback)completion
{
    if (!requestSerializer) requestSerializer = MNURLRequestSerializer.serializer;
    if (!responseSerializer) responseSerializer = MNURLResponseSerializer.serializer;
    NSError *serializationError;
    NSURLRequest *request = [requestSerializer requestWithUrl:url method:MNURLRequestMethodPOST error:&serializationError];
    if (serializationError) {
        dispatch_async(self.completionQueue ? : dispatch_get_main_queue(), ^{
            if (completion) completion(nil, nil, serializationError);
        });
        return nil;
    }
    __block NSURLSessionUploadTask *uploadTask = nil;
    mn_url_session_create_task_safely(^{
        uploadTask = [self.session uploadTaskWithRequest:request fromFile:fileURL];
    });
    /**保存代理*/
    [self setDelegateForDataTask:uploadTask responseSerializer:responseSerializer uploadProgress:uploadProgress downloadProgress:nil completion:completion];
    [uploadTask resume];
    return uploadTask;
}

- (NSURLSessionUploadTask *)uploadTaskWithUrl:(NSString *)url
                                         data:(NSData *)bodyData
                                requestSerializer:(MNURLRequestSerializer *)requestSerializer
                            responseSerializer:(MNURLResponseSerializer *)responseSerializer
                                     progress:(MNURLSessionTaskProgressCallback)uploadProgress
                                   completion:(MNURLSessionTaskCompleteCallback)completion
{
    if (!requestSerializer) requestSerializer = MNURLRequestSerializer.serializer;
    if (!responseSerializer) responseSerializer = MNURLResponseSerializer.serializer;
    NSError *serializationError;
    NSURLRequest *request = [requestSerializer requestWithUrl:url method:MNURLRequestMethodPOST error:&serializationError];
    if (serializationError) {
        dispatch_async(self.completionQueue ? : dispatch_get_main_queue(), ^{
            if (completion) completion(nil, nil, serializationError);
        });
        return nil;
    }
    __block NSURLSessionUploadTask *uploadTask = nil;
    mn_url_session_create_task_safely(^{
        uploadTask = [self.session uploadTaskWithRequest:request fromData:bodyData];
    });
    /**保存代理*/
    [self setDelegateForDataTask:uploadTask responseSerializer:responseSerializer uploadProgress:uploadProgress downloadProgress:nil completion:completion];
    [uploadTask resume];
    return uploadTask;
}

#pragma mark - DownloadTask
- (NSURLSessionDownloadTask *)downloadTaskWithUrl:(NSString *)url
                                            requestSerializer:(MNURLRequestSerializer *)requestSerializer
                                        responseSerializer:(MNURLResponseSerializer *)responseSerializer
                                             path:(MNURLSessionDownloadPathCallback)downloadPath
                                            progress:(MNURLSessionTaskProgressCallback)downloadProgress
                                        completion:(MNURLSessionTaskCompleteCallback)completion
{
    if (!requestSerializer) requestSerializer = MNURLRequestSerializer.serializer;
    if (!responseSerializer) responseSerializer = MNURLResponseSerializer.serializer;
    NSError *serializationError;
    NSURLRequest *request = [requestSerializer requestWithUrl:url method:MNURLRequestMethodGET error:&serializationError];
    if (serializationError) {
        dispatch_async(self.completionQueue ? : dispatch_get_main_queue(), ^{
            if (completion) completion(nil, nil, serializationError);
        });
        return nil;
    }
    __block NSURLSessionDownloadTask *downloadTask = nil;
    mn_url_session_create_task_safely(^{
        downloadTask = [self.session downloadTaskWithRequest:request];
    });
    /**下载回调*/
    [self setDelegateForDownloadTask:downloadTask responseSerializer:responseSerializer downloadProgress:downloadProgress downloadPath:downloadPath completion:completion];
    [downloadTask resume];
    return downloadTask;
}

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                responseSerializer:(MNURLResponseSerializer *)responseSerializer
                                                    path:(MNURLSessionDownloadPathCallback)downloadPath
                                                progress:(MNURLSessionTaskProgressCallback)downloadProgress
                                                completion:(MNURLSessionTaskCompleteCallback)completion
{
    if (!responseSerializer) responseSerializer = MNURLResponseSerializer.serializer;
    __block NSURLSessionDownloadTask *downloadTask = nil;
    mn_url_session_create_task_safely(^{
        downloadTask = [self.session downloadTaskWithResumeData:resumeData];
    });
    [self setDelegateForDownloadTask:downloadTask responseSerializer:responseSerializer downloadProgress:downloadProgress downloadPath:downloadPath completion:completion];
    [downloadTask resume];
    return downloadTask;
}

#pragma mark - Progress
- (NSProgress *)uploadProgressForTask:(NSURLSessionTask *)task {
    return [[self delegateForTask:task] uploadProgress];
}

- (NSProgress *)downloadProgressForTask:(NSURLSessionTask *)task {
    return [[self delegateForTask:task] downloadProgress];
}

#pragma mark - 设置代理
- (void)setDelegateForDataTask:(NSURLSessionDataTask *)dataTask
                responseSerializer:(MNURLResponseSerializer *)responseSerializer
                uploadProgress:(MNURLSessionTaskProgressCallback)uploadProgress
              downloadProgress:(MNURLSessionTaskProgressCallback)downloadProgress
                    completion:(MNURLSessionTaskCompleteCallback)completion
{
    if (!dataTask) return;
    MNURLSessionTaskDelegate *delegate = [[MNURLSessionTaskDelegate alloc] initWithTask:dataTask];
    delegate.session = self;
    delegate.responseSerializer = responseSerializer;
    delegate.completionCallback = completion;
    delegate.uploadProgressCallback = uploadProgress;
    delegate.downloadProgressCallback = downloadProgress;
    dataTask.taskDescription = [NSString stringWithFormat:@"%p", self];
    [self setDelegate:delegate forTask:dataTask];
}

- (void)setDelegateForDownloadTask:(NSURLSessionDownloadTask *)downloadTask
                    responseSerializer:(MNURLResponseSerializer *)responseSerializer
                  downloadProgress:(MNURLSessionTaskProgressCallback)downloadProgress
               downloadPath:(MNURLSessionDownloadPathCallback)downloadPath
                   completion:(MNURLSessionTaskCompleteCallback)completion
{
    if (!downloadTask) return;
    MNURLSessionTaskDelegate *delegate = [[MNURLSessionTaskDelegate alloc] initWithTask:downloadTask];
    delegate.session = self;
    delegate.responseSerializer = responseSerializer;
    delegate.completionCallback = completion;
    delegate.downloadProgressCallback = downloadProgress;
    delegate.downloadPathCallback = downloadPath;
    downloadTask.taskDescription = [NSString stringWithFormat:@"%p", self];
    [self setDelegate:delegate forTask:downloadTask];
}

#pragma mark - 存取代理<保证线程安全>
- (nullable MNURLSessionTaskDelegate *)delegateForTask:(NSURLSessionTask *)task {
    if (!task || !_delegateContainerRef) return nil;
    MNURLSessionTaskDelegate *delegate = nil;
    Lock();
    delegate = CFDictionaryGetValue(_delegateContainerRef, (__bridge const void *)(@(task.taskIdentifier)));
    Unlock();
    return delegate;
}

- (void)setDelegate:(MNURLSessionTaskDelegate *)delegate forTask:(NSURLSessionTask *)task {
    if (!task || !_delegateContainerRef) return;
    Lock();
    CFDictionaryAddValue(_delegateContainerRef, (__bridge const void *)(@(task.taskIdentifier)), (__bridge const void *)(delegate));
    Unlock();
}

- (BOOL)removeDelegateForTask:(NSURLSessionTask *)task {
    if (!task || !_delegateContainerRef) return NO;
    Lock();
    CFDictionaryRemoveValue(_delegateContainerRef, (__bridge const void *)(@(task.taskIdentifier)));
    Unlock();
    return YES;
}

#pragma mark - NSURLSessionDelegate
/**
 当前session失效时, 该代理方法被调用;
 如果使用finishTasksAndInvalidate函数使该session失效,
 那么session首先会先完成最后一个task, 然后再调用URLSession:didBecomeInvalidWithError:代理方法;
 如果使用invalidateAndCancel方法来使session失效, 那么该session会立即调用此代理方法;
 @param session 失效session
 @param error 错误信息
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    if (self.didBecomeInvalidCallback) {
        self.didBecomeInvalidCallback(session, error);
    }
}

/**
 Session级别HTTPS认证挑战
 如果不实现就调用Task级别的认证挑战
 @param session 当前session
 @param challenge 挑战类型
 @param completionHandler 回调挑战证书
 */
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    /*
     NSURLSessionAuthChallengePerformDefaultHandling：默认方式处理
     NSURLSessionAuthChallengeUseCredential：使用指定的证书
     NSURLSessionAuthChallengeCancelAuthenticationChallenge：取消挑战
    */
    /**先默认使用系统框架自行验证*/
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    if (self.didReceiveChallengeCallback) {
        disposition = self.didReceiveChallengeCallback(session, challenge, &credential);
    } else {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            /*
             此处服务器要求客户端的接收认证挑战方法是NSURLAuthenticationMethodServerTrust;
             也就是说服务器端需要客户端返回一个根据认证挑战的保护空间提供的信任(即challenge.protectionSpace.serverTrust)产生的挑战证书;
             而这个证书就需要使用credentialForTrust:来创建一个NSURLCredential对象;
            */
            //基于客户端的安全策略来决定是否信任该服务器, 不信任的话, 也就没必要响应挑战
            if ([self.SSLPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                /**信任就创建挑战证书*/
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if (credential) {
                    /**挑战证书创建成功就用证书应战*/
                    disposition = NSURLSessionAuthChallengeUseCredential;
                }
            } else {
                /**不信任就取消挑战*/
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        }
    }
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

/**
 Session中所有已经入队的消息被发送出去
 @param session 当前会话
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (self.didFinishEventsForBackgroundCallback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.didFinishEventsForBackgroundCallback(session);
        });
    }
}

#pragma mark - NSURLSessionTaskDelegate
/**
 服务器重定向时调用
 只会在default session或者ephemeral session中调用
 在background session中, session task会自动重定向
 @param session 当前会话
 @param task task
 @param response 响应
 @param request 请求对象
 @param completionHandler 回调处理
 */
- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task willPerformHTTPRedirection:(nonnull NSHTTPURLResponse *)response newRequest:(nonnull NSURLRequest *)request completionHandler:(nonnull void (^)(NSURLRequest * _Nullable))completionHandler {
    NSURLRequest *redirectRequest = request;
    /**回调重定向事件*/
    if (self.taskWillPerformHTTPRedirection) {
        redirectRequest = self.taskWillPerformHTTPRedirection(session, task, response, request);
    }
    /**使用原本的Request重新请求*/
    if (completionHandler) {
        completionHandler(redirectRequest);
    }
}

/**
 Task级别HTTPS认证挑战
 @Session级别认证挑战 不响应也会转向这个
 @param session 当前session
 @param task 当前task
 @param challenge 挑战类型
 @param completionHandler 回调挑战证书
 */
- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didReceiveChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    /**先默认使用系统框架自行验证*/
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    if (self.taskDidReceiveChallengeCallback) {
        disposition = self.taskDidReceiveChallengeCallback(session, task, challenge, &credential);
    } else {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            /*
             此处服务器要求客户端的接收认证挑战方法是NSURLAuthenticationMethodServerTrust;
             也就是说服务器端需要客户端返回一个根据认证挑战的保护空间提供的信任(即challenge.protectionSpace.serverTrust)产生的挑战证书;
             而这个证书就需要使用credentialForTrust:来创建一个NSURLCredential对象;
             */
            //基于客户端的安全策略来决定是否信任该服务器, 不信任的话, 也就没必要响应挑战
            if ([self.SSLPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                /**信任就创建挑战证书*/
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if (credential) {
                    /**挑战证书创建成功就用证书应战*/
                    disposition = NSURLSessionAuthChallengeUseCredential;
                }
            } else {
                /**不信任就取消挑战*/
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        }
    }
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

/**
 因为认证挑战或者其他可恢复的服务器错误导致需要客户端重新发送一个含有body stream的request;
 如果task是由uploadTaskWithStreamedRequest:创建的,那么提供初始的request body stream时候会调用
 @param session 当前会话
 @param task 当前task
 @param completionHandler 回调
 */
- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task needNewBodyStream:(nonnull void (^)(NSInputStream * _Nullable))completionHandler
{
    NSInputStream *inputStream;
    //有自定义的taskNeedNewBodyStream,用自定义的，不然用task里原始的stream
    if (self.taskNeedNewBodyStreamCallback) {
        inputStream = self.taskNeedNewBodyStreamCallback(session, task);
    } else if (task.originalRequest.HTTPBodyStream && [task.originalRequest.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
        inputStream = [task.originalRequest.HTTPBodyStream copy];
    }
    if (completionHandler) {
        completionHandler(inputStream);
    }
}

/**
 每次发送数据给服务器回调这个方法通知已经发送了多少, 总共要发送多少
 @param session 当前会话
 @param task 当前task
 @param bytesSent 已发送数据量
 @param totalBytesSent 总共要发送数据量
 @param totalBytesExpectedToSend 剩余数据量
 */
- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    //如果totalUnitCount获取失败，就使用HTTP header中的Content-Length作为totalUnitCount
    int64_t totalUnitCount = totalBytesExpectedToSend;
    if(totalUnitCount == NSURLSessionTransferSizeUnknown) {
        NSString *contentLength = [task.originalRequest valueForHTTPHeaderField:@"Content-Length"];
        if(contentLength) {
            totalUnitCount = (int64_t) [contentLength longLongValue];
        }
    }
    //转发代理处理
    MNURLSessionTaskDelegate *delegate = [self delegateForTask:task];
    if (delegate) {
        [delegate URLSession:session
                        task:task
             didSendBodyData:bytesSent
              totalBytesSent:totalBytesSent
            totalBytesExpectedToSend:totalBytesExpectedToSend];
    }
    if (self.taskDidSendBodyDataCallback) {
        self.taskDidSendBodyDataCallback(session, task, bytesSent, totalBytesSent, totalUnitCount);
    }
}

/**
 Task执行结束
 @param session 当前会话
 @param task 当前task
 @param error 错误信息
 */
- (void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    MNURLSessionTaskDelegate *delegate = [self delegateForTask:task];
    if (delegate) {
        [delegate URLSession:session task:task didCompleteWithError:error];
        [self removeDelegateForTask:task];
    }
    if (self.taskDidCompleteCallback) {
        self.taskDidCompleteCallback(session, task, error);
    }
}

#pragma mark - NSURLSessionDataDelegate
/**
 该data task获取到了服务器端传回的最初始回复(response);
 其中的completionHandler传入一个类型为NSURLSessionResponseDisposition的变量;
 通过回调completionHandler决定该传输任务接下来该做什么;
 NSURLSessionResponseAllow 该task正常进行;
 NSURLSessionResponseCancel 该task会被取消;
 NSURLSessionResponseBecomeDownload 会调用URLSession:dataTask:didBecomeDownloadTask:方法
 来新建一个download task以代替当前的data task
 NSURLSessionResponseBecomeStream 转成一个StreamTask
 */
- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
    //设置默认为继续进行
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    //自定义去设置
    if (self.dataTaskDidReceiveResponseCallback) {
        disposition = self.dataTaskDidReceiveResponseCallback(session, dataTask, response);
    }
    if (completionHandler) {
        completionHandler(disposition);
    }
}

/**
 didReceiveResponse:completionHandler设置为NSURLSessionResponseBecomeDownload, 则会调用
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    //因为转变了task, 所以要对task做一个重新绑定
    MNURLSessionTaskDelegate *delegate = [self delegateForTask:dataTask];
    if (delegate) {
        [self removeDelegateForTask:dataTask];
        [self setDelegate:delegate forTask:downloadTask];
    }
    //执行自定义Block
    if (self.dataTaskDidBecomeDownloadTaskCallback) {
        self.dataTaskDidBecomeDownloadTaskCallback(session, dataTask, downloadTask);
    }
}

/**
 didReceiveResponse:completionHandler设置为NSURLSessionResponseBecomeStream, 则会调用
 该方法是可选的, 除非必须支持“multipart/x-mixed-replace”类型的content-type;
 因为如果request中包含了这种类型的content-type, 服务器会将数据分片传回来;
 而且每次传回来的数据会覆盖之前的数据;
 每次返回新的数据时, session都会调用该函数;
 应该在这个函数中合理地处理先前的数据, 否则会被新数据覆盖;
 如果你没有提供该方法的实现, 那么session将会继续任务, 也就是说会覆盖之前的数据
 */
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask {
    //因为转变了task, 所以要对task做一个重新绑定
    MNURLSessionTaskDelegate *delegate = [self delegateForTask:dataTask];
    if (delegate) {
        [self removeDelegateForTask:dataTask];
        [self setDelegate:delegate forTask:streamTask];
    }
    //执行自定义Block
    if (self.dataTaskDidBecomeStreamTaskCallback) {
        self.dataTaskDidBecomeStreamTaskCallback(session, dataTask, streamTask);
    }
}
#pragma clang diagnostic pop
#endif

//当我们获取到数据就会调用，会被反复调用，请求到的数据就在这被拼装完整
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
            didReceiveData:(NSData *)data
{
    MNURLSessionTaskDelegate *delegate = [self delegateForTask:dataTask];
    [delegate URLSession:session dataTask:dataTask didReceiveData:data];
    if (self.dataTaskDidReceiveDataCallback) {
        self.dataTaskDidReceiveDataCallback(session, dataTask, data);
    }
}

/*
 当task接收到所有期望的数据后, session会调用此代理方法
 询问data task或upload task, 是否缓存response
 如果你没有实现该方法, 那么就会使用创建session时使用的configuration对象决定缓存策略
 阻止缓存特定的URL或者修改NSCacheURLResponse对象相关的userInfo字典可使用
 缓存准则:
 1, 该request是HTTP或HTTPS URL的请求(或者你自定义的网络协议且确保该协议支持缓存)
 2, 确保request请求是成功的(返回的status code为200-299)
 3, 返回的response是来自服务器端的, 而非缓存中本身就有的
 4, 提供的NSURLRequest对象的缓存策略要允许进行缓存
 5, 服务器返回的response中与缓存相关的header要允许缓存
 5, 该response的大小不能比提供的缓存空间大太多(超过5%)
 */
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    willCacheResponse:(NSCachedURLResponse *)proposedResponse
        completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    NSCachedURLResponse *cachedResponse = proposedResponse;
    
    if (self.dataTaskWillCacheResponseCallback) {
        cachedResponse = self.dataTaskWillCacheResponseCallback(session, dataTask, proposedResponse);
    }
    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}

#pragma mark - NSURLSessionDownloadDelegate
/**
 下载完成回调
 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
        didFinishDownloadingToURL:(NSURL *)location
{
    MNURLSessionTaskDelegate *delegate = [self delegateForTask:downloadTask];
    //这个是session的, 也就是全局的, 后面的个人代理也会做同样的这件事
    if (self.downloadTaskDidFinishDownloadingCallback) {
        //调用自定义的Callback拿到文件存储的地址
        NSString *filePath;
        id downloadPath = self.downloadTaskDidFinishDownloadingCallback(session, downloadTask, location);
        if ([downloadPath isKindOfClass:NSString.class]) {
            filePath = downloadPath;
        } else if ([downloadPath isKindOfClass:NSURL.class]) {
            filePath = ((NSURL *)downloadPath).path;
        }
        NSError *fileManagerError;
        if (filePath && filePath.length) {
            if (![NSFileManager.defaultManager fileExistsAtPath:filePath.stringByDeletingLastPathComponent]) {
                [NSFileManager.defaultManager createDirectoryAtPath:filePath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil];
            }
            if ([[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:&fileManagerError]) {
                delegate.downloadPath = downloadPath;
            }
        }
        if (fileManagerError && self.downloadTaskMoveFileFailedCallback) {
            self.downloadTaskMoveFileFailedCallback(downloadTask, location, fileManagerError);
        }
    }
    //转发代理
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
    }
}

/**
 周期性地通知下载进度
 @param session 当前session
 @param downloadTask 下载任务实例
 @param bytesWritten 上次调用该方法后，接收到的数据字节数
 @param totalBytesWritten 目前已经接收到的数据字节数
 @param totalBytesExpectedToWrite 期望收到的文件总字节数(由Content-Length header提供, 如果没有提供, 默认是NSURLSessionTransferSizeUnknown)
 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
        totalBytesWritten:(int64_t)totalBytesWritten
        totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    MNURLSessionTaskDelegate *delegate = [self delegateForTask:downloadTask];
    if (delegate) {
        [delegate URLSession:session
                downloadTask:downloadTask
                didWriteData:bytesWritten
           totalBytesWritten:totalBytesWritten
        totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
    if (self.downloadTaskDidWriteDataCallback) {
        self.downloadTaskDidWriteDataCallback(session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
}

/**
当下载被取消或者失败后重新恢复下载时调用
 如果下载任务被取消或者失败了, 可以请求一个resumeData对象;
 比如在userInfo字典中通过NSURLSessionDownloadTaskResumeData这个键来获取到resumeData;
 使用它来提供足够的信息以重新开始下载任务;
 随后可以使用resumeData作为downloadTaskWithResumeData:或downloadTaskWithResumeData:completionHandler:的参数;
 当调用这些方法时,将开始一个新的下载任务;
 一旦继续下载任务, session会调用此代理方法;
 其中的downloadTask参数表示的就是新的下载任务, 这也意味着下载重新开始了;
*/
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
        didResumeAtOffset:(int64_t)fileOffset
        expectedTotalBytes:(int64_t)expectedTotalBytes
{
    MNURLSessionTaskDelegate *delegate = [self delegateForTask:downloadTask];
    if (delegate) {
        [delegate URLSession:session
                downloadTask:downloadTask
           didResumeAtOffset:fileOffset
          expectedTotalBytes:expectedTotalBytes];
    }
    if (self.downloadTaskDidResumeCallback) {
        self.downloadTaskDidResumeCallback(session, downloadTask, fileOffset, expectedTotalBytes);
    }
}

@end
