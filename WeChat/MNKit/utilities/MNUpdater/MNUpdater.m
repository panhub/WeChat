//
//  MNUpdater.m
//  MNKit
//
//  Created by Vincent on 2018/10/28.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNUpdater.h"

#define MNVersionCheckCallback(callback, arg1, arg2, arg3, arg4) \
if (callback) { \
    callback(arg1, arg2, arg3, arg4); \
}

@implementation MNUpdater
#pragma mark - 检查版本更新
+ (void)checkProductVersionFromItunes:(nullable NSString *)appleID
                      timeoutInterval:(NSTimeInterval)timeInterval
                           completion:(MNVersionCheckHandler)completion
{
    [self checkProductVersionFromItunes:appleID
                 timeoutInterval:timeInterval
                           queue:nil
                      completion:completion];
}

+ (void)checkProductVersionFromItunes:(nullable NSString *)appleID
                      timeoutInterval:(NSTimeInterval)timeInterval
                                queue:(nullable dispatch_queue_t)queue
                           completion:(MNVersionCheckHandler)completion
{
    if (!completion) return;
    if (appleID.length <= 0) {
        appleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppleID"];
    }
    if (appleID.length <= 0) {
        NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                    code:0
                                                userInfo:@{NSLocalizedDescriptionKey:@"Apple Id is null unable!"}];
        MNVersionCheckCallback(completion ,NO, nil, nil, error);
        return;
    }
    NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appleID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeoutInterval = timeInterval;
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.allowsCellularAccess = YES;
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request.copy completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!completion) return;
        dispatch_async(queue ? queue : dispatch_get_main_queue(), ^{
            [self didLoadVersionData:data error:error completion:completion];
        });
    }];
    [dataTask resume];
}

#pragma mark - 解析版本信息
+ (void)didLoadVersionData:(NSData * _Nullable)data error:(NSError * _Nullable)error completion:(MNVersionCheckHandler)completion {
    if (error || data.length <= 0) {
        MNVersionCheckCallback(completion ,NO, nil, nil, error);
        return;
    }
    NSError *_error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&_error];
    if (_error || !dic) {
        MNVersionCheckCallback(completion ,NO, nil, nil, _error);
        return;
    }
    NSArray *array = [dic objectForKey:@"results"];
    if (array.count > 0) {
        NSDictionary *results = [array lastObject];
        NSString *version = [results objectForKey:@"version"];
        NSString *current = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        if (version.length <= 0 || current.length <= 0) {
            _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                        code:0
                                                    userInfo:@{NSLocalizedDescriptionKey:@"data error"}];
            MNVersionCheckCallback(completion ,NO, nil, nil, _error);
        } else {
            MNVersionCheckCallback(completion ,([version doubleValue] > [current doubleValue]), version, results, nil);
        }
    } else {
        _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                    code:0
                                                userInfo:@{NSLocalizedDescriptionKey:@"data error"}];
        MNVersionCheckCallback(completion ,NO, nil, nil, _error);
    }
}

@end
