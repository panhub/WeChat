//
//  WXUserPermissionController.h
//  WeChat
//
//  Created by Vicent on 2021/4/29.
//  Copyright © 2021 Vincent. All rights reserved.
//  朋友权限

#import "MNListViewController.h"
@class WXUser;

NS_ASSUME_NONNULL_BEGIN

@interface WXUserPermissionController : MNListViewController

/**
 用户设置构造入口
 @param user 用户
 @return 用户设置控制器
 */
- (instancetype)initWithUser:(WXUser *)user;

@end

NS_ASSUME_NONNULL_END
