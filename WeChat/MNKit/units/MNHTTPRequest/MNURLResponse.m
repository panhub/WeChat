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
@property (nonatomic, strong) id data;
@property (nonatomic, copy) NSError *error;
@property (nonatomic, weak, nullable) __kindof MNURLRequest *request;
@end

@implementation MNURLResponse

- (instancetype)init {
    if (self = [super init]) {
        _code = MNURLResponseCodeUnknown;
    }
    return self;
}

+ (MNURLResponse *)responseWithError:(NSError *)error {
    if (!error) return nil;
    MNURLResponse *response;
    if (error.code == NSURLErrorTimedOut) {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeTimeout data:nil error:error];
    } else if (error.code == NSURLErrorNotConnectedToInternet) {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeNotConnectToInternet data:nil error:error];
    } else if (error.code == NSURLErrorUnknown) {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeUnknown data:nil error:error];
    } else if (error.code == NSURLErrorCancelled) {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeCancelled data:nil error:error];
    } else if (error.code == NSURLErrorBadURL) {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeBadURL data:nil error:error];
    } else if (error.code == NSURLErrorUnsupportedURL) {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeUnsupportedURL data:nil error:error];
    } else if (error.code == NSURLErrorCannotFindHost) {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeCannotFindHost data:nil error:error];
    } else if (error.code == NSURLErrorCannotConnectToHost) {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeCannotConnectHost data:nil error:error];
    } else if (error.code == NSURLErrorCannotWriteToFile) {
        response = [MNURLResponse responseWithCode:MNURLResponseCodeCannotWriteToFile data:nil error:error];
    } else {
        response = [MNURLResponse responseWithCode:error.code data:nil error:error];
    }
    return response;
}

+ (MNURLResponse *)succeedResponseWithData:(id)data {
    return [MNURLResponse responseWithCode:MNURLResponseCodeSucceed data:data error:nil];
}

+ (MNURLResponse *)responseWithCode:(MNURLResponseCode)code data:(id)data error:(NSError *)error
{
    MNURLResponse *response = [MNURLResponse new];
    response.code = code;
    response.data = data;
    response.error = error;
    return response;
}

#pragma mark - Setter
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"⚠️⚠️⚠️⚠️ %@ undefined key:%@ ⚠️⚠️⚠️⚠️", NSStringFromClass(self.class), key);
}

#pragma mark - Getter
- (NSString *)message {
    if (_message && _message.length) return _message;
    NSString *msg = self.data ? @"请求成功" : (self.error ? self.error.localizedDescription : @"发生未知错误");
    switch (self.code) {
        case MNURLResponseCodeUnknown:
        {
            msg = @"发生未知错误";
        } break;
        case MNURLResponseCodeTimeout:
        {
            msg = @"请求超时";
        } break;
        case MNURLResponseCodeNotConnectToInternet:
        {
            msg = @"网络错误";
        } break;
        case MNURLResponseCodeCancelled:
        {
            msg = @"已取消请求";
        } break;
        case MNURLResponseCodeBadURL:
        {
            msg = @"未知请求地址";
        } break;
        case MNURLResponseCodeUnsupportedURL:
        {
            msg = @"请求地址不合法";
        } break;
        case MNURLResponseCodeCannotFindHost:
        {
            msg = @"未找到服务器";
        } break;
        case MNURLResponseCodeCannotConnectHost:
        {
            msg = @"无法链接到服务器";
        } break;
        case MNURLResponseCodeCannotWriteToFile:
        {
            msg = @"文件保存失败";
        } break;
        default:
            break;
    }
    _message = msg.copy;
    return _message;
}

- (NSString *)debugDescription {
    if (self.error) return self.error.localizedDescription;
    if ([self.data isKindOfClass:NSDictionary.class] || [self.data isKindOfClass:NSArray.class]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.data options:NSJSONWritingPrettyPrinted error:&error];
        if (jsonData && jsonData.length && !error) {
            NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            if (string) return string;
        }
    } else if ([self.data isKindOfClass:NSString.class]) {
        return (NSString *)self.data;
    }
    return self.message;
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    MNURLResponse *response = [MNURLResponse allocWithZone:zone];
    response.data = _data;
    response.code = _code;
    response.error = _error;
    response.request = _request;
    return response;
}

@end

@implementation NSError (MNURLRequestError)

+ (NSError *)taskError {
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:MNURLResponseCodeTaskError
                        userInfo:@{NSLocalizedDescriptionKey:@"请求体实例化失败",
                                           NSLocalizedFailureReasonErrorKey: @"MNURLSession初始化dataTask失败",
                                           NSURLErrorKey: @"data task is null"}];
}

@end
