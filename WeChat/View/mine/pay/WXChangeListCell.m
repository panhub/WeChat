//
//  WXChangeListCell.m
//  MNChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChangeListCell.h"
#import "WXChangeModel.h"

@interface WXChangeListCell ()
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation WXChangeListCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        self.titleLabel.frame = CGRectMake(20.f, MEAN(self.contentView.height_mn - 16.f - 13.f - 13.f), 0.f, 16.f);
        self.titleLabel.font = UIFontRegular(self.titleLabel.height_mn);
        self.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .85f);
        
        self.detailLabel.frame = CGRectMake(0.f, 0.f, 0.f, 17.f);
        self.detailLabel.centerY_mn = self.titleLabel.centerY_mn;
        self.detailLabel.font = [UIFont systemFontOfSizes:self.detailLabel.height_mn weights:.2f];
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        
        UILabel *timeLabel = [UILabel labelWithFrame:CGRectMake(self.titleLabel.left_mn, self.titleLabel.bottom_mn + 13.f, self.contentView.width_mn - self.titleLabel.left_mn*2.f, 13.f) text:nil textColor:UIColorWithAlpha([UIColor grayColor], .5f) font:[UIFont systemFontOfSize:13.f]];
        [self.contentView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setModel:(WXChangeModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    [self.titleLabel sizeToFit];
    
    NSString *money = [NSString stringWithFormat:@"%.2f", model.money];
    if (model.money > 0.f) money = [@"+" stringByAppendingString:money];
    self.detailLabel.text = money;
    self.detailLabel.textColor = model.money > 0.f ? R_G_B(238.f, 176.f, 38.f) : [UIColor blackColor];
    [self.detailLabel sizeToFit];
    self.detailLabel.right_mn = self.contentView.width_mn - self.titleLabel.left_mn;
    
    self.timeLabel.text = [NSDate dateStringWithTimestamp:model.timestamp format:@"MM月dd日 HH:mm"];
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
