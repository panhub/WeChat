//
//  MNHTTPDataRequest.m
//  MNKit
//
//  Created by Vincent on 2018/11/21.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNHTTPDataRequest.h"

@interface MNHTTPDataRequest ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation MNHTTPDataRequest
- (void)initialized {
    [super initialized];
    _page = 1;
    _more = NO;
    _pagingEnabled = NO;
    _dataArray = [NSMutableArray arrayWithCapacity:0];
}

- (void)loadData:(MNURLRequestStartCallback)startCallback completion:(MNURLRequestFinishCallback)finishCallback {
    [self handQuery];
    [self handBody];
    [self handHeaderField];
    [super loadData:startCallback completion:finishCallback];
}

- (void)didSucceedWithResponseObject:(id)responseObject {
    [super didSucceedWithResponseObject:responseObject];
    if (_page == 1 && _pagingEnabled) [self cleanMemory];
}

- (void)handQuery {}

- (void)handBody {}

- (void)handHeaderField {}

- (void)setParameter:(id)parameter {
    if (self.method == MNURLHTTPMethodGet) {
        self.query = parameter;
    } else {
        self.body = parameter;
    }
}

- (void)setValue:(NSString *)value forParameter:(NSString *)parameter {
    if (self.isLoading || !parameter || parameter.length <= 0) return;
    id obj = self.parameter;
    if (!obj) {
        if (value) self.parameter = @{parameter:value};
    } else if ([obj isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary *dic = ((NSDictionary *)obj).mutableCopy;
        if (value) {
            [dic setObject:value forKey:parameter];
        } else {
            [dic removeObjectForKey:parameter];
        }
        self.parameter = dic.copy;
    }
}

- (void)prepareReloadData {
    _page = 1;
}

- (BOOL)isDataEmpty {
    return (!_dataArray || _dataArray.count <= 0);
}

- (void)cleanMemory {
    if (_dataArray) [_dataArray removeAllObjects];
}

- (id)parameter {
    return self.method == MNURLHTTPMethodGet ? self.query : self.body;
}

@end
