//
//  WXRedpacketInfoCell.m
//  MNChat
//
//  Created by Vincent on 2019/5/29.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXRedpacketInfoCell.h"
#import "WXDataValueModel.h"

@interface WXRedpacketInfoCell ()
@property (nonatomic, strong) UILabel *moneyLabel;
@end

@implementation WXRedpacketInfoCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.imgView.frame = CGRectMake(13.f, 15.f, self.contentView.height_mn - 30.f, self.contentView.height_mn - 30.f);
        self.imgView.layer.cornerRadius = 4.f;
        self.imgView.clipsToBounds = YES;
        
        self.titleLabel.frame = CGRectMake(self.imgView.right_mn + 10.f, self.imgView.top_mn, 0.f, 18.f);
        self.titleLabel.font = UIFontRegular(16.f);
        self.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .85f);
        
        self.detailLabel.frame = CGRectMake(self.titleLabel.left_mn, self.imgView.bottom_mn - 17.f, 0.f, 14.f);
        self.detailLabel.font = [UIFont systemFontOfSize:14.f];
        self.detailLabel.textColor = UIColorWithAlpha([UIColor darkGrayColor], .5f);
        
        UILabel *moneyLabel = [UILabel labelWithFrame:CGRectMake(0.f, self.titleLabel.top_mn, 0.f, self.titleLabel.height_mn) text:nil alignment:NSTextAlignmentRight textColor:self.titleLabel.textColor font:self.titleLabel.font];
        [self.contentView addSubview:moneyLabel];
        self.moneyLabel = moneyLabel;
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    [self.titleLabel sizeToFit];
    self.detailLabel.text = model.desc;
    [self.detailLabel sizeToFit];
    self.moneyLabel.text = model.value;
    [self.moneyLabel sizeToFit];
    self.moneyLabel.right_mn = self.contentView.width_mn - 10.f;
    self.imgView.image = model.userInfo;
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
