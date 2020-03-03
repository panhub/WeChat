//
//  UITextField+MNEmojiHelper.m
//  MNKit
//
//  Created by Vincent on 2019/2/13.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "UITextField+MNEmojiHelper.h"
#import "UITextField+MNHelper.h"
#import "MNEmoji.h"
#import "NSAttributedString+MNEmojiHelper.h"

@implementation UITextField (MNEmojiHelper)

#pragma mark - 插入表情
- (BOOL)inputEmoji:(MNEmoji *)emoji {
    if (!emoji || emoji.desc.length <= 0) return NO;
    NSRange selectedRange = self.selectedRange;
    if (selectedRange.location == NSNotFound) return NO;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:emoji.desc];
    [attributedString setBackedString:[MNEmojiBackedString backedWithString:emoji.desc] range:attributedString.rangeOfAll];
    
    UIFont *font = self.font ? : MNEmojiNormalFont;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedText replaceCharactersInRange:selectedRange withAttributedString:attributedString];
    [attributedText addAttribute:NSFontAttributeName value:font range:attributedText.rangeOfAll];
    
    self.attributedText = attributedText;
    self.selectedRange = NSMakeRange(selectedRange.location + attributedString.length, 0);
    [self updateEmojiAttributeIfNeeded];
    return YES;
}

#pragma mark - 纯文本内容
- (NSString *)emoji_plainText {
    if (self.attributedText.length <= 0) return @"";
    return self.attributedText.emoji_plainText;
}

#pragma mark - 更新富文本内容
- (void)updateEmojiAttributeIfNeeded {
    
    NSRange selectedRange = self.selectedRange;
    if (selectedRange.location == NSNotFound) return;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.attributedText.emoji_plainText];
    
    if (attributedString.length <= 0) return;
    
    UIFont *font = self.font ? : MNEmojiNormalFont;
    [attributedString matchingEmojiWithFont:font];
    [attributedString addAttribute:NSFontAttributeName value:font range:attributedString.rangeOfAll];
    
    NSUInteger offset = self.attributedText.length - attributedString.length;
    self.attributedText = attributedString;
    self.selectedRange = NSMakeRange(selectedRange.location - offset, 0);
}

#pragma mark - 复制/粘贴/剪切
- (void)hand_copy:(id)sender {
    NSString *string = [self.attributedText emoji_plainTextForRange:self.selectedRange];
    [UIPasteboard generalPasteboard].string = string;
}

- (void)hand_paste:(id)sender {
    NSString *string = UIPasteboard.generalPasteboard.string;
    if (string.length <= 0) return;
    
    UIFont *font = self.font ? : MNEmojiNormalFont;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString matchingEmojiWithFont:font];
    [attributedString addAttribute:NSFontAttributeName value:font range:attributedString.rangeOfAll];
    
    NSRange selectedRange = self.selectedRange;
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedText replaceCharactersInRange:self.selectedRange withAttributedString:attributedString];
    self.attributedText = attributedText;
    self.selectedRange = NSMakeRange(selectedRange.location + attributedString.length, 0);
}

- (void)hand_cut:(id)sender {
    NSString *string = [self.attributedText emoji_plainTextForRange:self.selectedRange];
    [UIPasteboard generalPasteboard].string = string;
    NSRange selectedRange = self.selectedRange;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedString replaceCharactersInRange:self.selectedRange withString:@""];
    self.attributedText = attributedString;
    self.selectedRange = NSMakeRange(selectedRange.location, 0);
}

@end
