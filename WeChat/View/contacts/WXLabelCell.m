//
//  WXLabelCell.m
//  WeChat
//
//  Created by Vicent on 2021/3/29.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXLabelCell.h"
#import "WXLabel.h"

@interface WXLabelCell ()

@end

@implementation WXLabelCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.textColor = [UIColor.darkTextColor colorWithAlphaComponent:.9f];
        self.titleLabel.font = [UIFont systemFontOfSize:16.f];
        self.titleLabel.left_mn = kNavItemMargin;
        
        self.detailLabel.numberOfLines = 1;
        self.detailLabel.textColor = [UIColor.darkGrayColor colorWithAlphaComponent:.8f];
        self.detailLabel.font = [UIFont systemFontOfSize:16.f];
        self.detailLabel.left_mn = self.titleLabel.left_mn;
    }
    return self;
}

- (void)setLabel:(WXLabel *)label {
    _label = label;
    self.titleLabel.text = [label.name stringByAppendingFormat:@" (%@)", @(label.users.count).stringValue];
    [self.titleLabel sizeToFit];
    self.titleLabel.width_mn = MIN(self.titleLabel.width_mn, self.contentView.width_mn - self.titleLabel.left_mn*2.f);
    self.detailLabel.text = label.userString;
    [self.detailLabel sizeToFit];
    self.detailLabel.width_mn = MIN(self.detailLabel.width_mn, self.contentView.width_mn - self.detailLabel.left_mn*2.f);
    
    CGFloat m = (self.contentView.height_mn - self.titleLabel.height_mn - self.detailLabel.height_mn - 5.f)/2.f;
    self.titleLabel.top_mn = m;
    self.detailLabel.top_mn = self.titleLabel.bottom_mn + 5.f;
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
