//
//  WXMoment.m
//  MNChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMoment.h"

@interface WXMoment ()
{
    WXUser *_user;
    WXMomentWebpage *_webpage;
    NSMutableArray <NSString *>*_likes;
    NSMutableArray <WXMomentPicture *>*_pictures;
    NSMutableArray <WXMomentComment *>*_comments;
}
@end

@implementation WXMoment
- (instancetype)init {
    self = [super init];
    if (self) {
        self.identifier = MNFileHandle.fileName;
    }
    return self;
}

#pragma mark - Getter
- (BOOL)isMine {
    return [_uid isEqualToString:WXUser.shareInfo.uid];
}

- (WXUser *)user {
    if (!_user && _uid.length > 0) {
        _user = [[MNChatHelper helper] userForUid:_uid];
    }
    return _user;
}

- (WXMomentWebpage *)webpage {
    if (!_webpage && _web.length > 0) {
        NSArray *rows = [[MNDatabase sharedInstance] selectRowsModelFromTable:WXMomentWebpageTableName where:[@{@"identifier":sql_pair(_web)} componentString] limit:NSRangeZero class:WXMomentWebpage.class];
        if (rows.count > 0) _webpage = rows.firstObject;
    }
    return _webpage;
}

- (NSMutableArray <WXMomentPicture *>*)pictures {
    if (!_pictures) {
        _pictures = [NSMutableArray array];
        if (_img.length > 0) {
            NSArray <NSString *>*imgs = [_img componentsSeparatedByString:WXDataSeparatedSign];
            [imgs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                WXMomentPicture *picture = (WXMomentPicture *)[MNChatHelper.helper.cache objectForKey:obj];
                if (picture) [_pictures addObject:picture];
            }];
        }
    }
    return _pictures;
}

- (NSMutableArray <NSString *>*)likes {
    if (!_likes) {
        _likes = @[].mutableCopy;
        if (_like.length > 0) {
            [_likes addObjectsFromArray:[_like componentsSeparatedByString:WXDataSeparatedSign]];
        }
    }
    return _likes;
}

- (NSMutableArray <WXMomentComment *>*)comments {
    if (!_comments) {
        _comments = [NSMutableArray array];
        if (_comment.length > 0) {
            NSArray <NSString *>*comments = [_comment componentsSeparatedByString:WXDataSeparatedSign];
            [comments enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray <WXMomentComment *>*rows = [[MNDatabase sharedInstance] selectRowsModelFromTable:WXMomentCommentTableName where:[@{@"identifier":sql_pair(obj)} componentString] limit:NSRangeZero class:WXMomentComment.class];
                [_comments addObjectsFromArray:rows];
            }];
        }
    }
    return _comments;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    WXMoment *moment = [WXMoment allocWithZone:zone];
    moment.identifier = self.identifier;
    moment.uid = self.uid;
    moment.privacy = self.isPrivacy;
    moment.content = self.content;
    moment.timestamp = self.timestamp;
    moment.source = self.source;
    moment.location = self.location;
    moment.img = self.img;
    moment.like = self.like;
    moment.comment = self.comment;
    moment->_webpage = _webpage.copy;
    moment->_likes = _likes.mutableCopy;
    moment->_pictures = _pictures.mutableCopy;
    moment->_comments = _comments.mutableCopy;
    return moment;
}

@end
