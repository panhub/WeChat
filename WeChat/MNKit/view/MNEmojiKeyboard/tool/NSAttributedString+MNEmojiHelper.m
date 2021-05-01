//
//  NSMutableAttributedString+MNEmojiHelper.m
//  MNKit
//
//  Created by Vincent on 2019/2/7.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "NSAttributedString+MNEmojiHelper.h"
#import "MNEmojiManager.h"

@implementation NSAttributedString (MNEmojiHelper)

#pragma mark - 获取文字内容
- (NSString *)emoji_plainText {
    return [self emoji_plainTextForRange:NSMakeRange(0, self.length)];
}

- (NSString *)emoji_plainTextForRange:(NSRange)range {
    if (range.location == NSNotFound || range.length == 0 || (range.location + range.length) > self.length) return @"";
    NSMutableString *result = @"".mutableCopy;
    NSString *string = self.string;
    [self enumerateAttribute:MNEmojiBackedAttributeName inRange:range options:kNilOptions usingBlock:^(MNEmojiBackedString *backed, NSRange rag, BOOL *stop) {
        if (backed && backed.string.length > 0) {
            [result appendString:backed.string];
        } else {
            [result appendString:[string substringWithRange:rag]];
        }
    }];
    return result.copy;
}

#pragma mark - 获取自身Range
- (NSRange)rangeOfAll {
    return NSMakeRange(0, self.length);
}

#pragma mark - 制作表情富文本
+ (NSAttributedString *)emojiAttributedStringWithString:(NSString *)string font:(UIFont *)font {
    if (string.length <= 0) return nil;
    if (!font) font = MNEmojiNormalFont;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString matchingEmojiWithFont:font];
    [attributedString addAttribute:NSFontAttributeName value:font range:attributedString.rangeOfAll];
    return attributedString;
}

#pragma mark - 制作Label富文本
+ (NSAttributedString *)labelAttributedStringWithString:(NSString *)string font:(UIFont *)font backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor {
    return [self labelAttributedStringWithString:string font:font handler:^(UILabel *label) {
        label.textColor = textColor;
        label.backgroundColor = backgroundColor;
    }];
}

+ (NSAttributedString *)labelAttributedStringWithString:(NSString *)string font:(UIFont *)font handler:(void(^)(UILabel *label))handler {
    if (!font || string.length <= 0) return nil;
    CGSize size = [string sizeWithAttributes:@{NSFontAttributeName: font}];
    /// 制作label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, size.width + 10.f, size.height)];
    label.font = font;
    label.text = string;
    label.textAlignment = NSTextAlignmentCenter;
    if (handler) {
        handler(label);
    }
    /// 转换image
    UIGraphicsBeginImageContextWithOptions(label.layer.frame.size, NO, [[UIScreen mainScreen] scale]);
    [label.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    /// 制作富文本
    MNEmojiAttachment *attachment = [[MNEmojiAttachment alloc] init];
    attachment.desc = string;
    attachment.image = image;
    attachment.bounds = CGRectMake(0.f, 0.f, image.size.width, image.size.height);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    [attributedString setBackedString:[MNEmojiBackedString backedWithString:string] range:attributedString.rangeOfAll];
    return attributedString;
}

@end

@implementation NSMutableAttributedString (MNEmojiHelper)

#pragma mark - 设置表情文字富文本
- (void)setBackedString:(MNEmojiBackedString *)backedString range:(NSRange)range {
    if (backedString && ![NSNull isEqual:backedString]) {
        [self addAttribute:MNEmojiBackedAttributeName value:backedString range:range];
    } else {
        [self removeAttribute:MNEmojiBackedAttributeName range:range];
    }
}

#pragma mark - 匹配替换表情
- (void)matchingEmojiWithFont:(UIFont *)font {
    if (self.length <= 0) return;
    if (!font) font = MNEmojiNormalFont;
    NSArray<MNEmojiAttachment *>*matchResults = [MNEmojiManager matchingEmojiForString:self.string];
    if (matchResults.count <= 0) return;
    NSUInteger offset = 0;
    for (MNEmojiAttachment *attachment in matchResults) {
        attachment.bounds = CGRectMake(0.f, font.descender, font.lineHeight, font.lineHeight);
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        [attributedString setBackedString:[MNEmojiBackedString backedWithString:attachment.desc] range:NSMakeRange(0, attributedString.length)];
        if (!attributedString) continue;
        NSRange range = NSMakeRange(attachment.range.location - offset, attachment.desc.length);
        [self replaceCharactersInRange:range withAttributedString:attributedString];
        offset += (attachment.desc.length - attributedString.length);
    }
}

@end
