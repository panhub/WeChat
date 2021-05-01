//
//  WXNotifyCell.h
//  WeChat
//
//  Created by Vincent on 2019/7/23.
//  Copyright © 2019 AiZhe. All rights reserved.
//  朋友圈 - 提醒展示Cell

#import "MNTableViewCell.h"
@class WXNotifyViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXNotifyCell : MNTableViewCell

/**视图模型*/
@property (nonatomic, strong) WXNotifyViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
