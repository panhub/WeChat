//
//  MNMobRequest.m
//  MNChat
//
//  Created by Vincent on 2019/3/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNMobRequest.h"

@implementation MNMobRequest
- (instancetype)init {
    self = [super init];
    if (self) {
        self.cachePolicy = MNURLDataCacheNever;
    }
    return self;
}

#pragma mark - 拼接Header信息
- (void)loadData:(MNURLRequestStartCallback)startCallback
      completion:(MNURLRequestFinishCallback)finishCallback
{
    [self handParameters];
    [super loadData:startCallback completion:finishCallback];
}

#pragma mark - 拼接参数
- (void)handParameters {
    NSRange range = [self.url rangeOfString:@"?"];
    NSString *url = range.location == NSNotFound ? self.url : [self.url substringToIndex:range.location];
    if (url.length <= 0) return;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self.parameter];
    if (self.pagingEnabled) {
        [dictionary setObject:NSStringFromNumber(@(self.page)) forKey:@"page"];
    }
    NSString *parameter = [dictionary urlString];
    if (parameter.length > 0) {
        NSString *format = [url rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&";
        url = [url stringByAppendingString:NSStringWithFormat(@"%@%@", format, parameter)];
    }
    self.parameter = nil;
    self.url = url;
    NSLog(@"===============请求地址===============\n%@\n", self.url);
}

#pragma mark - 请求结束
- (void)didLoadFinishWithResponse:(MNURLResponse *)response {
    NSDictionary *data = response.data;
    NSInteger retCode = [MNJSONSerialization integerValueWithJSON:data forKey:@"retCode"];
    response.message = [MNJSONSerialization stringValueWithJSON:data forKey:@"msg" def:@"请求失败"];
    if (retCode == 200) {
        response.code = MNURLResponseCodeSucceed;
    } else if (retCode == 20901) {
        response.code = MNURLResponseCodeNotFound;
    } else {
        response.code = MNURLResponseCodeFailed;
    }
}

@end
