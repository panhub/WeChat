//
//  WXMomentReplyViewModel.h
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈评论/回复视图模型

#import <Foundation/Foundation.h>
@class WXMomentViewModel;

@interface WXMomentReplyViewModel : NSObject
/**
 触发此次事件的视图模型
 */
@property (nonatomic, strong) WXMomentViewModel *viewModel;
/**
 触发此次事件的索引<评论row为NSInterMin>
 */
@property (nonatomic, strong) NSIndexPath *indexPath;
/**
 发起人
 */
@property (nonatomic, strong) WXUser *from_user;
/**
 目标人
 */
@property (nonatomic, strong) WXUser *to_user;
/**
 内容
 */
@property (nonatomic, copy) NSString *content;


/**
 输入框占位符
 */
@property (nonatomic, readonly, copy) NSString *placeholder;

@end
