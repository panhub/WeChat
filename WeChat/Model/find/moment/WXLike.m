//
//  WXLike.m
//  WeChat
//
//  Created by Vicent on 2021/4/24.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXLike.h"

@implementation WXLike
{
    WXUser *_user;
}

- (WXUser *)user {
    if (!_user && _uid.length) {
        _user = [WechatHelper.helper userForUid:_uid];
    }
    return _user;
}

- (instancetype)initWithUid:(NSString *)uid {
    if (self = [super init]) {
        self.uid = uid;
        self.timestamp = NSDate.timestamps;
        self.identifier = NSDate.shortTimestamps;
    }
    return self;
}

#pragma mark - SQL
+ (NSDictionary <NSString *, NSString *>*)sqliteTableFields {
    return @{@"identifier":MNSQLFieldText, @"moment":MNSQLFieldText, @"uid":MNSQLFieldText, @"timestamp":MNSQLFieldText};
}

@end
