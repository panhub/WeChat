//
//  WXLabel.m
//  WeChat
//
//  Created by Vicent on 2021/3/29.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXLabel.h"

@interface WXLabel ()
@property (nonatomic, strong) NSString *userString;
@end

@implementation WXLabel
- (instancetype)init {
    if (self = [super init]) {
        self.users = @[].mutableCopy;
    }
    return self;
}

- (NSString *)userString {
    if (!_userString && self.users.count) {
        NSArray <NSString *>*names = [self.users valuesForKey:@"name"];
        _userString = [names componentsJoinedByString:@"、"];
    }
    return _userString;
}

#pragma mark - 数据库支持
+ (NSDictionary <NSString *, NSString *>*)sqliteTableFields {
    return @{@"identifier":MNSQLFieldText, @"timestamp":MNSQLFieldText, @"name":MNSQLFieldText};
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    WXLabel *label = [[WXLabel allocWithZone:zone] init];
    label.name = self.name;
    label.timestamp = NSDate.timestamps;
    [label.users addObjectsFromArray:self.users];
    return label;
}

@end
