//
//  MNEmptyView.m
//  MNKit
//
//  Created by Vincent on 2017/8/3.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "MNEmptyView.h"
#import "MNConfiguration.h"
#import "UIImage+MNHelper.h"
#import "UIView+MNFrame.h"
#import "NSString+MNHelper.h"
#import "UIImageView+MNHelper.h"
#import "MNExtern.h"

@interface MNEmptyView()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *imageView;
@end

#define MNEmptyViewFontSize                 16.f
#define MNEmptyViewLabelHeight            17.f
#define MNEmptyViewButtonHeight          35.f
#define MNEmptyViewContentMargin        25.f
#define MNEmptyViewAnimationDuration   .2f

@implementation MNEmptyView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame delegate:nil];
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<MNEmptyViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0.f;
        self.delegate = delegate;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self createView];
    }
    return self;
}

- (void)createView {
    UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    UIImageView *imageView = [[UIImageView alloc]init];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setClipsToBounds:YES];
    [contentView addSubview:imageView];
    self.imageView = imageView;
    
    UILabel *label = [[UILabel alloc]init];
    [label setTextColor:[[UIColor darkTextColor] colorWithAlphaComponent:.8f]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:UIFontRegular(MNEmptyViewFontSize)];
    [contentView addSubview:label];
    self.label = label;
    
    UIButton *button = [[UIButton alloc]init];
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [button setTitleColor:[UIColor colorWithRed:0.f/255.f green:122.f/255.f blue:254.f/255.f alpha:1.f] forState:UIControlStateNormal];
    [button.titleLabel setFont:UIFontRegular(MNEmptyViewFontSize)];
    button.layer.cornerRadius = 5.f;
    button.layer.borderColor = [[UIColor colorWithRed:0.f/255.f green:122.f/255.f blue:254.f/255.f alpha:1.f] CGColor];
    button.layer.borderWidth = .8f;
    [button addTarget:self action:@selector(buttonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:button];
    self.button = button;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = _imageView.height_mn;
    height += (_imageView.height_mn > 0.f && _label.height_mn > 0.f ? MNEmptyViewContentMargin : 0.f);
    height += _label.height_mn;
    height += (_label.height_mn > 0.f && _button.height_mn > 0.f ? MNEmptyViewContentMargin : 0.f);
    height += _button.height_mn;
    
    CGFloat y = (self.contentView.height_mn - height)/2.f;
    
    _imageView.top_mn = y;
    
    _label.width_mn = self.width_mn - MNEmptyViewContentMargin*2.f;
    _label.top_mn = (_imageView.bottom_mn + (_imageView.height_mn > 0.f && _label.height_mn > 0.f ? MNEmptyViewContentMargin : 0.f));
    
    _button.top_mn = (_label.bottom_mn + (_label.height_mn > 0.f && _button.height_mn > 0.f ? MNEmptyViewContentMargin : 0.f));
    
    _imageView.centerX_mn = _label.centerX_mn = _button.centerX_mn = self.width_mn/2.f;
}

#pragma mark - Setter
- (void)setImage:(UIImage *)image {
    _imageView.image = image;
    _imageView.size_mn = image ? CGSizeMake(130.f, 130.f) : CGSizeZero;
    [self setNeedsLayout];
}

- (void)setMessage:(NSString *)message {
    _label.text = message;
    _label.height_mn = message.length ? _label.font.pointSize : 0.f;
    [self setNeedsLayout];
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    if (buttonTitle.length <= 0) {
        _button.height_mn = 0.f;
    } else {
        CGSize size = [NSString getStringSize:buttonTitle font:UIFontRegular(MNEmptyViewFontSize)];
        _button.width_mn = size.width + 30.f;
        _button.height_mn = MNEmptyViewButtonHeight;
        [self.button setTitle:buttonTitle forState:UIControlStateNormal];
    }
    [self setNeedsLayout];
}

- (void)setTextColor:(UIColor *)textColor {
    self.label.textColor = textColor;
}

- (void)setButtonTitleColor:(UIColor *)buttonTitleColor {
    self.button.layer.borderColor = buttonTitleColor.CGColor;
    [self.button setTitleColor:buttonTitleColor forState:UIControlStateNormal];
}

#pragma mark - Event
- (void)buttonTouchUpInside {
    if ([self.delegate respondsToSelector:@selector(dataEmptyViewButtonClicked:)]) {
        [self.delegate dataEmptyViewButtonClicked:self];
    }
}

#pragma mark - show&&dismiss
- (void)show {
    if (self.alpha == 1.f) return;
    [UIView animateWithDuration:MNEmptyViewAnimationDuration animations:^{
        self.alpha = 1.f;
    } completion:nil];
}

- (void)dismiss {
    if (self.alpha == 0.f) return;
    [UIView animateWithDuration:MNEmptyViewAnimationDuration animations:^{
        self.alpha = 0.f;
    }];
}

@end
