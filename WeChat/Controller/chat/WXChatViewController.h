//
//  WXChatViewController.h
//  MNChat
//
//  Created by Vincent on 2019/3/28.
//  Copyright © 2019 Vincent. All rights reserved.
//  聊天

#import "MNListViewController.h"
#import "WXChatViewModel.h"
@class WXSession;

NS_ASSUME_NONNULL_BEGIN

@interface WXChatViewController : MNListViewController

@property (nonatomic, strong, readonly) WXChatViewModel *viewModel;

- (instancetype)initWithSession:(WXSession *)session;

@end

NS_ASSUME_NONNULL_END
