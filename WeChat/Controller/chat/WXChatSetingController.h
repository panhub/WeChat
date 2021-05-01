//
//  WXChatSetingController.h
//  WeChat
//
//  Created by Vincent on 2019/3/31.
//  Copyright © 2019 Vincent. All rights reserved.
//  聊天设置

#import "MNListViewController.h"
@class WXSession;

UIKIT_EXTERN NSNotificationName const WXChatTableDeleteNotificationName;

@interface WXChatSetingController : MNListViewController

- (instancetype)initWithSession:(WXSession *)session;

@end
