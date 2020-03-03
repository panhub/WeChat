//
//  MNEmojiButton.m
//  MNKit
//
//  Created by Vincent on 2019/2/1.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNEmojiButton.h"
#import "MNEmoji.h"

@interface MNEmojiButton ()
/**标题*/
@property (nonatomic, strong) UILabel *titleLabel;
/**背景图*/
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation MNEmojiButton
- (instancetype)init {
    return [self initWithFrame:self.bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleInset = UIEdgeInsetsZero;
        _imageInset = UIEdgeInsetsZero;
        
        self.backgroundColor = UIColor.clearColor;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.userInteractionEnabled = NO;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.userInteractionEnabled = NO;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

- (void)fixedImageSize {
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
}

- (void)fixedTitleSize {
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
}

#pragma mark - Setter
- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setTitleFont:(UIFont *)titleFont {
    self.titleLabel.font = titleFont;
}

- (void)setTitleColor:(UIColor *)titleColor {
    self.titleLabel.textColor = titleColor;
}

- (void)setEmoji:(MNEmoji *)emoji {
    _emoji = emoji;
    if (emoji.image.images.count) {
        self.imageView.image = emoji.image.images.firstObject;
    } else {
        self.imageView.image = emoji.image;
    }
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    self.imageView.contentMode = contentMode;
}

- (void)setTitleInset:(UIEdgeInsets)titleInset {
    _titleInset = titleInset;
    self.titleLabel.autoresizingMask = UIViewAutoresizingNone;
    self.titleLabel.frame = UIEdgeInsetsInsetRect(self.bounds, titleInset);
}

- (void)setImageInset:(UIEdgeInsets)imageInset {
    self.imageView.autoresizingMask = UIViewAutoresizingNone;
    self.imageView.frame = UIEdgeInsetsInsetRect(self.bounds, imageInset);
}

#pragma mark - Getter
- (NSString *)title {
    return self.titleLabel.text;
}

- (UIImage *)image {
    return self.imageView.image;
}

- (UIColor *)titleColor {
    return self.titleLabel.textColor;
}

- (UIFont *)titleFont {
    return self.titleLabel.font;
}

- (UIViewContentMode)contentMode {
    return self.imageView.contentMode;
}

@end
