//
//  WXLocationMessageViewModel.h
//  MNChat
//
//  Created by Vincent on 2019/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//  位置消息视图模型

#import "WXMessageViewModel.h"

@interface WXLocationMessageViewModel : WXMessageViewModel
/**
 位置图片
 */
@property (nonatomic, strong) WXExtendViewModel *locationViewModel;

@end
