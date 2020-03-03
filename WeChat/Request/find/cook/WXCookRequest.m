//
//  WXCookRequest.m
//  MNChat
//
//  Created by Vincent on 2019/6/20.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookRequest.h"

@interface WXCookRequest ()
@property (nonatomic, copy) NSString *cid;
@end

#define WXCookRequestSize    30

@implementation WXCookRequest
- (instancetype)initWithCid:(NSString *)cid {
    if (self = [super init]) {
        self.cid = cid;
        self.pagingEnabled = YES;
        self.url = @"http://apicloud.mob.com/v1/cook/menu/search";
        self.cacheOutInterval = 10.f;
        self.cachePolicy = MNURLDataCacheUseTime;
    }
    return self;
}

- (void)loadData:(MNURLRequestStartCallback)startCallback completion:(MNURLRequestFinishCallback)finishCallback {
    self.parameter = @{@"key":MobAppKey, @"cid":self.cid, @"size":NSStringWithFormat(@"%@", @(WXCookRequestSize))};
    [super loadData:startCallback completion:finishCallback];
}

- (void)didLoadSucceedWithResponseObject:(id)responseObject {
    [super didLoadSucceedWithResponseObject:responseObject];
    NSDictionary *result = [MNJSONSerialization dictionaryValueWithJSON:responseObject forKey:@"result"];
    NSUInteger total = [MNJSONSerialization integerValueWithJSON:result forKey:@"total"];
    NSUInteger curPage = [MNJSONSerialization integerValueWithJSON:result forKey:@"curPage"];
    NSArray <NSDictionary *>*list = [MNJSONSerialization arrayValueWithJSON:result forKey:@"list"];
    [list enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXCookModel *model = [WXCookModel modelWithDictionary:obj];
        if (model) [self.dataArray addObject:model];
    }];
    self.more = curPage*WXCookRequestSize < total;
    self.page ++;
}

@end
