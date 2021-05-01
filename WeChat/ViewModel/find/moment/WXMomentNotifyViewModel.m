//
//  WXMomentNotifyViewModel.m
//  WeChat
//
//  Created by Vicent on 2021/4/25.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXMomentNotifyViewModel.h"

@interface WXMomentNotifyViewModel ()
@property (nonatomic, strong) NSMutableArray <WXNotifyViewModel *>*dataSource;
@end

@implementation WXMomentNotifyViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.dataSource = @[].mutableCopy;
    }
    return self;
}

- (void)loadData {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *timestamp = self.dataSource.count ? self.dataSource.lastObject.notify.timestamp : NSDate.timestamps;
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE timestamp < %@ ORDER BY timestamp DESC LIMIT %@, %@;", WXMomentNotifyTableName, sql_pair(timestamp), @(0), @(15)];
        NSArray <WXNotify *>*rows = [MNDatabase.database selectRowsModelFromTable:WXMomentNotifyTableName sql:sql class:WXNotify.class];
        [rows enumerateObjectsUsingBlock:^(WXNotify * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WXNotifyViewModel *vm = [WXNotifyViewModel viewModelWithNotify:obj];
            if (vm) [weakself.dataSource addObject:vm];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakself.reloadTableHandler) weakself.reloadTableHandler();
            if (weakself.didLoadFinishHandler) weakself.didLoadFinishHandler(rows.count >= 15);
        });
    });
}

@end
