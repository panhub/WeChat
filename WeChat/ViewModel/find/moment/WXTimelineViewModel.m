//
//  WXTimelineViewModel.m
//  WeChat
//
//  Created by Vincent on 2019/5/7.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXTimelineViewModel.h"
#import "WechatHelper.h"

#define WXMomentPageCount   10

@interface WXTimelineViewModel ()
{
    dispatch_queue_t _queue;
}
@property (nonatomic, strong) NSMutableArray <WXMomentViewModel *>*dataSource;
@end

@implementation WXTimelineViewModel
- (instancetype)init {
    if (self = [super init]) {
        _dataSource = NSMutableArray.array;
        _queue = dispatch_queue_create("com.wx.moment.operation.queue", DISPATCH_QUEUE_CONCURRENT);
        [self handEvents];
    }
    return self;
}

- (void)handEvents {
    @weakify(self);
    /// 添加朋友圈
    [self handNotification:WXMomentUpdateNotificationName eventHandler:^(NSNotification *notify) {
        WXMoment *moment = notify.object;
        if (!moment) return;
        [weakself checkMoments:@[moment] handler:^(NSArray<WXMomentViewModel *> *viewModels) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self.dataSource insertObjects:viewModels atIndex:0];
                if (self.reloadTableHandler) self.reloadTableHandler();
                if (self.scrollToTopHandler) self.scrollToTopHandler(NO);
            });
        }];
    }];
}

#pragma mark - 加载朋友圈数据
- (void)reload {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY timestamp DESC LIMIT %@, %@", WXMomentTableName, @(0), @(WXMomentPageCount)];
        NSArray <WXMoment *>*result = [MNDatabase.database selectRowsModelFromTable:WXMomentTableName sql:sql class:WXMoment.class];
        [weakself checkMoments:result handler:^(NSArray<WXMomentViewModel *> *viewModels) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:viewModels];
                if (self.reloadTableHandler) self.reloadTableHandler();
                if (self.didLoadFinishHandler) self.didLoadFinishHandler(result.count >= WXMomentPageCount);
                [self reloadNotifys];
            });
        }];
    });
}

- (void)loadMore {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *timestamp = weakself.dataSource.count ? weakself.dataSource.lastObject.moment.timestamp : NSDate.timestamps;
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE timestamp < %@ ORDER BY timestamp DESC LIMIT %@, %@;", WXMomentTableName, sql_pair(timestamp), @(0), @(WXMomentPageCount)];
        NSArray <WXMoment *>*result = [MNDatabase.database selectRowsModelFromTable:WXMomentTableName sql:sql class:WXMoment.class];
        [weakself checkMoments:result handler:^(NSArray<WXMomentViewModel *> *viewModels) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self.dataSource addObjectsFromArray:viewModels];
                if (self.reloadTableHandler) self.reloadTableHandler();
                if (self.didLoadFinishHandler) self.didLoadFinishHandler(result.count >= WXMomentPageCount);
            });
        }];
    });
}

#pragma mark - 检查数据模型<删除了用户等情况, 耗时操作, 在分线程处理>
- (void)checkMoments:(NSArray<WXMoment *> *)moments handler:(void(^)(NSArray<WXMomentViewModel *> *))handler {
    dispatch_async(_queue, ^{
        NSMutableArray <WXMomentViewModel *>*viewModels = [NSMutableArray arrayWithCapacity:moments.count];
        [moments enumerateObjectsUsingBlock:^(WXMoment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            /// 判断朋友圈发布者用户是否存在
            if (![[WechatHelper helper] containsUserWithUid:obj.uid]) {
                [self deleteMoment:obj];
                return;
            }
            
            // 判断评论用户是否存在
            for (WXComment *comment in obj.comments.copy) {
                if (![[WechatHelper helper] containsUserWithUid:comment.from_uid]) {
                    // 用户不存在 评论无效
                    [obj.comments removeObject:comment];
                    [MNDatabase.database deleteRowFromTable:WXMomentCommentTableName
                                             where:@{sql_field(comment.identifier):sql_pair(comment.identifier)}.sqlQueryValue];
                } else if (comment.to_uid.length && ![[WechatHelper helper] containsUserWithUid:comment.to_uid]) {
                    // 回复无效
                    comment.to_uid = @"";
                    [MNDatabase.database updateTable:WXMomentCommentTableName
                                      where:@{sql_field(comment.identifier):sql_pair(comment.identifier)}.sqlQueryValue
                                      model:comment];
                }
            }
            
            /// 判断点赞用户是否存在
            [obj.likes.copy enumerateObjectsUsingBlock:^(WXLike *_Nonnull like, NSUInteger idx, BOOL * _Nonnull stop) {
                if (!like.user) {
                    [obj.likes removeObject:like];
                    [MNDatabase.database deleteRowFromTable:WXMomentLikeTableName where:@{sql_field(like.identifier):sql_pair(like.identifier)}.sqlQueryValue];
                }
            }];
            
            /// 添加数据
            [viewModels addObject:[self viewModelWithMoment:obj]];
        }];
        /// 回调数据
        if (handler) {
            handler(viewModels.copy);
        }
    });
}

- (WXMomentViewModel *)viewModelWithMoment:(WXMoment *)moment {
    WXMomentViewModel *viewModel = [[WXMomentViewModel alloc] initWithMoment:moment];
    viewModel.webViewEventHandler = self.webViewEventHandler;
    viewModel.pictureViewEventHandler = self.pictureViewEventHandler;
    viewModel.moreViewEventHandler = self.moreViewEventHandler;
    viewModel.locationViewEventHandler = self.locationViewEventHandler;
    viewModel.deleteButtonEventHandler = self.deleteButtonEventHandler;
    viewModel.avatarClickedEventHandler = self.avatarClickedEventHandler;
    viewModel.reloadMomentEventHandler = self.reloadMomentEventHandler;
    /// 点赞事件回调
    @weakify(self);
    viewModel.didUpdateLikesEventHandler = ^(WXMomentViewModel *vm) {
        @strongify(self);
        [self updateLikeNotify:vm.moment];
    };
    /// 评论/回复事件
    viewModel.didInsertCommentEventHandler = ^(WXComment *comment) {
        @strongify(self);
        WXNotify *notify = [[WXNotify alloc] initWithComment:comment];
        if ([[MNDatabase database] insertToTable:WXMomentNotifyTableName model:notify]) {
            if (self.reloadNotifyHandler) self.reloadNotifyHandler();
        }
    };
    /// 删除评论/回复事件
    viewModel.didDeleteCommentEventHandler = ^(WXComment *comment) {
        @strongify(self);
        if ([MNDatabase.database deleteRowFromTable:WXMomentNotifyTableName where:@{sql_field(comment.identifier):sql_pair(comment.identifier)}.sqlQueryValue]) {
            if (self.reloadNotifyHandler) self.reloadNotifyHandler();
        }
    };
    return viewModel;
}

/// 删除朋友圈, 同时删除数据库相关数据
- (void)deleteMoment:(WXMoment *)moment {
    if (!moment) return;
    /// 删除分享数据
    WXWebpage *webpage = moment.webpage;
    if (webpage) [webpage removeContentsAtFile];
    /// 配图数据
    [moment.profiles makeObjectsPerformSelector:@selector(removeContentsAtFile)];
    [MNDatabase.database deleteRowFromTable:WXMomentProfileTableName where:@{@"moment":sql_pair(moment.identifier)}.sqlQueryValue];
    /// 删除点赞
    [MNDatabase.database deleteRowFromTable:WXMomentLikeTableName where:@{@"moment":sql_pair(moment.identifier)}.sqlQueryValue];
    /// 删除评论
    [MNDatabase.database deleteRowFromTable:WXMomentCommentTableName where:@{@"moment":sql_pair(moment.identifier)}.sqlQueryValue];
    /// 删除提醒
    [MNDatabase.database deleteRowFromTable:WXMomentNotifyTableName where:@{@"moment":sql_pair(moment.identifier)}.sqlQueryValue];
    /// 删除朋友圈
    [MNDatabase.database deleteRowFromTable:WXMomentTableName where:@{sql_field(moment.identifier):sql_pair(moment.identifier)}.sqlQueryValue];
}

- (void)deleteMomentViewModel:(WXMomentViewModel *)viewModel {
    [self deleteMoment:viewModel.moment];
    [self.dataSource removeObject:viewModel];
    if (self.reloadTableHandler) self.reloadTableHandler();
    if (self.reloadNotifyHandler) self.reloadNotifyHandler();
}

#pragma mark - 检查朋友圈提醒数据
- (void)reloadNotifys {
    dispatch_async(_queue, ^{
        NSArray <WXNotify *>*rows = [[MNDatabase database] selectRowsModelFromTable:WXMomentNotifyTableName class:WXNotify.class];
        [rows.copy enumerateObjectsUsingBlock:^(WXNotify * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![[WechatHelper helper] containsUserWithUid:obj.from_uid]) {
                [MNDatabase.database deleteRowFromTable:WXMomentNotifyTableName
                                          where:@{sql_field(obj.identifier):sql_pair(obj.identifier)}.sqlQueryValue];
            } else if (obj.to_uid.length && ![[WechatHelper helper] containsUserWithUid:obj.to_uid]) {
                obj.to_uid = @"";
                [MNDatabase.database updateTable:WXMomentNotifyTableName where:@{sql_field(obj.identifier):sql_pair(obj.identifier)}.sqlQueryValue model:obj];
            }
        }];
        /// 通知刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.reloadNotifyHandler) {
                self.reloadNotifyHandler();
            }
        });
    });
}

#pragma mark - 检查是否包含某条朋友圈
- (BOOL)containsMomentWithIdentifier:(NSString *)identifier {
    return [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.moment.identifier == %@", identifier]].count > 0;
}

#pragma mark - 刷新点赞提醒
- (void)updateLikeNotify:(WXMoment *)moment {
    // 删除旧点赞新增新点赞
    NSMutableArray <WXLike *>*dels = @[].mutableCopy;
    NSMutableArray <WXNotify *>*deletes = @[].mutableCopy;
    NSMutableArray <WXLike *>*likes = moment.likes.mutableCopy;
    NSMutableArray <WXNotify *>*notifys = ([MNDatabase.database selectRowsModelFromTable:WXMomentNotifyTableName where:@{@"moment":sql_pair(moment.identifier)}.sqlQueryValue limit:NSRangeZero class:WXNotify.class] ? : @[]).mutableCopy;
    [notifys enumerateObjectsUsingBlock:^(WXNotify * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.content.length) return;
        NSArray <WXLike *>*result = [moment.likes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.identifier == %@", obj.identifier]];
        if (result.count) {
            [dels addObjectsFromArray:result];
        } else {
            [deletes addObject:obj];
        }
    }];
    [deletes enumerateObjectsUsingBlock:^(WXNotify * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [MNDatabase.database deleteRowFromTable:WXMomentNotifyTableName where:@{sql_field(obj.identifier):sql_pair(obj.identifier)}.sqlQueryValue];
    }];
    [likes removeObjectsInArray:dels];
    [likes enumerateObjectsUsingBlock:^(WXLike * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.uid isEqualToString:WXUser.shareInfo.uid]) return;
        WXNotify *notify = [[WXNotify alloc] initWithLike:obj];
        [MNDatabase.database insertToTable:WXMomentNotifyTableName model:notify];
    }];
    if (self.reloadNotifyHandler) self.reloadNotifyHandler();
}

@end
