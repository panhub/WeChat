//
//  MNTabBarItem.m
//  MNKit
//
//  Created by Vincent on 2018/12/14.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNTabBarItem.h"

@interface MNTabBarItem ()
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *badgeLabel;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIImageView *imageView;
@end

@implementation MNTabBarItem
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialized];
        [self createView];
    }
    return self;
}

- (void)initialized {
    _title = @"";
    _selectedTitle = @"";
    _badgeValue = @"";
    _badgeAlignment = MNTabBadgeAlignmentCenter;
    _titleOffset = UIOffsetMake(0.f, 3.f);
    _badgeOffset = UIOffsetZero;
    _imageEdgeInsets = UIEdgeInsetsZero;
    _titleEdgeInsets = UIEdgeInsetsZero;
    _titleColor = [UIColor darkTextColor];
    _selectedTitleColor = [UIColor colorWithRed:0.f/255.f green:122.f/255.f blue:254.f/255.f alpha:1.f];
}

- (void)createView {
    
    UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
    contentView.userInteractionEnabled = NO;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.userInteractionEnabled = NO;
    imageView.contentScaleFactor = [[UIScreen mainScreen] scale];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [contentView addSubview:imageView];
    self.imageView = imageView;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.userInteractionEnabled = NO;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:11.5f];
    [contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *badgeLabel = [UILabel new];
    badgeLabel.userInteractionEnabled = NO;
    badgeLabel.backgroundColor = [UIColor redColor];
    badgeLabel.textAlignment = NSTextAlignmentCenter;
    badgeLabel.textColor = [UIColor whiteColor];
    badgeLabel.font = UIFontRegular(12.f);
    badgeLabel.hidden = YES;
    badgeLabel.clipsToBounds = YES;
    [contentView addSubview:badgeLabel];
    self.badgeLabel = badgeLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat interval = _titleOffset.vertical;
    interval = MAX(0.f, interval);
    CGRect imageRect, titleRect;
    
    CGFloat width = self.contentView.frame.size.width;
    CGFloat height = self.contentView.frame.size.height - _titleLabel.font.pointSize - interval;
    CGFloat size = MIN(width, height);
    CGFloat max = size + interval + _titleLabel.font.pointSize;
    
    imageRect = CGRectMake((self.contentView.width_mn - size)/2.f, (self.contentView.height_mn - max)/2.f, size, size);
    
    titleRect = CGRectMake(0.f, CGRectGetMaxY(imageRect) + interval, self.contentView.width_mn, self.titleFont.pointSize);
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.imageEdgeInsets, UIEdgeInsetsZero)) {
        imageRect = UIEdgeInsetsInsetRect(self.contentView.bounds, self.imageEdgeInsets);
    }
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.titleEdgeInsets, UIEdgeInsetsZero)) {
        titleRect = UIEdgeInsetsInsetRect(self.contentView.bounds, self.titleEdgeInsets);
    }

    _imageView.frame = imageRect;
    _titleLabel.frame = titleRect;
    _badgeLabel.height_mn = _badgeLabel.font.lineHeight;
    _badgeLabel.layer.cornerRadius = _badgeLabel.height_mn/2.f;
    [self updateBadgeIfNeeded];
}

#pragma mark - 更新角标位置
- (void)updateBadgeIfNeeded {
    CGRect frame = CGRectZero;
    frame.size = _badgeLabel.size_mn;
    frame.origin.x = _badgeOffset.horizontal;
    frame.origin.y = _imageView.top_mn - frame.size.height/2.f + _badgeOffset.vertical;
    if (_badgeAlignment == MNTabBadgeAlignmentLeft) {
        frame.origin.x += _imageView.right_mn;
    } else if (_badgeAlignment == MNTabBadgeAlignmentRight) {
        frame.origin.x += _imageView.right_mn - frame.size.width;
    } else {
        frame.origin.x += _imageView.right_mn - frame.size.width/2.f;
    }
    _badgeLabel.frame = frame;
}

#pragma mark - Setter
- (void)setSelected:(BOOL)selected {
    if (selected == self.selected) return;
    [super setSelected:selected];
    if (selected) {
        self.titleLabel.text = self.selectedTitle;
        self.titleLabel.textColor = self.selectedTitleColor;
        self.imageView.image = self.selectedImage;
    } else {
        self.titleLabel.text = self.title;
        self.titleLabel.textColor = self.titleColor;
        self.imageView.image = self.image;
    }
}

#pragma mark - 修改内容
- (void)setTitle:(NSString *)title {
    if (title.length <= 0) return;
    _title = [title copy];
    if (!self.selected) {
        self.titleLabel.text = title;
    }
}

- (void)setSelectedTitle:(NSString *)selectedTitle {
    if (selectedTitle.length <= 0) return;
    _selectedTitle = [selectedTitle copy];
    if (self.selected) {
        self.titleLabel.text = selectedTitle;
    }
}

- (void)setTitleColor:(UIColor *)titleColor {
    if (!titleColor) return;
    _titleColor = [titleColor copy];
    if (!self.selected) {
        self.titleLabel.textColor = titleColor;
    }
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    if (!selectedTitleColor) return;
    _selectedTitleColor = [selectedTitleColor copy];
    if (self.selected) {
        self.titleLabel.textColor = selectedTitleColor;
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    if (!titleFont) return;
    _titleLabel.font = titleFont;
    [self setNeedsLayout];
}

- (void)setTitleOffset:(UIOffset)titleOffset {
    if (UIOffsetEqualToOffset(titleOffset, _titleOffset)) return;
    _titleOffset = titleOffset;
    [self setNeedsLayout];
}

- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(titleEdgeInsets, self.titleEdgeInsets)) return;
    _titleEdgeInsets = titleEdgeInsets;
    [self setNeedsLayout];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    if (!self.selected) {
        self.imageView.image = image;
    }
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    if (self.selected) {
        self.imageView.image = selectedImage;
    }
}

- (void)setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(imageEdgeInsets, self.imageEdgeInsets)) return;
    _imageEdgeInsets = imageEdgeInsets;
    [self setNeedsLayout];
}

- (void)setBadgeOffset:(UIOffset)badgeOffset {
    if (UIOffsetEqualToOffset(badgeOffset, _badgeOffset)) return;
    _badgeOffset = badgeOffset;
    [self setNeedsLayout];
}

- (void)setBadgeColor:(UIColor *)badgeColor {
    if (!badgeColor) return;
    _badgeLabel.backgroundColor = badgeColor;
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor {
    if (!badgeTextColor) return;
    _badgeLabel.textColor = badgeTextColor;
}

- (void)setBadgeFont:(UIFont *)badgeFont {
    if (!badgeFont) return;
    _badgeLabel.font = badgeFont;
    [self setNeedsLayout];
}

- (void)setBadgeAlignment:(MNTabBadgeAlignment)badgeAlignment {
    if (badgeAlignment == _badgeAlignment) return;
    _badgeAlignment = badgeAlignment;
    [self setNeedsLayout];
}

- (void)setBadgeValue:(NSString *)badgeValue {
    if (badgeValue.length <= 0 || [badgeValue isEqualToString:@"0"]) badgeValue = @"";
    if ([badgeValue isEqualToString:_badgeValue]) return;
    _badgeValue = [badgeValue copy];
    if (badgeValue.length <= 1) {
        _badgeLabel.width_mn = _badgeLabel.height_mn;
    } else {
        CGFloat width = [NSString stringSize:_badgeValue font:_badgeLabel.font].width + 13.f;
        width = MAX(width, _badgeLabel.height_mn);
        _badgeLabel.width_mn = width;
    }
    [_badgeLabel setText:_badgeValue];
    [self updateBadgeIfNeeded];
    [_badgeLabel setHidden:(_badgeValue.length <= 0)];
}

#pragma mark - Getter
- (UIFont *)titleFont {
    return _titleLabel.font;
}

- (UIFont *)badgeFont {
    return _badgeLabel.font;
}

- (UIColor *)badgeColor {
    return _badgeLabel.backgroundColor;
}

- (UIColor *)badgeTextColor {
    return _badgeLabel.textColor;
}

@end
