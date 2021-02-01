//
//  WXCookListCell.m
//  MNChat
//
//  Created by Vincent on 2019/6/20.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookListCell.h"
#import "WXCook.h"

@implementation WXCookListCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.backgroundColor = UIColor.whiteColor;
        UIViewSetBorderRadius(self.contentView, 5.f, 1.f, [UIColor.grayColor colorWithAlphaComponent:.1f]);
        
        self.imageView.frame = self.contentView.bounds;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        self.detailLabel.frame = CGRectMake(7.f, self.contentView.height_mn - 18.f, self.contentView.width_mn - 12.f, 13.f);
        self.detailLabel.font = UIFontSystem(self.detailLabel.height_mn);
        self.detailLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.75f];
        
        self.titleLabel.frame = CGRectMake(self.detailLabel.left_mn, self.detailLabel.top_mn - 23.f, self.detailLabel.width_mn, 16.f);
        self.titleLabel.font = UIFontSystem(self.titleLabel.height_mn);
        self.titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1.f];
    }
    return self;
}

- (void)setModel:(WXCook *)model {
    _model = model;
    if (model.albums.count) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.albums.firstObject] placeholderImage:nil];
    }
}

@end
