//
//  WXUserMoreController.h
//  WeChat
//
//  Created by Vicent on 2021/5/1.
//  Copyright © 2021 Vincent. All rights reserved.
//  用户信息更多

#import "MNListViewController.h"
@class WXUser;

NS_ASSUME_NONNULL_BEGIN

@interface WXUserMoreController : MNListViewController

/**
 用户设置构造入口
 @param user 用户
 @return 用户设置控制器
 */
- (instancetype)initWithUser:(WXUser *)user;

@end

NS_ASSUME_NONNULL_END
