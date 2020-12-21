//
//  UIImage+MNAttributed.m
//  MNFoundation
//
//  Created by Vicent on 2020/10/11.
//

#import "UIImage+MNAttributed.h"

@implementation UIImage (MNAttributed)

- (NSAttributedString *)attachmentWithFont:(UIFont *)imageFont {
    return [self appendString:nil font:imageFont color:nil resizing:0.f];
}

- (NSAttributedString *)appendString:(NSString *)string font:(UIFont *)textFont color:(UIColor *)textColor resizing:(CGFloat)resizing {
    if (!textFont) textFont = [UIFont systemFontOfSize:16.5f];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageWithCGImage:self.CGImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
    attachment.bounds = CGRectMake(0.f, textFont.descender - resizing, textFont.lineHeight + resizing*2.f, textFont.lineHeight + resizing*2.f);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    if (!string || string.length <= 0) return attributedString.copy;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedText addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, string.length)];
    if (textColor) [attributedText addAttribute:NSForegroundColorAttributeName value:(textColor ? : UIColor.darkTextColor) range:NSMakeRange(0, string.length)];
    [attributedString appendAttributedString:attributedText];
    return attributedString.copy;
}

- (NSAttributedString *)insertString:(NSString *_Nullable)string font:(UIFont *)textFont color:(UIColor *_Nullable)textColor resizing:(CGFloat)resizing {
    if (!textFont) textFont = [UIFont systemFontOfSize:16.5f];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageWithCGImage:self.CGImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
    attachment.bounds = CGRectMake(0.f, textFont.descender - resizing, textFont.lineHeight + resizing*2.f, textFont.lineHeight + resizing*2.f);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    if (!string || string.length <= 0) return attributedString.copy;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedText addAttribute:NSFontAttributeName value:textFont range:NSMakeRange(0, string.length)];
    if (textColor) [attributedText addAttribute:NSForegroundColorAttributeName value:(textColor ? : UIColor.darkTextColor) range:NSMakeRange(0, string.length)];
    [attributedString insertAttributedString:attributedText atIndex:0];
    return attributedString.copy;
}

@end
