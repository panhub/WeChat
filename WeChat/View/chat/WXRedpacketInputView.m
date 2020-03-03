//
//  WXRedpacketInputView.m
//  MNChat
//
//  Created by Vincent on 2019/5/22.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXRedpacketInputView.h"

@interface WXRedpacketInputView () <UITextFieldDelegate, MNTextFieldHandler>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *unitLabel;
@property (nonatomic, strong) MNTextField *textField;
@end

@implementation WXRedpacketInputView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.f;
        self.clipsToBounds = YES;
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(10.f, MEAN(self.height_mn - 17.f), 35.f, 17.f) text:@"金额" textColor:UIColorWithAlpha([UIColor darkTextColor], .9f) font:[UIFont systemFontOfSize:17.f]];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *unitLabel = [UILabel labelWithFrame:CGRectMake(self.width_mn - 28.f - titleLabel.left_mn, titleLabel.top_mn, 28.f, titleLabel.height_mn) text:@"元" textAlignment:NSTextAlignmentRight textColor:titleLabel.textColor font:titleLabel.font];
        [self addSubview:unitLabel];
        self.unitLabel = unitLabel;
        
        MNTextField *textField = [[MNTextField alloc] initWithFrame:CGRectMake(titleLabel.right_mn, 0.f, unitLabel.left_mn - titleLabel.right_mn, self.height_mn)];
        textField.delegate = self;
        textField.handler = self;
        textField.type = MNTextFieldTypeNormal;
        textField.performActions = MNTextFieldActionNone;
        textField.font = titleLabel.font;
        textField.placeholder = @"0.00";
        textField.textColor = titleLabel.textColor;
        textField.tintColor = THEME_COLOR;
        textField.textAlignment = NSTextAlignmentRight;
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
    }
    return self;
}

#pragma mark - Setter
- (void)setTextColor:(UIColor *)textColor {
    self.unitLabel.textColor = textColor;
    self.titleLabel.textColor = textColor;
    self.textField.textColor = textColor;
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
    if ([self.delegate respondsToSelector:@selector(inputView:didChangeText:)]) {
        [self.delegate inputView:self didChangeText:textField.text];
    }
}

@end
