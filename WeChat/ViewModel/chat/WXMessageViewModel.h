//
//  WXMessageViewModel.h
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  消息视图模型

#import <Foundation/Foundation.h>
#import "WXExtendViewModel.h"
#import "WXMessage.h"

@interface WXMessageViewModel : NSObject
/**
 消息数据模型
 */
@property (nonatomic, strong) WXMessage *message;
/**
 高度<代表cell高度>
 */
@property (nonatomic, readonly) CGFloat height;
/**
 是否播放发送/接收音
 */
@property (nonatomic, getter=isAllowsPlaySound) BOOL allowsPlaySound;
/**
 头像
 */
@property (nonatomic, strong) WXExtendViewModel *headButtonModel;
/**
 时间
 */
@property (nonatomic, strong) WXExtendViewModel *timeLabelModel;
/**
 文字内容
 */
@property (nonatomic, strong) WXExtendViewModel *textLabelModel;
/**
 描述文字
 */
@property (nonatomic, strong) WXExtendViewModel *detailLabelModel;
/**
 消息可视部分
 */
@property (nonatomic, strong) WXExtendViewModel *imageViewModel;
/**
 气泡
 */
@property (nonatomic, strong) WXExtendViewModel *borderModel;
/**
 头像点击事件
 */
@property (nonatomic, copy) void (^headButtonClickedHandler) (WXMessageViewModel *viewModel);
/**
 图片点击事件
 */
@property (nonatomic, copy) void (^imageViewClickedHandler) (WXMessageViewModel *viewModel);
/**
 文字点击事件
 */
@property (nonatomic, copy) void (^textLabelClickedHandler) (WXMessageViewModel *viewModel);

/**
 唯一实例化入口
 @param message 消息模型
 @return 消息视图模型
 */
+ (instancetype)viewModelWithMessage:(WXMessage *)message;

/**
 约束控件
 */
- (void)layoutSubviews MNKIT_REQUIRES_SUPER;

/**
 更新控件信息<红包状态改变>
 @return 是否更新成功
 */
- (BOOL)setNeedsUpdateSubviews;

@end
