//
//  WXWebpageMessageViewModel.h
//  WeChat
//
//  Created by Vincent on 2019/5/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  网页消息视图模型

#import "WXMessageViewModel.h"

@interface WXWebpageMessageViewModel : WXMessageViewModel

/**
 网页缩略图片
 */
@property (nonatomic, strong) WXExtendViewModel *thumbnailViewModel;

@end
