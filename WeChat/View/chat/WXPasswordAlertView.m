//
//  WXPasswordAlertView.m
//  WeChat
//
//  Created by Vincent on 2019/5/31.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXPasswordAlertView.h"
#import "WXMoneyLabel.h"

@interface WXPasswordAlertView ()<MNNumberKeyboardDelegate, MNPasswordViewDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) WXMoneyLabel *moneyLabel;
@property (nonatomic, strong) MNPasswordView *passwordView;
@end

@implementation WXPasswordAlertView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self createView];
    }
    return self;
}

- (void)createView {
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(47.f, 0.f, self.width_mn - 92.f, 0.f)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 7.f;
    contentView.clipsToBounds = YES;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    UILabel *hintLabel = [UILabel labelWithFrame:CGRectMake(15.f, 13.f, contentView.width_mn - 30.f, 30.f) text:@"请输入支付密码" alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor darkTextColor], .9f) font:[UIFont systemFontOfSize:18.f]];
    hintLabel.numberOfLines = 1;
    hintLabel.userInteractionEnabled = NO;
    [contentView addSubview:hintLabel];
    
    UIButton *closeButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 20.f, 20.f) image:[UIImage imageNamed:@"wx_watch_close"] title:nil titleColor:nil titleFont:nil];
    closeButton.left_mn = hintLabel.left_mn;
    closeButton.centerY_mn = hintLabel.centerY_mn;
    closeButton.touchInset = UIEdgeInsetWith(-7.f);
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:closeButton];
    
    UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(hintLabel.left_mn, hintLabel.bottom_mn + 20.f, hintLabel.width_mn, 30.f) text:@"" alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor darkTextColor], .9f) font:[UIFont systemFontOfSize:17.f]];
    [contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    WXMoneyLabel *moneyLabel = [[WXMoneyLabel alloc] initWithFrame:CGRectMake(titleLabel.left_mn, titleLabel.bottom_mn + 5.f, titleLabel.width_mn, 38.f)];
    moneyLabel.textColor = titleLabel.textColor;
    [contentView addSubview:moneyLabel];
    self.moneyLabel = moneyLabel;
    
    UIImageView *divider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moment_more_line"]];
    divider.frame = CGRectMake(moneyLabel.left_mn, moneyLabel.bottom_mn + 30.f, moneyLabel.width_mn, 1.f);
    [contentView addSubview:divider];
    
    UILabel *payLabel = [UILabel labelWithFrame:CGRectMake(moneyLabel.left_mn, divider.bottom_mn + 18.f, 0.f, 14.f) text:@"支付方式" textColor:[UIColor.darkTextColor colorWithAlphaComponent:.75f] font:UIFontRegular(14.f)];
    payLabel.width_mn = [payLabel.text sizeWithFont:payLabel.font].width;
    [contentView addSubview:payLabel];
    
    UIImageView *changeView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 16.f, 16.f) image:[UIImage imageNamed:@"wx_pay_change"]];
    changeView.centerY_mn = payLabel.centerY_mn;
    [contentView addSubview:changeView];
    
    UILabel *changeLabel = [UILabel labelWithFrame:CGRectMake(0.f, payLabel.top_mn, 0.f, payLabel.height_mn) text:@"零钱" textColor:payLabel.textColor font:payLabel.font];
    changeLabel.width_mn = [changeLabel.text sizeWithFont:changeLabel.font].width;
    [contentView addSubview:changeLabel];
    
    UIImage *image = [UIImage imageNamed:@"wx_pay_arrow"];
    CGSize size = CGSizeMultiplyToHeight(image.size, changeLabel.height_mn);
    UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, size.width, size.height) image:[UIImage imageNamed:@"wx_pay_arrow"]];
    arrowView.centerY_mn = payLabel.centerY_mn;
    [contentView addSubview:arrowView];
    
    arrowView.right_mn = moneyLabel.right_mn;
    changeLabel.right_mn = arrowView.left_mn - 5.f;
    changeView.right_mn = changeLabel.left_mn - 5.f;
    
    MNPasswordView *passwordView = [[MNPasswordView alloc] initWithFrame:CGRectMake(moneyLabel.left_mn, payLabel.bottom_mn + 35.f, moneyLabel.width_mn, floor(moneyLabel.width_mn/6.f)) capacity:6];
    passwordView.delegate = self;
    passwordView.borderWidth = .8f; 
    passwordView.normalColor = UIColorWithSingleRGB(216.f);
    passwordView.highlightColor = UIColorWithSingleRGB(216.f);
    MNNumberKeyboard *keyboard = [MNNumberKeyboard new];
    keyboard.delegate = self;
    passwordView.inputView = keyboard;
    [passwordView reloadInputViews];
    [contentView addSubview:passwordView];
    self.passwordView = passwordView;
    
    contentView.height_mn = passwordView.bottom_mn + 25.f;
    contentView.top_mn = (self.height_mn - contentView.height_mn)/3.f*.88f;
}

#pragma mark - MNNumberKeyboardDelegate
- (void)numberKeyboardDidClickDeleteButton:(MNNumberKeyboard *)keyboard {
    [self.passwordView deleteBackward];
}

- (void)numberKeyboardDidSelectNumber:(NSString *)number {
    [self.passwordView shouldInputPasswordCharacter:number];
}

#pragma mark - MNPasswordViewDelegate
- (void)passwordView:(MNPasswordView *)passwordView didChangePassword:(NSString *)password {
    if (password.length < passwordView.capacity) return;
    [passwordView resignFirstResponder];
    [self showWechatDialog];
    dispatch_after_main(.5f, ^{
        [self closeDialog];
        if ([password isEqualToString:WXPreference.preference.payword]) {
            /// 密码匹配
            [self dismissWithCallback:YES];
        } else {
            /// 密码错误
            MNAlertView *av = [MNAlertView alertViewWithTitle:nil message:@"支付密码错误, 请重试" handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [passwordView deleteAllPassword];
                    [passwordView becomeFirstResponder];
                } else {
                    MNAlertView *ac = [MNAlertView alertViewWithTitle:@"支付密码" message:WXPreference.preference.payword handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
                        [passwordView deleteAllPassword];
                        [passwordView becomeFirstResponder];
                    } ensureButtonTitle:@"确定" otherButtonTitles:nil];
                    [ac setButtonTitleColor:TEXT_COLOR ofIndex:0];
                    [ac show];
                }
            } ensureButtonTitle:@"忘记密码" otherButtonTitles:@"取消", nil];
            [av setButtonTitleColor:TEXT_COLOR ofIndex:1];
            [av show];
        }
    });
}

- (UIRectEdge)passwordView:(MNPasswordView *)passwordView itemBorderEdgeOfIndex:(NSUInteger)index {
    return index == passwordView.capacity - 1 ? UIRectEdgeAll : UIRectEdgeLeft|UIRectEdgeTop|UIRectEdgeBottom;
}

#pragma mark - Show && Dismiss
- (void)show {
    if (self.superview) return;
    [[UIWindow mainWindow] endEditing:YES];
    self.contentView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    [[UIWindow mainWindow] addSubview:self];
    [UIView animateWithDuration:.4f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.contentView.transform = CGAffineTransformIdentity;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.65f];
    } completion:^(BOOL finished) {
        [self.passwordView becomeFirstResponder];
    }];
}

- (void)dismiss {
    [self dismissWithCallback:NO];
}

- (void)dismissWithCallback:(BOOL)callback {
    if (!self.superview) return;
    [self.passwordView resignFirstResponder];
    [UIView animateWithDuration:.15f animations:^{
        self.backgroundColor = [UIColor clearColor];
    }];
    [UIView animateWithDuration:.2f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.alpha = 0.f;
        self.contentView.transform = CGAffineTransformMakeScale(.9f, .9f);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (!callback) return;
        if ([self.delegate respondsToSelector:@selector(passwordAlertViewDidSucceed:)]) {
            [self.delegate passwordAlertViewDidSucceed:self];
        }
    }];
}

#pragma mark - Setter
- (void)setTitle:(NSString *)title {
    _title = title.copy;
    self.titleLabel.text = title;
}

- (void)setMoney:(NSString *)money {
    _money = money.copy;
    self.moneyLabel.money = money;
}

- (void)setFrame:(CGRect)frame {
    frame = [[UIScreen mainScreen] bounds];
    [super setFrame:frame];
}

@end
