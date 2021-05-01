//
//  WXLocationListCell.m
//  WeChat
//
//  Created by Vincent on 2019/5/11.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXLocationListCell.h"
#import <AMapSearchKit/AMapSearchKit.h>

@implementation WXLocationListCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.titleLabel.frame = CGRectMake(15.f, 0.f, self.contentView.width_mn - 30.f, 16.f);
        self.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .95f);
        self.titleLabel.font = UIFontRegular(self.titleLabel.height_mn);
        
        self.detailLabel.frame = CGRectMake(self.titleLabel.left_mn, 0.f, self.titleLabel.width_mn, 12.f);
        self.detailLabel.textColor = UIColorWithAlpha([UIColor darkGrayColor], .7f);
        self.detailLabel.font = UIFontRegular(self.detailLabel.height_mn);
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setText:(NSString *)text {
    self.titleLabel.textColor = TEXT_COLOR;
    self.titleLabel.text = text;
    self.titleLabel.centerY_mn = self.contentView.height_mn/2.f;
    self.detailLabel.hidden = YES;
}

- (NSString *)text {
    return self.titleLabel.text;
}

- (void)setLocation:(AMapPOI *)location {
    _location = location;
    self.titleLabel.text = location.name;
    [self.titleLabel sizeToFit];
    self.titleLabel.width_mn = MIN(self.contentView.width_mn - self.titleLabel.left_mn*2.f, self.titleLabel.width_mn);
    self.detailLabel.text = location.address;
    self.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .8f);
    [self.detailLabel sizeToFit];
    self.detailLabel.width_mn = MIN(self.contentView.width_mn - self.detailLabel.left_mn*2.f, self.detailLabel.width_mn);
    if (self.detailLabel.text.length) {
        CGFloat interval = (self.contentView.height_mn - self.titleLabel.height_mn - self.detailLabel.height_mn)/2.f;
        self.titleLabel.top_mn = interval;
        self.detailLabel.top_mn = self.titleLabel.bottom_mn;
        self.detailLabel.hidden = NO;
    } else {
        self.titleLabel.centerY_mn = self.contentView.height_mn/2.f;
        self.detailLabel.hidden = YES;
    }
}

- (void)setTip:(AMapTip *)tip {
    _tip = tip;
    self.titleLabel.text = tip.name;
    [self.titleLabel sizeToFit];
    self.titleLabel.width_mn = MIN(self.contentView.width_mn - self.titleLabel.left_mn*2.f, self.titleLabel.width_mn);
    self.detailLabel.text = tip.address;
    [self.detailLabel sizeToFit];
    self.detailLabel.width_mn = MIN(self.contentView.width_mn - self.detailLabel.left_mn*2.f, self.detailLabel.width_mn);
    if (self.detailLabel.text.length) {
        CGFloat interval = (self.contentView.height_mn - self.titleLabel.height_mn - self.detailLabel.height_mn)/2.f;
        self.titleLabel.top_mn = interval;
        self.detailLabel.top_mn = self.titleLabel.bottom_mn;
        self.detailLabel.hidden = NO;
    } else {
        self.titleLabel.centerY_mn = self.contentView.height_mn/2.f;
        self.detailLabel.hidden = YES;
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.accessoryType = UITableViewCellAccessoryNone;
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
