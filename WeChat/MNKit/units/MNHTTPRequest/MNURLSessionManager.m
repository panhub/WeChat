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
#import "MNURLDatabase.h"
#import "MNURLDataRequest.h"
#import "MNURLUploadRequest.h"
#import "MNURLDownloadRequest.h"
#import "UIApplication+MNNetworkActivity.h"

#define Lock()       dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)
#define Unlock()    dispatch_semaphore_signal(_semaphore)

@interface MNURLSessionManager ()
@property (nonatomic, strong) MNURLDatabase *database;
@end

static MNURLSessionManager *_manager;
@implementation MNURLSessionManager
{
    MNURLSession *_session;
    dispatch_semaphore_t _semaphore;
    NSMutableDictionary <NSNumber *, MNURLRequest *>*_requestCache;
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
            _session = [MNURLSession defaultSession];
            _semaphore = dispatch_semaphore_create(1);
            _requestCache = [NSMutableDictionary dictionaryWithCapacity:1];
            _session.completionQueue = dispatch_queue_create("com.mn.session.manager.completion.queue", DISPATCH_QUEUE_CONCURRENT);
        }
    });
    return _manager;
}

#pragma mark - LoadRequest
- (BOOL)resumeRequest:(__kindof MNURLRequest *)request
{
    [request setValue:nil forKey:MNURLPath(request.response)];
    if ([request isKindOfClass:[MNURLDataRequest class]]) {
        return [self loadDataWithRequest:(MNURLDataRequest *)request];
    } else if ([request isKindOfClass:[MNURLUploadRequest class]]) {
        return [self uploadDataWithRequest:(MNURLUploadRequest *)request];
    } else if ([request isKindOfClass:[MNURLDownloadRequest class]]) {
        return [self downloadDataWithRequest:(MNURLDownloadRequest *)request];
    }
    return NO;
}

#pragma mark - LoadRequestFinish
- (void)loadRequestFinishWithTask:(NSURLSessionTask *)task
                   responseObject:(id)responseObject
                            error:(NSError *)error
{
    // 判断task是否有效
    if (!task) {
        NSLog(@"⚠️⚠️⚠️⚠️请求task无效⚠️⚠️⚠️⚠️");
        return;
    }
    // 取出请求对象
    MNURLRequest *request = [self requestForTask:task];
    if (!request) {
        NSLog(@"⚠️⚠️⚠️⚠️获取指定请求失败 taskIdentifier:%ld⚠️⚠️⚠️⚠️", task.taskIdentifier);
        return;
    }
    // 移除请求体
    [self removeRequestForTask:task];
    // 标记已结束第一次请求
    [request setValue:@(NO) forKey:MNURLPath(request.firstLoading)];
    // 取消请求且不允许回调不做操作
    if (error && error.code == NSURLErrorCancelled && !request.isAllowsCancelCallback) return;
    // 判断是否需要重新请求并修改数据来源
    if ([request isKindOfClass:MNURLDataRequest.class]) {
        MNURLDataRequest *dataRequest = (MNURLDataRequest *)request;
        // 判断是否需要重新请求
        if (error && error.code != NSURLErrorCancelled && dataRequest.retryCount > 0 && dataRequest.currentRequestCount <= dataRequest.retryCount) {
            [self resumeRequest:dataRequest];
            return;
        }
        // 重置请求计次
        dataRequest.currentRequestCount = 0;
        // 记录数据来源
        dataRequest.dataSource = MNURLDataSourceNetwork;
    }
    // 关闭网络指示图
    if (request.isAllowsNetworkActivity) [UIApplication closeNetworkActivityIndicating];
    // 处理数据 回调结果
    [request didFinishWithResponseObject:responseObject error:error];
}

#pragma mark - Serialization
- (MNURLResponseSerializer *)responseSerializerForRequest:(__kindof MNURLRequest *)request {
    MNURLResponseSerializer *serializer = MNURLResponseSerializer.serializer;
    serializer.JSONOptions = request.JSONReadingOptions;
    serializer.acceptableStatus = request.acceptableStatus;
    serializer.stringEncoding = request.stringReadingEncoding;
    serializer.serializationType = (MNURLSerializationType)(request.serializationType);
    return serializer;
}

- (MNURLRequestSerializer *)requestSerializerForRequest:(__kindof MNURLRequest *)request {
    MNURLRequestSerializer *serializer = MNURLRequestSerializer.serializer;
    serializer.body = request.body; request.body = nil;
    serializer.query = request.query; request.query = nil;
    serializer.headerFields = request.headerFields; request.headerFields = nil;
    serializer.timeoutInterval = request.timeoutInterval;
    serializer.allowsCellularAccess = request.allowsCellularAccess;
    serializer.stringEncoding = request.stringWritingEncoding;
    serializer.authHeader = request.authHeader;
    if ([request isKindOfClass:MNURLUploadRequest.class]) serializer.boundary = ((MNURLUploadRequest *)request).boundary;
    return serializer;
}

#pragma mark - DataRequest
- (BOOL)loadDataWithRequest:(__kindof MNURLDataRequest *)request {
    /**读取缓存*/
    if (request.method == MNURLHTTPMethodGet && request.cachePolicy == MNURLDataCachePolicyDontLoad) {
        id<NSCoding> cache = [self cacheForUrl:request.cacheForUrl timeoutInterval:request.cacheTimeOutInterval];
        if (cache) {
            request.currentRequestCount = 0;
            request.dataSource = MNURLDataSourceCache;
            [request setValue:@(NO) forKey:MNURLPath(request.firstLoading)];
            [request didFinishWithResponseObject:cache error:nil];
            return YES;
        }
    }
    /**开启请求*/
    NSURLSessionDataTask *dataTask = [self dataTaskWithRequest:request];
    if (!dataTask) {
        request.currentRequestCount = 0;
        [request setValue:@(NO) forKey:MNURLPath(request.firstLoading)];
        [request didFinishWithResponseObject:nil error:NSError.taskError];
        return NO;
    }
    request.currentRequestCount ++;
    [request setValue:dataTask forKey:MNURLPath(request.task)];
    if (request.isAllowsNetworkActivity) [UIApplication startNetworkActivityIndicating];
    [self setRequest:request forTask:dataTask];
    /**回调请求开始*/
    if (request.currentRequestCount <= 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (request.startCallback) {
                request.startCallback();
            }
            if ([request.delegate respondsToSelector:@selector(didStartRequesting:)]) {
                [request.delegate didStartRequesting:request];
            }
        });
    }
    return YES;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(__kindof MNURLDataRequest *)request {
    __weak typeof(self) weakself = self;
    __block NSURLSessionDataTask *dataTask;
    if (request.method == MNURLHTTPMethodGet) {
        dataTask = [_session GET:request.url requestSerializer:[self requestSerializerForRequest:request] responseSerializer:[self responseSerializerForRequest:request] progress:request.progressCallback completion:^(NSURLResponse *response, id responseObject, NSError *error) {
            __strong typeof(self) self = weakself;
            [self loadRequestFinishWithTask:dataTask responseObject:responseObject error:error];
        }];
    } else {
        dataTask = [_session POST:request.url requestSerializer:[self requestSerializerForRequest:request] responseSerializer:[self responseSerializerForRequest:request] progress:request.progressCallback completion:^(NSURLResponse *response, id responseObject, NSError *error) {
            __strong typeof(self) self = weakself;
            [self loadRequestFinishWithTask:dataTask responseObject:responseObject error:error];
        }];
    }
    return dataTask;
}

#pragma mark - UploadRequest
- (BOOL)uploadDataWithRequest:(__kindof MNURLUploadRequest *)request {
    /**开启请求*/
    NSURLSessionUploadTask *uploadTask = [self uploadTaskWithRequest:request];
    if (!uploadTask) {
        [request setValue:@(NO) forKey:MNURLPath(request.firstLoading)];
        [request didFinishWithResponseObject:nil error:NSError.taskError];
        return NO;
    }
    [request setValue:uploadTask forKey:MNURLPath(request.task)];
    if (request.isAllowsNetworkActivity) [UIApplication startNetworkActivityIndicating];
    [self setRequest:request forTask:uploadTask];
    /**回调请求开始*/
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.startCallback) {
            request.startCallback();
        }
        if ([request.delegate respondsToSelector:@selector(didStartRequesting:)]) {
            [request.delegate didStartRequesting:request];
        }
    });
    return YES;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(__kindof MNURLUploadRequest *)request {
    __weak typeof(self) weakself = self;
    __block NSURLSessionUploadTask *uploadTask;
    uploadTask = [_session uploadTaskWithUrl:request.url requestSerializer:[self requestSerializerForRequest:request] responseSerializer:[self responseSerializerForRequest:request] body:request.bodyCallback progress:request.progressCallback completion:^(NSURLResponse *response, id responseObject, NSError *error) {
        __strong typeof(self) self = weakself;
        [self loadRequestFinishWithTask:uploadTask responseObject:responseObject error:error];
    }];
    return uploadTask;
}

#pragma mark - DownloadRequest
- (BOOL)downloadDataWithRequest:(__kindof MNURLDownloadRequest *)request {
    /**开启请求*/
    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithRequest:request];
    if (!downloadTask) {
        [request setValue:@(NO) forKey:MNURLPath(request.firstLoading)];
        [request didFinishWithResponseObject:nil error:NSError.taskError];
        return NO;
    }
    [request setValue:downloadTask forKey:MNURLPath(request.task)];
    if (request.isAllowsNetworkActivity) [UIApplication startNetworkActivityIndicating];
    [self setRequest:request forTask:downloadTask];
    /**回调请求开始*/
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.startCallback) {
            request.startCallback();
        }
        if ([request.delegate respondsToSelector:@selector(didStartRequesting:)]) {
            [request.delegate didStartRequesting:request];
        }
    });
    return YES;
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(__kindof MNURLDownloadRequest *)request {
    __weak typeof(self) weakself = self;
    __block NSURLSessionDownloadTask *downloadTask;
    downloadTask = [_session downloadTaskWithUrl:request.url requestSerializer:[self requestSerializerForRequest:request] responseSerializer:[self responseSerializerForRequest:request] path:request.downloadPathCallback progress:request.progressCallback completion:^(NSURLResponse *response, id responseObject, NSError *error) {
        __strong typeof(self) self = weakself;
        [self loadRequestFinishWithTask:downloadTask responseObject:responseObject error:error];
    }];
    return downloadTask;
}

#pragma mark - CancelRequest
- (void)cancelRequest:(__kindof MNURLRequest *)request {
    /**这里的取消是不可恢复的, 断点下载有专属的取消方法*/
    if (!request.isLoading) return;
    if (!request.isAllowsCancelCallback) {
        if ([request isKindOfClass:MNURLDataRequest.class]) ((MNURLDataRequest *)request).currentRequestCount = 0;
        if (request.isAllowsNetworkActivity) [UIApplication closeNetworkActivityIndicating];
    }
    [request.task cancel];
}

#pragma mark - DownloadRequest Cancel/Resume
- (void)cancelByProducingResumeData:(__kindof MNURLDownloadRequest *)downloadRequest
                       completion:(void (^)(NSData *resumeData))completion
{
    /**这里不要清除对下载请求体的保留, 回调等, 重新下载时还会赋值*/
    if (!downloadRequest.isLoading) {
        if (completion) completion(downloadRequest.resumeData);
        return;
    }
    NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)(downloadRequest.task);
    if (!downloadTask) {
        if (completion) completion(nil);
        return;
    }
    __weak typeof(downloadRequest) request = downloadRequest;
    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        __strong typeof(downloadRequest) downloadRequest = request;
        if (downloadRequest) {
            [downloadRequest setValue:@(NO) forKey:MNURLPath(downloadRequest.firstLoading)];
            [downloadRequest setValue:resumeData forKey:MNURLPath(downloadRequest.resumeData)];
            if (!request.isAllowsCancelCallback && downloadRequest.isAllowsNetworkActivity) [UIApplication closeNetworkActivityIndicating];
        }
        if (completion) completion(resumeData);
    }];
}

- (BOOL)resumeDownloadWithRequest:(__kindof MNURLDownloadRequest *)request {
    if (request.isLoading || !request.resumeData) return NO;
    __weak typeof(self) weakself = self;
    __block NSURLSessionDownloadTask *downloadTask;
    [request setValue:@(NO) forKey:MNURLPath(request.firstLoading)];
    downloadTask = [_session downloadTaskWithResumeData:request.resumeData responseSerializer:[self responseSerializerForRequest:request] path:request.downloadPathCallback progress:request.progressCallback completion:^(NSURLResponse *response, id responseObject, NSError *error) {
        __strong typeof(self) self = weakself;
        [self loadRequestFinishWithTask:downloadTask responseObject:responseObject error:error];
    }];
    if (!downloadTask) return NO;
    /**释放数据*/
    [request setValue:nil forKey:MNURLPath(request.resumeData)];
    [request setValue:downloadTask forKey:MNURLPath(request.task)];
    if (request.isAllowsNetworkActivity) [UIApplication startNetworkActivityIndicating];
    [self setRequest:request forTask:downloadTask];
    /**回调请求开始*/
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.startCallback) {
            request.startCallback();
        }
        if ([request.delegate respondsToSelector:@selector(didStartRequesting:)]) {
            [request.delegate didStartRequesting:request];
        }
    });
    return YES;
}

#pragma mark - Cache 存取
- (id<NSCoding>)cacheForUrl:(NSString *)url {
    return [self.database cacheForUrl:url];
}

- (id)cacheForUrl:(NSString *)url timeoutInterval:(NSTimeInterval)timeoutInterval {
    return [self.database cacheForUrl:url timeoutInterval:timeoutInterval];
}

- (BOOL)setCache:(id<NSCoding>)cache forUrl:(NSString *)url {
    return [self.database setCache:cache forUrl:url];
}

- (MNURLDatabase *)database {
    if (!_database) {
        _database = MNURLDatabase.database;
    }
    return _database;
}

#pragma mark - Request 存取
- (MNURLRequest *)requestForTask:(NSURLSessionTask *)task {
    if (!task) return nil;
    Lock();
    id request = [_requestCache objectForKey:@(task.taskIdentifier)];
    Unlock();
    return request;
}

- (void)setRequest:(MNURLRequest *)request forTask:(NSURLSessionTask *)task {
    if (!task) return;
    Lock();
    [_requestCache setObject:request forKey:@(task.taskIdentifier)];
    Unlock();
}

- (BOOL)removeRequestForTask:(NSURLSessionTask *)task {
    if (!task) return NO;
    Lock();
    [_requestCache removeObjectForKey:@(task.taskIdentifier)];
    Unlock();
    return YES;
}

@end

