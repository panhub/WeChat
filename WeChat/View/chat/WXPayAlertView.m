//
//  WXPayAlertView.m
//  MNChat
//
//  Created by Vincent on 2019/5/31.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXPayAlertView.h"
#import "WXMoneyLabel.h"

@interface WXPayAlertView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) WXMoneyLabel *moneyLabel;
@end

@implementation WXPayAlertView
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
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(47.f, 0.f, self.width_mn - 94.f, 0.f)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 7.f;
    contentView.clipsToBounds = YES;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    UIButton *closeButton = [UIButton buttonWithFrame:CGRectMake(13.f, 13.f, 30.f, 30.f)
                                                image:UIImageNamed(@"wx_common_close")
                                                title:nil
                                           titleColor:nil
                                                 titleFont:nil];
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:closeButton];
    
    UIButton *passwordButton = [UIButton buttonWithFrame:closeButton.frame
                                                   image:nil
                                                   title:@"使用密码"
                                              titleColor:TEXT_COLOR
                                                    titleFont:[UIFont systemFontOfSize:17.f]];
    passwordButton.width_mn = [@"使用密码" sizeWithFont:[UIFont systemFontOfSize:17.f]].width;
    passwordButton.right_mn = contentView.width_mn - closeButton.left_mn - 5.f;
    [passwordButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:passwordButton];
    
    UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(15.f, closeButton.bottom_mn + 18.f, contentView.width_mn - 30.f, 20.f) text:@"" textAlignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor darkTextColor], .9f) font:[UIFont systemFontOfSize:17.f]];
    [contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    WXMoneyLabel *moneyLabel = [[WXMoneyLabel alloc] initWithFrame:CGRectMake(titleLabel.left_mn, titleLabel.bottom_mn + 10.f, titleLabel.width_mn, 38.f)];
    moneyLabel.textColor = titleLabel.textColor;
    [contentView addSubview:moneyLabel];
    self.moneyLabel = moneyLabel;
    
    UIImageView *divider = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_comment_horizontal_line")];
    divider.frame = CGRectMake(moneyLabel.left_mn, moneyLabel.bottom_mn + 33.f, moneyLabel.width_mn, 1.f);
    [contentView addSubview:divider];
    
    UILabel *payLabel = [UILabel labelWithFrame:CGRectMake(moneyLabel.left_mn, divider.bottom_mn + 18.f, 0.f, 14.f) text:@"支付方式" textColor:UIColorWithAlpha([UIColor darkTextColor], .5f) font:UIFontRegular(14.f)];
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
    
    UIButton *payButton = [UIButton buttonWithFrame:CGRectMake(MEAN(contentView.width_mn - 185.f), payLabel.bottom_mn + 35.f, 185.f, 40.f) image:[UIImage imageWithColor:THEME_COLOR] title:@"确认支付" titleColor:[UIColor whiteColor] titleFont:UIFontMedium(17.f)];
    payButton.tag = 1;
    [payButton setBackgroundImage:[UIImage imageWithColor:THEME_COLOR] forState:UIControlStateHighlighted];
    UIViewSetCornerRadius(payButton, 4.f);
    [payButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:payButton];
    
    contentView.height_mn = payButton.bottom_mn + 35.f;
    contentView.top_mn = (self.height_mn - contentView.height_mn)/3.f*1.15f;
}

- (void)buttonClicked:(UIButton *)button {
    [self dismissWithSender:button];
}

- (void)show {
    if (self.superview) return;
    [[UIWindow mainWindow] endEditing:YES];
    self.contentView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    [[UIWindow mainWindow] addSubview:self];
    [UIView animateWithDuration:.4f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.contentView.transform = CGAffineTransformIdentity;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.65f];
    } completion:nil];
}

- (void)dismiss {
    [self dismissWithSender:nil];
}

- (void)dismissWithSender:(UIButton *)sender {
    if (!self.superview) return;
    [UIView animateWithDuration:.15f animations:^{
        self.backgroundColor = [UIColor clearColor];
    }];
    [UIView animateWithDuration:.2f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.alpha = 0.f;
        self.contentView.transform = CGAffineTransformMakeScale(.9f, .9f);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (!sender) return;
        if (sender.tag == 0) {
            if ([self.delegate respondsToSelector:@selector(payAlertViewShouldNeedPassword:)]) {
                [self.delegate payAlertViewShouldNeedPassword:self];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(payAlertViewShouldPayment:)]) {
                [self.delegate payAlertViewShouldPayment:self];
            }
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
