//
//  WXCallButton.m
//  MNChat
//
//  Created by Vincent on 2020/1/31.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXCallButton.h"

@interface WXCallButton ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation WXCallButton
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
        imageView.userInteractionEnabled = NO;
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectZero text:nil textAlignment:NSTextAlignmentCenter textColor:UIColorWithAlpha(UIColor.whiteColor, .95f) font:[UIFont systemFontOfSize:12.f]];
        titleLabel.userInteractionEnabled = NO;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.size_mn = CGSizeMake(self.width_mn, self.width_mn);
    [self.titleLabel sizeToFit];
    self.titleLabel.height_mn = self.titleLabel.font.pointSize;
    self.titleLabel.bottom_mn = self.height_mn;
    self.titleLabel.centerX_mn = self.width_mn/2.f;
}

#pragma mark - Setter
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.imageView.highlighted = selected;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setSelectedImage:(UIImage *)image {
    self.imageView.highlightedImage = image;
}

#pragma mark - Getter
- (NSString *)title {
    return self.titleLabel.text;
}

- (UIImage *)image {
    return self.imageView.image;
}

- (UIImage *)selectedImage {
    return self.imageView.highlightedImage;
}

- (CGFloat)imag_cornerRadius {
    return self.imageView.layer.cornerRadius;
}

@end
