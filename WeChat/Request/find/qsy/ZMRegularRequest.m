//
//  ZMRegularRequest.m
//  WeChat
//
//  Created by Vicent on 2021/1/30.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "ZMRegularRequest.h"

@implementation ZMRegularRequest
- (instancetype)init {
    if (self = [super init]) {
        self.url = @"https://api.zimuok.com/api/v1/config";
        self.cachePolicy = MNURLDataCachePolicyDontLoad;
        self.cacheTimeOutInterval = 60.f*60.f*24.f*10.f;
        self.timeoutInterval = 10.f;
    }
    return self;
}

#pragma mark - Super
- (void)handHeaderField {
    [super handHeaderField];
    NSString *temptimes = NSDate.timestamps;
    NSString *token = [NSUserDefaults.standardUserDefaults objectForKey:kVideoToken];
    NSMutableDictionary *headerFields = [NSMutableDictionary dictionaryWithDictionary:self.headerFields ? : @{}];
    [headerFields setObject:@"1.3.2" forKey:@"version"];
    if (token) [headerFields setObject:token forKey:@"access-token"];
    [headerFields setObject:IOS_VERSION() forKey:@"sys-version"];
    [headerFields setObject:temptimes forKey:@"time"];
    [headerFields setObject:UIDevice.identifier forKey:@"device"];
    [headerFields setObject:@"zh-Hans-CN" forKey:@"language"];
    [headerFields setObject:@"DEBUG" forKey:@"channel"];
    [headerFields setObject:@"WiFi" forKey:@"network"];
    [headerFields setObject:UIDevice.model forKey:@"model"];
    self.headerFields = headerFields.copy;
}

- (void)didLoadFinishWithResponse:(MNURLResponse *)response {
    /**定义错误*/
    if (self.serializationType != MNURLRequestSerializationTypeJSON) return;
    NSDictionary *json = response.data;
    response.code = (MNURLResponseCode)[NSDictionary integerValueWithDictionary:json forKey:@"code"];
    NSString *message = [NSDictionary stringValueWithDictionary:json forKey:@"msg"];
    if (message) response.message = message;
}

@end
