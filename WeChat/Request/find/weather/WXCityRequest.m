//
//  WXCityRequest.m
//  MNKit
//
//  Created by Vincent on 2018/12/20.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "WXCityRequest.h"
#import "WXCityModel.h"

@implementation WXCityRequest
- (instancetype)init {
    if (self = [super init]) {
        self.url = @"http://apicloud.mob.com/v1/weather/citys";
        self.cachePolicy = MNURLCachePolicyNever;
    }
    return self;
}

- (void)loadData:(MNURLRequestStartCallback)startCallback completion:(MNURLRequestFinishCallback)finishCallback {
    self.query = @{@"key":MobAppKey};
    [super loadData:startCallback completion:finishCallback];
}

/**
 解析数据
 @param responseObject 数据信息
 */
- (void)didSucceedWithResponseObject:(id)responseObject {
    [super didSucceedWithResponseObject:responseObject];
    NSArray <NSDictionary *>*result = [NSDictionary arrayValueWithDictionary:responseObject forKey:@"result"];
    [result enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
        WXProvinceModel *model = [WXProvinceModel modelWithDic:dic];
        if (model) [self.dataArray addObject:model];
    }];
}

@end
