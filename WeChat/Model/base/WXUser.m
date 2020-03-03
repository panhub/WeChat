//
//  WXUser.m
//  MNChat
//
//  Created by Vincent on 2019/3/7.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXUser.h"

@interface WXUser ()

@end

#define WXUserEncodeKey @"com.wx.user.encode.key"

static WXUser *_userInfo;

@implementation WXUser
@synthesize avatar = _avatar;
@synthesize username = _username;

+ (instancetype)shareInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_userInfo) {
            _userInfo = [[WXUser alloc] init];
            [_userInfo setUserInfo:[NSUserDefaults.standardUserDefaults dictionaryForKey:WXUserEncodeKey]];
        }
    });
    return _userInfo;
}

+ (void)updateUserInfo:(NSDictionary *)userInfo {
    if (userInfo) {
        [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:WXUserEncodeKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:WXUserEncodeKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[WXUser shareInfo] setUserInfo:userInfo];
}

- (void)setUserInfo:(NSDictionary *)userInfo {
    self->_uid = [MNJSONSerialization stringValueWithJSON:userInfo forKey:kPath(self.uid)];
    self->_location = [MNJSONSerialization stringValueWithJSON:userInfo forKey:kPath(self.location) def:WXUserDefaultLocation];
    self->_username = [MNJSONSerialization stringValueWithJSON:userInfo forKey:kPath(self.username) def:@""];
    self->_wechatId = [MNJSONSerialization stringValueWithJSON:userInfo forKey:kPath(self.wechatId) def:MNChatHelper.generateRandomWechatId];
    self->_number = [MNJSONSerialization stringValueWithJSON:userInfo forKey:kPath(self.number)];
    self->_nickname = [MNJSONSerialization stringValueWithJSON:userInfo forKey:kPath(self.nickname) def:self.username];
    self->_signature = [MNJSONSerialization stringValueWithJSON:userInfo forKey:kPath(self.signature) def:@""];
    self->_avatarData = [MNJSONSerialization dataValueWithJSON:userInfo forKey:kPath(self.avatarData)];
    self->_gender = [MNJSONSerialization integerValueWithJSON:userInfo forKey:kPath(self.gender)];
    self->_password = [MNJSONSerialization stringValueWithJSON:userInfo forKey:kPath(self.password) def:@""];
}

+ (void)logout {
    [WXUser shareInfo]->_uid = @"";
    [WXUser shareInfo]->_username = @"";
    [[WXUser shareInfo] synchronize];
}

+ (BOOL)isLogin {
    return (WXUser.shareInfo.uid.length > 0 && WXUser.shareInfo.username.length > 0);
}

+ (void)performReplacingHandler:(void(^)(WXUser *))handler {
    WXUser *userInfo = [WXUser shareInfo];
    if (handler) handler(userInfo);
    [userInfo synchronize];
}

- (void)synchronize {
    if (self.uid.length <= 0) {
        [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
            [userDefaults removeObjectForKey:WXUserEncodeKey];
        }];
        if (self.username.length) {
            [MNDatabase deleteRowFromTable:WXUsersTableName
                                     where:@{sql_field(self.username):self.username}.componentString
                                completion:nil];
        }
    } else {
        if (self.avatarData) self->_avatar = [UIImage imageWithData:self.avatarData];
        [NSUserDefaults synchronly:^(NSUserDefaults *userDefaults) {
            [userDefaults setObject:self.JsonValue forKey:WXUserEncodeKey];
        }];
        [MNDatabase updateTable:WXUsersTableName
                          where:@{sql_field(self.username):self.username}.componentString
                          model:self
                     completion:nil];
    }
}

+ (instancetype)userWithInfo:(NSDictionary *)info {
    if (!info) return nil;
    WXUser *user = [WXUser new];
    user.uid = [MNJSONSerialization stringValueWithJSON:info forKey:kPath(user.uid)];
    user.desc = [MNJSONSerialization stringValueWithJSON:info forKey:kPath(user.desc)];
    user.label = [MNJSONSerialization stringValueWithJSON:info forKey:kPath(user.label)];
    user.number = [MNJSONSerialization stringValueWithJSON:info forKey:kPath(user.number)];
    user.username = [MNJSONSerialization stringValueWithJSON:info forKey:kPath(user.username)];
    user.notename = [MNJSONSerialization stringValueWithJSON:info forKey:kPath(user.notename)];
    user.avatarData = [MNJSONSerialization dataValueWithJSON:info forKey:kPath(user.avatarData)];
    user.location = [MNJSONSerialization stringValueWithJSON:info forKey:kPath(user.location)];
    user.wechatId = [MNJSONSerialization stringValueWithJSON:info forKey:kPath(user.wechatId)];
    user.nickname = [MNJSONSerialization stringValueWithJSON:info forKey:kPath(user.nickname)];
    user.gender = [MNJSONSerialization integerValueWithJSON:info forKey:kPath(user.gender)];
    user.signature = [MNJSONSerialization stringValueWithJSON:info forKey:kPath(user.signature)];
    user.password = [MNJSONSerialization stringValueWithJSON:info forKey:kPath(user.password)];
    user.asterisk = [MNJSONSerialization boolValueWithJSON:info forKey:kPath(user.asterisk)];
    user.privacy = [MNJSONSerialization boolValueWithJSON:info forKey:kPath(user.privacy)];
    user.looked = [MNJSONSerialization boolValueWithJSON:info forKey:kPath(user.looked)];
    return user;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.uid forKey:kPath(self.uid)];
    [coder encodeObject:self.avatarData forKey:kPath(self.avatarData)];
    [coder encodeObject:self.username forKey:kPath(self.username)];
    [coder encodeObject:self.password forKey:kPath(self.password)];
    [coder encodeObject:self.wechatId forKey:kPath(self.wechatId)];
    [coder encodeObject:self.notename forKey:kPath(self.notename)];
    [coder encodeObject:self.nickname forKey:kPath(self.nickname)];
    [coder encodeObject:self.number forKey:kPath(self.number)];
    [coder encodeObject:self.label forKey:kPath(self.label)];
    [coder encodeObject:self.desc forKey:kPath(self.desc)];
    [coder encodeObject:self.location forKey:kPath(self.location)];
    [coder encodeObject:self.signature forKey:kPath(self.signature)];
    [coder encodeInteger:self.gender forKey:kPath(self.gender)];
    [coder encodeBool:self.asterisk forKey:kPath(self.asterisk)];
    [coder encodeBool:self.privacy forKey:kPath(self.privacy)];
    [coder encodeBool:self.looked forKey:kPath(self.looked)];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.uid = [coder decodeObjectForKey:kPath(self.uid)];
        self.avatarData = [coder decodeObjectForKey:kPath(self.avatarData)];
        self.username = [coder decodeObjectForKey:kPath(self.username)];
        self.password = [coder decodeObjectForKey:kPath(self.password)];
        self.wechatId = [coder decodeObjectForKey:kPath(self.wechatId)];
        self.notename = [coder decodeObjectForKey:kPath(self.notename)];
        self.nickname = [coder decodeObjectForKey:kPath(self.nickname)];
        self.number = [coder decodeObjectForKey:kPath(self.number)];
        self.label = [coder decodeObjectForKey:kPath(self.label)];
        self.desc = [coder decodeObjectForKey:kPath(self.desc)];
        self.location = [coder decodeObjectForKey:kPath(self.location)];
        self.signature = [coder decodeObjectForKey:kPath(self.signature)];
        self.gender = [coder decodeIntForKey:kPath(self.gender)];
        self.asterisk = [coder decodeBoolForKey:kPath(self.asterisk)];
        self.privacy = [coder decodeBoolForKey:kPath(self.privacy)];
        self.looked = [coder decodeBoolForKey:kPath(self.looked)];
    }
    return self;
}

#pragma mark - Getter
- (UIImage *)avatar {
    if (!_avatar) {
        if (_avatarData.length > 0) {
            _avatar = [UIImage imageWithData:_avatarData];
        } else {
            _avatar = MNChatHelper.randomAvatarImage;
            _avatarData = _avatar.PNGData;
        }
    }
    return _avatar;
}

- (NSString *)name {
    return self.notename.length > 0 ? self.notename : self.nickname;
}

- (id)JsonValue {
    NSMutableDictionary *dic = @{}.mutableCopy;
    [dic setObject:NSStringEmpty(self.uid) forKey:kPath(self.uid)];
    [dic setObject:NSStringEmpty(self.username) forKey:kPath(self.username)];
    [dic setObject:NSStringEmpty(self.password) forKey:kPath(self.password)];
    [dic setObject:NSStringEmpty(self.wechatId) forKey:kPath(self.wechatId)];
    [dic setObject:NSStringEmpty(self.notename) forKey:kPath(self.notename)];
    [dic setObject:NSStringEmpty(self.nickname) forKey:kPath(self.nickname)];
    [dic setObject:NSStringEmpty(self.number) forKey:kPath(self.number)];
    [dic setObject:NSStringEmpty(self.label) forKey:kPath(self.label)];
    [dic setObject:NSStringEmpty(self.desc) forKey:kPath(self.desc)];
    [dic setObject:[NSString replacingBlankCharacter:self.location withCharacter:WXUserDefaultLocation] forKey:kPath(self.location)];
    [dic setObject:NSStringEmpty(self.signature) forKey:kPath(self.signature)];
    [dic setObject:NSStringFromNumber(@(self.gender)) forKey:kPath(self.gender)];
    [dic setObject:NSStringFromNumber(@(self.asterisk)) forKey:kPath(self.asterisk)];
    [dic setObject:NSStringFromNumber(@(self.privacy)) forKey:kPath(self.privacy)];
    [dic setObject:NSStringFromNumber(@(self.looked)) forKey:kPath(self.looked)];
    if (self.avatarData.length) [dic setObject:self.avatarData forKey:kPath(self.avatarData)];
    return dic.copy;
}

@end
