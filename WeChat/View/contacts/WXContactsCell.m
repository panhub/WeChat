//
//  WXContactsCell.m
//  WeChat
//
//  Created by Vincent on 2019/3/14.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXContactsCell.h"


@interface WXContactsCell ()
@property (nonatomic, strong) UIImageView *badgeView;
@end

@implementation WXContactsCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        UIImageView *badgeView = [UIImageView imageViewWithFrame:CGRectZero image:[UIImage imageNamed:@"wx_contacts_checkbox"]];
        badgeView.highlightedImage = [UIImage imageNamed:@"wx_contacts_checkboxHL"];
        badgeView.size_mn = CGSizeMultiplyToWidth(badgeView.image.size, 19.f);
        badgeView.left_mn = kNavItemMargin;
        badgeView.hidden = YES;
        [self.contentView addSubview:badgeView];
        self.badgeView = badgeView;
        
        self.imgView.frame = CGRectMake(badgeView.left_mn, 0.f, self.contentView.height_mn - 16.f, self.contentView.height_mn - 16.f);
        UIViewSetCornerRadius(self.imgView, 4.f);
        self.imgView.image = [UIImage imageWithColor:VIEW_COLOR];
        
        self.titleLabel.left_mn = self.imgView.right_mn + 10.f;
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        self.titleLabel.textColor = [UIColor.darkTextColor colorWithAlphaComponent:.8f];
        
        badgeView.centerY_mn = self.imgView.centerY_mn = self.titleLabel.centerY_mn = self.contentView.height_mn/2.f;
        
        //self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setUser:(WXUser *)user {
    _user = user;
    self.titleLabel.text = user.name;
    [self.titleLabel sizeToFit];
    self.titleLabel.centerY_mn = self.imgView.centerY_mn;
    self.titleLabel.width_mn = MIN(self.titleLabel.width_mn, self.contentView.width_mn - self.titleLabel.left_mn - self.badgeView.left_mn);
    self.imgView.image = user.avatar ? : [UIImage imageNamed:@"common_head_placeholder"];
}

- (void)setMultipleSelectEnabled:(BOOL)multipleSelectEnabled {
    if (multipleSelectEnabled == _multipleSelectEnabled) return;
    _multipleSelectEnabled = multipleSelectEnabled;
    [self setMultipleSelectEnabled:multipleSelectEnabled animated:NO];
}

- (void)setMultipleSelectEnabled:(BOOL)multipleSelectEnabled animated:(BOOL)animated {
    self.badgeView.hidden = !multipleSelectEnabled;
    [UIView animateWithDuration:(animated ? .3f : 0.f) delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.imgView.left_mn = multipleSelectEnabled ? (self.badgeView.right_mn + self.badgeView.left_mn) : self.badgeView.left_mn;
        self.titleLabel.left_mn = self.imgView.right_mn + 10.f;
        self.titleLabel.width_mn = self.contentView.width_mn - self.titleLabel.left_mn - self.badgeView.left_mn;
        //self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    } completion:nil];
}

- (void)setSelected:(BOOL)selected {
    self.badgeView.highlighted = selected;
}

- (BOOL)isSelected {
    return self.badgeView.isHighlighted;
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
