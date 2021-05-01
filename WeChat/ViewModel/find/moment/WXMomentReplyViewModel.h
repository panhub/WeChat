//
//  WXMomentReplyViewModel.h
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈评论/回复视图模型

#import <Foundation/Foundation.h>
@class WXMomentViewModel;

@interface WXMomentReplyViewModel : NSObject
/**
 发起人
 */
@property (nonatomic, strong) WXUser *fromUser;
/**
 目标人
 */
@property (nonatomic, strong) WXUser *toUser;
/**
 内容
 */
@property (nonatomic, copy) NSString *content;
/**
 事件索引
 */
@property (nonatomic, strong) NSIndexPath *indexPath;
/**
 触发此次事件的视图模型
 */
@property (nonatomic, strong) WXMomentViewModel *viewModel;
/**
 输入框占位符
 */
@property (nonatomic, readonly, copy) NSString *placeholder;

@end
