//
//  WXUser.m
//  MNChat
//
//  Created by Vincent on 2019/3/7.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXUser.h"
#import "WechatHelper.h"

static WXUser *_userInfo;
#define kUserKeychain   @"com.wx.users.key"

@interface WXUser ()
@property (nonatomic, getter=isRootUser) BOOL rootUser;
@end

@implementation WXUser
@synthesize avatar = _avatar;
@synthesize username = _username;

+ (instancetype)shareInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_userInfo) {
            _userInfo = [[WXUser alloc] init];
            _userInfo.rootUser = YES;
            NSString *username = [NSUserDefaults.standardUserDefaults stringForKey:kLoginLastUsername];
            if (username) [_userInfo updateUserInfo:[WXUser userInfoWithUsername:username]];
        }
    });
    return _userInfo;
}

- (void)updateUserInfo:(NSDictionary *)userInfo {
    _uid = [NSDictionary stringValueWithDictionary:userInfo forKey:kPath(self.uid) def:@""];
    _location = [NSDictionary stringValueWithDictionary:userInfo forKey:kPath(self.location) def:WXUserDefaultLocation];
    _username = [NSDictionary stringValueWithDictionary:userInfo forKey:kPath(self.username) def:@""];
    _wechatId = [NSDictionary stringValueWithDictionary:userInfo forKey:kPath(self.wechatId) def:WechatHelper.wechatId];
    _phone = [NSDictionary stringValueWithDictionary:userInfo forKey:kPath(self.phone) def:@""];
    _nickname = [NSDictionary stringValueWithDictionary:userInfo forKey:kPath(self.nickname) def:self.username];
    _signature = [NSDictionary stringValueWithDictionary:userInfo forKey:kPath(self.signature) def:@""];
    _avatarData = [NSDictionary dataValueWithDictionary:userInfo forKey:kPath(self.avatarData)];
    _gender = (WechatGender)[NSDictionary integerValueWithDictionary:userInfo forKey:kPath(self.gender)];
    _password = [NSDictionary stringValueWithDictionary:userInfo forKey:kPath(self.password) def:@""];
    _avatarString = [NSDictionary stringValueWithDictionary:userInfo forKey:kPath(self.avatarString) def:@""];
    _desc = [NSDictionary stringValueWithDictionary:userInfo forKey:kPath(self.desc) def:@""];
    _label = [NSDictionary stringValueWithDictionary:userInfo forKey:kPath(self.label) def:@""];
    _notename = [NSDictionary stringValueWithDictionary:userInfo forKey:kPath(self.notename) def:@""];
    _asterisk = [NSDictionary boolValueWithDictionary:userInfo forKey:kPath(self.asterisk)];
    _privacy = [NSDictionary boolValueWithDictionary:userInfo forKey:kPath(self.privacy)];
    _looked = [NSDictionary boolValueWithDictionary:userInfo forKey:kPath(self.looked)];
    if (_avatarString.length) _avatar = [UIImage imageWithBase64EncodedString:_avatarString];
}

+ (void)logout {
    WXUser.shareInfo->_uid = @"";
    WXUser.shareInfo->_username = @"";
}

+ (BOOL)isLogin {
    return (WXUser.shareInfo.uid.length > 0 && WXUser.shareInfo.username.length > 0);
}

+ (void)performReplacingHandler:(void(^)(WXUser *))handler {
    WXUser *user = [WXUser shareInfo];
    if (handler) handler(user);
    [WXUser setUserInfoToKeychain:user.JsonValue];
    [MNDatabase updateTable:WXUsersTableName where:@{sql_field(user.uid):user.uid}.componentString model:user completion:nil];
}

+ (instancetype)userWithInfo:(NSDictionary *)info {
    if (!info) return nil;
    WXUser *user = [WXUser new];
    [user updateUserInfo:info];
    return user;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.uid forKey:kPath(self.uid)];
    [coder encodeObject:self.avatarData forKey:kPath(self.avatarData)];
    [coder encodeObject:self.avatarString forKey:kPath(self.avatarString)];
    [coder encodeObject:self.username forKey:kPath(self.username)];
    [coder encodeObject:self.password forKey:kPath(self.password)];
    [coder encodeObject:self.wechatId forKey:kPath(self.wechatId)];
    [coder encodeObject:self.notename forKey:kPath(self.notename)];
    [coder encodeObject:self.nickname forKey:kPath(self.nickname)];
    [coder encodeObject:self.phone forKey:kPath(self.phone)];
    [coder encodeObject:self.label forKey:kPath(self.label)];
    [coder encodeObject:self.desc forKey:kPath(self.desc)];
    [coder encodeObject:self.location forKey:kPath(self.location)];
    [coder encodeObject:self.signature forKey:kPath(self.signature)];
    [coder encodeInteger:self.gender forKey:kPath(self.gender)];
    [coder encodeBool:self.asterisk forKey:kPath(self.asterisk)];
    [coder encodeBool:self.privacy forKey:kPath(self.privacy)];
    [coder encodeBool:self.looked forKey:kPath(self.looked)];
    [coder encodeBool:self.isRootUser forKey:kPath(self.rootUser)];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.uid = [coder decodeObjectForKey:kPath(self.uid)];
        self.avatarData = [coder decodeObjectForKey:kPath(self.avatarData)];
        self.avatarString = [coder decodeObjectForKey:kPath(self.avatarString)];
        self.username = [coder decodeObjectForKey:kPath(self.username)];
        self.password = [coder decodeObjectForKey:kPath(self.password)];
        self.wechatId = [coder decodeObjectForKey:kPath(self.wechatId)];
        self.notename = [coder decodeObjectForKey:kPath(self.notename)];
        self.nickname = [coder decodeObjectForKey:kPath(self.nickname)];
        self.phone = [coder decodeObjectForKey:kPath(self.phone)];
        self.label = [coder decodeObjectForKey:kPath(self.label)];
        self.desc = [coder decodeObjectForKey:kPath(self.desc)];
        self.location = [coder decodeObjectForKey:kPath(self.location)];
        self.signature = [coder decodeObjectForKey:kPath(self.signature)];
        self.gender = [coder decodeIntForKey:kPath(self.gender)];
        self.asterisk = [coder decodeBoolForKey:kPath(self.asterisk)];
        self.privacy = [coder decodeBoolForKey:kPath(self.privacy)];
        self.looked = [coder decodeBoolForKey:kPath(self.looked)];
        self.rootUser = [coder decodeBoolForKey:kPath(self.rootUser)];
    }
    return self;
}

#pragma mark - Getter
- (UIImage *)avatar {
    if (!_avatar) {
        if (_avatarString.length) {
            _avatar = [UIImage imageWithBase64EncodedString:_avatarString];
        } else {
            _avatar = WechatHelper.avatar;
            _avatarString = _avatar.PNGBase64Encoding;
        }
    }
    return _avatar;
}

- (NSString *)name {
    return self.notename.length > 0 ? self.notename : self.nickname;
}

- (id)JsonValue {
    NSMutableDictionary *dic = @{}.mutableCopy;
    [dic setObject:[NSString replacingEmptyCharacters:self.uid] forKey:kPath(self.uid)];
    [dic setObject:[NSString replacingEmptyCharacters:self.username] forKey:kPath(self.username)];
    [dic setObject:[NSString replacingEmptyCharacters:self.password] forKey:kPath(self.password)];
    [dic setObject:[NSString replacingEmptyCharacters:self.wechatId] forKey:kPath(self.wechatId)];
    [dic setObject:[NSString replacingEmptyCharacters:self.notename] forKey:kPath(self.notename)];
    [dic setObject:[NSString replacingEmptyCharacters:self.nickname] forKey:kPath(self.nickname)];
    [dic setObject:[NSString replacingEmptyCharacters:self.phone] forKey:kPath(self.phone)];
    [dic setObject:[NSString replacingEmptyCharacters:self.label] forKey:kPath(self.label)];
    [dic setObject:[NSString replacingEmptyCharacters:self.desc] forKey:kPath(self.desc)];
    [dic setObject:[NSString replacingEmptyCharacters:self.avatarString] forKey:kPath(self.avatarString)];
    [dic setObject:[NSString replacingEmptyCharacters:self.location withCharacters:WXUserDefaultLocation] forKey:kPath(self.location)];
    [dic setObject:[NSString replacingEmptyCharacters:self.signature] forKey:kPath(self.signature)];
    [dic setObject:@(self.gender).stringValue forKey:kPath(self.gender)];
    [dic setObject:@(self.asterisk).stringValue forKey:kPath(self.asterisk)];
    [dic setObject:@(self.privacy).stringValue forKey:kPath(self.privacy)];
    [dic setObject:@(self.looked).stringValue forKey:kPath(self.looked)];
    return dic.copy;
}

+ (NSDictionary *)userInfoWithUsername:(NSString *)username {
    if (!username) return nil;
    NSData *userData = [MNKeychain dataForKey:kUserKeychain];
    if (!userData) return nil;
    NSDictionary *dic = userData.JsonValue;
    if (!dic) return nil;
    return [dic objectForKey:username];
}

+ (BOOL)setUserInfoToKeychain:(NSDictionary *)userInfo {
    if (!userInfo) return NO;
    NSString *username = [userInfo objectForKey:@"username"];
    if (!username) return NO;
    NSDictionary *dic = [MNKeychain dataForKey:kUserKeychain].JsonValue;
    if (!dic) dic = @{};
    NSMutableDictionary *cache = dic.mutableCopy;
    [cache setObject:userInfo forKey:username];
    NSData *userData = cache.JsonData;
    if (!userData) return NO;
    return [MNKeychain setData:userData forKey:kUserKeychain];
}

#pragma mark - 数据库支持
+ (NSDictionary <NSString *, NSString *>*)sqliteTableFields {
    return @{@"uid":MNSQLFieldText, @"wechatId":MNSQLFieldText, @"username":MNSQLFieldText, @"password":MNSQLFieldText, @"nickname":MNSQLFieldText, @"notename":MNSQLFieldText, @"gender":MNSQLFieldInteger, @"avatarString":MNSQLFieldText, @"phone":MNSQLFieldText, @"label":MNSQLFieldText, @"desc":MNSQLFieldText, @"location":MNSQLFieldText, @"signature":MNSQLFieldText, @"asterisk":MNSQLFieldInteger, @"privacy": MNSQLFieldInteger, @"looked":MNSQLFieldInteger};
}

@end
