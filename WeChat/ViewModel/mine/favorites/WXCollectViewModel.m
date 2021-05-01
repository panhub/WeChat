//
//  WXCollectViewModel.m
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXCollectViewModel.h"
#import "WXFavoriteViewModel.h"
#import "WXFavorite.h"

@implementation WXCollectViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.dataSource = @[].mutableCopy;
        [self handEvents];
    }
    return self;
}

- (void)handEvents {
    /// ShareExtension 引发事件
    @weakify(self);
    [self handNotification:WXFavoriteUpdateNotificationName eventHandler:^(NSNotification *notify) {
        @strongify(self);
        NSArray <WXFavorite *>*favorites = notify.object;
        if ([favorites isKindOfClass:NSArray.class]) {
            NSMutableArray <WXFavoriteViewModel *>*vms = @[].mutableCopy;
            [favorites enumerateObjectsUsingBlock:^(WXFavorite * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [vms addObject:[self viewModelWithFavorite:obj]];
            }];
            [self.dataSource insertObjects:vms fromIndex:0];
            if (self.reloadTableHandler) self.reloadTableHandler();
        }
    }];
}

#pragma mark - ViewModel
- (WXFavoriteViewModel *)viewModelWithFavorite:(WXFavorite *)favorite {
    WXFavoriteViewModel *viewModel = [WXFavoriteViewModel viewModelWithFavorite:favorite];
    viewModel.imageViewClickedHandler = self.imageViewClickedHandler;
    viewModel.backgroundLongPressHandler = self.backgroundLongPressHandler;
    return viewModel;
}

- (void)loadData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSInteger count = [MNDatabase.database selectCountFromTable:WXFavoriteTableName where:nil];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY timestamp DESC LIMIT %@, %@", WXFavoriteTableName, @(self.dataSource.count), @(10)];
        NSArray <WXFavorite *>*favorites = [MNDatabase.database selectRowsModelFromTable:WXFavoriteTableName sql:sql class:WXFavorite.class];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (favorites.count > 0) {
                NSMutableArray <WXFavoriteViewModel *>*vms = [NSMutableArray arrayWithCapacity:favorites.count];
                [favorites enumerateObjectsUsingBlock:^(WXFavorite * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [vms addObject:[self viewModelWithFavorite:obj]];
                }];
                [self.dataSource addObjectsFromArray:vms];
            }
            if (self.reloadTableHandler) self.reloadTableHandler();
            if (self.didLoadFinishHandler) self.didLoadFinishHandler(self.dataSource.count < count);
        });
    });
}

- (void)reloadData {
    [self.dataSource removeAllObjects];
    if (self.reloadTableHandler) self.reloadTableHandler();
    [self loadData];
}

@end
