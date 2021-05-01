//
//  WXTransferViewController.h
//  WeChat
//
//  Created by Vincent on 2019/5/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  转账

#import "MNExtendViewController.h"

@interface WXTransferViewController : MNExtendViewController

/**转账回调*/
@property (nonatomic, copy) void (^completionHandler) (NSString *money, NSString *text);

/**
 实例化转账控制器
 @param user 用户
 @return 转账控制器
 */
- (instancetype)initWithUser:(WXUser *)user;

@end
