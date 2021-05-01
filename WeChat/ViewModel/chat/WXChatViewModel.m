//
//  WXChatViewModel.m
//  WeChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChatViewModel.h"
#import "WXVoiceMessageViewModel.h"
#import "WXVideoMessageViewModel.h"
#import "WXSession.h"
#import "WXMessage.h"
#import "WXLocation.h"
#import "WXFileModel.h"
#import "WXFavorite.h"
#import "WXWebpage.h"
#if __has_include(<Speech/Speech.h>)
#import <Speech/Speech.h>
#endif

@interface WXChatViewModel () <MNPlayerDelegate>
/// 播放器
@property (nonatomic, strong) MNPlayer *player;
@end

@implementation WXChatViewModel
- (instancetype)initWithSession:(WXSession *)session {
    if (self = [super init]) {
        self.session = session;
        [self handEvents];
    }
    return self;
}

- (void)handEvents {
    @weakify(self);
    /// 更新数据
    [self handNotification:WXMessageUpdateNotificationName eventHandler:^(NSNotification *notify) {
        @strongify(self);
        WXMessage *msg = notify.object;
        if ([msg isKindOfClass:WXMessage.class] && [(NSString *)msg.user_info isEqualToString:self.session.identifier]) {
            WXMessageViewModel *vm = [self viewModelWithMessage:msg];
            [self.dataSource addObject:vm];
            if (self.reloadTableHandler) self.reloadTableHandler();
            if (self.scrollRowToVisibleHandler) self.scrollRowToVisibleHandler(self.dataSource.count - 1, NO);
        }
    }];
}

- (void)loadData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray <WXMessageViewModel *>* result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.message.type == %ld", WXTurnMessage]];
        NSInteger count = [MNDatabase.database selectCountFromTable:self.session.table_name where:nil];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY timestamp DESC LIMIT %@, %@", self.session.table_name, @(self.dataSource.count - result.count), @(20)];
        NSArray <WXMessage *>*msgs = [MNDatabase.database selectRowsModelFromTable:self.session.table_name sql:sql class:WXMessage.class];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (msgs.count > 0) {
                NSMutableArray <WXMessageViewModel *>*vms = [NSMutableArray arrayWithCapacity:msgs.count];
                [msgs.reverseObjectEnumerator.allObjects enumerateObjectsUsingBlock:^(WXMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [vms addObject:[self viewModelWithMessage:obj]];
                }];
                [self.dataSource insertObjects:vms atIndex:0];
                if (self.reloadTableHandler) self.reloadTableHandler();
                if (self.dataSource.count == msgs.count) {
                    /// 第一次加载 self.dataSource.count < WXChatListRequestPageCount
                    if (self.scrollRowToBottomHandler) {
                        self.scrollRowToBottomHandler((self.dataSource.count - 1), NO);
                    }
                }
            }
            if (self.didLoadFinishHandler) self.didLoadFinishHandler(self.dataSource.count < count);
        });
    });
}

- (WXMessageViewModel *)viewModelWithMessage:(WXMessage *)message {
    WXMessageViewModel *viewModel = [WXMessageViewModel viewModelWithMessage:message];
    viewModel.textLabelClickedHandler = self.textLabelClickedHandler;
    viewModel.imageViewClickedHandler = self.imageViewClickedHandler;
    viewModel.imageViewLongPressHandler = self.imageViewLongPressHandler;
    viewModel.headButtonClickedHandler = self.headButtonClickedHandler;
    return viewModel;
}

#pragma mark - 发送消息
- (BOOL)sendTextMsg:(NSString *)text isMine:(BOOL)isMine {
    WXMessage *msg = [WXMessage createTextMsg:text isMine:isMine session:self.session];
    if (!msg) return NO;
    WXMessageViewModel *viewModel = [self viewModelWithMessage:msg];
    [self.dataSource addObject:viewModel];
    if (self.didInsertViewModelHandler) {
        self.didInsertViewModelHandler(@[viewModel]);
    }
    dispatch_after_main(.3f, ^{
        if (self.didSendViewModelHandler) {
            self.didSendViewModelHandler(@[viewModel]);
        }
    });
    return YES;
}

- (BOOL)sendImageMsg:(UIImage *)image isMine:(BOOL)isMine {
    WXMessage *msg = [WXMessage createImageMsg:image isMine:isMine session:self.session];
    if (!msg) return NO;
    WXMessageViewModel *viewModel = [self viewModelWithMessage:msg];
    [self.dataSource addObject:viewModel];
    if (self.didInsertViewModelHandler) {
        self.didInsertViewModelHandler(@[viewModel]);
    }
    if (self.didSendViewModelHandler) {
        self.didSendViewModelHandler(@[viewModel]);
    }
    return YES;
}

- (BOOL)sendEmotionMsg:(UIImage *)image isMine:(BOOL)isMine {
    WXMessage *msg = [WXMessage createEmotionMsg:image isMine:isMine session:self.session];
    if (!msg) return NO;
    WXMessageViewModel *viewModel = [self viewModelWithMessage:msg];
    [self.dataSource addObject:viewModel];
    if (self.didInsertViewModelHandler) {
        self.didInsertViewModelHandler(@[viewModel]);
    }
    dispatch_after_main(.3f, ^{
        if (self.didSendViewModelHandler) {
            self.didSendViewModelHandler(@[viewModel]);
        }
    });
    return YES;
}

- (BOOL)sendLocationMsg:(WXLocation *)location isMine:(BOOL)isMine {
    WXMessage *msg = [WXMessage createLocationMsg:location isMine:isMine session:self.session];
    if (!msg) return NO;
    WXMessageViewModel *viewModel = [self viewModelWithMessage:msg];
    [self.dataSource addObject:viewModel];
    if (self.didInsertViewModelHandler) {
        self.didInsertViewModelHandler(@[viewModel]);
    }
    if (self.didSendViewModelHandler) {
        self.didSendViewModelHandler(@[viewModel]);
    }
    return YES;
}

- (BOOL)sendFavoriteMsg:(WXFavorite *)favorite isMine:(BOOL)isMine {
    WXMessage *msg;
    if (favorite.type == WXFavoriteTypeText) {
        msg = [WXMessage createTextMsg:favorite.title isMine:isMine session:self.session];
    } else if (favorite.type == WXFavoriteTypeVideo) {
        msg = [WXMessage createVideoMsg:favorite.filePath isMine:isMine session:self.session];
    } else if (favorite.type == WXFavoriteTypeImage) {
        msg = [WXMessage createImageMsg:favorite.image isMine:isMine session:self.session];
    } else if (favorite.type == WXFavoriteTypeWeb) {
        msg = [WXMessage createWebpageMsg:[WXWebpage webpageWithWebFavorite:favorite session:self.session] isMine:isMine session:self.session];
    } else if (favorite.type == WXFavoriteTypeLocation) {
        WXLocation *location = [WXLocation locationWithCoordinate:favorite.url.coordinate2DValue];
        location.name = favorite.title;
        location.address = favorite.subtitle;
        msg = [WXMessage createLocationMsg:location isMine:isMine session:self.session];
    }
    if (!msg) return NO;
    WXMessageViewModel *viewModel = [self viewModelWithMessage:msg];
    [self.dataSource addObject:viewModel];
    if (self.didInsertViewModelHandler) {
        self.didInsertViewModelHandler(@[viewModel]);
    }
    if (self.didSendViewModelHandler) {
        self.didSendViewModelHandler(@[viewModel]);
    }
    return YES;
}

- (BOOL)sendRedpacketMsg:(NSString *)text money:(NSString *)money isMine:(BOOL)isMine {
    WXMessage *msg = [WXMessage createRedpacketMsg:text money:money isMine:isMine session:self.session];
    if (!msg) return NO;
    WXMessageViewModel *viewModel = [self viewModelWithMessage:msg];
    [self.dataSource addObject:viewModel];
    if (self.didInsertViewModelHandler) {
        self.didInsertViewModelHandler(@[viewModel]);
    }
    if (self.didSendViewModelHandler) {
        self.didSendViewModelHandler(@[viewModel]);
    }
    return YES;
}

- (BOOL)sendTransferMsg:(NSString *)text money:(NSString *)money time:(NSString *)time isMine:(BOOL)isMine isUpdate:(BOOL)isUpdate {
    WXMessage *msg = [WXMessage createTransferMsg:text money:money time:time isMine:isMine isUpdate:isUpdate session:self.session];
    if (!msg) return NO;
    WXMessageViewModel *viewModel = [self viewModelWithMessage:msg];
    [self.dataSource addObject:viewModel];
    if (self.didInsertViewModelHandler) {
        self.didInsertViewModelHandler(@[viewModel]);
    }
    if (self.didSendViewModelHandler) {
        self.didSendViewModelHandler(@[viewModel]);
    }
    return YES;
}

- (BOOL)sendVoiceMsg:(NSString *)voicePath isMine:(BOOL)isMine {
    if (voicePath.length) {
        /// 此时应已有语音消息模型
        if (self.dataSource.count <= 0) return NO;
        WXMessageViewModel *viewModel = self.dataSource.lastObject;
        if (viewModel.message.type != WXVoiceMessage) return NO;
        WXMessage *msg = [WXMessage createVoiceMsg:voicePath isMine:isMine session:self.session];
        if (!msg) {
            if (self.dataSource.count > 1 && self.scrollRowToBottomHandler) {
                self.scrollRowToBottomHandler(self.dataSource.count - 2, YES);
                dispatch_after_main(.3f, ^{
                    [self.dataSource removeLastObject];
                    if (self.reloadTableHandler) {
                        self.reloadTableHandler();
                    }
                });
            } else {
                [self.dataSource removeLastObject];
                if (self.reloadTableHandler) {
                    self.reloadTableHandler();
                }
            }
            return NO;
        }
        WXMessageViewModel *vm = [self viewModelWithMessage:msg];
        [self.dataSource replaceObjectAtIndex:(self.dataSource.count - 1) withObject:vm];
        if (self.reloadRowHandler) {
            self.reloadRowHandler(self.dataSource.count - 1);
        }
        if (self.didSendViewModelHandler) {
            self.didSendViewModelHandler(@[vm]);
        }
    } else {
        /// 发送消息
        WXMessage *msg = [WXMessage createVoiceMsg:nil isMine:isMine session:self.session];
        if (!msg) return NO;
        WXMessageViewModel *vm = [self viewModelWithMessage:msg];
        vm.allowsPlaySound = NO;
        [self.dataSource addObject:vm];
        if (self.didInsertViewModelHandler) {
            self.didInsertViewModelHandler(@[vm]);
        }
        if (self.didSendViewModelHandler) {
            self.didSendViewModelHandler(@[vm]);
        }
    }
    return YES;
}

- (BOOL)cancelVoiceMsg {
    if (self.dataSource.count <= 0) return NO;
    WXMessageViewModel *viewModel = [self.dataSource lastObject];
    if (viewModel.message.type != WXVoiceMessage) return NO;
    if (self.dataSource.count > 1 && self.scrollRowToBottomHandler) {
        self.scrollRowToBottomHandler(self.dataSource.count - 2, YES);
        dispatch_after_main(.3f, ^{
            [self.dataSource removeLastObject];
            if (self.reloadTableHandler) {
                self.reloadTableHandler();
            }
        });
    } else {
        [self.dataSource removeLastObject];
        if (self.reloadTableHandler) {
            self.reloadTableHandler();
        }
    }
    return YES;
}

- (BOOL)updateVoiceModel:(WXVoiceMessageViewModel *)viewModel {
    BOOL isPlaying = viewModel.isPlaying;
    if (self.player.user_info) {
        // 说明有语音在播放中
        [self.player pause];
    }
    // 此时状态改变, 说明操作播放器时已刷新模型
    if (viewModel.isPlaying != isPlaying) return YES;
    // 此时还在播放, 说明视图模型状态有误
    if (viewModel.isPlaying) {
        [self updateVoiceModel:viewModel withPlayState:NO];
        return YES;
    }
    // 播放
    WXFileModel *fileModel = viewModel.message.fileModel;
    if (fileModel.filePath.length <= 0) return NO;
    self.player.playURLs = @[[NSURL fileURLWithPath:fileModel.filePath]];
    self.player.user_info = viewModel; //绑定视图模型
    [self.player play];
    return YES;
}

- (BOOL)sendVideoMsg:(NSString *)videoPath isMine:(BOOL)isMine {
    if (videoPath.length <= 0) return NO;
    WXMessage *msg = [WXMessage createVideoMsg:videoPath isMine:isMine session:self.session];
    if (!msg) return NO;
    WXVideoMessageViewModel *viewModel = (WXVideoMessageViewModel *)[self viewModelWithMessage:msg];
    viewModel.state = WXVideoMessageStateUpdating;
    [self.dataSource addObject:viewModel];
    if (self.didInsertViewModelHandler) {
        self.didInsertViewModelHandler(@[viewModel]);
    }
    if (self.didSendViewModelHandler) {
        self.didSendViewModelHandler(@[viewModel]);
    }
    return YES;
}

- (BOOL)sendCardMsg:(WXUser *)user text:(NSString *)text isMine:(BOOL)isMine {
    NSArray <WXMessage *>*msgs = [WXMessage createCardMsg:user text:text isMine:isMine session:self.session];
    if (msgs.count <= 0) return NO;
    NSMutableArray <WXMessageViewModel *>*viewModels = @[].mutableCopy;
    [msgs enumerateObjectsUsingBlock:^(WXMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXMessageViewModel *vm = [self viewModelWithMessage:obj];
        [self.dataSource addObject:vm];
        [viewModels addObject:vm];
    }];
    if (self.didInsertViewModelHandler) {
        self.didInsertViewModelHandler(viewModels.copy);
    }
    if (self.didSendViewModelHandler) {
        self.didSendViewModelHandler(viewModels.copy);
    }
    return YES;
}

- (BOOL)sendCallMsg:(NSString *)desc isVideo:(BOOL)isVideo isMine:(BOOL)isMine {
    WXMessage *msg = [WXMessage createCallMsg:desc isVideo:isVideo isMine:isMine session:self.session];
    if (!msg) return NO;
    WXMessageViewModel *viewModel = [self viewModelWithMessage:msg];
    viewModel.allowsPlaySound = NO;
    [self.dataSource addObject:viewModel];
    if (self.didInsertViewModelHandler) {
        self.didInsertViewModelHandler(@[viewModel]);
    }
    if (self.didSendViewModelHandler) {
        self.didSendViewModelHandler(@[viewModel]);
    }
    return YES;
}

- (void)stopPlaying {
    if (!_player || !_player.isPlaying) return;
    [_player pause];
}

#pragma mark - Update
- (BOOL)updateViewModel:(WXMessageViewModel *)viewModel {
    if ([viewModel isKindOfClass:WXVoiceMessageViewModel.class]) {
        return [self updateVoiceModel:kTransform(WXVoiceMessageViewModel *, viewModel)];
    } else if ([viewModel update]) {
        NSInteger row = [self.dataSource indexOfObject:viewModel];
        if (self.reloadRowHandler) {
            self.reloadRowHandler(row);
        }
        if (viewModel.message.type == WXTransferMessage) {
            /// 转账消息更新
            WXRedpacket *redpacket = kTransform(WXRedpacket *, viewModel.message.fileModel.content);
            [self sendTransferMsg:redpacket.text money:redpacket.money time:redpacket.create_time isMine:!redpacket.isMine isUpdate:YES];
        }
        return YES;
    }
    return NO;
}

#pragma mark - Tip
- (void)deleteViewModel:(WXMessageViewModel *)viewModel {
    // 停止音频播放
    if (viewModel.message.type == WXVoiceMessage && _player.isPlaying && _player.user_info == viewModel) {
        [self stopPlaying];
    }
    // 检索非转文字消息
    NSArray <WXMessageViewModel *>*result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.message.type != %ld", WXTurnMessage]];
    if (![result containsObject:viewModel]) return;
    // 替换会话消息标识并展示下一条消息时间
    WXSession *session = self.session;
    WXMessage *message = viewModel.message;
    NSInteger index = [result indexOfObject:viewModel];
    if (result.count == 1) {
        [session setValue:nil forKey:sql_field(session.desc)];
        [session setValue:nil forKey:sql_field(session.latest)];
        [session setValue:nil forKey:sql_field(session.message)];
        [session setValue:nil forKey:sql_field(session.identifier)];
    } else {
        if (index < result.count - 1) {
            WXMessageViewModel *vm = result[index + 1];
            WXMessage *msg = vm.message;
            if (msg.show_time == NO) {
                msg.show_time = YES;
                [vm layoutSubviews];
                [MNDatabase updateTable:session.table_name where:@{sql_field(msg.identifier):sql_pair(msg.identifier)}.sqlQueryValue model:msg completion:nil];
            }
        } else {
            WXMessageViewModel *vm = result[index - 1];
            session.desc = vm.message.desc;
            session.latest = vm.message.identifier;
            if (message.show_time) session.timestamp = vm.message.timestamp;
            [session setValue:vm.message forKey:sql_field(session.message)];
            [MNDatabase updateTable:WXSessionTableName where:@{sql_field(session.identifier):sql_pair(session.identifier)}.sqlQueryValue model:session completion:^(BOOL succeed) {
                dispatch_async_main(^{
                    @PostNotify(WXSessionTableReloadNotificationName, nil);
                });
            }];
        }
    }
    // 删除与此消息关联的转文字消息
    index = [self.dataSource indexOfObject:viewModel];
    NSMutableArray <WXMessageViewModel *>*deletes = @[].mutableCopy;
    [deletes addObject:viewModel];
    if (message.type == WXVoiceMessage && index < self.dataSource.count - 1) {
        WXMessageViewModel *vm = self.dataSource[index + 1];
        if (vm.message.type == WXTurnMessage) {
            [deletes addObject:vm];
        }
    }
    [self.dataSource removeObjectsInArray:deletes];
    [MNDatabase deleteRowFromTable:session.table_name where:@{sql_field(message.identifier):sql_pair(message.identifier)}.sqlQueryValue completion:nil];
    if (message.fileModel && [message.fileModel respondsToSelector:@selector(removeContentsAtFile)]) {
        [message.fileModel removeContentsAtFile];
    }
    if (self.reloadTableHandler) self.reloadTableHandler();
}

- (BOOL)collectViewModel:(WXMessageViewModel *)viewModel {
    WXMessage *message = viewModel.message;
    if (!message) return NO;
    WXFavorite *favorite;
    if (message.type == WXTextMessage) {
        favorite = [WXFavorite favoriteWithText:message.content];
    } else if (message.type == WXImageMessage || message.type == WXEmotionMessage) {
        favorite = [WXFavorite favoriteWithImagePath:message.fileModel.filePath];
    } else if (message.type == WXVideoMessage) {
        favorite = [WXFavorite favoriteWithVideoPath:message.fileModel.filePath];
    } else if (message.type == WXLocationMessage) {
        favorite = [WXFavorite favoriteWithLocation:message.fileModel.content];
    } else if (message.type == WXWebpageMessage) {
        favorite = [WXFavorite favoriteWithWebpage:message.fileModel.content];
    }
    if (!favorite) return NO;
    favorite.uid = message.uid;
    return [[MNDatabase database] insertToTable:WXFavoriteTableName model:favorite];
}

- (BOOL)forwardViewModel:(WXMessageViewModel *)viewModel user:(WXUser *)user {
    WXSession *session = [WXSession sessionForUser:user];
    if (!session) return NO;
    WXMessage *message;
    switch (viewModel.message.type) {
        case WXTextMessage:
        case WXImageMessage:
        case WXEmotionMessage:
        case WXLocationMessage:
        case WXWebpageMessage:
        {
            message = [WXMessage createLocationMsg:message.fileModel.content isMine:YES session:session];
        } break;
        case WXVideoMessage:
        case WXVoiceMessage:
        {
            message = [WXMessage createVideoMsg:viewModel.message.fileModel.filePath isMine:YES session:session];
        } break;
        default:
            break;
    }
    if (message) {
        [MNDatabase updateTable:WXSessionTableName where:@{sql_field(session.identifier):sql_pair(session.identifier)}.sqlQueryValue model:session completion:^(BOOL succeed) {
            if (succeed) {
                dispatch_async_main(^{
                    @PostNotify(WXSessionTableReloadNotificationName, nil);
                });
            }
        }];
    }
    return message != nil;
}

#if __has_include(<Speech/Speech.h>)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (BOOL)turnTextForViewModel:(WXMessageViewModel *)viewModel {
    // 判断是否支持语音转文字
    WXMessage *message = viewModel.message;
    if (message.type != WXVoiceMessage || message.fileModel.filePath.length <= 0) return NO;
    if (![self.dataSource containsObject:viewModel]) return NO;
    // 关闭交互
    if (self.userInteractionHandler) self.userInteractionHandler(NO);
    // 插入新视图模型
    NSInteger index = [self.dataSource indexOfObject:viewModel];
    WXMessageViewModel *vm = [self viewModelWithMessage:[WXMessage createTurnMsg:nil isMine:message.isMine]];
    [self.dataSource insertObject:vm atIndex:index + 1];
    if (self.reloadTableHandler) self.reloadTableHandler();
    if (self.scrollRowToVisibleHandler) self.scrollRowToBottomHandler(index + 1, NO);
    // 开始转文字
    SFSpeechURLRecognitionRequest *request = [[SFSpeechURLRecognitionRequest alloc] initWithURL:[NSURL fileURLWithPath:message.fileModel.filePath]];
    SFSpeechRecognizer *recognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    recognizer.queue = NSOperationQueue.new;
    __weak typeof(self) weakself = self;
    [recognizer recognitionTaskWithRequest:request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 关闭动画
                vm.message.user_info = @(NO);
                [vm layoutSubviews];
                if (weakself.reloadRowHandler) self.reloadRowHandler(index + 1);
                // 删除失败项
                [weakself.dataSource removeObject:vm];
                if (weakself.reloadTableHandler) weakself.reloadTableHandler();
                // 开启交互
                if (weakself.userInteractionHandler) weakself.userInteractionHandler(YES);
            });
            return;
        }
        BOOL isFinal = result.isFinal;
        NSString *string = result.bestTranscription.formattedString;
        dispatch_async(dispatch_get_main_queue(), ^{
            vm.message.content = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
            [vm layoutSubviews];
            if (weakself.reloadRowHandler) weakself.reloadRowHandler(index + 1);
            if (weakself.scrollRowToVisibleHandler) weakself.scrollRowToBottomHandler(index + 1, NO);
            if (isFinal && weakself.userInteractionHandler) weakself.userInteractionHandler(YES);
        });
    }];
    return YES;
}

- (void)hideTurnTextForViewModel:(WXMessageViewModel *)viewModel {
    if (![self.dataSource containsObject:viewModel]) return;
    [self.dataSource removeObject:viewModel];
    if (self.reloadTableHandler) self.reloadTableHandler();
}
#pragma clang diagnostic pop
#endif

#pragma mark - Getter
- (NSMutableArray <WXMessageViewModel *>*)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:1];
    }
    return _dataSource;
}

- (MNPlayer *)player {
    if (!_player) {
        MNPlayer *player = [MNPlayer new];
        player.delegate = self;
        player.playbackEnabled = NO;
        _player = player;
    }
    return _player;
}

#pragma mark - MNPlayerDelegate
- (void)playerDidChangeState:(MNPlayer *)player {
    WXVoiceMessageViewModel *viewModel = player.user_info;
    if (!viewModel) return;
    if (player.state == MNPlayerStatePlaying) {
        [self updateVoiceModel:viewModel withPlayState:YES];
    } else {
        player.user_info = nil;
        [player removeAllURLs];
        [self updateVoiceModel:viewModel withPlayState:NO];
    }
}

- (void)updateVoiceModel:(WXVoiceMessageViewModel *)viewModel withPlayState:(BOOL)playState {
    viewModel.playing = playState;
    if ([self.dataSource containsObject:viewModel] && self.reloadRowHandler) {
        self.reloadRowHandler([self.dataSource indexOfObject:viewModel]);
    }
}

@end
