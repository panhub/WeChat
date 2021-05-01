//
//  UITextField+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2017/12/11.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "UITextField+MNHelper.h"
#import "MNConfiguration.h"
#import "NSObject+MNSwizzle.h"
#import <objc/message.h>

static NSString * MNTextFieldActionKey = @"com.mn.textfield.perform.actions.key";
static NSString * MNTextFieldPlaceholderFontKey = @"com.mn.textfield.placeholder.font.key";
static NSString * MNTextFieldPlaceholderColorKey = @"com.mn.textfield.placeholder.color.key";

@implementation UITextField (MNHelper)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSClassFromString(@"UITextField") swizzleInstanceMethod:@selector(canPerformAction:withSender:) withSelector:@selector(mn_canPerformAction:withSender:)];
        [NSClassFromString(@"UITextField") swizzleInstanceMethod:@selector(setPlaceholder:) withSelector:@selector(mn_setPlaceholder:)];
        [NSClassFromString(@"UITextField") swizzleInstanceMethod:@selector(setAttributedPlaceholder:) withSelector:@selector(mn_setAttributedPlaceholder:)];
    });
}

- (UIColor *)placeholderColor {
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        return objc_getAssociatedObject(self, &MNTextFieldPlaceholderColorKey);
    }
#endif
    return [self valueForKeyPath:@"placeholderLabel.textColor"];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        objc_setAssociatedObject(self, &MNTextFieldPlaceholderColorKey, placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.attributedPlaceholder = self.attributedPlaceholder ? : [[NSAttributedString alloc] initWithString:self.placeholder ? : @""];
        return;
    }
#endif
    [self setValue:placeholderColor forKeyPath:@"placeholderLabel.textColor"];
}

- (UIFont *)placeholderFont {
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        return objc_getAssociatedObject(self, &MNTextFieldPlaceholderFontKey);
    }
#endif
    return [self valueForKeyPath:@"placeholderLabel.font"];
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont {
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        objc_setAssociatedObject(self, &MNTextFieldPlaceholderFontKey, placeholderFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.attributedPlaceholder = self.attributedPlaceholder ? : [[NSAttributedString alloc] initWithString:self.placeholder ? : @""];
        return;
    }
#endif
    [self setValue:placeholderFont forKeyPath:@"placeholderLabel.font"];
}

- (void)mn_setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        if (attributedPlaceholder) {
            UIFont *placeholderFont = self.placeholderFont;
            UIColor *placeholderColor = self.placeholderColor;
            NSMutableAttributedString *attributedString = attributedPlaceholder.mutableCopy;
            if (placeholderFont) {
                [attributedString addAttribute:NSFontAttributeName value:placeholderFont range:NSMakeRange(0, attributedString.length)];
            }
            if (placeholderColor) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:placeholderColor range:NSMakeRange(0, attributedString.length)];
            }
            attributedPlaceholder = attributedString.copy;
        }
    }
#endif
    [self mn_setAttributedPlaceholder:attributedPlaceholder];
}

- (void)mn_setPlaceholder:(NSString *)placeholder {
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        if (placeholder) {
            UIFont *placeholderFont = self.placeholderFont;
            UIColor *placeholderColor = self.placeholderColor;
            if (placeholderFont || placeholderColor) {
                [self mn_setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholder]];
                return;
            }
        }
    }
#endif
    [self mn_setPlaceholder:placeholder];
}

- (NSRange)selectedRange {
    /*if (!self.isFirstResponder) return NSMakeRange(0, 0);*/
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
    NSInteger length = [self offsetFromPosition:self.selectedTextRange.start toPosition:self.selectedTextRange.end];
    return NSMakeRange(location, length);
}

- (void)setSelectedRange:(NSRange)selectedRange {
    if (/*!self.isFirstResponder || */selectedRange.location == NSNotFound || (selectedRange.location + selectedRange.length) > self.text.length) return;
    UITextPosition *startPosition = [self positionFromPosition:self.beginningOfDocument offset:selectedRange.location];
    UITextPosition *endPosition = [self positionFromPosition:self.beginningOfDocument offset:selectedRange.location + selectedRange.length];
    UITextRange *selectedTextRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectedTextRange];
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

#pragma mark - 关闭粘贴/拷贝/剪切等
- (MNTextFieldActions)performActions {
    NSNumber *number = objc_getAssociatedObject(self, &MNTextFieldActionKey);
    if (number) return ((MNTextFieldActions)[number unsignedIntegerValue]);
    return MNTextFieldActionAll;
}

- (void)setPerformActions:(MNTextFieldActions)performActions {
    objc_setAssociatedObject(self, &MNTextFieldActionKey, @(performActions), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)mn_canPerformAction:(SEL)action withSender:(id)sender {
    MNTextFieldActions type = self.performActions;
    if (type == MNTextFieldActionAll) {
        return [self mn_canPerformAction:action withSender:sender];
    } else if (type == MNTextFieldActionNone) {
        return NO;
    } else {
        if (action == @selector(paste:)&&(type & MNTextFieldActionPaste)) return NO;
        if (action == @selector(select:)&&(type & MNTextFieldActionSelect)) return NO;
        if (action == @selector(selectAll:)&&(type & MNTextFieldActionSelectAll)) return NO;
        if (action == @selector(cut:)&&(type & MNTextFieldActionCut)) return NO;
        if (action == @selector(copy:)&&(type & MNTextFieldActionCopy)) return NO;
        if (action == @selector(delete:)&&(type & MNTextFieldActionDelete)) return NO;
    }
    return [self mn_canPerformAction:action withSender:sender];
}


+ (UITextField *)textFieldWithFrame:(CGRect)frame
                               font:(id)font
                        placeholder:(NSString *)placeholder
                           delegate:(id<UITextFieldDelegate>)delegate {
    UITextField *textField = [[self alloc]initWithFrame:frame];
    if (font) textField.textFont = font;
    if (placeholder) textField.placeholder = placeholder;
    if (delegate) textField.delegate = delegate;
    textField.textColor = [UIColor darkTextColor];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.clearsOnBeginEditing = NO;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.returnKeyType = UIReturnKeyDefault;
    if (@available(iOS 11.0, *)) textField.textDragInteraction.enabled = NO;
    return textField;
}

@end
