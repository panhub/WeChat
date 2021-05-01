//
//  WXMyMomentController.h
//  WeChat
//
//  Created by Vicent on 2021/4/16.
//  Copyright © 2021 Vincent. All rights reserved.
//  我的朋友圈控制器

#import "MNListViewController.h"
@class WXUser;

NS_ASSUME_NONNULL_BEGIN

@interface WXMyMomentController : MNListViewController

/**
 依据用户模型实例化
 @param user 指定用户
 @return 用户朋友圈模型
 */
- (instancetype)initWithUser:(WXUser *)user;

@end

NS_ASSUME_NONNULL_END
