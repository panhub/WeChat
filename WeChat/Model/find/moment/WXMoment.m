//
//  WXMoment.m
//  WeChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMoment.h"

@implementation WXMoment
{
    WXUser *_user;
    BOOL _isNewMoment;
    WXWebpage *_webpage;
    NSMutableArray <WXLike *>*_likes;
    NSMutableArray <WXProfile *>*_profiles;
    NSMutableArray <WXComment *>*_comments;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.identifier = NSDate.shortTimestamps;
    }
    return self;
}

- (void)cleanMemory {
    _webpage = nil;
    if (_likes) {
        [_likes removeAllObjects];
        _likes = nil;
    }
    if (_profiles) {
        [_profiles removeAllObjects];
        _profiles = nil;
    }
    if (_comments) {
        [_comments removeAllObjects];
        _comments = nil;
    }
}

- (BOOL)isEqualToMoment:(WXMoment *)moment {
    if ([moment isMemberOfClass:WXMoment.class]) {
        return [moment.identifier isEqualToString:self.identifier];
    }
    return NO;
}

#pragma mark - Getter
- (BOOL)isMine {
    return [_uid isEqualToString:WXUser.shareInfo.uid];
}

- (BOOL)isNewMoment {
    return _isNewMoment;
}

- (WXUser *)user {
    if (!_user && _uid.length > 0) {
        _user = [[WechatHelper helper] userForUid:_uid];
    }
    return _user;
}

- (WXWebpage *)webpage {
    if (!_webpage && _web.length) {
        _webpage = _web.unarchivedObject;
    }
    return _webpage;
}

- (NSMutableArray <WXProfile *>*)profiles {
    if (!_profiles) {
        _profiles = [NSMutableArray array];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE moment = %@ ORDER BY identifier ASC;", WXMomentProfileTableName, sql_pair(self.identifier)];
        NSArray <WXProfile *>*profiles = [MNDatabase.database selectRowsModelFromTable:WXMomentProfileTableName sql:sql class:WXProfile.class];
        if (profiles.count) [_profiles addObjectsFromArray:profiles];
    }
    return _profiles;
}

- (NSMutableArray <WXLike *>*)likes {
    if (!_likes) {
        _likes = @[].mutableCopy;
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE moment = %@ ORDER BY timestamp ASC;", WXMomentLikeTableName, sql_pair(self.identifier)];
        NSArray <WXLike *>*likes = [MNDatabase.database selectRowsModelFromTable:WXMomentLikeTableName sql:sql class:WXLike.class];
        if (likes.count) [_likes addObjectsFromArray:likes];
    }
    return _likes;
}

- (NSMutableArray <WXComment *>*)comments {
    if (!_comments) {
        _comments = [NSMutableArray array];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE moment = %@ ORDER BY timestamp ASC;", WXMomentCommentTableName, sql_pair(self.identifier)];
        NSArray <WXComment *>*comments = [MNDatabase.database selectRowsModelFromTable:WXMomentCommentTableName sql:sql class:WXComment.class];
        if (comments.count) [_comments addObjectsFromArray:comments];
    }
    return _comments;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    WXMoment *moment = [[WXMoment allocWithZone:zone] init];
    moment.identifier = self.identifier;
    moment.uid = self.uid;
    moment.privacy = self.isPrivacy;
    moment.content = self.content;
    moment.timestamp = self.timestamp;
    moment.source = self.source;
    moment.location = self.location;
    moment.type = self.type;
    moment.web = self.web;
    moment->_webpage = self->_webpage;
    moment->_likes = (self->_likes).mutableCopy;
    moment->_profiles = (self->_profiles).mutableCopy;
    moment->_comments = (self->_comments).mutableCopy;
    return moment;
}

#pragma mark - SQL
+ (NSDictionary <NSString *, NSString *>*)sqliteTableFields {
    return @{@"identifier":MNSQLFieldText, @"type":MNSQLFieldInteger, @"uid":MNSQLFieldText, @"timestamp":MNSQLFieldText, @"content":MNSQLFieldText, @"source":MNSQLFieldText, @"location":MNSQLFieldText, @"privacy":MNSQLFieldInteger, @"web":MNSQLFieldBlob};
}

@end
