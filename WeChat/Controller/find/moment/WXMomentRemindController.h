//
//  WXMomentRemindController.h
//  MNChat
//
//  Created by Vincent on 2019/7/23.
//  Copyright © 2019 AiZhe. All rights reserved.
//  提醒详情

#import "MNListViewController.h"
@class WXMomentProfileViewModel, WXMomentRemind;

NS_ASSUME_NONNULL_BEGIN

@interface WXMomentRemindController : MNListViewController

@property (nonatomic, copy) void (^didDeleteRemindHandler) (void);

- (instancetype)initWithViewModel:(WXMomentProfileViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
