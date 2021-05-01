//
//  WXRedpacketMessageViewModel.h
//  WeChat
//
//  Created by Vincent on 2019/5/23.
//  Copyright © 2019 Vincent. All rights reserved.
//  红包消息视图模型

#import "WXMessageViewModel.h"

@interface WXRedpacketMessageViewModel : WXMessageViewModel
/**
 红包图片
 */
@property (nonatomic, strong) WXExtendViewModel *iconViewModel;
/**
 领取状态
 */
@property (nonatomic, strong) WXExtendViewModel *stateLabelModel;
/**
 领取描述
 */
@property (nonatomic, strong) WXExtendViewModel *descLabelModel;

@end
