//
//  WXTransferMessageViewModel.h
//  MNChat
//
//  Created by Vincent on 2019/5/29.
//  Copyright © 2019 Vincent. All rights reserved.
//  转账消息视图模型

#import "WXMessageViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXTransferMessageViewModel : WXMessageViewModel
/**
 红包图片
 */
@property (nonatomic, strong) WXExtendViewModel *iconViewModel;
/**
 领取状态
 */
@property (nonatomic, strong) WXExtendViewModel *stateLabelModel;

@end

NS_ASSUME_NONNULL_END
