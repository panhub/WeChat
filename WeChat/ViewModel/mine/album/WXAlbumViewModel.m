//
//  WXAlbumViewModel.m
//  WeChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAlbumViewModel.h"
#import "WXMoment.h"

@interface WXAlbumViewModel ()
@property (nonatomic, strong) NSMutableArray <WXYearViewModel *>*dataSource;
@end

@implementation WXAlbumViewModel
- (instancetype)init {
    if (self = [super init]) {
        self.dataSource = @[].mutableCopy;
        @weakify(self);
        // 添加朋友圈
        [self handNotification:WXMomentUpdateNotificationName eventHandler:^(NSNotification *_Nonnull notify) {
            WXMoment *moment = notify.object;
            if (!moment || ![moment isKindOfClass:WXMoment.class] || moment.profiles.count <= 0) return;
            [weakself insertMoment:moment];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakself.reloadTableHandler) weakself.reloadTableHandler();
            });
        }];
        // 删除照片
        [self handNotification:WXAlbumPictureDeleteNotificationName eventHandler:^(NSNotification * _Nonnull notify) {
            WXProfile *picture = notify.object;
            if (!picture || ![picture isKindOfClass:WXProfile.class]) return;
            if ([weakself del:picture]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakself.reloadTableHandler) weakself.reloadTableHandler();
                });
            }
        }];
    }
    return self;
}

#pragma mark - 加载相册
- (void)loadData {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *timestamp = self.dataSource.count ? self.dataSource.lastObject.dataSource.lastObject.pictures.lastObject.timestamp : NSDate.timestamps;
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid = %@ AND type > %@ AND timestamp < %@ ORDER BY timestamp DESC LIMIT %@, %@;", WXMomentTableName, sql_pair(WXUser.shareInfo.uid), sql_pair(@(WXMomentTypeWeb).stringValue), sql_pair(timestamp), @(0), @(10)];
        NSArray <WXMoment *>*moments = [MNDatabase.database selectRowsModelFromTable:WXMomentTableName sql:sql class:WXMoment.class];
        [moments enumerateObjectsUsingBlock:^(WXMoment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.profiles.count <= 0) return;
            [weakself addMoment:obj];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakself.reloadTableHandler) weakself.reloadTableHandler();
            if (weakself.didLoadFinishHandler) weakself.didLoadFinishHandler(moments.count >= 10);
        });
    });
}

- (void)addMoment:(WXMoment *)moment {
    NSString *year = [NSDate stringValueWithTimestamp:moment.timestamp format:@"yyyy"];
    NSArray <WXYearViewModel *>*result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.year == %@", year]];
    WXYearViewModel *viewModel;
    if (result.count) {
        viewModel = result.lastObject;
    } else {
        viewModel = [[WXYearViewModel alloc] initWithYear:year];
        viewModel.touchEventHandler = self.touchEventHandler;
        [self.dataSource addObject:viewModel];
    }
    [viewModel addMoment:moment];
}

- (void)insertMoment:(WXMoment *)moment {
    NSString *year = [NSDate stringValueWithTimestamp:moment.timestamp format:@"yyyy"];
    NSArray <WXYearViewModel *>*result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.year == %@", year]];
    WXYearViewModel *viewModel;
    if (result.count) {
        viewModel = result.lastObject;
    } else {
        viewModel = [[WXYearViewModel alloc] initWithYear:year];
        viewModel.touchEventHandler = self.touchEventHandler;
        NSArray <WXYearViewModel *>*years = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.year < %@", year]];
        [self.dataSource insertObject:viewModel atIndex:(years.count ? [self.dataSource indexOfObject:years.firstObject] : 0)];
    }
    [viewModel insertMoment:moment];
}

- (BOOL)del:(WXProfile *)picture {
    NSString *year = [NSDate stringValueWithTimestamp:picture.timestamp format:@"yyyy"];
    NSArray <WXYearViewModel *>*result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.year == %@", year]];
    if (result.count <= 0) return NO;
    WXYearViewModel *vm = result.lastObject;
    if ([vm del:picture]) {
        if (vm.dataSource.count <= 0) [self.dataSource removeObject:vm];
        return YES;
    }
    return NO;
}

@end
