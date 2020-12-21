//
//  WXMomentRemindCell.h
//  MNChat
//
//  Created by Vincent on 2019/7/23.
//  Copyright © 2019 AiZhe. All rights reserved.
//  朋友圈 - 提醒展示Cell

#import "MNTableViewCell.h"
@class WXMomentRemindViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXMomentRemindCell : MNTableViewCell

@property (nonatomic, strong) WXMomentRemindViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
