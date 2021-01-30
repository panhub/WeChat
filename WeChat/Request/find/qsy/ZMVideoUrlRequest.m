//
//  ZMVideoUrlRequest.m
//  WeChat
//
//  Created by Vicent on 2021/1/30.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "ZMVideoUrlRequest.h"

@interface ZMVideoUrlRequest ()

@end

@implementation ZMVideoUrlRequest
- (instancetype)init {
    return [self initWithVideoUrl:nil];
}

- (instancetype)initWithVideoUrl:(NSString *)url {
    if (self = [super init]) {
        self.videoUrl = url;
        self.timeoutInterval = 10.f;
        self.url = @"https://api.zimuok.com/api/v1/water/clean";
        self.method = MNURLHTTPMethodPost;
        self.cachePolicy = MNURLDataCachePolicyNever;
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
    [headerFields setObject:@"f295c0c3dbfaaa934171" forKey:@"token"];
    self.headerFields = headerFields.copy;
}

- (void)handBody {
    [super handBody];
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:self.body ? : @{}];
    if (self.videoUrl.length > 0) [body setObject:self.videoUrl forKey:@"url"];
    [body setObject:@"f295c0c3dbfaaa934171" forKey:@"token"];
    self.body = body;
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
    self.downloadUrl = [NSDictionary stringValueWithDictionary:data forKey:@"url"];
}

@end
