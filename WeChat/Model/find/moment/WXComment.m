//
//  WXComment.m
//  WeChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXComment.h"

@implementation WXComment
{
    WXUser *_fromUser;
    WXUser *_toUser;
}

#pragma mark - Getter
- (WXUser *)fromUser {
    if (!_fromUser && _from_uid.length > 0) {
        _fromUser = [[WechatHelper helper] userForUid:_from_uid];
    }
    return _fromUser;
}

- (WXUser *)toUser {
    if (!_toUser && _to_uid.length > 0) {
        _toUser = [[WechatHelper helper] userForUid:_to_uid];
    }
    return _toUser;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    WXComment *comment = [[self.class allocWithZone:zone] init];
    comment.identifier = self.identifier;
    comment.from_uid = self.from_uid;
    comment.to_uid = self.to_uid;
    comment.content = self.content;
    comment.timestamp = self.timestamp;
    comment.moment = self.moment;
    comment->_fromUser = self->_fromUser;
    comment->_toUser = self->_toUser;
    return comment;
}

#pragma mark - SQL
+ (NSDictionary <NSString *, NSString *>*)sqliteTableFields {
    return @{@"identifier":MNSQLFieldText, @"moment":MNSQLFieldText, @"from_uid":MNSQLFieldText, @"to_uid":MNSQLFieldText, @"content":MNSQLFieldText, @"timestamp":MNSQLFieldText};
}

@end
