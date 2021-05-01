//
//  WXTransferSucceedController.h
//  WeChat
//
//  Created by Vincent on 2019/5/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  转账成功

#import "MNBaseViewController.h"

@interface WXTransferSucceedController : MNBaseViewController
/**
 转账信息
 */
@property (nonatomic, copy) NSString *text;
/**
 转账金额
 */
@property (nonatomic, copy) NSString *money;

- (instancetype)initWithUser:(WXUser *)user;

@end

