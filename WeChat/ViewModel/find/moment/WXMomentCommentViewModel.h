//
//  WXMomentCommentViewModel.h
//  WeChat
//
//  Created by Vincent on 2019/5/8.
//  Copyright © 2019 Vincent. All rights reserved.
//  评论视图模型

#import "WXMomentEventViewModel.h"
#import "WXComment.h"

@interface WXMomentCommentViewModel : WXMomentEventViewModel
/**
 记录数据模型
 */
@property (nonatomic, readonly, strong) WXComment *comment;

/**
 实例化评论视图模型
 */
- (instancetype)initWithComment:(WXComment *)comment;

@end
