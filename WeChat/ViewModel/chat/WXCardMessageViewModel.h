//
//  WXCardMessageViewModel.h
//  MNChat
//
//  Created by Vincent on 2020/1/21.
//  Copyright © 2020 Vincent. All rights reserved.
//  名片消息视图模型

#import "WXMessageViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXCardMessageViewModel : WXMessageViewModel
/**
 头像视图模型
 */
@property (nonatomic, strong) WXExtendViewModel *avatarViewModel;
/**
 分割线视图模型
 */
@property (nonatomic, strong) WXExtendViewModel *separatorViewModel;
/**
 分割线视图模型
 */
@property (nonatomic, strong) WXExtendViewModel *typeLabelModel;

@end

NS_ASSUME_NONNULL_END
