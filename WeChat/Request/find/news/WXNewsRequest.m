//
//  WXNewsRequest.m
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXNewsRequest.h"
#import "WXNewsViewModel.h"
#import "WXNewsDataModel.h"

@implementation WXNewsRequest
- (instancetype)init {
    if (self = [super init]) {
        self.url = @"http://v.juhe.cn/toutiao/index?type=top&key=APPKEY";
        self.cachePolicy = MNURLDataCachePolicyElseLoad;
        self.cacheTimeOutInterval = 60.f*60.f*24.f*30.f;
        self.timeoutInterval = 10.f;
    }
    return self;
}

- (void)handQuery {
    [super handQuery];
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:self.query ? : @{}];
    if (self.type.length > 0) [query setObject:self.type forKey:@"type"];
    [query setObject:@"f95a1f98e4a55ea8e27233cb4d57d962" forKey:@"key"];
    self.query = query;
}

- (void)didSucceedWithResponseObject:(id)responseObject {
    NSDictionary *result = [NSDictionary dictionaryValueWithDictionary:responseObject forKey:@"result"];
    NSArray <NSDictionary *>*data = [NSDictionary arrayValueWithDictionary:result forKey:@"data"];
    [data enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXNewsDataModel *m = [WXNewsDataModel modelWithDictionary:obj];
        WXNewsViewModel *vm = [[WXNewsViewModel alloc] initWithDataModel:m];
        [self.dataArray addObject:vm];
    }];
}

@end