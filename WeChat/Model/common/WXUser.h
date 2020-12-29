//
//  WXUser.h
//  MNChat
//
//  Created by Vincent on 2019/3/7.
//  Copyright © 2019 Vincent. All rights reserved.
//  用户模型

#import <Foundation/Foundation.h>

/**
 性别
 - WechatGenderUnknown 未知
 - WechatGenderMale 男
 - WechatGenderFemale 女
 */
typedef NS_ENUM(NSInteger, WechatGender) {
    WechatGenderUnknown = 0,
    WechatGenderMale,
    WechatGenderFemale
};

@interface WXUser : NSObject <NSSecureCoding>

#pragma mark - 登录体系
/**
 用户标识
 */
@property (nonatomic, copy) NSString *uid;
/**
 头像Base64字符串
 */
@property (nonatomic, copy) NSString *avatarString;
/**
 头像
 */
@property (nonatomic, strong, readonly) UIImage *avatar;
/**
 注册用户名
 */
@property (nonatomic, copy) NSString *username;
/**
 注册时的密码<仅登录时判断, 注册时填写>
 */
@property (nonatomic, copy) NSString *password;
/**
 性别
 */
@property (nonatomic, assign) WechatGender gender;
/**
 微信号
 */
@property (nonatomic, copy) NSString *wechatId;
/**
 微信备注名
 */
@property (nonatomic, copy) NSString *notename;
/**
 微信昵称
 */
@property (nonatomic, copy) NSString *nickname;
/**
 手机号
 */
@property (nonatomic, copy) NSString *phone;
/**
 微信标签
 */
@property (nonatomic, copy) NSString *label;
/**
 预留字段<微信来源等>
 */
@property (nonatomic, copy) NSString *desc;
/**
 微信地区
 */
@property (nonatomic, copy) NSString *location;
/**
 微信签名
 */
@property (nonatomic, copy) NSString *signature;
/**
 微信星标
 */
@property (nonatomic) BOOL asterisk;
/**
 微信不让他看
 */
@property (nonatomic) BOOL privacy;
/**
 微信不看他
 */
@property (nonatomic) BOOL looked;
/**
 是否已登录
 */
@property (nonatomic, readonly, class) BOOL isLogin;
/**
 登录用户
 */
@property (nonatomic, readonly, class) WXUser *shareInfo;

#pragma mark - Public

/**
 更新用户信息
 @param userInfo 用户信息
 */
- (void)updateUserInfo:(NSDictionary *)userInfo;

/// 退出登录
+ (void)logout;

/// 修改用户信息
/// @param handler 修改回调
+ (void)performReplacingHandler:(void(^)(WXUser *user))handler;

/**
 依据用户信息实例化用户模型
 @param userInfo 用户信息
 @return 用户模型
 */
+ (WXUser *)userWithInfo:(NSDictionary *)userInfo;

/**
 快速获取备注,昵称
 @return 有备注时返回备注, 否则返回昵称
 */
- (NSString *)name;

/**
 从钥匙串中取出指定用户信息
 @param username 指定用户名
 @return 指定用户信息
 */
+ (NSDictionary *)userInfoWithUsername:(NSString *)username;

/**
 往钥匙串中存入用户信息
 @param userInfo 用户信息
 @return 是否保存成功
 */
+ (BOOL)setUserInfoToKeychain:(NSDictionary *)userInfo;

@end

