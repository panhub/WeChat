//
//  MNAppRequest.m
//  MNKit
//
//  Created by Vincent on 2018/10/28.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNAppRequest.h"

#define MNAppRequestCallback(handler, arg1, arg2, arg3) \
if (handler) { \
    handler(arg1, arg2, arg3); \
}

@implementation MNAppRequest
#pragma mark - 检查版本更新
+ (void)requestContent:(nullable NSString *)appleID
                  completion:(MNAppRequestHandler)completion
{
    [self requestContent:appleID timeoutInterval:10.f completion:completion];
}

+ (void)requestContent:(nullable NSString *)appleID
                      timeoutInterval:(NSTimeInterval)timeInterval
                           completion:(MNAppRequestHandler)completion
{
    [self requestContent:appleID timeoutInterval:timeInterval queue:nil completion:completion];
}

+ (void)requestContent:(nullable NSString *)appleID
                      timeoutInterval:(NSTimeInterval)timeInterval
                                queue:(nullable dispatch_queue_t)queue
                           completion:(MNAppRequestHandler)completion
{
    if (!completion) return;
    if (appleID.length <= 0) {
        appleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppleID"];
    }
    if (appleID.length <= 0) {
        NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                    code:0
                                                userInfo:@{NSLocalizedDescriptionKey:@"Apple Id is null unable!"}];
        MNAppRequestCallback(completion, nil, nil, error);
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
+ (void)didLoadVersionData:(NSData * _Nullable)data error:(NSError * _Nullable)error completion:(MNAppRequestHandler)completion {
    if (error || data.length <= 0) {
        MNAppRequestCallback(completion, nil, nil, error);
        return;
    }
    NSError *_error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&_error];
    if (_error || !dic) {
        MNAppRequestCallback(completion, nil, nil, _error);
        return;
    }
    NSArray *array = [dic objectForKey:@"results"];
    if (array.count) {
        NSDictionary *results = [array lastObject];
        NSString *version = [results objectForKey:@"version"];
        MNAppRequestCallback(completion, version, results, nil);
    } else {
        _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                    code:0
                                                userInfo:@{NSLocalizedDescriptionKey:@"data error"}];
        MNAppRequestCallback(completion, nil, nil, _error);
    }
}

@end
