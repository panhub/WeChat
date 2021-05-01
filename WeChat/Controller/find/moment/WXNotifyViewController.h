//
//  WXNotifyViewController.h
//  WeChat
//
//  Created by Vincent on 2019/7/23.
//  Copyright © 2019 AiZhe. All rights reserved.
//  提醒详情 

#import "MNListViewController.h"
@class WXTimelineViewModel, WXNotify;

NS_ASSUME_NONNULL_BEGIN

@interface WXNotifyViewController : MNListViewController

/**删除朋友圈通知回调*/
@property (nonatomic, copy) void (^didDeleteNotifyHandler) (void);

@end

NS_ASSUME_NONNULL_END
