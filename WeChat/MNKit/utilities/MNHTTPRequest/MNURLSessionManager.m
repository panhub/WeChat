//
//  MNURLSessionManager.m
//  MNKit
//
//  Created by Vincent on 2018/11/6.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNURLSessionManager.h"
#import "MNURLSession.h"
#import <pthread/pthread.h>
#import "MNURLDataCache.h"
#import "MNURLDataRequest.h"
#import "MNURLUploadRequest.h"
#import "MNURLDownloadRequest.h"

static NSString * MNApplicationSessionAssociatedKey = @"com.mn.application.session.associated.key";

@interface UIApplication (MNURLRequest)
void session_manager_start_indicator (void);
void session_manager_close_indicator (void);
@end

@implementation UIApplication (MNURLRequest)
void session_manager_start_indicator (void) {
    NSUInteger sessionCount = [[UIApplication sharedApplication] sessionCount];
    sessionCount ++;
    [[UIApplication sharedApplication] setSessionCount:sessionCount];
}

void session_manager_close_indicator (void) {
    NSUInteger sessionCount = [[UIApplication sharedApplication] sessionCount];
    sessionCount --;
    [[UIApplication sharedApplication] setSessionCount:sessionCount];
}

- (NSUInteger)sessionCount {
    NSNumber *number = objc_getAssociatedObject(self, &MNApplicationSessionAssociatedKey);
    return number ? [number unsignedIntegerValue] : 0;
}

- (void)setSessionCount:(NSUInteger)sessionCount {
    objc_setAssociatedObject(self, &MNApplicationSessionAssociatedKey, @(sessionCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNetworkActivityIndicatorVisible:(sessionCount > 0)];
    });
}

@end

static NSMutableDictionary <NSNumber *, MNURLRequest *>*MNURLRequestCache (void) {
    static NSMutableDictionary <NSNumber *, MNURLRequest *>*url_request_cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        url_request_cache = [NSMutableDictionary dictionaryWithCapacity:1];
    });
    return url_request_cache;
}

#define Lock()       dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)
#define Unlock()    dispatch_semaphore_signal(_semaphore)

@interface MNURLSessionManager ()
@end

static MNURLSessionManager *_manager;
@implementation MNURLSessionManager
{
    MNURLSession *_session;
    MNURLDataCache *_dataCache;
    dispatch_semaphore_t _semaphore;
}

+ (MNURLSessionManager *)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[MNURLSessionManager alloc] init];
    });
    return _manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super init];
        if (_manager) {
            _semaphore = dispatch_semaphore_create(1);
            _dataCache = [MNURLDataCache dataCache];
            _session = [MNURLSession defaultSession];
            _session.completionQueue = dispatch_queue_create("com.mn.session.manager.completion.queue", DISPATCH_QUEUE_CONCURRENT);
        }
    });
    return _manager;
}

#pragma mark - LoadRequest
- (void)loadRequest:(__kindof MNURLRequest *)request
{
    if (request.url.length <= 0) return;
    if ([request isKindOfClass:[MNURLDataRequest class]]) {
        [self loadDataWithRequest:(MNURLDataRequest *)request];
    } else if ([request isKindOfClass:[MNURLUploadRequest class]]) {
        [self uploadDataWithRequest:(MNURLUploadRequest *)request];
    } else if ([request isKindOfClass:[MNURLDownloadRequest class]]) {
        [self downloadDataWithRequest:(MNURLDownloadRequest *)request];
    }
}

#pragma mark - LoadRequestFinish
- (void)loadRequestFinishWithTask:(NSURLSessionTask *)task
                   responseObject:(id)responseObject
                            error:(NSError *)error
{
    /**取出请求对象*/
    MNURLRequest *request = [self requestForTask:task];
    [request setValue:@(NO) forKey:@"firstLoading"];
    /**移除请求体*/
    [self removeRequestForTask:task];
    /**没有请求体或取消请求不做操作*/
    if (!request || (error && error.code == NSURLErrorCancelled)) return;
    /**关闭网络指示图*/
    if (request.allowsNetworkActivity) session_manager_close_indicator();
    /**修改数据来源*/
    if ([request isKindOfClass:MNURLDataRequest.class]) {
        MNURLDataRequest *r = (MNURLDataRequest *)request;
        r.dataSource = MNURLDataSourceNetwork;
    }
    /**处理数据, 回调结果*/
    [request didLoadFinishWithResponseObject:responseObject error:error];
    if (request.didLoadFinishCallback) {
        request.didLoadFinishCallback(responseObject, error);
    }
}

#pragma mark - ConfigSessionSerialization
- (void)configSessionSerializationWithRequest:(__kindof MNURLRequest *)request {
    _session.responseSerializer.type = (MNURLResponseSerializationType)(request.serializationType);
    _session.requestSerializer.allowsCellularAccess = request.allowsCellularAccess;
    _session.requestSerializer.timeoutInterval = request.timeoutInterval;
    _session.requestSerializer.headerField = request.headerField;
    if (request.authorizationHeaderField.count > 0) {
        NSString *username = [request.authorizationHeaderField.allKeys firstObject];
        NSString *password = [request.authorizationHeaderField.allValues firstObject];
        [_session.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
    }
}

#pragma mark - DataRequest
- (void)loadDataWithRequest:(__kindof MNURLDataRequest *)request {
    /**回调请求开始*/
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.startCallback) {
            request.startCallback();
        }
    });
    /**读取缓存*/
    if (request.method == MNURLHTTPMethodGet && request.cachePolicy != MNURLDataCacheNever) {
        id<NSCoding> cache = [_dataCache cacheForUrl:request.url timeoutInterval:(request.cachePolicy == MNURLDataCacheUseTime ? request.cacheOutInterval : 0.f)];
        if (cache) {
            request.dataSource = MNURLDataSourceCache;
            [request setValue:@(NO) forKey:@"firstLoading"];
            [request didLoadFinishWithResponseObject:cache error:nil];
            return;
        }
    }
    /**开启请求*/
    NSURLSessionDataTask *dataTask = [self dataTaskWithRequest:request];
    if (!dataTask) return;
    [request setValue:dataTask forKey:@"task"];
    request.dataSource = MNURLDataSourceNetwork;
    if (request.allowsNetworkActivity) session_manager_start_indicator();
    [self setRequest:request forTask:dataTask];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(__kindof MNURLDataRequest *)request {
    Lock();
    __weak typeof(self) weakself = self;
    __block NSURLSessionDataTask *dataTask;
    [self configSessionSerializationWithRequest:request];
    if (request.method == MNURLHTTPMethodGet) {
        dataTask = [_session GET:request.url parameter:request.parameter downloadProgress:request.progressCallback completion:^(NSURLResponse *response, id responseObject, NSError *error) {
            __strong typeof(self) self = weakself;
            [self loadRequestFinishWithTask:dataTask responseObject:responseObject error:error];
        }];
    } else {
        dataTask = [_session POST:request.url parameter:request.parameter uploadProgress:request.progressCallback completion:^(NSURLResponse *response, id responseObject, NSError *error) {
            __strong typeof(self) self = weakself;
            [self loadRequestFinishWithTask:dataTask responseObject:responseObject error:error];
        }];
    }
    /// 置空参数
    request.parameter = nil;
    Unlock();
    return dataTask;
}

#pragma mark - UploadRequest
- (void)uploadDataWithRequest:(__kindof MNURLUploadRequest *)request {
    /**回调请求开始*/
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.startCallback) {
            request.startCallback();
        }
    });
    /**开启请求*/
    NSURLSessionUploadTask *uploadTask = [self uploadTaskWithRequest:request];
    if (!uploadTask) return;
    [request setValue:uploadTask forKey:@"task"];
    if (request.allowsNetworkActivity) session_manager_start_indicator();
    [self setRequest:request forTask:uploadTask];
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(__kindof MNURLUploadRequest *)request {
    Lock();
    __weak typeof(self) weakself = self;
    __block NSURLSessionUploadTask *uploadTask;
    [self configSessionSerializationWithRequest:request];
    uploadTask = [_session uploadTaskWithUrl:request.url parameter:request.parameter uploadPath:request.uploadPathCallback uploadProgress:request.progressCallback completion:^(NSURLResponse *response, id responseObject, NSError *error) {
        __strong typeof(self) self = weakself;
        [self loadRequestFinishWithTask:uploadTask responseObject:responseObject error:error];
    }];
    Unlock();
    return uploadTask;
}

#pragma mark - DownloadRequest
- (void)downloadDataWithRequest:(__kindof MNURLDownloadRequest *)request {
    /**回调请求开始*/
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.startCallback) {
            request.startCallback();
        }
    });
    /**开启请求*/
    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithRequest:request];
    if (!downloadTask) return;
    [request setValue:downloadTask forKey:@"task"];
    if (request.allowsNetworkActivity) session_manager_start_indicator();
    [self setRequest:request forTask:downloadTask];
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(__kindof MNURLDownloadRequest *)request {
    Lock();
    __weak typeof(self) weakself = self;
    __block NSURLSessionDownloadTask *downloadTask;
    [self configSessionSerializationWithRequest:request];
    downloadTask = [_session downloadTaskWithUrl:request.url parameter:request.parameter downloadPath:request.downloadPathCallback downloadProgress:request.progressCallback completion:^(NSURLResponse *response, id responseObject, NSError *error) {
        __strong typeof(self) self = weakself;
        [self loadRequestFinishWithTask:downloadTask responseObject:responseObject error:error];
    }];
    Unlock();
    return downloadTask;
}

#pragma mark - CancelRequest
- (void)cancelRequest:(__kindof MNURLRequest *)request {
    /**这里的取消是不可恢复的, 即便是断点下载, 断点下载有专属的取消方法*/
    if (!request.isLoading) return;
    [request.task cancel];
    if (request.allowsNetworkActivity) session_manager_close_indicator();
}

#pragma mark - DownloadRequest Cancel/Resume
- (void)suspendDownloadWithRequest:(__kindof MNURLDownloadRequest *)downloadRequest
                       completion:(void (^)(NSData *resumeData))completion
{
    /**这里不要清除对下载请求体的保留, 回调等, 重新下载时还会赋值*/
    if (!downloadRequest.isLoading) return;
    NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)(downloadRequest.task);
    if (!downloadTask) return;
    [downloadRequest setValue:@(NO) forKey:@"firstLoading"];
    if (downloadRequest.allowsNetworkActivity) session_manager_close_indicator();
    __weak typeof(downloadRequest) request = downloadRequest;
    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        if (!request) return;
        [request setValue:resumeData forKey:@"resumeData"];
        if (completion) {
            completion(resumeData);
        }
    }];
}

- (void)resumeDownloadWithRequest:(__kindof MNURLDownloadRequest *)request {
    if (!request.resumeData) return;
    __block NSURLSessionDownloadTask *downloadTask;
    __weak typeof(self) _self = self;
    downloadTask = [_session downloadTaskWithResumeData:request.resumeData downloadPath:request.downloadPathCallback downloadProgress:request.progressCallback completion:^(NSURLResponse *response, id responseObject, NSError *error) {
        [_self loadRequestFinishWithTask:downloadTask responseObject:responseObject error:error];
    }];
    if (!downloadTask) return;
    /**释放数据*/
    [request setValue:nil forKey:@"resumeData"];
    [request setValue:downloadTask forKey:@"task"];
    if (request.allowsNetworkActivity) session_manager_start_indicator();
    [self setRequest:request forTask:downloadTask];
}

#pragma mark - Cache 存取
- (id<NSCoding>)cacheForUrl:(NSString *)url {
    return [_dataCache cacheForUrl:url];
}

- (void)setCache:(id<NSCoding>)cache forUrl:(NSString *)url {
    [_dataCache setCache:cache forUrl:url completion:nil];
}

#pragma mark - Request 存取
- (MNURLRequest *)requestForTask:(NSURLSessionTask *)task {
    if (!task) return nil;
    Lock();
    id request = [MNURLRequestCache() objectForKey:@(task.taskIdentifier)];
    Unlock();
    return request;
}

- (void)setRequest:(MNURLRequest *)request forTask:(NSURLSessionTask *)task {
    if (!task) return;
    Lock();
    [MNURLRequestCache() setObject:request forKey:@(task.taskIdentifier)];
    Unlock();
}

- (BOOL)removeRequestForTask:(NSURLSessionTask *)task {
    if (!task) return NO;
    Lock();
    [MNURLRequestCache() removeObjectForKey:@(task.taskIdentifier)];
    Unlock();
    return YES;
}

@end

