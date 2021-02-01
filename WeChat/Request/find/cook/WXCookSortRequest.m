//
//  WXCookSortRequest.m
//  MNChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookSortRequest.h"
#import "WXCookSort.h"

@implementation WXCookSortRequest
- (instancetype)init {
    if (self = [super init]) {
        self.timeoutInterval = 10.f;
        self.cacheTimeOutInterval = 60.f*60.f*24.f*30.f;
        self.cachePolicy = MNURLDataCachePolicyElseLoad;
        self.url = @"http://apis.juhe.cn/cook/category";
    }
    return self;
}

- (void)handQuery {
    [super handQuery];
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:self.query ? : @{}];
    [query setObject:@"json" forKey:@"dtype"];
    [query setObject:@"6f2afb00fbb3b72f311f914f8f692132" forKey:@"key"];
    self.query = query;
}

- (void)didFinishWithSupposedResponse:(MNURLResponse *)response {
    [super didFinishWithSupposedResponse:response];
    if (response.code != MNURLResponseCodeSucceed) return;
    NSDictionary *json = response.data;
    NSString *error_code = [NSDictionary stringValueWithDictionary:json forKey:@"error_code" def:@""];
    // 服务器级错误
    NSInteger code = error_code.integerValue;
    if (code == 204601) {
        response.code = code;
        response.message = @"菜谱名称不能为空";
    } else if (code == 204602) {
        response.code = code;
        response.message = @"查询不到相关信息";
    } else if (code == 204603) {
        response.code = code;
        response.message = @"菜谱名过长";
    } else if (code == 204604) {
        response.code = code;
        response.message = @"错误的标签ID";
    } else if (code == 204605) {
        response.code = code;
        response.message = @"查询不到数据";
    } else if (code == 204606) {
        response.code = code;
        response.message = @"错误的菜谱ID";
    } else if (code == 10008) {
        response.code = code;
        response.message = @"被禁止的IP";
    }
}

- (void)didSucceedWithResponseObject:(id)responseObject {
    [super didSucceedWithResponseObject:responseObject];
    NSArray <NSDictionary *>*result = [NSDictionary arrayValueWithDictionary:responseObject forKey:@"result"];
    [result enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXCookSort *model = [WXCookSort modelWithDictionary:obj];
        [self.dataArray addObject:model];
    }];
}

@end
