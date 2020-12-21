//
//  WXBankCardView.m
//  MNChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXBankCardView.h"
#import "WXBankCard.h"

@interface WXBankCardView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *cardLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIImageView *arrowView;
@end

@implementation WXBankCardView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColorWithSingleRGB(251.f);
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(23.f, 18.f, 0.f, 14.f) text:@"" textColor:UIColorWithAlpha([UIColor darkTextColor], .85f) font:[UIFont systemFontOfSize:14.f]];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UIImageView *iconView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 17.f, 17.f) image:[UIImage imageNamed:@"wx_pay_card"]];
        iconView.centerY_mn = titleLabel.centerY_mn;
        [self addSubview:iconView];
        self.iconView = iconView;
        
        UIImage *image = [UIImage imageNamed:@"wx_common_list_arrow"];
        CGSize size = CGSizeMultiplyToHeight(image.size, 22.f);
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(self.width_mn - size.width - titleLabel.left_mn + 3.f, 0.f, size.width, size.height) image:image];
        arrowView.centerY_mn = titleLabel.centerY_mn;
        [self addSubview:arrowView];
        self.arrowView = arrowView;
        
        UILabel *cardLabel = [UILabel labelWithFrame:CGRectMake(0.f, titleLabel.top_mn, 0.f, titleLabel.height_mn) text:@"请选择银行卡" textColor:UIColorWithAlpha([UIColor darkTextColor], .85f) font:titleLabel.font];
        [self addSubview:cardLabel];
        self.cardLabel = cardLabel;
        
        UILabel *hintLabel = [UILabel labelWithFrame:CGRectMake(0.f, cardLabel.bottom_mn + 10.f, 0.f, cardLabel.height_mn) text:@"" textColor:UIColorWithAlpha([UIColor darkTextColor], .5f) font:cardLabel.font];
        [self addSubview:hintLabel];
        self.hintLabel = hintLabel;
        
        self.height_mn = hintLabel.bottom_mn + cardLabel.top_mn;
    }
    return self;
}

- (void)setType:(WXBankCardViewType)type {
    _type = type;
    self.titleLabel.text = type == WXBankCardViewRecharge ? @"储蓄卡" : @"到账银行卡";
    self.hintLabel.text = type == WXBankCardViewRecharge ? @"单日交易限额 ¥ 50000.00" : @"2小时内到账";
    [self.titleLabel sizeToFit];
    self.iconView.left_mn = self.titleLabel.right_mn + 15.f;
    self.cardLabel.left_mn = self.iconView.right_mn + 8.f;
    self.cardLabel.width_mn = self.arrowView.left_mn - self.cardLabel.left_mn - 10.f;
    self.hintLabel.left_mn = self.cardLabel.left_mn;
    self.hintLabel.width_mn = self.cardLabel.width_mn;
}

- (void)setCard:(WXBankCard *)card {
    _card = card;
    if (!card) {
        self.iconView.image = [UIImage imageNamed:@"wx_pay_card"];
        self.cardLabel.text = @"请选择银行卡";
    } else {
        self.iconView.image = card.icon;
        self.cardLabel.text = [NSString stringWithFormat:@"%@ (%@)", card.name, [card.number substringFromIndex:card.number.length - 4]];
    }
}

@end
