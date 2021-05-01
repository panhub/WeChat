//
//  WXUserSettingController.h
//  WeChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//  微信用户资料设置

#import "MNListViewController.h"
@class WXUser;

NS_ASSUME_NONNULL_BEGIN

@interface WXUserSettingController : MNListViewController

/**
 用户设置构造入口
 @param user 用户
 @return 用户设置控制器
 */
- (instancetype)initWithUser:(WXUser *)user;

@end

NS_ASSUME_NONNULL_END
