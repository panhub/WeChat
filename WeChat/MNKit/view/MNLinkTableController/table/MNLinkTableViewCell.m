//
//  MNLinkTableViewCell.m
//  MNKit
//
//  Created by Vincent on 2019/6/25.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNLinkTableViewCell.h"

@interface MNLinkTableViewCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation MNLinkTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

- (void)setTitleFont:(UIFont *)titleFont {
    self.titleLabel.font = titleFont;
}

- (void)setTitleColor:(UIColor *)titleColor {
    self.titleLabel.textColor = titleColor;
}

- (void)setTitleAlignment:(NSTextAlignment)titleAlignment {
    self.titleLabel.textAlignment = titleAlignment;
}

- (void)setTitle:(id)title {
    if ([title isKindOfClass:NSString.class]) {
        self.titleLabel.text = title;
    } else if ([title isKindOfClass:NSAttributedString.class]) {
        self.titleLabel.attributedText = title;
    } else {
        self.titleLabel.text = @"";
    }
}

- (void)setTitleInset:(UIEdgeInsets)titleInset {
    self.titleLabel.autoresizingMask = UIViewAutoresizingNone;
    self.titleLabel.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, titleInset);
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
}

- (void)setTitleNumberOfLines:(NSInteger)titleNumberOfLines {
    self.titleLabel.numberOfLines = titleNumberOfLines;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
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
