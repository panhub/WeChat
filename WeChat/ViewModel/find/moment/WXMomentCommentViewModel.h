//
//  WXMomentCommentViewModel.h
//  MNChat
//
//  Created by Vincent on 2019/5/8.
//  Copyright © 2019 Vincent. All rights reserved.
//  评论视图模型

#import "WXMomentItemViewModel.h"
#import "WXMomentComment.h"

@interface WXMomentCommentViewModel : WXMomentItemViewModel

/**
 记录数据模型
 */
@property (nonatomic, readonly, strong) WXMomentComment *comment;

- (instancetype)initWithComment:(WXMomentComment *)comment;

@end
