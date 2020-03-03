//
//  WXUser.h
//  MNChat
//
//  Created by Vincent on 2019/3/7.
//  Copyright © 2019 Vincent. All rights reserved.
//  用户模型

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MNGender) {
    MNGenderUnknown = 0,
    MNGenderMale,
    MNGenderFemale
};

@interface WXUser : NSObject <NSSecureCoding>

#pragma mark - 登录体系
/**
 用户登录uid
 */
@property (nonatomic, copy) NSString *uid;
/**
 本地保存的头像
 */
@property (nonatomic, strong) NSData *avatarData;
/**
 外界获取头像
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
@property (nonatomic, assign) MNGender gender;
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
@property (nonatomic, copy) NSString *number;
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

#pragma mark - Public
/// 本地用户
+ (instancetype)shareInfo;

/// 更新用户信息
/// @param userInfo 用户信息字典
+ (void)updateUserInfo:(NSDictionary *)userInfo;

/// 退出登录
+ (void)logout;

/// 判断是否登录
+ (BOOL)isLogin;

/// 同步用户信息
- (void)synchronize;

/// 修改用户信息
/// @param handler 修改回调
+ (void)performReplacingHandler:(void(^)(WXUser *userInfo))handler;

/// 根据字典信息创建用户模型
/// @param info 用户模型
+ (instancetype)userWithInfo:(NSDictionary *)info;

/**
 快速获取备注,昵称
 @return 有备注时返回备注, 否则返回昵称
 */
- (NSString *)name;

@end

