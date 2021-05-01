//
//  WXUserViewController.h
//  WeChat
//
//  Created by Vincent on 2019/3/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  微信用户资料详情

#import "MNListViewController.h"
@class WXUser;

NS_ASSUME_NONNULL_BEGIN

@interface WXUserViewController : MNListViewController

/**
 用户详情构造入口
 @param user 用户
 @return 用户详情控制器
 */
- (instancetype)initWithUser:(WXUser *)user;

@end

NS_ASSUME_NONNULL_END
