//
//  UILabel+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2017/12/11.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "UILabel+MNHelper.h"

@implementation UILabel (MNHelper)
+ (instancetype)labelWithFrame:(CGRect)frame
                          text:(id)text
                     textColor:(UIColor *)textColor
                          font:(id)font {
    UILabel* label = [[UILabel alloc]initWithFrame:frame];
    label.textFont = font;
    label.string = text;
    if (textColor) label.textColor = textColor;
    return label;
}

+ (instancetype)labelWithFrame:(CGRect)frame
                          text:(id)text
                 textAlignment:(NSTextAlignment)textAlignment
                     textColor:(UIColor*)textColor
                          font:(id)font {
    UILabel *label = [UILabel labelWithFrame:frame text:text textColor:textColor font:font];
    label.textAlignment = textAlignment;
    return label;
}

- (void)setTextFont:(id)textFont {
    if (!textFont) return;
    if ([textFont isKindOfClass:[UIFont class]]) {
        self.font = (UIFont *)textFont;
    } else if ([textFont isKindOfClass:[NSNumber class]]) {
        self.font = UIFontRegular([textFont floatValue]);
    }
}

- (id)textFont {
    return self.font;
}

- (void)setString:(id)string {
    if ([string isKindOfClass:[NSString class]]) {
        self.text = (NSString *)string;
    } else if ([string isKindOfClass:[NSAttributedString class]]) {
        self.attributedText = (NSAttributedString *)string;
    }
}

- (id)string {
    if (self.attributedText) return self.attributedText;
    return self.text;
}

@end
