//
//  WXTransferViewController.m
//  MNChat
//
//  Created by Vincent on 2019/5/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXTransferViewController.h"
#import "WXMoneyInputView.h"
#import "WXEditingViewController.h"
#import "WXTransferSucceedController.h"
#import "WXPayAlertView.h"
#import "WXPasswordAlertView.h"
#import "WXChangeModel.h"

@interface WXTransferViewController () <WXMoneyInputDelegate, WXPayAlertViewDelegate, WXPasswordAlertViewDelegate>
@property (nonatomic, strong) WXUser *user;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *explainLabel;
@property (nonatomic, strong) UIButton *explainButton;
@property (nonatomic, strong) UIButton *transferButton;
@property (nonatomic, strong) WXMoneyInputView *moneyView;
@end

@implementation WXTransferViewController
- (instancetype)initWithUser:(WXUser *)user {
    if (self = [super init]) {
        self.user = user;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    UIImageView *headView = [UIImageView imageViewWithFrame:CGRectMake(MEAN(self.contentView.width_mn - 40.f), 5.f, 40.f, 40.f) image:self.user.avatar];
    UIViewSetCornerRadius(headView, 4.f);
    [self.contentView addSubview:headView];
    
    UILabel *nameLabel = [UILabel labelWithFrame:CGRectMake(0.f, headView.bottom_mn + 15.f, self.contentView.width_mn, 20.f)
                                            text:[NSString stringWithFormat:@"%@ (**%@)", self.user.name, [NSString generateChineseWithLength:1]]
                                   textAlignment:NSTextAlignmentCenter
                                       textColor:UIColorWithAlpha([UIColor darkTextColor], .95f)
                                            font:UIFontMedium(17.f)];
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.f, nameLabel.bottom_mn + 30.f, self.contentView.width_mn, self.contentView.height_mn - nameLabel.bottom_mn - 30.f)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [backgroundView.layer setMaskRadius:20.f byCorners:UIRectCornerTopLeft|UIRectCornerTopRight];
    [self.contentView addSubview:backgroundView];
    
    UILabel *sumLabel = [UILabel labelWithFrame:CGRectMake(30.f, 35.f, backgroundView.width_mn - 60.f, 14.f) text:@"转账金额" textColor:[UIColor blackColor] font:UIFontLight(14.f)];
    [backgroundView addSubview:sumLabel];
    
    WXMoneyInputView *moneyView = [[WXMoneyInputView alloc] initWithFrame:CGRectMake(sumLabel.left_mn, sumLabel.bottom_mn + 20.f, sumLabel.width_mn, 55.f)];
    moneyView.delegate = self;
    [backgroundView addSubview:moneyView];
    self.moneyView = moneyView;
    
    UIImageView *divider = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_comment_horizontal_line")];
    divider.frame = CGRectMake(moneyView.left_mn, moneyView.bottom_mn + 2.f, moneyView.width_mn, 1.f);
    [backgroundView addSubview:divider];
    
    UILabel *explainLabel = [UILabel labelWithFrame:CGRectMake(moneyView.left_mn, divider.bottom_mn + 24.f, 0.f, sumLabel.height_mn) text:nil textColor:sumLabel.textColor font:sumLabel.font];
    [backgroundView addSubview:explainLabel];
    self.explainLabel = explainLabel;
    
    UIButton *explainButton = [UIButton buttonWithFrame:CGRectMake(0.f, explainLabel.top_mn, 0.f, explainLabel.height_mn) image:nil title:nil titleColor:TEXT_COLOR titleFont:explainLabel.font];
    explainButton.touchInset = UIEdgeInsetWith(-5.f);
    [backgroundView addSubview:explainButton];
    self.explainButton = explainButton;
    
    UIButton *transferButton = [UIButton buttonWithFrame:CGRectMake(MEAN(self.view.width_mn - 185.f), self.view.height_mn*.76f, 185.f, 47.f) image:[UIImage imageWithColor:THEME_COLOR] title:@"转账" titleColor:[UIColor whiteColor] titleFont:UIFontMedium(18.f)];
    [transferButton setBackgroundImage:[UIImage imageWithColor:THEME_COLOR] forState:UIControlStateHighlighted];
    [transferButton setBackgroundImage:[UIImage imageWithColor:R_G_B(156.f, 229.f, 191.f)] forState:UIControlStateDisabled];
    UIViewSetCornerRadius(transferButton, 4.f);
    transferButton.enabled = NO;
    [self.view addSubview:transferButton];
    self.transferButton = transferButton;
    
    [self layoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    @weakify(self);
    /// 键盘变化
    [self handNotification:UIKeyboardWillChangeFrameNotification eventHandler:^(NSNotification *notify) {
        @strongify(self);
        if (self.moneyView.isFirstResponder == NO) return;
        UIKeyboardWillChangeFrameConvert(notify, ^(CGRect from, CGRect to, CGFloat duration, UIViewAnimationOptions options) {
            if (to.origin.y < SCREEN_HEIGHT) {
                [UIView animateWithDuration:duration delay:0.f options:options animations:^{
                    self.transferButton.bottom_mn = to.origin.y - 20.f;
                } completion:nil];
            } else {
                [UIView animateWithDuration:duration delay:0.f options:options animations:^{
                    self.transferButton.top_mn = self.view.height_mn*.76f;
                } completion:nil];
            }
        });
    }];
    
    /// 转账说明
    [self.explainButton handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        @strongify(self);
        if ([[MNConfiguration configuration] keyboardVisible]) {
            [self.view endEditing:YES];
        } else {
            /// 添加/修改转账说明
            WXEditingViewController *vc = [WXEditingViewController new];
            vc.title = @"添加转账说明";
            vc.numberOfLines = 1;
            vc.numberOfWords = 10;
            vc.text = self.explainLabel.text;
            vc.placeholder = @"收款方可见, 最多10个字";
            vc.completionHandler = ^(NSString *result, WXEditingViewController *v) {
                [v.navigationController popViewControllerAnimated:YES];
                self.explainLabel.text = result;
                [self layoutSubviews];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    
    /// 转账事件
    [self.transferButton handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        @strongify(self);
        [self.view endEditing:YES];
        [self.view showPayDialogDelay:1.7f completionHandler:^{
            WXPayAlertView *alertView = [WXPayAlertView new];
            alertView.delegate = self;
            alertView.money = self.moneyView.money;
            alertView.title = [NSString stringWithFormat:@"向%@转账", self.nameLabel.text];
            [alertView show];
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstAppear) [self.moneyView becomeFirstResponder];
}

- (void)layoutSubviews {
    self.explainLabel.width_mn = [self.explainLabel.text sizeWithFont:self.explainLabel.font].width;
    NSString *title = self.explainLabel.text.length > 0 ? @"修改" : @"添加转账说明";
    [self.explainButton setTitle:title forState:UIControlStateNormal];
    self.explainButton.width_mn = [title sizeWithFont:self.explainLabel.font].width;
    self.explainButton.left_mn = self.explainLabel.right_mn + (self.explainLabel.text.length > 0 ? 5.f : 0.f);
}

#pragma mark - WXMoneyInputDelegate
- (void)inputViewTextDidChange:(WXMoneyInputView *)inputView {
    self.transferButton.enabled = inputView.money.floatValue > 0.f;
}

#pragma mark - WXPayAlertViewDelegate
- (void)payAlertViewShouldPayment:(WXPayAlertView *)alertView {
    if (WXPreference.preference.isAllowsFingerprint) {
        /// 允许指纹
        [MNTouchContext touchEvaluateLocalizedReason:@"请验证已有的指纹, 用于支付" password:^{
            [self presentPasswordAlertView];
        } reply:^(BOOL success, NSError *error) {
            if (success) {
                [self paymentSucceed:YES];
            }
        }];
    } else {
        /// 密码验证
        [self presentPasswordAlertView];
    }
}

- (void)payAlertViewShouldNeedPassword:(WXPayAlertView *)alertView {
    [self presentPasswordAlertView];
}

- (void)presentPasswordAlertView {
    WXPasswordAlertView *alertView = [WXPasswordAlertView new];
    alertView.delegate = self;
    alertView.money = self.moneyView.money;
    alertView.title = [NSString stringWithFormat:@"向%@转账", self.nameLabel.text];
    [alertView show];
}

- (void)paymentSucceed:(BOOL)interaction {
    [self.view showPayDialog:interaction delay:1.7f completionHandler:^{
        [self paySucceed];
    }];
}

- (void)paySucceed {
    if ([self.user.uid isEqualToString:[[WXUser shareInfo] uid]]) {
        /// 对方转账直接回调返回
        @weakify(self);
        [self.view showWeChatDialogDelay:.5f eventHandler:^{
            @strongify(self);
            if (self.completionHandler) {
                self.completionHandler(self.moneyView.money, self.explainLabel.text);
            }
        } completionHandler:^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        /// 给朋友转账, 判断零钱是否够用
        if (self.moneyView.money.floatValue <= WXPreference.preference.money.floatValue) {
            if (self.completionHandler) self.completionHandler(self.moneyView.money, self.explainLabel.text);
            WXTransferSucceedController *vc = [[WXTransferSucceedController alloc] initWithUser:self.user];
            vc.text = self.explainLabel.text;
            vc.money = self.moneyView.money;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [self.view showInfoDialog:@"零钱不足"];
        }
    }
}

#pragma mark - WXPasswordAlertViewDelegate
- (void)passwordAlertViewDidSucceed:(WXPasswordAlertView *)alertView {
    [self paymentSucceed:NO];
}

#pragma mark - Super
- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModel];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModel];
}

@end
