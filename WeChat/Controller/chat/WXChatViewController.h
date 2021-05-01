//
//  WXChatViewController.h
//  WeChat
//
//  Created by Vincent on 2019/3/28.
//  Copyright © 2019 Vincent. All rights reserved.
//  聊天控制器

#import "MNListViewController.h"
@class WXSession, WXChatViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXChatViewController : MNListViewController

/**聊天视图模型*/
@property (nonatomic, strong, readonly) WXChatViewModel *viewModel;

/**
 实例化聊天控制器
 @param session 会话模型
 @return 聊天控制器
 */
- (instancetype)initWithSession:(WXSession *)session;

@end

NS_ASSUME_NONNULL_END
