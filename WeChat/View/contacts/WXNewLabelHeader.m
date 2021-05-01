//
//  WXNewLabelHeader.m
//  WeChat
//
//  Created by Vicent on 2021/3/30.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXNewLabelHeader.h"
#import "WXLabelHeader.h"

@interface WXNewLabelHeader ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *userTipLabel;
@end

@implementation WXNewLabelHeader
- (void)createView {
    [super createView];
    
    UILabel *nameTipLabel = [UILabel labelWithFrame:CGRectZero text:@"标签名字" textColor:MN_RGB(167.f) font:[UIFont systemFontOfSize:14.f]];
    nameTipLabel.numberOfLines = 1;
    [nameTipLabel sizeToFit];
    nameTipLabel.top_mn = 10.f;
    nameTipLabel.height_mn = 30.f;
    nameTipLabel.left_mn = kNavItemMargin;
    [self.contentView addSubview:nameTipLabel];
    
    UITextField *textField = [UITextField textFieldWithFrame:CGRectMake(0.f, nameTipLabel.bottom_mn, self.contentView.width_mn, 45.f) font:[UIFont systemFontOfSize:17.f] placeholder:@"未设置标签名字" delegate:self];
    textField.borderStyle = UITextBorderStyleNone;
    textField.textColor = UIColor.darkTextColor;
    textField.backgroundColor = UIColor.whiteColor;
    textField.placeholderColor = nameTipLabel.textColor;
    textField.placeholderFont = [UIFont systemFontOfSize:17.f];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kNavItemMargin, textField.height_mn)];
    view.backgroundColor = textField.backgroundColor;
    textField.leftView = view;
    textField.rightView = view.viewCopy;
    
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.rightViewMode = UITextFieldViewModeAlways;
    
    [self.contentView addSubview:textField];
    self.textField = textField;
    
    UILabel *userTipLabel = [UILabel labelWithFrame:CGRectZero text:@"添加成员 (0)" textColor:nameTipLabel.textColor font:nameTipLabel.font];
    userTipLabel.numberOfLines = 1;
    [userTipLabel sizeToFit];
    userTipLabel.top_mn = textField.bottom_mn;
    userTipLabel.height_mn = nameTipLabel.height_mn;
    userTipLabel.left_mn = nameTipLabel.left_mn;
    [self.contentView addSubview:userTipLabel];
    self.userTipLabel = userTipLabel;
    
    WXLabelHeader *selectControl = [[WXLabelHeader alloc] initWithFrame:CGRectMake(0.f, userTipLabel.bottom_mn, self.contentView.width_mn, 60.f)];
    selectControl.title = @"添加成员";
    selectControl.titleFont = textField.font;
    selectControl.contentInset = UIEdgeInsetsMake(0.f, userTipLabel.left_mn, 0.f, 0.f);
    selectControl.separatorInset = UIEdgeInsetsZero;
    selectControl.backgroundColor = UIColor.whiteColor;
    [selectControl addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:selectControl];
    
    self.height_mn = selectControl.bottom_mn;
}

#pragma mark - Event
- (void)add {
    if ([self.delegate respondsToSelector:@selector(newLabelHeaderAddUserButtonTouchUpInside:)]) {
        [self.delegate newLabelHeaderAddUserButtonTouchUpInside:self];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(newLabelHeaderNameButtonTouchUpInside:)]) {
        [self.delegate newLabelHeaderNameButtonTouchUpInside:self];
    }
    return NO;
}

#pragma mark - Setter
- (void)setName:(NSString *)name {
    self.textField.text = name;
}

- (void)setNumber:(NSInteger)number {
    _number = number;
    CGFloat y = self.userTipLabel.centerY_mn;
    self.userTipLabel.text = [NSString stringWithFormat:@"添加成员 (%ld)", number];
    [self.userTipLabel sizeToFit];
    self.userTipLabel.centerY_mn = y;
}

#pragma mark - Getter
- (NSString *)name {
    return self.textField.text;
}

@end
