//
//  WXChangeAccessController.h
//  WeChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//  零钱存取

#import "MNListViewController.h"

typedef NS_ENUM(NSInteger, WXChangeAccessType) {
    WXChangeAccessRecharge = 0,
    WXChangeAccessWithdraw
};

@interface WXChangeAccessController : MNListViewController

- (instancetype)initWithType:(WXChangeAccessType)type;


@end
