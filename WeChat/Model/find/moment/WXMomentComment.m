//
//  WXMomentComment.m
//  MNChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentComment.h"

@implementation WXMomentComment
{
    WXUser *_from_user;
    WXUser *_to_user;
}

#pragma mark - Getter
- (WXUser *)from_user {
    if (!_from_user && _from_uid.length > 0) {
        _from_user = [[WechatHelper helper] userForUid:_from_uid];
    }
    return _from_user;
}

- (WXUser *)to_user {
    if (!_to_user && _to_uid.length > 0) {
        _to_user = [[WechatHelper helper] userForUid:_to_uid];
    }
    return _to_user;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    WXMomentComment *comment = [WXMomentComment allocWithZone:zone];
    comment.identifier = self.identifier;
    comment.from_uid = self.from_uid;
    comment.to_uid = self.to_uid;
    comment.content = self.content;
    comment.date = self.date;
    comment->_from_user = self->_from_user;
    comment->_to_user = self->_to_user;
    return comment;
}

@end
