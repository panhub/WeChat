//
//  WXJHRequest.m
//  MNChat
//
//  Created by Vincent on 2019/3/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXJHRequest.h"

@implementation WXJHRequest
- (instancetype)init {
    self = [super init];
    if (self) {
        self.cachePolicy = MNURLDataCachePolicyNever;
    }
    return self;
}

#pragma mark - 请求链接
- (void)handCacheUrl {
    NSMutableString *url = self.url.mutableCopy;
    if (url.length <= 0) {
        self.cacheForUrl = nil;
        return;
    }
    NSString *query = ((NSDictionary *)self.query).queryValue;
    if (query.length <= 0) {
        if ([url containsString:@"?"]) {
            [url appendString:@"&"];
        } else {
            [url appendString:@"?"];
        }
        [url appendString:query];
        self.cacheForUrl = url;
    } else {
        self.cacheForUrl = url;
    }
}

#pragma mark - 请求结束
- (void)didFinishWithSupposedResponse:(MNURLResponse *)response {
    NSDictionary *json = response.data;
    NSString *error_code = [NSDictionary stringValueWithDictionary:json forKey:@"error_code" def:@""];
    // 没有错误码 以失败处理
    if (error_code.length <= 0) {
        response.code = MNURLResponseCodeFailed;
        response.message = @"请求失败";
        return;
    }
    // 成功
    if (error_code == 0) return;
    // 寻找系统级错误
    NSInteger code = error_code.integerValue;
    if (code == 10001) {
        response.code = code;
        response.message = @"错误的请求KEY";
    } else if (code == 10002) {
        response.code = code;
        response.message = @"该KEY无请求权限";
    } else if (code == 10003) {
        response.code = code;
        response.message = @"KEY过期";
    } else if (code == 10004) {
        response.code = code;
        response.message = @"错误的OPENID";
    } else if (code == 10005) {
        response.code = code;
        response.message = @"应用未审核超时, 请提交认证";
    } else if (code == 10007) {
        response.code = code;
        response.message = @"未知的请求源";
    } else if (code == 10008) {
        response.code = code;
        response.message = @"被禁止的IP";
    } else if (code == 10009) {
        response.code = code;
        response.message = @"被禁止的KEY";
    } else if (code == 10011) {
        response.code = code;
        response.message = @"当前IP请求超过限制";
    } else if (code == 10012) {
        response.code = code;
        response.message = @"请求超过次数限制";
    } else if (code == 10013) {
        response.code = code;
        response.message = @"测试KEY超过请求限制";
    } else if (code == 10014) {
        response.code = code;
        response.message = @"系统内部异常";
    } else if (code == 10020) {
        response.code = code;
        response.message = @"接口维护";
    } else if (code == 10021) {
        response.code = code;
        response.message = @"接口停用";
    }
}

@end
