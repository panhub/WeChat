//
//  WXChatViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChatViewModel.h"
#import "WXVoiceMessageViewModel.h"
#import "WXVideoMessageViewModel.h"
#import "WXSession.h"
#import "WXMessage.h"
#import "WXMapLocation.h"
#import "WXFileModel.h"

@interface WXChatViewModel () <MNPlayerDelegate>
/// 播放器
@property (nonatomic, strong) MNPlayer *player;
@end

#define WXChatListRequestPageCount  15

@implementation WXChatViewModel
- (instancetype)initWithSession:(WXSession *)session {
    if (self = [super init]) {
        self.session = session;
    }
    return self;
}

- (void)loadData {
    dispatch_async_default(^{
        NSInteger count = [MNDatabase.database selectCountFromTable:self.session.list where:nil];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY timestamp DESC LIMIT %@, %@", self.session.list, @(self.dataSource.count), @(WXChatListRequestPageCount)];
        NSArray <WXMessage *>*rows = [MNDatabase.database selectRowsModelFromTable:self.session.list sql:sql class:WXMessage.class];
        dispatch_async_main(^{
            if (rows.count > 0) {
                NSMutableArray <WXMessageViewModel *>*listArray = [NSMutableArray arrayWithCapacity:rows.count];
                [rows.reversedArray enumerateObjectsUsingBlock:^(WXMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [listArray addObject:[self viewModelWithMessage:obj]];
                }];
                [self.dataSource insertObjects:listArray atIndex:0];
                if (self.reloadTableHandler) self.reloadTableHandler();
                if (self.dataSource.count == rows.count) {
                    /// 第一次加载
                    if (self.scrollRowToBottomHandler) {
                        self.scrollRowToBottomHandler((self.dataSource.count - 1), self.dataSource.count < WXChatListRequestPageCount);
                    }
                }
            }
            if (self.didLoadFinishHandler) self.didLoadFinishHandler(self.dataSource.count >= count);
        });
    });
}

- (WXMessageViewModel *)viewModelWithMessage:(WXMessage *)message {
    WXMessageViewModel *viewModel = [WXMessageViewModel viewModelWithMessage:message];
    viewModel.textLabelClickedHandler = self.textLabelClickedHandler;
    viewModel.imageViewClickedHandler = self.imageViewClickedHandler;
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

- (BOOL)sendLocationMsg:(WXMapLocation *)location isMine:(BOOL)isMine {
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

- (BOOL)sendWebpage:(WXWebpage *)webpage isMine:(BOOL)isMine {
    WXMessage *msg = [WXMessage createWebpageMsg:webpage isMine:isMine session:self.session];
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
    if (viewModel.message.type != WXVoiceMessage || viewModel.message.file.length <= 0) return NO;
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
    [self.player removeAllURLs];
    [self.player addURL:[NSURL fileURLWithPath:fileModel.filePath]];
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

- (void)pauseVoicePlay {
    if (!_player || !_player.isPlaying) return;
    [_player pause];
}

#pragma mark - Update
- (BOOL)updateViewModel:(WXMessageViewModel *)viewModel {
    if ([viewModel isKindOfClass:WXVoiceMessageViewModel.class]) {
        return [self updateVoiceModel:kTransform(WXVoiceMessageViewModel *, viewModel)];
    } else if ([viewModel setNeedsUpdateSubviews]) {
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
