//
//  WXMessageCell.h
//  WeChat
//
//  Created by Vincent on 2019/3/28.
//  Copyright © 2019 Vincent. All rights reserved.
//  聊天消息Cell

#import "MNTableViewCell.h"
#import "WXMessageViewModel.h"

@interface WXMessageCell : MNTableViewCell
/**
 头像
 */
@property (nonatomic, strong, readonly) UIButton *headButton;
/**
 时间
 */
@property (nonatomic, strong, readonly) UILabel *timeLabel;
/**
 制作气泡
 */
@property (nonatomic, strong, readonly) UIImageView *maskImageView;
/**
 视图模型
 */
@property (nonatomic, strong) WXMessageViewModel *viewModel;

/**
 工厂方法获取cell
 @param tableView 加载cell的表格
 @param model 视图模型<依据视图模型类型来确定cell类型>
 @return 消息cell
 */
+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView model:(WXMessageViewModel *)model;

/**
 定制事件
 */
- (void)handEvents MNKIT_REQUIRES_SUPER;

@end
