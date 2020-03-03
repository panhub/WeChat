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
        self.cachePolicy = MNURLDataCacheAllowable;
        self.url = @"http://apicloud.mob.com/v1/cook/category/query";
    }
    return self;
}

- (void)loadData:(MNURLRequestStartCallback)startCallback completion:(MNURLRequestFinishCallback)finishCallback {
    self.parameter = @{@"key":MobAppKey};
    [super loadData:startCallback completion:finishCallback];
}

/**
 解析数据
 @param responseObject 数据信息
 */
- (void)didLoadSucceedWithResponseObject:(id)responseObject {
    [super didLoadSucceedWithResponseObject:responseObject];
    NSDictionary *result = [MNJSONSerialization dictionaryValueWithJSON:responseObject forKey:@"result"];
    NSArray <NSDictionary *>*childs = [MNJSONSerialization arrayValueWithJSON:result forKey:@"childs"];
    [childs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXCookSort *model = [WXCookSort modelWithDictionary:obj];
        if (model) [self.dataArray addObject:model];
    }];
}

@end
