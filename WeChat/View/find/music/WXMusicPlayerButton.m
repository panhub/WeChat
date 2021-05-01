//
//  WXMusicPlayerButton.m
//  WeChat
//
//  Created by Vincent on 2020/2/3.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXMusicPlayerButton.h"

#define WXMusicPlayerDarkColor      [UIColor.darkTextColor colorWithAlphaComponent:.8f]
#define WXMusicPlayerWhiteColor    MN_R_G_B(248.f, 248.f, 255.f)
#define WXMusicPlayerDisableColor  MN_R_G_B(145.f, 154.f, 165.f)

@interface WXMusicPlayerButton ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation WXMusicPlayerButton
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.timeInterval = .5f;
        self.backgroundColor = UIColor.clearColor;
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:self.bounds image:nil];
        imageView.userInteractionEnabled = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageView];
        self.imageView = imageView;
    }
    return self;
}

#pragma mark - Setter
- (void)setImage:(UIImage *)image {
    self.imageView.image = image.templateImage;
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    self.imageView.highlightedImage = selectedImage.templateImage;
}

- (void)setSelected:(BOOL)selected {
    if (selected == self.isSelected) return;
    [super setSelected:selected];
    self.imageView.highlighted = selected;
}

- (void)setEnabled:(BOOL)enabled {
    if (enabled == self.isEnabled) return;
    [super setEnabled:enabled];
    self.style = self.style;
}

- (void)setStyle:(WXPlayStyle)style {
    _style = style;
    self.imageView.tintColor = self.isEnabled ? (style == WXPlayStyleDark ? WXMusicPlayerWhiteColor : WXMusicPlayerDarkColor) : WXMusicPlayerDisableColor;
}

- (void)setTintColor:(UIColor *)tintColor {
    self.imageView.tintColor = tintColor;
}

#pragma mark - Getter
- (UIImage *)image {
    return self.imageView.image;
}

- (UIImage *)selectedImage {
    return self.imageView.highlightedImage.originalImage;
}

- (UIColor *)tintColor {
    return self.imageView.tintColor;
}

@end
