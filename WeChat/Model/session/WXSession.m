//
//  WXSession.m
//  MNChat
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
        self.remind = NO;
        self.front = NO;
        self.unread_count = 0;
        self.type = WXSessionTypeSingle;
        self.identifier = [NSDate shortTimestamps];
        self.timestamp = @"0";
        self.list = [@"t_" stringByAppendingString:self.identifier];
    }
    return self;
}

+ (instancetype)sessionForUser:(WXUser *)user {
    if (user.uid.length <= 0) return nil;
    WXSession *session = [[MNChatHelper helper] sessionForUid:user.uid];
    if (session) {
        session.user = user;
        session.uid = user.uid;
    } else {
        session = [WXSession new];
        session.user = user;
        session.uid = user.uid;
        if ([[MNDatabase sharedInstance] insertIntoTable:WXSessionTableName model:session] && [[MNDatabase sharedInstance] createTable:session.list class:WXMessage.class]) {
            /// 发送添加会话通知
            [MNFileManager createDirectoryAtPath:[MNChatHelper.helper.directoryPath stringByAppendingFormat:@"/%@", session.identifier] error:nil];
            @PostNotify(WXSessionAddNotificationName, session);
        } else {
            session = nil;
        }
    }
    return session;
}

#pragma mark - Getter
- (WXUser *)user {
    if (!_user) {
        WXUser *user = [[MNChatHelper helper] userForUid:self.uid];
        _user = user;
    }
    return _user;
}

- (WXMessage *)message {
    if (!_message && _latest.length > 0 && _list.length > 0) {
        NSArray <WXMessage *>* msgs = [[MNDatabase sharedInstance] selectRowsModelFromTable:_list where:@{@"identifier":_latest}.componentString limit:NSMakeRange(0, 1) class:[WXMessage class]];
        if (msgs.count > 0) {
            _message = [msgs lastObject];
        }
    }
    return _message;
}

@end
