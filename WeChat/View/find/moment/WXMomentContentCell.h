//
//  WXMomentContentCell.h
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈 评论/点赞

#import "MNTableViewCell.h"
@class WXMomentItemViewModel;

@interface WXMomentContentCell : MNTableViewCell

@property (nonatomic, strong) WXMomentItemViewModel *viewModel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
