//
//  UIButton+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2017/11/30.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "UIButton+MNHelper.h"
#import "UIImage+MNHelper.h"
#import "NSString+MNHelper.h"
#import "MNConfiguration.h"
#import <objc/runtime.h>

@implementation UIButton (MNHelper)
#pragma mark - 实例化快捷入口
+ (UIButton *)buttonWithFrame:(CGRect)frame
                          image:(id)image
                          title:(id)title
                     titleColor:(UIColor*)titleColor
                           titleFont:(id)font
{
    UIButton* button = [[self alloc]initWithFrame:frame];
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [button setTitleFont:font];
    [button setButtonTitle:title forState:UIControlStateNormal];
    [button setBackgroundImage:image];
    if (titleColor) [button setTitleColor:titleColor forState:UIControlStateNormal];
    return button;
}

- (void)setTitleFont:(id)titleFont {
    if (!titleFont) return;
    if ([titleFont isKindOfClass:[UIFont class]]) {
        self.titleLabel.font = (UIFont *)titleFont;
    } else if ([titleFont isKindOfClass:[NSNumber class]]) {
        self.titleLabel.font = UIFontRegular([titleFont floatValue]);
    }
}

- (id)titleFont {
    return self.titleLabel.font;
}

- (void)setBackgroundImage:(id)backgroundImage {
    [self setBackgroundImage:backgroundImage
                    forState:UIControlStateNormal
            placeholderImage:nil];
}

- (id)backgroundImage {
    return [self backgroundImageForState:UIControlStateNormal];
}

- (void)setBackgroundImage:(id)image
                  forState:(UIControlState)state
          placeholderImage:(UIImage *)placeholderImage
{
    if (placeholderImage) [self setBackgroundImage:placeholderImage forState:state];
    if (!image) return;
    if ([image isKindOfClass:UIImage.class]) {
        [self setBackgroundImage:image forState:state];
    } else {
        __weak typeof(self) weakself = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *img = [UIImage imageWithObject:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (img) [weakself setBackgroundImage:img forState:state];
            });
        });
    }
}

- (void)setButtonTitle:(id)title {
    [self setButtonTitle:title forState:UIControlStateNormal];
}

- (id)buttonTitle {
    id title = [self attributedTitleForState:UIControlStateNormal];
    if (!title) {
        title = [self titleForState:UIControlStateNormal];
    }
    return title;
}

- (void)setButtonTitle:(id)title forState:(UIControlState)state {
    if (!title) return;
    if ([title isKindOfClass:[NSString class]]) {
        [self setTitle:(NSString *)title forState:state];
    } else if ([title isKindOfClass:[NSAttributedString class]]) {
        [self setAttributedTitle:(NSAttributedString *)title forState:state];
    }
}

#pragma mark - 取消按钮效果
- (void)cancelHighlightedEffect {
    self.adjustsImageWhenHighlighted = NO;
    [self.layer removeAllAnimations];
}

- (void)cancelDisabledEffect {
    self.adjustsImageWhenDisabled = NO;
    [self.layer removeAllAnimations];
}

@end
