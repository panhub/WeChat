//
//  WXMoneyInputView.m
//  MNChat
//
//  Created by Vincent on 2019/5/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMoneyInputView.h"

@interface WXMoneyInputView () <UITextFieldDelegate, MNTextFieldHandler>
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) UILabel *explainLabel;
@property (nonatomic, strong) MNTextField *textField;
@end

@implementation WXMoneyInputView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UILabel *badgeLabel = [UILabel new];
        badgeLabel.font = SansFontBold(self.height_mn/3.f*2.f);
        badgeLabel.textColor = UIColor.blackColor;
        badgeLabel.text = @"¥";
        [badgeLabel sizeToFit];
        [self addSubview:badgeLabel];
        self.badgeLabel = badgeLabel;
        
        MNTextField *textField = [[MNTextField alloc] initWithFrame:CGRectMake(badgeLabel.right_mn + 13.f, 0.f, self.width_mn - badgeLabel.right_mn - 13.f, self.height_mn)];
        textField.delegate = self;
        textField.handler = self;
        textField.performActions = MNTextFieldActionNone;
        textField.font = SansFontMedium(self.height_mn);
        textField.tintColor = THEME_COLOR;
        textField.textColor = UIColor.blackColor;
        textField.borderStyle = UITextBorderStyleNone;
        textField.clearButtonMode = UITextFieldViewModeNever;
        textField.clearsOnBeginEditing = NO;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        textField.returnKeyType = UIReturnKeyDone;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        if (@available(iOS 11.0, *)) textField.textDragInteraction.enabled = NO;
        [self addSubview:textField];
        self.textField = textField;
    
        self.badgeLabel.top_mn = self.badgeLabel.font.descender - self.textField.font.descender;
    }
    return self;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    /// 删除
    if (string.length <= 0) return YES;
    /// 直接输入小数点, 或已经存在小数点
    if ([string isEqualToString:@"."] && (textField.text.length <= 0 || [textField.text containsString:@"."])) return NO;
    /// 小数模式下, 第一个数字已经是0, 接下来必须是小数点
    if (textField.text.length == 1 && [[textField.text substringToIndex:1] isEqualToString:@"0"] && ![string isEqualToString:@"."]) return NO;
    /// 确保精度
    if ([textField.text rangeOfString:@"."].location == (textField.text.length - 3)) return NO;
    /// 保证长度
    if ([textField.text rangeOfString:@"."].location == NSNotFound && textField.text.length >= 7) return NO;
    return YES;
}

#pragma mark - MNTextFieldHandler
- (void)textFieldTextDidChange:(MNTextField *)textField {
    if ([self.delegate respondsToSelector:@selector(inputViewTextDidChange:)]) {
        [self.delegate inputViewTextDidChange:self];
    }
}

#pragma mark - Setter
- (void)setInterval:(CGFloat)interval {
    self.textField.left_mn = self.badgeLabel.right_mn + interval;
    self.textField.width_mn = self.width_mn - self.badgeLabel.right_mn - interval;
}

#pragma mark - Getter
- (NSString *)money {
    NSString *text = self.textField.text;
    if (text.length <= 0) return @"0.00";
    NSUInteger location = [text rangeOfString:@"."].location;
    if (location == NSNotFound) {
        text = [text stringByAppendingString:@".00"];
    } else if (location == text.length - 1) {
        text = [text stringByAppendingString:@"00"];
    } else if (location == text.length - 2) {
        text = [text stringByAppendingString:@"0"];
    }
    return text;
}

- (void)setMoney:(NSString *)money {
    if (money.floatValue > 0.f) {
        NSUInteger location = [money rangeOfString:@"."].location;
        if (location == money.length - 1) {
            money = [money substringToIndex:money.length - 1];
        } else if (location < money.length - 3) {
            money = [money substringToIndex:location + 3];
        }
    } else {
        money = @"0";
    }
    self.textField.text = money;
    [self textFieldTextDidChange:self.textField];
}

#pragma mark - Super
- (void)setTintColor:(UIColor *)tintColor {
    self.textField.tintColor = tintColor;
}

- (BOOL)isFirstResponder {
    return self.textField.isFirstResponder;
}

- (BOOL)resignFirstResponder {
    return [self.textField resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

@end
