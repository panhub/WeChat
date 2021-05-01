//
//  WXRedpacketViewController.m
//  WeChat
//
//  Created by Vincent on 2019/5/22.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXRedpacketViewController.h"
#import "WXRedpacketInputView.h"
#import "WXRedpacketTextView.h"
#import "WXRedpacketHintView.h"
#import "WXPayAlertView.h"
#import "WXPasswordAlertView.h"
#import "WXMoneyLabel.h"
#import "WXChangeModel.h"

@interface WXRedpacketViewController () <WXRedpacketInputViewDelegate, WXPayAlertViewDelegate, WXPasswordAlertViewDelegate>
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) WXRedpacketTextView *textView;
@property (nonatomic, strong) WXMoneyLabel *moneyLabel;
@property (nonatomic, strong) WXRedpacketHintView *hintView;
@end

@implementation WXRedpacketViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"发红包";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowView.backgroundColor = VIEW_COLOR;
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    UIScrollView *scrollView = [UIScrollView scrollViewWithFrame:self.contentView.bounds delegate:nil];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.alwaysBounceVertical = YES;
    [self.contentView addSubview:scrollView];
    
    WXRedpacketInputView *inputView = [[WXRedpacketInputView alloc] initWithFrame:CGRectMake(25.f, 25.f, scrollView.width_mn - 50.f, 55.f)];
    inputView.delegate = self;
    [scrollView addSubview:inputView];
    
    WXRedpacketTextView *textView = [[WXRedpacketTextView alloc] initWithFrame:CGRectMake(inputView.left_mn, inputView.bottom_mn + 15.f, inputView.width_mn, 65.f)];
    [scrollView addSubview:textView];
    self.textView = textView;
    
    WXMoneyLabel *moneyLabel = [[WXMoneyLabel alloc] initWithFrame:CGRectMake(textView.left_mn, textView.bottom_mn + textView.height_mn, textView.width_mn, 50.f)];
    [scrollView addSubview:moneyLabel];
    self.moneyLabel = moneyLabel;
    
    UIButton *confirmButton = [UIButton buttonWithFrame:CGRectMake(MEAN(scrollView.width_mn - 190.f), moneyLabel.bottom_mn + 30.f, 190.f, 47.f)
                                                  image:[UIImage imageWithColor:MN_R_G_B(233.f, 96.f, 55.f)]
                                                  title:@"塞钱进红包"
                                             titleColor:UIColorWithAlpha([UIColor whiteColor], 1.f)
                                                   titleFont:UIFontRegular(17.f)];
    [confirmButton setBackgroundImage:[UIImage imageWithColor:MN_R_G_B(233.f, 96.f, 55.f)] forState:UIControlStateHighlighted];
    [confirmButton setBackgroundImage:[UIImage imageWithColor:MN_R_G_B(229.f, 189.f, 179.f)] forState:UIControlStateDisabled];
    confirmButton.enabled = NO;
    UIViewSetCornerRadius(confirmButton, 5.f);
    [confirmButton addTarget:self action:@selector(confirmButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:confirmButton];
    self.confirmButton = confirmButton;
    
    /// 未领取的红包, 将于24小时之后发起退款
    UILabel *hintLabel = [UILabel labelWithFrame:CGRectMake(0.f, scrollView.height_mn - 43.f, scrollView.width_mn, 13.f)
                                            text:@"可直接使用收到的零钱发红包"
                                   alignment:NSTextAlignmentCenter
                                       textColor:UIColorWithAlpha([UIColor blackColor], .5f)
                                            font:UIFontRegular(13.f)];
    [scrollView addSubview:hintLabel];
    
    WXRedpacketHintView *hintView = [[WXRedpacketHintView alloc] initWithFrame:CGRectMake(0.f, -35.f, self.contentView.width_mn, 35.f)];
    [self.contentView addSubview:hintView];
    self.hintView = hintView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - 按钮事件
- (void)confirmButtonClicked {
    [self.view endEditing:YES];
    [self.view showPayDialogDelay:1.7f completionHandler:^{
        WXPayAlertView *alertView = [WXPayAlertView new];
        alertView.delegate = self;
        alertView.title = @"微信红包";
        alertView.money = self.moneyLabel.money;
        [alertView show];
    }];
}

#pragma mark - WXRedpacketInputViewDelegate
- (void)inputView:(WXRedpacketInputView *)inputView didChangeText:(NSString *)text {
    self.moneyLabel.money = text;
    CGFloat money = self.moneyLabel.money.floatValue;
    self.confirmButton.enabled = (money > 0.f && money <= 200.f);
    [self.hintView setVisible:(money > 200.f) animated:YES];
    inputView.textColor = money > 200.f ? self.hintView.textColor : UIColorWithAlpha([UIColor darkTextColor], .9f);
}

#pragma mark - WXPayAlertViewDelegate
- (void)payAlertViewShouldPayment:(WXPayAlertView *)alertView {
    if (WXPreference.preference.isAllowsLocalEvaluation) {
        /// 允许指纹
        [MNLocalEvaluation evaluateReason:@"请验证已有的指纹, 用于支付" password:^{
            [self presentPasswordAlertView];
        } reply:^(BOOL succeed, NSError * _Nonnull error) {
            if (succeed) {
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
    alertView.title = @"微信红包";
    alertView.money = self.moneyLabel.money;
    [alertView show];
}

- (void)paymentSucceed:(BOOL)interaction {
    @weakify(self);
    [self.view showPayDialogNeeds:interaction delay:1.7f completionHandler:^{
        [weakself paySucceed];
    }];
}

- (void)paySucceed {
    if (self.isMine && self.moneyLabel.money.floatValue > WXPreference.preference.money.floatValue) {
        /// 给朋友发红包, 判断零钱是否够用
        [self.view showWechatError:@"零钱不足"];
    } else {
        /// 符合发红包要求
        @weakify(self);
        [self.view showWechatDialogDelay:.5f eventHandler:^{
            @strongify(self);
            if (self.completionHandler) {
                self.completionHandler(self.moneyLabel.money, self.textView.text);
            }
        } completionHandler:^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

#pragma mark - WXPasswordAlertViewDelegate
- (void)passwordAlertViewDidSucceed:(WXPasswordAlertView *)alertView {
    [self paymentSucceed:NO];
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIButton *leftItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 24.f, 24.f) image:[UIImage imageNamed:@"wx_watch_close"] title:nil titleColor:nil titleFont:nil];
    leftItem.touchInset = UIEdgeInsetWith(-5.f);
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, kNavItemSize, kNavItemSize) image:[UIImage imageNamed:@"wx_common_more_black"] title:nil titleColor:nil titleFont:nil];
    rightItem.touchInset = UIEdgeInsetWith(-3.f);
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

#pragma mark - Super
- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

@end
