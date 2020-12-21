//
//  UILabel+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2017/12/11.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "UILabel+MNHelper.h"

@implementation UILabel (MNHelper)
+ (UILabel *)labelWithFrame:(CGRect)frame
                          text:(id)text
                     textColor:(UIColor *)textColor
                          font:(id)font {
    UILabel* label = [[self alloc] initWithFrame:frame];
    label.textFont = font;
    label.string = text;
    if (textColor) label.textColor = textColor;
    return label;
}

+ (UILabel *)labelWithFrame:(CGRect)frame
                          text:(id)text
                     alignment:(NSTextAlignment)alignment
                     textColor:(UIColor*)textColor
                          font:(id)font {
    UILabel *label = [UILabel labelWithFrame:frame text:text textColor:textColor font:font];
    label.textAlignment = alignment;
    return label;
}

- (void)setTextFont:(id)textFont {
    if (!textFont) return;
    if ([textFont isKindOfClass:[UIFont class]]) {
        self.font = (UIFont *)textFont;
    } else if ([textFont isKindOfClass:[NSNumber class]]) {
        self.font = [UIFont systemFontOfSize:[textFont floatValue]];
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

- (CGSize)stringSize {
    if (self.attributedText) {
        NSString *string = self.attributedText.string;
        NSDictionary<NSAttributedStringKey, id> *attributes = [self.attributedText attributesAtIndex:0 effectiveRange:nil];
        if (attributes.count && string.length) {
            return [string sizeWithAttributes:attributes];
        }
    }
    if (!self.font || self.text.length <= 0) return CGSizeZero;
    return [self.text sizeWithAttributes:@{NSFontAttributeName: self.font}];
}

- (CGSize)boundingSizeByWidth {
    if (self.attributedText) {
        NSString *string = self.attributedText.string;
        NSDictionary<NSAttributedStringKey, id> *attributes = [self.attributedText attributesAtIndex:0 effectiveRange:nil];
        if (attributes.count && string.length) {
            return [string boundingRectWithSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                     attributes:attributes
                                        context:nil].size;
        }
    }
    if (!self.font || self.text.length <= 0) return CGSizeZero;
    return [self.text boundingRectWithSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)
                                options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName: self.font}
                                context:nil].size;
}

- (CGSize)boundingSizeByHeight {
    if (self.attributedText) {
        NSString *string = self.attributedText.string;
        NSDictionary<NSAttributedStringKey, id> *attributes = [self.attributedText attributesAtIndex:0 effectiveRange:nil];
        if (attributes.count && string.length) {
            return [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.bounds.size.height)
                                        options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                     attributes:attributes
                                        context:nil].size;
        }
    }
    if (!self.font || self.text.length <= 0) return CGSizeZero;
    return [self.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.bounds.size.height)
                                options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName: self.font}
                                context:nil].size;
}

@end
