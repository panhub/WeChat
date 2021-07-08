//
//  WXMessage.m
//  WeChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMessage.h"
#import "WXSession.h"
#import "WXChangeModel.h"
#import "WXFileModel.h"
#import "WXWebpage.h"
#import "WXLocation.h"
#import "WXMsg.h"

@interface WXMessage ()

@end

@implementation WXMessage
@synthesize user = _user;
@synthesize fileModel = _fileModel;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.identifier = NSString.identifier;
    }
    return self;
}

#pragma mark - Msg
+ (instancetype)createInitialMessageWithSession:(WXSession *)session {
    WXMessage *msg = [WXMessage new];
    msg.timestamp = NSDate.shortTimestamps;
    msg.content = [NSString stringWithFormat:@"你已添加了%@，现在可以开始聊天了。", session.user.name ? : @""];
    msg.type = WXInitialMessage;
    msg.desc = msg.content;
    msg.uid = session.uid;
    msg.show_time = YES;
    if ([MNDatabase.database insertToTable:session.table_name model:msg]) {
        session.desc = msg.content;
        session.latest = msg.identifier;
        session.timestamp = msg.timestamp;
        [session setValue:msg forKey:sql_field(session.message)];
        return msg;
    }
    return nil;
}

+ (instancetype)createTextMsg:(NSString *)content isMine:(BOOL)isMine session:(WXSession *)session {
    if (content.length <= 0 || session.table_name.length <= 0) return nil;
    WXMessage *msg = [WXMessage new];
    msg.timestamp = NSDate.shortTimestamps;
    msg->_user = isMine ? WXUser.shareInfo : session.user;
    msg.uid = msg.user.uid;
    msg.content = content;
    msg.type = WXTextMessage;
    msg.desc = content;
    msg.mine = isMine;
    msg.show_time = msg.timestamp.integerValue - session.timestamp.integerValue > WXMsgTimeInterval;
    if ([MNDatabase.database insertToTable:session.table_name model:msg]) {
        if (msg.show_time) session.timestamp = msg.timestamp;
        session.desc = content;
        session.latest = msg.identifier;
        [session setValue:msg forKey:sql_field(session.message)];
        return msg;
    }
    return nil;
}

+ (instancetype)createImageMsg:(UIImage *)image isMine:(BOOL)isMine session:(WXSession *)session {
    if (!image || session.table_name.length <= 0) return nil;
    WXFileModel *fileModel = [WXFileModel fileWithImage:image session:session.identifier];
    if (!fileModel) return nil;
    WXMessage *msg = [WXMessage new];
    msg.identifier = fileModel.identifier;
    msg.timestamp = NSDate.shortTimestamps;
    msg->_user = isMine ? WXUser.shareInfo : session.user;
    msg.uid = msg.user.uid;
    msg.profile = fileModel.archivedData;
    msg->_fileModel = fileModel;
    msg.type = WXImageMessage;
    msg.desc = @"[图片]";
    msg.mine = isMine;
    msg.show_time = msg.timestamp.integerValue - session.timestamp.integerValue > WXMsgTimeInterval;
    if ([MNDatabase.database insertToTable:session.table_name model:msg]) {
        if (msg.show_time) session.timestamp = msg.timestamp;
        session.desc = msg.desc;
        session.latest = msg.identifier;
        [session setValue:msg forKey:sql_field(session.message)];
        return msg;
    }
    return nil;
}

+ (instancetype)createEmotionMsg:(UIImage *)image isMine:(BOOL)isMine session:(WXSession *)session {
    if (!image || session.table_name.length <= 0) return nil;
    WXFileModel *fileModel = [WXFileModel fileWithImage:image session:session.identifier];
    if (!fileModel) return nil;
    WXMessage *msg = [WXMessage new];
    msg.identifier = fileModel.identifier;
    msg.timestamp = NSDate.shortTimestamps;
    msg->_user = isMine ? WXUser.shareInfo : session.user;
    msg.uid = msg.user.uid;
    msg.profile = fileModel.archivedData;
    msg->_fileModel = fileModel;
    msg.type = WXEmotionMessage;
    msg.desc = @"[表情]";
    msg.mine = isMine;
    msg.show_time = msg.timestamp.integerValue - session.timestamp.integerValue > WXMsgTimeInterval;
    if ([MNDatabase.database insertToTable:session.table_name model:msg]) {
        if (msg.show_time) session.timestamp = msg.timestamp;
        session.desc = msg.desc;
        session.latest = msg.identifier;
        [session setValue:msg forKey:sql_field(session.message)];
        return msg;
    }
    return nil;
}

+ (instancetype)createLocationMsg:(WXLocation *)location isMine:(BOOL)isMine session:(WXSession *)session {
    if (!location || session.table_name.length <= 0) return nil;
    MNReplacingEmptyStringWith(location.name, @"未知位置名称")
    WXFileModel *fileModel = [WXFileModel fileWithObject:location session:session.identifier];
    if (!fileModel) return nil;
    WXMessage *msg = [WXMessage new];
    msg.identifier = fileModel.identifier;
    msg.timestamp = NSDate.shortTimestamps;
    msg->_user = isMine ? WXUser.shareInfo : session.user;
    msg.uid = msg.user.uid;
    msg.profile = fileModel.archivedData;
    msg->_fileModel = fileModel;
    msg.type = WXLocationMessage;
    msg.desc = @"[位置]";
    msg.mine = isMine;
    msg.show_time = msg.timestamp.integerValue - session.timestamp.integerValue > WXMsgTimeInterval;
    if ([MNDatabase.database insertToTable:session.table_name model:msg]) {
        if (msg.show_time) session.timestamp = msg.timestamp;
        session.desc = msg.desc;
        session.latest = msg.identifier;
        [session setValue:msg forKey:sql_field(session.message)];
        return msg;
    }
    return nil;
}

+ (instancetype)createWebpageMsg:(WXWebpage *)webpage isMine:(BOOL)isMine session:(WXSession *)session {
    if (!webpage) return nil;
    WXFileModel *fileModel = [WXFileModel fileWithObject:webpage session:session.identifier];
    if (!fileModel) return nil;
    WXMessage *msg = [WXMessage new];
    msg.identifier = fileModel.identifier;
    msg.timestamp = NSDate.shortTimestamps;
    msg->_user = isMine ? WXUser.shareInfo : session.user;
    msg.uid = msg.user.uid;
    msg.profile = fileModel.archivedData;
    msg->_fileModel = fileModel;
    msg.type = WXWebpageMessage;
    msg.desc = [NSString stringWithFormat:@"[链接] %@", [NSString replacingEmptyCharacters:webpage.url]];
    msg.content = msg.desc;
    msg.mine = isMine;
    msg.show_time = msg.timestamp.integerValue - session.timestamp.integerValue > WXMsgTimeInterval;
    if ([MNDatabase.database insertToTable:session.table_name model:msg]) {
        if (msg.show_time) session.timestamp = msg.timestamp;
        session.desc = msg.desc;
        session.latest = msg.identifier;
        [session setValue:msg forKey:sql_field(session.message)];
        return msg;
    }
    return nil;
}

+ (instancetype)createRedpacketMsg:(NSString *)text money:(NSString *)money isMine:(BOOL)isMine session:(WXSession *)session {
    if (money.length <= 0 || session.table_name.length <= 0) return nil;
    /// 红包数据
    WXRedpacket *redpacket = [WXRedpacket new];
    redpacket.mine = isMine;
    redpacket.from_uid = isMine ? [WXUser.shareInfo uid] : session.user.uid;
    redpacket.to_uid = isMine ? session.user.uid : [WXUser.shareInfo uid];
    redpacket.money = money;
    redpacket.text = text;
    redpacket.create_time = [NSDate timestamps];
    redpacket.type = @"微信红包";
    WXFileModel *fileModel = [WXFileModel fileWithObject:redpacket session:session.identifier];
    if (!fileModel) return nil;
    /// 交易记录
    if (isMine) {
        WXChangeModel *change = [WXChangeModel new];
        change.title = text.length > 0 ? text : @"微信红包";
        change.money = opposite(money.floatValue);
        change.timestamp = redpacket.create_time;
        change.type = @"支出";
        change.channel = WXChangeChannelRedpacket;
        change.note = text.length > 0 ? text : @"微信红包";
        change.uid = redpacket.to_uid;
        [MNDatabase insertToTable:WXChangeTableName model:change completion:^(BOOL succeed) {
            if (succeed) {
                dispatch_async_default(^{
                    @PostNotify(WXChangeUpdateNotificationName, nil);
                });
            }
        }];
    }
    /// 消息
    WXMessage *msg = [WXMessage new];
    msg.timestamp = NSDate.shortTimestamps;
    msg.identifier = fileModel.identifier;
    msg->_user = isMine ? WXUser.shareInfo : session.user;
    msg.uid = msg.user.uid;
    msg.profile = fileModel.archivedData;
    msg->_fileModel = fileModel;
    msg.content = text;
    msg.type = WXRedpacketMessage;
    msg.desc = @"[红包]";
    msg.mine = isMine;
    msg.show_time = msg.timestamp.integerValue - session.timestamp.integerValue > WXMsgTimeInterval;
    if ([MNDatabase.database insertToTable:session.table_name model:msg]) {
        if (msg.show_time) session.timestamp = msg.timestamp;
        session.desc = msg.desc;
        session.latest = msg.identifier;
        [session setValue:msg forKey:sql_field(session.message)];
        return msg;
    }
    return nil;
}

+ (instancetype)createTransferMsg:(NSString *)text money:(NSString *)money time:(NSString *)time isMine:(BOOL)isMine isUpdate:(BOOL)isUpdate session:(WXSession *)session {
    if (money.length <= 0 || session.table_name.length <= 0) return nil;
    /// 红包数据
    WXRedpacket *redpacket = [WXRedpacket new];
    redpacket.mine = isMine;
    redpacket.open = isUpdate;
    if (isUpdate) {
        redpacket.from_uid = isMine ? session.user.uid : [WXUser.shareInfo uid];
        redpacket.to_uid = isMine ? [WXUser.shareInfo uid] : session.user.uid;
        redpacket.draw_time = [NSDate timestamps];
    } else {
        redpacket.from_uid = isMine ? [WXUser.shareInfo uid] : session.user.uid;
        redpacket.to_uid = isMine ? session.user.uid : [WXUser.shareInfo uid];
    }
    redpacket.money = money;
    redpacket.text = text;
    redpacket.create_time = time;
    redpacket.type = @"微信转账";
    WXFileModel *fileModel = [WXFileModel fileWithObject:redpacket session:session.identifier];
    if (!fileModel) return nil;
    /// 交易记录
    if (!isUpdate && isMine) {
        WXChangeModel *change = [WXChangeModel new];
        change.title = text.length > 0 ? text : @"微信转账";
        change.money = opposite(money.floatValue);
        change.timestamp = redpacket.create_time;
        change.channel = WXChangeChannelTransfer;
        change.type = @"支出";
        change.note = text;
        change.uid = redpacket.to_uid;
        [MNDatabase insertToTable:WXChangeTableName model:change completion:^(BOOL succeed) {
            dispatch_async_default(^{
                if (succeed) {
                    @PostNotify(WXChangeUpdateNotificationName, nil);
                }
            });
        }];
    }
    /// 消息
    WXMessage *msg = [WXMessage new];
    msg.timestamp = NSDate.shortTimestamps;
    msg.identifier = fileModel.identifier;
    msg->_user = isMine ? WXUser.shareInfo : session.user;
    msg.uid = msg.user.uid;
    msg.profile = fileModel.archivedData;
    msg->_fileModel = fileModel;
    msg.content = text;
    msg.type = WXTransferMessage;
    msg.mine = isMine;
    if (isUpdate) {
        msg.desc = isMine ? @"[转账]已收款" : @"[转账]朋友已确认收款";
    } else {
        msg.desc = isMine ? @"[转账]待确认收款" : @"[转账]请你确认收款";
    }
    msg.show_time = msg.timestamp.integerValue - session.timestamp.integerValue > WXMsgTimeInterval;
    if ([MNDatabase.database insertToTable:session.table_name model:msg]) {
        if (msg.show_time) session.timestamp = msg.timestamp;
        session.desc = msg.desc;
        session.latest = msg.identifier;
        [session setValue:msg forKey:sql_field(session.message)];
        return msg;
    }
    return nil;
}

+ (instancetype)createVoiceMsg:(NSString *)voicePath isMine:(BOOL)isMine session:(WXSession *)session {
    WXMessage *msg = [WXMessage new];
    msg.timestamp = NSDate.shortTimestamps;
    msg.identifier = NSDate.shortTimestamps;
    msg->_user = isMine ? WXUser.shareInfo : session.user;
    msg.uid = msg.user.uid;
    msg.type = WXVoiceMessage;
    msg.desc = @"[语音]";
    msg.content = @"[语音]";
    msg.mine = isMine;
    msg.show_time = msg.timestamp.integerValue - session.timestamp.integerValue > WXMsgTimeInterval;
    if (voicePath.length) {
        WXFileModel *fileModel = [WXFileModel fileWithAudio:voicePath session:session.identifier];
        if (!fileModel) return nil;
        msg.identifier = fileModel.identifier;
        msg.profile = fileModel.archivedData;
        msg->_fileModel = fileModel;
        if (session.table_name.length && [MNDatabase.database insertToTable:session.table_name model:msg]) {
            if (msg.show_time) session.timestamp = msg.timestamp;
            session.desc = msg.desc;
            session.latest = msg.identifier;
            [session setValue:msg forKey:sql_field(session.message)];
            return msg;
        }
        return nil;
    }
    return msg;
}

+ (instancetype)createTurnMsg:(NSString *)message isMine:(BOOL)isMine {
    WXMessage *msg = [WXMessage new];
    msg.timestamp = NSDate.shortTimestamps;
    msg.identifier = NSDate.shortTimestamps;
    msg.type = WXTurnMessage;
    msg.desc = message;
    msg.content = message;
    msg.user_info = @(YES);
    msg.mine = isMine;
    msg.show_time = NO;
    return msg;
}

+ (instancetype)createVideoMsg:(NSString *)videoPath isMine:(BOOL)isMine session:(WXSession *)session {
    if (videoPath.length <= 0 || session.table_name.length <= 0) return nil;
    WXFileModel *fileModel = [WXFileModel fileWithVideo:videoPath session:session.identifier];
    if (!fileModel) return nil;
    WXMessage *msg = [WXMessage new];
    msg.timestamp = NSDate.shortTimestamps;
    msg.identifier = fileModel.identifier;
    msg->_user = isMine ? WXUser.shareInfo : session.user;
    msg.uid = msg.user.uid;
    msg.type = WXVideoMessage;
    msg.desc = @"[视频]";
    msg.content = @"[视频]";
    msg.mine = isMine;
    msg.profile = fileModel.archivedData;
    msg->_fileModel = fileModel;
    msg.show_time = msg.timestamp.integerValue - session.timestamp.integerValue > WXMsgTimeInterval;
    if ([MNDatabase.database insertToTable:session.table_name model:msg]) {
        if (msg.show_time) session.timestamp = msg.timestamp;
        session.desc = msg.desc;
        session.latest = msg.identifier;
        [session setValue:msg forKey:sql_field(session.message)];
        return msg;
    }
    return nil;
}

+ (NSArray <WXMessage *>*)createCardMsg:(WXUser *)user text:(NSString *)text isMine:(BOOL)isMine session:(WXSession *)session {
    if (!user || !session) return nil;
    WXFileModel *fileModel = [WXFileModel fileWithObject:user session:session.identifier];
    if (!fileModel) return nil;
    NSMutableArray <WXMessage *>*msgs = @[].mutableCopy;
    WXMessage *cardMsg = WXMessage.new;
    cardMsg.identifier = fileModel.identifier;
    cardMsg.timestamp = NSDate.shortTimestamps;
    cardMsg.type = WXCardMessage;
    cardMsg.mine = isMine;
    cardMsg->_user = isMine ? WXUser.shareInfo : session.user;
    cardMsg.uid = cardMsg.user.uid;
    cardMsg.profile = fileModel.archivedData;
    cardMsg->_fileModel = fileModel;
    cardMsg.desc = @"[名片]";
    cardMsg.show_time = cardMsg.timestamp.integerValue - session.timestamp.integerValue > WXMsgTimeInterval;
    if ([MNDatabase.database insertToTable:session.table_name model:cardMsg]) {
        if (cardMsg.show_time) session.timestamp = cardMsg.timestamp;
        session.desc = cardMsg.desc;
        session.latest = cardMsg.identifier;
        [session setValue:cardMsg forKey:sql_field(session.message)];
        [msgs addObject:cardMsg];
        WXMessage *textMsg = [WXMessage createTextMsg:text isMine:isMine session:session];
        if (textMsg) [msgs addObject:textMsg];
        return msgs.copy;
    }
    return nil;
}

+ (instancetype)createCallMsg:(NSString *)desc isVideo:(BOOL)isVideo isMine:(BOOL)isMine session:(WXSession *)session {
    if (desc.length <= 0 || session.table_name.length <= 0) return nil;
    WXMessage *msg = [WXMessage new];
    msg.timestamp = NSDate.shortTimestamps;
    msg->_user = isMine ? WXUser.shareInfo : session.user;
    msg.uid = msg.user.uid;
    msg.content = desc;
    msg.type = isVideo ? WXVideoCallMessage : WXVoiceCallMessage;
    msg.desc = isVideo ? @"[视频通话]" : @"[语音通话]";
    msg.mine = isMine;
    msg.show_time = msg.timestamp.integerValue - session.timestamp.integerValue > WXMsgTimeInterval;
    if ([MNDatabase.database insertToTable:session.table_name model:msg]) {
        if (msg.show_time) session.timestamp = msg.timestamp;
        session.desc = msg.desc;
        session.latest = msg.identifier;
        [session setValue:msg forKey:sql_field(session.message)];
        return msg;
    }
    return nil;
}

#pragma mark - Update
- (BOOL)update {
    WXRedpacket *redpacket;
    if (self.type == WXRedpacketMessage) {
        /// 红包
        redpacket = kTransform(WXRedpacket *, self.fileModel.content).copy;
        if (!redpacket || redpacket.isOpen) return NO;
        redpacket.open = YES;
        redpacket.draw_time = [NSDate timestamps];
        /// 零钱记录
        if (redpacket.isMine == NO) {
            WXChangeModel *change = [WXChangeModel new];
            change.title = @"微信红包";
            change.money = redpacket.money.floatValue;
            change.timestamp = redpacket.draw_time;
            change.channel = WXChangeChannelRedpacket;
            change.type = @"收入";
            change.note = redpacket.text.length > 0 ? redpacket.text : @"微信红包";
            change.uid = redpacket.from_uid;
            [MNDatabase insertToTable:WXChangeTableName model:change completion:^(BOOL succeed) {
                dispatch_async_default(^{
                    if (succeed) {
                        @PostNotify(WXChangeUpdateNotificationName, nil);
                    }
                });
            }];
        }
        return [self.fileModel replaceContentWithObject:redpacket];
    } else if (self.type == WXTransferMessage) {
        /// 转账
        redpacket = kTransform(WXRedpacket *, self.fileModel.content).copy;
        if (!redpacket || redpacket.isOpen) return NO;
        redpacket.open = YES;
        if (redpacket.draw_time.length <= 0) {
            redpacket.draw_time = [NSDate timestamps];
            /// 插入零钱记录, 领取时间有值, 说明已在领取时插入
            /// 判读 isMine 只有自己収钱时才插入零钱记录
            if (redpacket.isMine == NO) {
                WXChangeModel *change = [WXChangeModel new];
                change.title = @"微信转账";
                change.money = redpacket.money.floatValue;
                change.timestamp = redpacket.draw_time;
                change.channel = WXChangeChannelTransfer;
                change.type = @"收入";
                change.note = redpacket.text;
                change.uid = redpacket.from_uid;
                [MNDatabase insertToTable:WXChangeTableName model:change completion:^(BOOL succeed) {
                    dispatch_async_default(^{
                        if (succeed) {
                            @PostNotify(WXChangeUpdateNotificationName, nil);
                        }
                    });
                }];
            }
        }
        return [self.fileModel replaceContentWithObject:redpacket];
    }
    return NO;
}

#pragma mark - Getter
- (WXUser *)user {
    if (!_user && self.uid.length > 0) {
        _user = [[WechatHelper helper] userForUid:self.uid];
    }
    return _user;
}

- (WXFileModel *)fileModel {
    if (!_fileModel && _profile.length > 0) {
        _fileModel = _profile.unarchivedObject;
    }
    return _fileModel;
}

@end
