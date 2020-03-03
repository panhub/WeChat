//
//  MNURLResponse.m
//  MNKit
//
//  Created by Vincent on 2018/11/7.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNURLResponse.h"
#import "MNURLRequest.h"

@interface MNURLResponse ()

@end

@implementation MNURLResponse

- (instancetype)init {
    if (self = [super init]) {
        _code = MNURLResponseCodeUnknown;
    }
    return self;
}

+ (MNURLResponse *)responseWithCode:(MNURLResponseCode)code
                               data:(id)data
                            message:(NSString *)message
                              error:(NSError *)error
{
    MNURLResponse *response = [MNURLResponse new];
    response.code = code;
    response.data = data;
    response.message = message;
    response.error = error;
    return response;
}

+ (MNURLResponse *)responseWithError:(NSError *)error {
    if (!error) return nil;
    MNURLResponse *response;
    if (error.code == NSURLErrorUnsupportedURL) {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeUnsupportedURL
                                              data:nil
                                           message:@"url错误"
                                             error:error];
    } else if (error.code == NSURLErrorNotConnectedToInternet) {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeNotConnectToInternet
                                              data:nil
                                           message:@"网络错误"
                                             error:error];
    } else if (error.code == NSURLErrorCannotFindHost) {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeCannotFindHost
                                              data:nil
                                           message:@"未找到服务器"
                                             error:error];
    } else if (error.code == NSURLErrorCannotConnectToHost) {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeCannotConnectHost
                                              data:nil
                                           message:@"未连接到服务器"
                                             error:error];
    } else if (error.code == NSURLErrorTimedOut) {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeTimeout
                                              data:nil
                                           message:@"请求超时"
                                             error:error];
    } else {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeUnknown
                                              data:nil
                                           message:@"发生未知错误"
                                             error:error];
    }
    return response;
}

+ (MNURLResponse *)succeedResponseWithData:(id)data {
    return [MNURLResponse responseWithCode:MNURLResponseCodeSucceed
                                      data:data
                                   message:@"succeed"
                                     error:nil];
}

- (NSString *)message {
    if (_message.length <= 0) return @"未知错误";
    return _message;
}

- (NSString *)description {
    return self.message;
}

- (NSString *)debugDescription {
    return self.message;
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    MNURLResponse *response = [MNURLResponse allocWithZone:zone];
    response.data = self.data;
    response.code = self.code;
    response.message = self.message;
    response.error = self.error;
    response->_request = self.request;
    return response;
}

@end
