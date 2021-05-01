//
//  WXLabelHeader.m
//  WeChat
//
//  Created by Vicent on 2021/3/29.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXLabelHeader.h"

@interface WXLabelHeader ()
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation WXLabelHeader
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectZero image:[[UIImage imageNamed:@"wx_chat_add"] imageWithColor:THEME_COLOR]];
        imageView.width_mn = 15.f;
        [imageView sizeFitToWidth];
        imageView.left_mn = kNavItemMargin;
        imageView.centerY_mn = self.height_mn/2.f;
        imageView.userInteractionEnabled = NO;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *textLabel = [UILabel labelWithFrame:CGRectZero text:@"" textColor:THEME_COLOR font:[UIFont systemFontOfSize:16.f]];
        textLabel.numberOfLines = 1;
        [textLabel sizeToFit];
        textLabel.left_mn = imageView.right_mn + 10.f;
        textLabel.centerY_mn = imageView.centerY_mn;
        textLabel.userInteractionEnabled = NO;
        [self addSubview:textLabel];
        self.textLabel = textLabel;
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, MN_SEPARATOR_HEIGHT)];
        separator.userInteractionEnabled = NO;
        separator.backgroundColor = SEPARATOR_COLOR;
        [self addSubview:separator];
        self.separator = separator;
        
        self.title = @"新建标签";
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.imageView.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title.copy;
    self.textLabel.text = title;
    [self.textLabel sizeToFit];
    self.textLabel.centerY_mn = self.height_mn/2.f;
    self.textLabel.left_mn = self.imageView.right_mn + 10.f;
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    self.textLabel.font = titleFont;
    self.title = self.textLabel.text;
    self.imageView.size_mn = CGSizeMake(titleFont.pointSize - 1.f, titleFont.pointSize - 1.f);
    self.contentInset = UIEdgeInsetsMake(0.f, self.imageView.left_mn, 0.f, 0.f);
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    self.imageView.left_mn = contentInset.left;
    self.imageView.centerY_mn = self.height_mn/2.f;
    self.textLabel.left_mn = self.imageView.right_mn + 10.f;
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset {
    _separatorInset = separatorInset;
    self.separator.left_mn = separatorInset.left;
    self.separator.width_mn = self.width_mn - separatorInset.left - separatorInset.right;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.separator.bottom_mn = self.height_mn;
}

@end
