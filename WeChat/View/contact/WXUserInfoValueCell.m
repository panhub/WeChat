//
//  WXUserInfoValueCell.m
//  MNChat
//
//  Created by Vincent on 2019/5/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXUserInfoValueCell.h"

@implementation WXUserInfoValueCell
+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView model:(WXDataValueModel *)model {
    NSString *cls = [@"WXUserInfoValueCell" stringByAppendingString:[NSString stringWithFormat:@"%@", model.userInfo]];
    WXUserInfoValueCell *cell = [tableView dequeueReusableCellWithIdentifier:cls];
    if (!cell) {
        cell = [[NSClassFromString(cls) alloc] initWithReuseIdentifier:cls size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
    }
    return cell;
}

- (void)setModel:(WXDataValueModel *)model {
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
