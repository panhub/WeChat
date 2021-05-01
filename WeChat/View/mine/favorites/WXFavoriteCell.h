//
//  WXFavoriteCell.h
//  WeChat
//
//  Created by Vicent on 2021/3/20.
//  Copyright © 2021 Vincent. All rights reserved.
//  收藏夹Cell

#import "MNTableViewCell.h"
@class WXFavoriteViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXFavoriteCell : MNTableViewCell

/**视图模型*/
@property (nonatomic, strong) WXFavoriteViewModel *viewModel;

/**白色背景*/
@property (nonatomic, strong, readonly) UIView *containerView;

/**
 工厂方法获取cell
 @param tableView 加载cell的表格
 @param model 视图模型<依据视图模型类型来确定cell类型>
 @param delegate 交互代理
 @return 收藏cell
 */
+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView model:(WXFavoriteViewModel *)model delegate:(id<MNTableViewCellDelegate> _Nullable)delegate;

@end

NS_ASSUME_NONNULL_END
