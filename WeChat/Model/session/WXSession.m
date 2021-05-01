//
//  WXSession.m
//  WeChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXSession.h"
#import "WXMessage.h"

@interface WXSession ()
@property (nonatomic, strong) WXUser *user;
@property (nonatomic, strong) WXMessage *message;
@end

@implementation WXSession
- (instancetype)init {
    if (self = [super init]) {
        self.mute = NO;
        self.front = NO;
        self.unread_count = 0;
        self.type = WXSessionTypeSingle;
        self.identifier = [NSDate shortTimestamps];
        self.timestamp = @"0";
        self.table_name = [@"t_" stringByAppendingString:self.identifier];
    }
    return self;
}

+ (instancetype)sessionForUser:(WXUser *)user {
    if (user.uid.length <= 0) return nil;
    WXSession *session = [[WechatHelper helper] sessionForUid:user.uid];
    if (session) {
        session.user = user;
        session.uid = user.uid;
    } else {
        session = [WXSession new];
        session.user = user;
        session.uid = user.uid;
        if ([MNDatabase.database insertToTable:WXSessionTableName model:session]) {
            if ([MNDatabase.database createTable:session.table_name class:WXMessage.class]) {
                if ([WXMessage createInitialMessageWithSession:session]) {
                    /// 更新会话
                    [MNDatabase updateTable:WXSessionTableName where:@{sql_field(session.identifier):sql_pair(session.identifier)}.sqlQueryValue model:session completion:nil];
                    /// 发送添加会话通知
                    @PostNotify(WXSessionAddNotificationName, session);
                } else {
                    NSString *tableName = session.table_name;
                    [MNDatabase deleteRowFromTable:WXSessionTableName where:@{sql_field(session.identifier):sql_pair(session.identifier)}.sqlQueryValue completion:^(BOOL succeed) {
                        if (succeed) [MNDatabase deleteTable:tableName completion:nil];
                    }];
                    session = nil;
                }
            } else {
                [[MNDatabase database] deleteRowFromTable:WXSessionTableName where:@{sql_field(session.identifier):sql_pair(session.identifier)}.sqlQueryValue];
                session = nil;
            }
        } else {
            session = nil;
        }
    }
    return session;
}

#pragma mark - Getter
- (WXUser *)user {
    if (!_user && self.uid.length) {
        WXUser *user = [[WechatHelper helper] userForUid:self.uid];
        _user = user;
    }
    return _user;
}

- (WXMessage *)message {
    if (!_message && self.latest.length && self.table_name.length) {
        NSArray <WXMessage *>* msgs = [[MNDatabase database] selectRowsModelFromTable:self.table_name where:@{sql_field(self.identifier):sql_pair(self.latest)}.sqlQueryValue limit:NSMakeRange(0, 1) class:WXMessage.class];
        if (msgs.count) _message = msgs.firstObject;
    }
    return _message;
}

@end
