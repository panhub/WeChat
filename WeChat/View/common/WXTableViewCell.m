//
//  WXTableViewCell.m
//  WeChat
//
//  Created by Vicent on 2021/3/25.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXTableViewCell.h"

@interface WXTableViewCell ()
@property (nonatomic, strong) UIView *topSeparator;
@property (nonatomic, strong) UIView *bottomSeparator;
@end

@implementation WXTableViewCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        _topSeparatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, self.contentView.width_mn);
        UIImageView *topSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_more_line"]];
        topSeparator.clipsToBounds = YES;
        topSeparator.height_mn = MN_SEPARATOR_HEIGHT;
        topSeparator.contentMode = UIViewContentModeScaleToFill;
        //topSeparator.backgroundColor = [UIColor colorWithRed:100.f/255.f green:100.f/255.f blue:100.f/255.f alpha:.2f];
        [self.contentView addSubview:topSeparator];
        self.topSeparator = topSeparator;
        
        _bottomSeparatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, self.contentView.width_mn);
        UIImageView *bottomSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_more_line"]];
        //UIView *bottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, MN_SEPARATOR_HEIGHT)];
        bottomSeparator.clipsToBounds = YES;
        bottomSeparator.height_mn = MN_SEPARATOR_HEIGHT;
        bottomSeparator.contentMode = UIViewContentModeScaleToFill;
        //bottomSeparator.backgroundColor = [UIColor colorWithRed:100.f/255.f green:100.f/255.f blue:100.f/255.f alpha:.2f];
        [self.contentView addSubview:bottomSeparator];
        self.bottomSeparator = bottomSeparator;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.topSeparator.top_mn = 0.f;
    self.topSeparator.left_mn = self.topSeparatorInset.left;
    self.topSeparator.width_mn = self.contentView.width_mn - self.topSeparatorInset.left - self.topSeparatorInset.right;
    
    self.bottomSeparator.left_mn = self.bottomSeparatorInset.left;
    self.bottomSeparator.width_mn = self.contentView.width_mn - self.bottomSeparatorInset.left - self.bottomSeparatorInset.right;
    self.bottomSeparator.bottom_mn = self.contentView.height_mn;
}

#pragma mark - Setter
- (void)setSeparatorColor:(UIColor *)separatorColor {
    [super setSeparatorColor:separatorColor];
    self.topSeparator.backgroundColor = separatorColor;
    self.bottomSeparator.backgroundColor = separatorColor;
}

- (void)setTopSeparatorInset:(UIEdgeInsets)topSeparatorInset {
    _topSeparatorInset = topSeparatorInset;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setBottomSeparatorInset:(UIEdgeInsets)bottomSeparatorInset {
    _bottomSeparatorInset = bottomSeparatorInset;
    [self setNeedsLayout];
    [self layoutIfNeeded];
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
