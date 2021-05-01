//
//  WXEditUserInfoViewController.h
//  WeChat
//
//  Created by Vincent on 2019/3/22.
//  Copyright © 2019 Vincent. All rights reserved.
//  微信用户资料编辑

#import "MNListViewController.h"
@class WXUser;

NS_ASSUME_NONNULL_BEGIN

@interface WXEditUserInfoViewController : MNListViewController

- (instancetype)initWithUser:(WXUser *)user;

@end

NS_ASSUME_NONNULL_END
