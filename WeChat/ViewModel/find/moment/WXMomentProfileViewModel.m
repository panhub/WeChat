//
//  WXMomentProfileViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/5/7.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentProfileViewModel.h"
#import "WechatHelper.h"

@interface WXMomentProfileViewModel ()
{
    dispatch_queue_t moment_operation_queue;
}
@property (nonatomic, strong) NSMutableArray <WXMomentViewModel *>*dataSource;
@end

@implementation WXMomentProfileViewModel
- (instancetype)init {
    if (self = [super init]) {
        _reminds = [NSMutableArray array];
        _dataSource = [NSMutableArray array];
        moment_operation_queue = dispatch_queue_create("com.wx.moment.operation.queue", DISPATCH_QUEUE_CONCURRENT);
        [self handEvents];
    }
    return self;
}

- (void)handEvents {
    @weakify(self);
    /// 添加朋友圈
    [self handNotification:WXMomentAddNotificationName eventHandler:^(NSNotification *notify) {
        @strongify(self);
        WXMoment *moment = notify.object;
        if (!moment) return;
        [self checkMoments:@[moment] handler:^(NSArray<WXMomentViewModel *> *viewModels) {
            dispatch_async_main(^{
                [self.dataSource insertObjects:viewModels atIndex:0];
                if (self.reloadTableHandler) {
                    self.reloadTableHandler();
                }
            });
        }];
    }];
}

#pragma mark - 加载朋友圈数据
- (void)loadData {
    [MNDatabase selectRowsModelFromTable:WXMomentTableName class:WXMoment.class completion:^(NSArray<WXMoment *> * _Nonnull rows) {
        @weakify(self);
        [self checkMoments:rows.reversedArray handler:^(NSArray<WXMomentViewModel *> *viewModels) {
            @strongify(self);
            dispatch_async_main(^{
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:viewModels];
                if (self.reloadTableHandler) {
                    self.reloadTableHandler();
                }
                [self reloadReminds];
            });
        }];
    }];
}

#pragma mark - 检查数据模型<删除了用户等情况, 耗时操作, 在分线程处理>
- (void)checkMoments:(NSArray<WXMoment *> *)moments handler:(void(^)(NSArray<WXMomentViewModel *> *))handler {
    dispatch_async(moment_operation_queue, ^{
        NSMutableArray <WXMomentViewModel *>*viewModels = [NSMutableArray arrayWithCapacity:moments.count];
        [moments enumerateObjectsUsingBlock:^(WXMoment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /// 判断朋友圈发布者用户是否存在
            if (![[WechatHelper helper] containsUserWithUid:obj.uid]) {
                [self deleteMoment:obj];
                return;
            }
            
            /// 标记是否需要更新朋友圈数据
            __block BOOL need_update_moment = NO;
            
            /// 判断评论用户是否存在
            NSMutableArray *temp = [NSMutableArray arrayWithCapacity:0];
            for (WXMomentComment *comment in obj.comments) {
                NSString *from_uid = comment.from_uid;
                NSString *to_uid = comment.to_uid;
                if (from_uid.length <= 0 && to_uid.length <= 0) {
                    [temp addObject:comment];
                } else if (![[WechatHelper helper] containsUserWithUid:from_uid] && ![[WechatHelper helper] containsUserWithUid:to_uid]) {
                    [temp addObject:comment];
                }
            }
            [temp enumerateObjectsUsingBlock:^(WXMomentComment *_Nonnull comment, NSUInteger idx, BOOL * _Nonnull stop) {
                [MNDatabase deleteRowFromTable:WXMomentCommentTableName
                                          where:[@{sql_field(comment.identifier):sql_pair(comment.identifier)} componentString]
                                     completion:nil];
                if (obj.comment.length <= 0) return;
                NSMutableArray *array = [obj.comment componentsSeparatedByString:WXDataSeparatedSign].mutableCopy;
                if ([array containsObject:comment.identifier]) [array removeObject:comment.identifier];
                obj.comment = [array.copy componentsJoinedByString:WXDataSeparatedSign];
                need_update_moment = YES;
            }];
            [obj.comments removeObjectsInArray:temp];
            [temp removeAllObjects];
            
            /// 判断点赞用户是否存在
            [obj.likes enumerateObjectsUsingBlock:^(NSString * _Nonnull uid, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![[WechatHelper helper] containsUserWithUid:uid]) {
                    [temp addObject:uid];
                }
            }];
            [temp enumerateObjectsUsingBlock:^(NSString *_Nonnull uid, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.like.length <= 0) return;
                NSMutableArray *array = [obj.like componentsSeparatedByString:WXDataSeparatedSign].mutableCopy;
                if ([array containsObject:uid]) [array removeObject:uid];
                obj.like = [array.copy componentsJoinedByString:WXDataSeparatedSign];
                need_update_moment = YES;
            }];
            [obj.likes removeObjectsInArray:temp];
            [temp removeAllObjects];
            
            /// 更新朋友圈数据
            if (need_update_moment) {
                [MNDatabase updateTable:WXMomentTableName
                                   where:[@{sql_field(obj.identifier):obj.identifier} componentString]
                                  fields:@{sql_field(obj.comment):obj.comment, sql_field(obj.like):obj.like}
                              completion:nil];
            }
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
    viewModel.moreButtonEventHandler = self.moreButtonEventHandler;
    viewModel.locationViewEventHandler = self.locationViewEventHandler;
    viewModel.deleteButtonEventHandler = self.deleteButtonEventHandler;
    viewModel.avatarClickedEventHandler = self.avatarClickedEventHandler;
    viewModel.reloadMomentEventHandler = self.reloadMomentEventHandler;
    /// 点赞事件回调
    @weakify(self);
    viewModel.didUpdateLikesEventHandler = ^(WXMomentViewModel *vm, NSArray <NSString *>*likes) {
        @strongify(self);
        [self updateRemindOfOldLikes:likes withMoment:vm.moment];
    };
    /// 评论/回复事件
    viewModel.didInsertCommentEventHandler = ^(WXMomentViewModel *vm, WXMomentComment *comment) {
        @strongify(self);
        [self insertCommentRemind:comment withMoment:vm.moment];
    };
    /// 删除评论/回复事件
    viewModel.didDeleteCommentEventHandler = ^(WXMomentViewModel *vm, WXMomentComment *comment) {
        @strongify(self);
        [self deleteCommentRemind:comment withMoment:vm.moment];
    };
    return viewModel;
}

/// 删除朋友圈, 同时删除数据库相关数据
- (void)deleteMoment:(WXMoment *)moment {
    if (!moment) return;
    /// 删除分享数据
    WXMomentWebpage *webpage = moment.webpage;
    if (webpage) {
        if (webpage.img.length) {
            [WechatHelper.helper.cache removeObjectForKey:webpage.img completion:nil];
        }
        [MNDatabase deleteRowFromTable:WXMomentWebpageTableName
                                  where:[@{sql_field(webpage.identifier):sql_pair(webpage.identifier)} componentString]
                             completion:nil];
    }
    /// 配图数据
    [moment.pictures enumerateObjectsUsingBlock:^(WXMomentPicture * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [WechatHelper.helper.cache removeObjectForKey:obj.identifier completion:nil];
    }];
    /// 删除评论数据
    [moment.comments enumerateObjectsUsingBlock:^(WXMomentComment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [MNDatabase deleteRowFromTable:WXMomentCommentTableName
                                  where:[@{sql_field(obj.identifier):sql_pair(obj.identifier)} componentString]
                             completion:nil];
    }];
    /// 删除朋友圈
    [MNDatabase deleteRowFromTable:WXMomentTableName
                              where:[@{sql_field(moment.identifier):sql_pair(moment.identifier)} componentString]
                         completion:nil];
}

- (void)deleteMomentViewModel:(WXMomentViewModel *)viewModel {
    [self deleteMoment:viewModel.moment];
    if ([self.dataSource containsObject:viewModel]) {
        [self.dataSource removeObject:viewModel];
    }
    [self reloadReminds];
}

#pragma mark - 检查朋友圈提醒数据
- (void)reloadReminds {
    dispatch_async(moment_operation_queue, ^{
        NSMutableArray <WXMomentRemind *>*rows = [[MNDatabase database] selectRowsModelFromTable:WXMomentRemindTableName class:WXMomentRemind.class].mutableCopy;
        if (rows.count) {
            NSMutableArray <WXMomentRemind *>*temp = [NSMutableArray arrayWithCapacity:0];
            [rows enumerateObjectsUsingBlock:^(WXMomentRemind * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *from_uid = obj.from_uid;
                NSString *to_uid = obj.to_uid;
                NSString *moment = obj.moment;
                if (![self containsMomentWithIdentifier:moment] || ![[WechatHelper helper] containsUserWithUid:from_uid] || (to_uid.length && ![[WechatHelper helper] containsUserWithUid:to_uid])) {
                    [temp addObject:obj];
                }
            }];
            [temp enumerateObjectsUsingBlock:^(WXMomentRemind * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [MNDatabase deleteRowFromTable:WXMomentRemindTableName
                                          where:[@{sql_field(obj.identifier):sql_pair(obj.identifier)} componentString]
                                     completion:nil];
            }];
            [rows removeObjectsInArray:temp];
            [self.reminds removeAllObjects];
            [self.reminds addObjectsFromArray:rows];
        } else {
            [self.reminds removeAllObjects];
        }
        /// 通知刷新
        dispatch_async_main(^{
            if (self.reloadRemindHandler) {
                self.reloadRemindHandler();
            }
        });
    });
}

#pragma mark - 检查是否包含某条朋友圈
- (BOOL)containsMomentWithIdentifier:(NSString *)identifier {
    __block BOOL contains = NO;
    [self.dataSource enumerateObjectsUsingBlock:^(WXMomentViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.moment.identifier isEqualToString:identifier]) {
            contains = YES;
            *stop = YES;
        }
    }];
    return contains;
}

#pragma mark - 刷新点赞提醒
- (void)updateRemindOfOldLikes:(NSArray <NSString *>*)oldLikes withMoment:(WXMoment *)moment {
    // 对比新旧点赞人员, 分辨新增和删除人
    NSArray <NSString *>*likes = moment.likes.copy;
    NSMutableArray <NSString *>*addLikes = @[].mutableCopy;
    NSMutableArray <NSString *>*deleteLikes = @[].mutableCopy;
    [likes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![oldLikes containsObject:obj]) [addLikes addObject:obj];
    }];
    [oldLikes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![likes containsObject:obj]) [deleteLikes addObject:obj];
    }];
    // 取出关于此条朋友圈的提醒事项
    NSMutableArray <WXMomentRemind *>*reminds = @[].mutableCopy;
    [self.reminds.copy enumerateObjectsUsingBlock:^(WXMomentRemind * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.moment isEqualToString:moment.identifier] && obj.content.length <= 0) {
            [reminds addObject:obj];
        }
    }];
    // 分别取出删除提醒事项和插入新增提醒事项
    NSMutableArray <WXMomentRemind *>*addReminds = @[].mutableCopy;
    NSMutableArray <WXMomentRemind *>*deleteReminds = @[].mutableCopy;
    // 取出删除提醒事项
    [deleteLikes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [reminds enumerateObjectsUsingBlock:^(WXMomentRemind * _Nonnull o, NSUInteger i, BOOL * _Nonnull s) {
            if ([o.from_uid isEqualToString:obj]) {
                if ([MNDatabase.database deleteRowFromTable:WXMomentRemindTableName where:@{sql_field(o.identifier):sql_pair(o.identifier)}.componentString]) {
                    [deleteReminds addObject:o];
                }
                *s = YES;
            }
        }];
    }];
    // 插入新增提醒事项
    [addLikes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL isExists = NO;
        [reminds enumerateObjectsUsingBlock:^(WXMomentRemind * _Nonnull o, NSUInteger i, BOOL * _Nonnull s) {
            if ([o.from_uid isEqualToString:obj]) {
                isExists = YES;
                *s = YES;
            }
        }];
        if (!isExists) {
            WXMomentRemind *model = [WXMomentRemind remindWithUid:obj withMoment:moment];
            if ([[MNDatabase database] insertToTable:WXMomentRemindTableName model:model]) {
                [addReminds addObject:model];
            }
        }
    }];
    [self.reminds removeObjectsInArray:deleteReminds];
    [self.reminds addObjectsFromArray:addReminds];
    if (self.reloadRemindHandler) self.reloadRemindHandler();
}

#pragma mark - 插入 评论/回复 提醒
- (void)insertCommentRemind:(WXMomentComment *)comment withMoment:(WXMoment *)moment {
    WXMomentRemind *model = [WXMomentRemind remindWithComment:comment withMoment:moment];
    if ([[MNDatabase database] insertToTable:WXMomentRemindTableName model:model]) {
        [self.reminds addObject:model];
        if (self.reloadRemindHandler) {
            self.reloadRemindHandler();
        }
    }
}

#pragma mark - 删除 评论/回复 提醒
- (void)deleteCommentRemind:(WXMomentComment *)comment withMoment:(WXMoment *)moment {
    if (self.reminds.count <= 0) return;
    __block WXMomentRemind *model;
    [self.reminds enumerateObjectsUsingBlock:^(WXMomentRemind * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.moment isEqualToString:moment.identifier] && [obj.from_uid isEqualToString:comment.from_uid]) {
            if (comment.to_uid.length <= 0) {
                /// 点赞
                if (obj.to_uid.length <= 0) {
                    model = obj;
                    *stop = YES;
                }
            } else if ([obj.to_uid isEqualToString:comment.to_uid]) {
                /// 评论
                if ([obj.content isEqualToString:comment.content]) {
                    model = obj;
                    *stop = YES;
                }
            }
        }
    }];
    if (!model) return;
    [MNDatabase deleteRowFromTable:WXMomentRemindTableName where:[@{sql_field(model.identifier):model.identifier} componentString] completion:nil];
    [self.reminds removeObject:model];
    if (self.reloadRemindHandler) {
        self.reloadRemindHandler();
    }
}

@end
