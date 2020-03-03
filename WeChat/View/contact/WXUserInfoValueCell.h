//
//  WXUserInfoValueCell.h
//  MNChat
//
//  Created by Vincent on 2019/5/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNTableViewCell.h"
#import "WXDataValueModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXUserInfoValueCell : MNTableViewCell

@property (nonatomic, strong) WXDataValueModel *model;

+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView model:(WXDataValueModel *)model;

@end

NS_ASSUME_NONNULL_END
