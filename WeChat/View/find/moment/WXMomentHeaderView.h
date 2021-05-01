//
//  WXMomentHeaderView.h
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈正文

#import "MNTableViewHeaderFooterView.h"
@class WXMomentViewModel;

@interface WXMomentHeaderView : MNTableViewHeaderFooterView

+ (instancetype)headerViewWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) WXMomentViewModel *viewModel;

@end
