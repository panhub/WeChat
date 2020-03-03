//
//  WXUserInfoValueCell2.m
//  MNChat
//
//  Created by Vincent on 2019/3/22.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXUserInfoValueCell2.h"

@implementation WXUserInfoValueCell2

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.imgView.frame = CGRectMake(0.f, MEAN(self.contentView.height_mn - 20.f), 20.f, 20.f);
        
        self.titleLabel.frame = CGRectMake(0.f, 0.f, 0.f, 17.f);
        self.titleLabel.centerY_mn = self.imgView.centerY_mn - 3.f;
        self.titleLabel.textColor = TEXT_COLOR;
        self.titleLabel.font = UIFontWithNameSize(MNFontNameMedium, 17.f);
        
        self.separatorInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    [super setModel:model];
    self.titleLabel.text = model.title;
    [self.titleLabel sizeToFit];
    self.imgView.image = [UIImage imageNamed:model.img];
    if (model.img.length > 0) {
        self.imgView.hidden = NO;
        CGFloat x = MEAN(self.contentView.width_mn - self.titleLabel.width_mn - self.imgView.width_mn - 8.f);
        self.imgView.left_mn = x;
        self.titleLabel.left_mn = self.imgView.right_mn + 8.f;
    } else {
        self.imgView.hidden = YES;
        self.titleLabel.left_mn = MEAN(self.contentView.width_mn - self.titleLabel.width_mn);
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
