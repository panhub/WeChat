//
//  WXBankCardListCell.m
//  MNChat
//
//  Created by Vincent on 2019/6/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXBankCardListCell.h"
#import "WXBankCard.h"

@interface WXBankCardListCell ()
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *watermarkView;
@end

@implementation WXBankCardListCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.contentView.backgroundColor = UIColorWithSingleRGB(51.f);
        
        self.imgView.frame = CGRectMake(8.f, 3.f, self.contentView.width_mn - 16.f, self.contentView.height_mn - 5.f);
        self.imgView.layer.cornerRadius = 4.f;
        self.imgView.clipsToBounds = YES;
        
        CGFloat wh = self.imgView.height_mn + 35.f;
        UIImageView *watermarkView = [UIImageView imageViewWithFrame:CGRectMake(self.imgView.width_mn - wh - 15.f, MEAN(self.imgView.height_mn - wh), wh, wh) image:nil];
        watermarkView.contentMode = UIViewContentModeScaleAspectFill;
        [self.imgView addSubview:watermarkView];
        self.watermarkView = watermarkView;
        
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(15.f, 15.f, 37.f, 37.f)];
        iconView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
        iconView.layer.cornerRadius = iconView.height_mn/2.f;
        iconView.clipsToBounds = YES;
        [self.imgView addSubview:iconView];
        
        UIImageView *iconImageView = [UIImageView imageViewWithFrame:UIEdgeInsetsInsetRect(iconView.bounds, UIEdgeInsetWith(5.f)) image:nil];
        [iconView addSubview:iconImageView];
        self.iconImageView = iconImageView;
        
        self.titleLabel.frame = CGRectMake(iconView.right_mn + 5.f, iconView.top_mn, 0.f, 16.f);
        self.titleLabel.font = [UIFont systemFontOfSizes:15.f weights:.2f];
        self.titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.85f];
        [self.imgView addSubview:self.titleLabel];
        
        self.detailLabel.frame = CGRectMake(self.titleLabel.left_mn, self.titleLabel.bottom_mn + 3.f, 0.f, 13.f);
        self.detailLabel.font = [UIFont systemFontOfSize:13.f];
        self.detailLabel.textColor = self.titleLabel.textColor;
        [self.imgView addSubview:self.detailLabel];
        
        UIImage *image = [UIImage imageNamed:@"wx_pay_card_number"];
        CGSize image_size = CGSizeMultiplyToHeight(image.size, 11.f);
        for (int idx = 0; idx < 3; idx++) {
            UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(self.titleLabel.left_mn + (image_size.width + 10.f)*idx, self.imgView.height_mn - MEAN_3(self.imgView.height_mn), image_size.width, image_size.height) image:image];
            [self.imgView addSubview:imageView];
            if (idx == 2) {
                UILabel *numberLabel = [UILabel labelWithFrame:CGRectMake(imageView.right_mn + 10.f, 0.f, 0.f, 30.f) text:nil textColor:[UIColor whiteColor] font:[UIFont systemFontOfSizes:30.f weights:.15f]];
                numberLabel.centerY_mn = imageView.centerY_mn - 3.f;
                [self.imgView addSubview:numberLabel];
                self.numberLabel = numberLabel;
            }
        }
    }
    return self;
}

- (void)setCard:(WXBankCard *)card {
    _card = card;
    self.iconImageView.image = card.icon;
    self.titleLabel.text = card.name;
    [self.titleLabel sizeToFit];
    self.detailLabel.text = card.desc;
    [self.detailLabel sizeToFit];
    self.numberLabel.text = [card.number substringFromIndex:card.number.length - 4];
    [self.numberLabel sizeToFit];
    self.watermarkView.image = UIImageWithUnicode(card.watermark, UIColorWithAlpha([UIColor whiteColor], .07f), self.watermarkView.height_mn);
    if (@available(iOS 11.0, *)) {
        self.imgView.backgroundColor = [UIColor colorNamed:[card.img stringByAppendingString:@"_color"]];
    } else {
        self.imgView.backgroundColor = [self.iconImageView.image colorAtPoint:CGPointZero];
    }
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
