//
//  WXMomentInputView.h
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈评论视图

#import <UIKit/UIKit.h>
@class WXMomentReplyViewModel;

@interface WXMomentInputView : UIView

/**
 编辑事件回调
 */
@property (nonatomic, copy) void (^beginEditingHandler) (WXMomentReplyViewModel *viewModel, BOOL animated);
@property (nonatomic, copy) void (^endEditingHandler) (WXMomentReplyViewModel *viewModel, BOOL animated);

/**
 绑定视图模型
 @param viewModel 视图模型
 */
- (void)bindViewModel:(WXMomentReplyViewModel *)viewModel;

@end
