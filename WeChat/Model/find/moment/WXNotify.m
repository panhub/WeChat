//
//  WXNotify.m
//  WeChat
//
//  Created by Vincent on 2019/7/22.
//  Copyright © 2019 AiZhe. All rights reserved.
//

#import "WXNotify.h"
#import "WXLike.h"
#import "WXMoment.h"

@implementation WXNotify
- (instancetype)initWithLike:(WXLike *)like {
    if (self = [super init]) {
        self.from_uid = like.uid;
        self.moment = like.moment;
        self.identifier = like.identifier;
        self.timestamp = like.timestamp;
    }
    return self;
}

- (instancetype)initWithComment:(WXComment *)comment {
    if (self = [super init]) {
        self.from_uid = comment.from_uid;
        self.to_uid = comment.to_uid;
        self.content = comment.content;
        self.moment = comment.moment;
        self.identifier = comment.identifier;
        self.timestamp = comment.timestamp;
    }
    return self;
}

#pragma mark - SQL
+ (NSDictionary <NSString *, NSString *>*)sqliteTableFields {
    return @{@"identifier":MNSQLFieldText, @"moment":MNSQLFieldText, @"from_uid":MNSQLFieldText, @"to_uid":MNSQLFieldText, @"content":MNSQLFieldText, @"timestamp":MNSQLFieldText};
}

@end
