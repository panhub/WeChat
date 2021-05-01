//
//  WXBankCardAlertViewCell.m
//  WeChat
//
//  Created by Vincent on 2019/6/4.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXBankCardAlertViewCell.h"
#import "WXBankCard.h"

@implementation WXBankCardAlertViewCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        CGFloat y = (self.contentView.height_mn - 17.f - 10.f - 14.f)/2.f;
        
        self.imgView.frame = CGRectMake(15.f, y, 25.f, 25.f);
        
        self.titleLabel.frame = CGRectMake(self.imgView.right_mn + 10.f, self.imgView.top_mn, self.contentView.width_mn - self.imgView.right_mn - 20.f, 17.f);
        self.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .9f);
        self.titleLabel.font = [UIFont systemFontOfSize:self.titleLabel.height_mn];
        
        self.detailLabel.frame = CGRectMake(self.titleLabel.left_mn, self.titleLabel.bottom_mn + 10.f, self.titleLabel.width_mn, 14.f);
        self.detailLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .5f);
        self.detailLabel.font = [UIFont systemFontOfSize:self.detailLabel.height_mn];
        
        //self.separatorInset = UIEdgeInsetsMake(0.f, self.imgView.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setWithdraw:(BOOL)withdraw {
    _withdraw = withdraw;
    self.detailLabel.text = withdraw ? @"2小时内到账" : @"单日交易限额 ¥ 50000.00";
}

- (void)setCard:(WXBankCard *)card {
    _card = card;
    self.imgView.image = card.icon;
    NSString *type = card.type ? @"储蓄卡" : @"信用卡";
    NSString *number = [card.number substringFromIndex:card.number.length - 4];
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@ (%@)", card.name, type, number];
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
