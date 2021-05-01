//
//  WXCookRecipeCell.h
//  WeChat
//
//  Created by Vincent on 2019/6/24.
//  Copyright © 2019 Vincent. All rights reserved.
//  菜谱详情Cell

#import "MNTableViewCell.h"
#import "WXCookMethodViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXCookRecipeCell : MNTableViewCell

@property (nonatomic, strong) WXCookMethodViewModel *viewModel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
