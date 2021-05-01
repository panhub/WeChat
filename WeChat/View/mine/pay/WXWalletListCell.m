//
//  WXWalletListCell.m
//  WeChat
//
//  Created by Vincent on 2019/6/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXWalletListCell.h"
#import "WXDataValueModel.h"

@interface WXWalletListCell ()
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UIImageView *arrowView;
@end

@implementation WXWalletListCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.imgView.frame = CGRectMake(15.f, MEAN(self.contentView.height_mn - 25.f), 25.f, 25.f);
        
        self.titleLabel.frame = CGRectMake(self.imgView.right_mn + self.imgView.left_mn, 0.f, 0.f, 17.f);
        self.titleLabel.centerY_mn = self.imgView.centerY_mn - 2.f;
        self.titleLabel.textColor = UIColor.darkTextColor;
        self.titleLabel.font = [UIFont systemFontOfSize:self.titleLabel.height_mn];
        
        UIImage *image = UIImageNamed(@"wx_common_list_arrow");
        CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(self.contentView.width_mn - size.width - 12.f, 0.f, size.width, size.height)
                                                           image:image];
        arrowView.centerY_mn = self.imgView.centerY_mn;
        [self.contentView addSubview:arrowView];
        self.arrowView = arrowView;
        
        self.detailLabel.frame = self.titleLabel.frame;
        self.detailLabel.font = SansFontRegular(17.f);
        self.detailLabel.textColor = self.titleLabel.textColor;
        self.detailLabel.textAlignment = NSTextAlignmentCenter;
        
        UILabel *valueLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, 0.f, 22.f) text:nil alignment:NSTextAlignmentCenter textColor:MN_R_G_B(249.f, 156.f, 59.f) font:[UIFont systemFontOfSize:12.f]];
        valueLabel.centerY_mn = self.imgView.centerY_mn;
        valueLabel.backgroundColor = MN_R_G_B(253.f, 236.f, 217.f);
        valueLabel.layer.cornerRadius = 4.f;
        valueLabel.clipsToBounds = YES;
        [self.contentView addSubview:valueLabel];
        self.valueLabel = valueLabel;
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.imgView.image = [UIImage imageNamed:model.img];
    self.titleLabel.text = model.title;
    [self.titleLabel sizeToFit];
    self.detailLabel.text = model.desc;
    [self.detailLabel sizeToFit];
    self.detailLabel.right_mn = self.arrowView.left_mn;
    self.detailLabel.hidden = model.desc.length <= 0;
    self.valueLabel.width_mn = [kTransform(NSString *, model.value) sizeWithFont:self.valueLabel.font].width + 10.f;
    self.valueLabel.text = model.value;
    self.valueLabel.left_mn = self.titleLabel.right_mn + 5.f;
    self.valueLabel.hidden = kTransform(NSString *, model.value).length <= 0;
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
