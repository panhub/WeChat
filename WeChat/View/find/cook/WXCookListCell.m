//
//  WXCookListCell.m
//  MNChat
//
//  Created by Vincent on 2019/6/20.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookListCell.h"
#import "WXCookModel.h"

@implementation WXCookListCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.backgroundColor = UIColorWithSingleRGB(51.f);
        
        self.imageView.frame = self.contentView.bounds;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, self.contentView.height_mn/2.f, self.contentView.width_mn, self.contentView.height_mn/2.f) image:[MNBundle imageForResource:@"mask_bottom"]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:imageView];
        
        self.detailLabel.frame = CGRectMake(7.f, self.contentView.height_mn - 18.f, self.contentView.width_mn - 12.f, 13.f);
        self.detailLabel.font = UIFontSystem(self.detailLabel.height_mn);
        self.detailLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.75f];
        
        self.titleLabel.frame = CGRectMake(self.detailLabel.left_mn, self.detailLabel.top_mn - 23.f, self.detailLabel.width_mn, 16.f);
        self.titleLabel.font = UIFontSystem(self.titleLabel.height_mn);
        self.titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.f];
    }
    return self;
}

- (void)setModel:(WXCookModel *)model {
    _model = model;
    self.titleLabel.text = model.name;
    self.detailLabel.text = model.titles;
    if (model.recipe.img.length > 0) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.recipe.img] placeholderImage:nil];
    } else {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.thumbnail] placeholderImage:nil];
    }
}

@end
