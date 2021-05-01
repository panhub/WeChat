//
//  WXUserCell.h
//  WeChat
//
//  Created by Vincent on 2019/5/24.
//  Copyright © 2019 Vincent. All rights reserved.
//  用户资料详情Cell

#import "MNTableViewCell.h"
#import "WXUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXUserCell : MNTableViewCell

/**数据模型*/
@property (nonatomic, strong) WXUserInfo *model;

+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView model:(WXUserInfo *)model;

@end

NS_ASSUME_NONNULL_END
