//
//  WXMyTimelineViewModel.m
//  WeChat
//
//  Created by Vicent on 2021/4/18.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXMyTimelineViewModel.h"
#import "WXMoment.h"

@interface WXMyTimelineViewModel ()
@property (nonatomic, strong) NSMutableArray <WXMyMomentYearModel *>*dataSource;
@end

@implementation WXMyTimelineViewModel
- (instancetype)init {
    return [self initWithUser:WXUser.shareInfo];
}

- (instancetype)initWithUser:(WXUser *)user {
    if (self = [super init]) {
        self.user = user;
        self.dataSource = @[].mutableCopy;
        @weakify(self);
        // 添加朋友圈
        [self handNotification:WXMomentUpdateNotificationName eventHandler:^(NSNotification *_Nonnull notify) {
            WXMoment *moment = notify.object;
            if (!moment || ![moment isKindOfClass:WXMoment.class]) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself insertMoment:moment];
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

- (void)loadToday {
    if ([self.user.uid isEqualToString:WXUser.shareInfo.uid]) {
        WXMoment *moment = [WXMoment new];
        moment.uid = WXUser.shareInfo.uid;
        moment.location = @"";
        moment.content = @"";
        moment.timestamp = NSDate.timestamps;
        [moment setValue:@(YES) forKey:sql_field(moment.isNewMoment)];
        WXProfile *picture = WXProfile.new;
        picture.type = WXProfileTypeImage;
        picture.identifier = NSDate.shortTimestamps;
        picture.timestamp = moment.timestamp;
        picture.moment = moment.identifier;
        [picture setValue:[UIImage imageNamed:@"album_today_camera"] forKey:@"_image"];
        moment.profiles = @[picture].mutableCopy;
        
        [self addMoment:moment];
    }
}

- (void)loadData {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *timestamp = weakself.dataSource.count ? self.dataSource.lastObject.dataSource.lastObject.moment.timestamp : NSDate.timestamps;
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid = %@ AND timestamp < %@ ORDER BY timestamp DESC LIMIT %@, %@;", WXMomentTableName, sql_pair(self.user.uid), sql_pair(timestamp), @(0), @(10)];
        NSArray <WXMoment *>*moments = [MNDatabase.database selectRowsModelFromTable:WXMomentTableName sql:sql class:WXMoment.class];
        [moments enumerateObjectsUsingBlock:^(WXMoment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    NSArray <WXMyMomentYearModel *>*result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.year == %@", year]];
    WXMyMomentYearModel *viewModel;
    if (result.count) {
        viewModel = result.lastObject;
    } else {
        viewModel = [[WXMyMomentYearModel alloc] initWithYear:year];
        viewModel.touchEventHandler = self.touchEventHandler;
        [self.dataSource addObject:viewModel];
    }
    [viewModel addMoment:moment];
}

- (void)insertMoment:(WXMoment *)moment {
    NSString *year = [NSDate stringValueWithTimestamp:moment.timestamp format:@"yyyy"];
    NSArray <WXMyMomentYearModel *>*result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.year == %@", year]];
    WXMyMomentYearModel *viewModel;
    if (result.count) {
        viewModel = result.lastObject;
    } else {
        // 有新朋友圈入口一般不会到这里
        viewModel = [[WXMyMomentYearModel alloc] initWithYear:year];
        viewModel.touchEventHandler = self.touchEventHandler;
        NSArray <WXMyMomentYearModel *>*years = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.year < %@", year]];
        [self.dataSource insertObject:viewModel atIndex:(years.count ? [self.dataSource indexOfObject:years.firstObject] : 0)];
    }
    [viewModel insertMoment:moment];
}

- (BOOL)del:(WXProfile *)picture {
    NSString *year = [NSDate stringValueWithTimestamp:picture.timestamp format:@"yyyy"];
    NSArray <WXMyMomentYearModel *>*result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.year == %@", year]];
    if (result.count <= 0) return NO;
    WXMyMomentYearModel *vm = result.lastObject;
    if ([vm del:picture]) {
        if (vm.dataSource.count <= 0) [self.dataSource removeObject:vm];
        return YES;
    }
    return NO;
}

@end
