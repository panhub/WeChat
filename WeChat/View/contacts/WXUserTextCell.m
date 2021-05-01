//
//  WXUserTextCell.m
//  WeChat
//
//  Created by Vincent on 2019/3/22.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXUserTextCell.h"

@implementation WXUserTextCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.imgView.frame = CGRectMake(0.f, 0.f, 20.f, 20.f);
        
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.textColor = TEXT_COLOR;
        self.titleLabel.font = UIFontWithNameSize(MNFontNameMedium, 17.f);
    }
    return self;
}

- (void)setModel:(WXUserInfo *)model {
    [super setModel:model];
    self.titleLabel.text = model.title;
    [self.titleLabel sizeToFit];
    if (model.image) {
        self.imgView.hidden = NO;
        self.imgView.image = model.image;
        CGFloat x = (self.contentView.width_mn - self.titleLabel.width_mn - self.imgView.width_mn - 8.f)/2.f;
        self.imgView.left_mn = x;
        self.titleLabel.left_mn = self.imgView.right_mn + 8.f;
        self.titleLabel.centerY_mn = self.imgView.centerY_mn = self.contentView.height_mn/2.f;
    } else {
        self.imgView.hidden = YES;
        self.titleLabel.left_mn = (self.contentView.width_mn - self.titleLabel.width_mn)/2.f;
        self.titleLabel.centerY_mn = self.contentView.height_mn/2.f;
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
