//
//  WXMoneyLabel.m
//  WeChat
//
//  Created by Vincent on 2019/5/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMoneyLabel.h"

@interface WXMoneyLabel ()
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) UILabel *moneyLabel;
@end

@implementation WXMoneyLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        /// ¥
        UILabel *badgeLabel = [UILabel new];
        badgeLabel.font = SansFontBold(self.height_mn/3.f*2.f);
        badgeLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:.8f];
        badgeLabel.text = @"¥";
        [badgeLabel sizeToFit];
        [self addSubview:badgeLabel];
        self.badgeLabel = badgeLabel;
        /// 金额
        UILabel *moneyLabel = [UILabel new];
        moneyLabel.font = SansFontMedium(self.height_mn);
        moneyLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:.8f];
        [self addSubview:moneyLabel];
        self.moneyLabel = moneyLabel;
        /// 金额角标位置
        self.badgeLabel.top_mn = self.badgeLabel.font.descender - self.moneyLabel.font.descender;
        /// 设置默认值
        [self setMoney:@"0.00"];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat x = (self.width_mn - (self.badgeLabel.width_mn + self.moneyLabel.width_mn) - 5.f)/2.f;
    self.badgeLabel.left_mn = x;
    self.moneyLabel.left_mn = self.badgeLabel.right_mn + 5.f;
}

#pragma mark - Setter/Getter
- (void)setMoney:(NSString *)money {
    if (money.length > 0) {
        NSUInteger location = [money rangeOfString:@"."].location;
        if (location == NSNotFound) {
            money = [money stringByAppendingString:@".00"];
        } else if (location == money.length - 1) {
            money = [money stringByAppendingString:@"00"];
        } else if (location == money.length - 2) {
            money = [money stringByAppendingString:@"0"];
        } else if (location < money.length - 3) {
            money = [money substringToIndex:location + 3];
        }
    } else {
        money = @"0.00";
    }
    _money = [money copy];
    self.moneyLabel.text = money;
    [self.moneyLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor.copy;
    self.badgeLabel.textColor = textColor;
    self.moneyLabel.textColor = textColor;
}

@end
