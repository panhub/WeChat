//
//  WXUserCell.m
//  WeChat
//
//  Created by Vincent on 2019/5/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXUserCell.h"

@implementation WXUserCell
+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView model:(WXUserInfo *)model {
    WXUserCell *cell = [tableView dequeueReusableCellWithIdentifier:model.cell];
    if (!cell) {
        cell = [[NSClassFromString(model.cell) alloc] initWithReuseIdentifier:model.cell size:CGSizeMake(tableView.width_mn, model.rowHeight)];
    }
    return cell;
}

- (void)setModel:(WXUserInfo *)model {
    _model = model;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
