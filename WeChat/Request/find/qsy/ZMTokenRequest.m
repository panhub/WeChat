//
//  ZMTokenRequest.m
//  WeChat
//
//  Created by Vicent on 2021/1/30.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "ZMTokenRequest.h"

@implementation ZMTokenRequest
- (instancetype)init {
    if (self = [super init]) {
        self.url = @"https://api.zimuok.com/api/v1/cgibin";
        self.cachePolicy = MNURLDataCachePolicyDontLoad;
        self.cacheTimeOutInterval = 60.f*60.f*24.f*30.f;
        self.timeoutInterval = 10.f;
        self.query = @{@"grantType":@"user_credential"};
    }
    return self;
}

#pragma mark - Super
- (void)handHeaderField {
    [super handHeaderField];
    NSString *temptimes = NSDate.timestamps;
    NSMutableDictionary *headerFields = [NSMutableDictionary dictionaryWithDictionary:self.headerFields ? : @{}];
    [headerFields setObject:@"1.3.2" forKey:@"version"];
    [headerFields setObject:IOS_VERSION() forKey:@"sys-version"];
    [headerFields setObject:temptimes forKey:@"time"];
    [headerFields setObject:UIDevice.identifier forKey:@"device"];
    [headerFields setObject:@"zh-Hans-CN" forKey:@"language"];
    [headerFields setObject:@"DEBUG" forKey:@"channel"];
    [headerFields setObject:@"WiFi" forKey:@"network"];
    [headerFields setObject:UIDevice.model forKey:@"model"];
    NSString *sign = [NSString stringWithFormat:@"appid=ee298ae860a211c4eb16cfed2e367cf8&appsecret=a84d1fba51214da8d3f55c27269dc342&temptimes=%@zmk", temptimes];
    sign = [sign md5String32];
    NSString *token = [@{@"appid":@"ee298ae860a211c4eb16cfed2e367cf8", @"temptimes":temptimes, @"sign":sign} JsonString];
    [headerFields setObject:token forKey:@"token"];
    self.headerFields = headerFields.copy;
}

- (void)didFinishWithSupposedResponse:(MNURLResponse *)response {
    /**定义错误*/
    if (self.serializationType != MNURLRequestSerializationTypeJSON) return;
    NSDictionary *json = response.data;
    response.code = (MNURLResponseCode)[NSDictionary integerValueWithDictionary:json forKey:@"code"];
    NSString *message = [NSDictionary stringValueWithDictionary:json forKey:@"msg"];
    if (message) response.message = message;
}

- (void)didSucceedWithResponseObject:(id)responseObject {
    NSDictionary *data = [NSDictionary dictionaryValueWithDictionary:responseObject forKey:@"data"];
    NSString *token = [NSDictionary stringValueWithDictionary:data forKey:@"access_token" def:@""];
    [NSUserDefaults synchronly:^(NSUserDefaults * _Nonnull userDefaults) {
        [userDefaults setObject:token forKey:kVideoToken];
    }];
}

@end
