//
//  WXChangeAccessController.m
//  MNChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChangeAccessController.h"
#import "WXPasswordViewController.h"
#import "WXBankCardBindController.h"
#import "WXChangeListController.h"
#import "WXBankCardView.h"
#import "WXMoneyInputView.h"
#import "WXBankCardAlertView.h"
#import "WXChangeModel.h"

@interface WXChangeAccessController () <WXMoneyInputDelegate, WXBankCardAlertViewDelegate>
@property (nonatomic) WXChangeAccessType type;
@property (nonatomic, strong) WXBankCardView *cardView;
@property (nonatomic, strong) WXMoneyInputView *moneyView;
@property (nonatomic, strong) UILabel *explainLabel;
@property (nonatomic, strong) UIButton *explainButton;
@property (nonatomic, strong) UIButton *accessButton;
@end

@implementation WXChangeAccessController
- (instancetype)initWithType:(WXChangeAccessType)type {
    if (self = [super init]) {
        self.type = type;
        self.title = type == WXChangeAccessRecharge ? @"零钱充值" : @"零钱提现";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.contentView.backgroundColor = UIColorWithSingleRGB(237.f);
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = UIColorWithSingleRGB(237.f);
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.rightItemImage = [UIImage imageNamed:@"wx_common_more_black"];
    self.navigationBar.rightBarItem.hidden = self.type == WXChangeAccessRecharge;
    
    self.tableView.frame = CGRectMake(13.f, 0.f, self.contentView.width_mn - 26.f, self.contentView.height_mn);
    self.tableView.rowHeight = 0.f;
    self.tableView.backgroundColor = UIColorWithSingleRGB(237.f);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    WXBankCardView *cardView = [[WXBankCardView alloc] initWithFrame:CGRectMake(0.f, 20.f, self.tableView.width_mn, 0.f)];
    cardView.type = (WXBankCardViewType)(self.type);
    if ([[[MNChatHelper helper] cards] count] > 0) cardView.card = [[[MNChatHelper helper] cards] firstObject];
    [self.tableView addSubview:cardView];
    self.cardView = cardView;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.f, cardView.bottom_mn, self.tableView.width_mn, 0.f)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [self.tableView addSubview:backgroundView];
    
    UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(23.f, 20.f, backgroundView.width_mn - 46.f, 14.f) text:(self.type == WXChangeAccessRecharge ? @"充值金额" : @"提现金额") textColor:UIColorWithAlpha([UIColor darkTextColor], .85f) font:[UIFont systemFontOfSize:14.f]];
    [backgroundView addSubview:titleLabel];
    
    WXMoneyInputView *moneyView = [[WXMoneyInputView alloc] initWithFrame:CGRectMake(titleLabel.left_mn, titleLabel.bottom_mn + 18.f, titleLabel.width_mn, 53.f)];
    moneyView.delegate = self;
    moneyView.interval = 8.f;
    moneyView.tintColor = THEME_COLOR;
    [backgroundView addSubview:moneyView];
    self.moneyView = moneyView;
    
    UIImageView *divider = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_comment_horizontal_line")];
    divider.frame = CGRectMake(moneyView.left_mn, moneyView.bottom_mn + 8.f, moneyView.width_mn, 1.f);
    [backgroundView addSubview:divider];
    
    UILabel *explainLabel = [UILabel labelWithFrame:CGRectMake(moneyView.left_mn, divider.bottom_mn + 15.f, 0.f, 15.f) text:@"" textColor:UIColorWithAlpha([UIColor darkTextColor], .5f) font:UIFontLight(13.f)];
    [backgroundView addSubview:explainLabel];
    self.explainLabel = explainLabel;
    
    UIButton *explainButton = [UIButton buttonWithFrame:CGRectMake(0.f, explainLabel.top_mn, 0.f, explainLabel.height_mn) image:nil title:@"全部提现" titleColor:TEXT_COLOR titleFont:explainLabel.font];
    explainButton.touchInset = UIEdgeInsetWith(-5.f);
    [backgroundView addSubview:explainButton];
    self.explainButton = explainButton;
    
    UIButton *accessButton = [UIButton buttonWithFrame:CGRectMake(titleLabel.left_mn, explainLabel.bottom_mn + 18.f, titleLabel.width_mn, 48.f) image:[UIImage imageWithColor:THEME_COLOR] title:(self.type == WXChangeAccessRecharge ? @"下一步" : @"提现") titleColor:[UIColor whiteColor] titleFont:UIFontMedium(18.f)];
    [accessButton setBackgroundImage:[UIImage imageWithColor:THEME_COLOR] forState:UIControlStateHighlighted];
    [accessButton setBackgroundImage:[UIImage imageWithColor:R_G_B(156.f, 229.f, 191.f)] forState:UIControlStateDisabled];
    UIViewSetCornerRadius(accessButton, 4.f);
    accessButton.enabled = NO;
    [accessButton addTarget:self action:@selector(accessButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:accessButton];
    self.accessButton = accessButton;
    
    backgroundView.height_mn = accessButton.bottom_mn + 18.f;
    
    if (self.type == WXChangeAccessRecharge) {
        explainLabel.hidden = explainButton.hidden = YES;
        accessButton.top_mn = (backgroundView.height_mn - divider.bottom_mn - explainButton.height_mn)/2.f + divider.bottom_mn;
    } else {
        [self layoutSubviews];
    }
}

- (void)layoutSubviews {
    if (self.type == WXChangeAccessRecharge) return;
    if (self.accessButton.isEnabled) {
        self.explainButton.width_mn = 0.f;
        CGFloat money = self.moneyView.money.floatValue;
        NSString *cost_money = [self moneyCost:money];
        CGFloat cost = cost_money.floatValue;
        if ((money + cost) > WXPreference.preference.money.floatValue) {
            /// 超出范围
            self.explainLabel.textColor = BADGE_COLOR;
            self.explainLabel.text = @"输入金额超过零钱余额";
        } else {
            /// 费率
            self.explainLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .5f);
            self.explainLabel.text = [NSString stringWithFormat:@"额外扣除¥%@服务费 (费率0.10%%)", cost_money];
        }
        self.explainLabel.width_mn = [self.explainLabel.text sizeWithFont:self.explainLabel.font].width;
    } else {
        self.explainLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .5f);
        self.explainLabel.text = [NSString stringWithFormat:@"零钱余额¥%@, ", WXPreference.preference.money];
        self.explainLabel.width_mn = [self.explainLabel.text sizeWithFont:self.explainLabel.font].width;
        NSString *title = [self.explainButton titleForState:UIControlStateNormal];
        self.explainButton.width_mn = [title sizeWithFont:self.explainLabel.font].width;
        self.explainButton.left_mn = self.explainLabel.right_mn;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    @weakify(self);
    /// 银行卡点击
    [self.cardView handTapConfiguration:nil eventHandler:^(id sender) {
        @strongify(self);
        WXBankCardAlertView *alertView = [WXBankCardAlertView new];
        alertView.type = (WXBankCardAlertViewType)(self.type);
        alertView.delegate = self;
        [alertView show];
    }];
    /// 全部提现
    [self.explainButton handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        @strongify(self);
        CGFloat money = WXPreference.preference.money.floatValue;
        CGFloat cost = [self moneyCost:money].floatValue;
        self.moneyView.money = [NSString stringWithFormat:@"%@", @(money - cost)];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstAppear) [self.moneyView becomeFirstResponder];
}

#pragma mark - 充值/提现
- (void)accessButtonClicked {
    [self.moneyView resignFirstResponder];
    [self.view showWeChatDialog];
    WXBankCard *card = self.cardView.card;
    if (!card) {
        [self showErrorMessage:@"请选择银行卡"];
        return;
    }
    CGFloat money = self.moneyView.money.floatValue;
    if (self.type == WXChangeAccessRecharge) {
        /// 充值
        if (card.money < money) {
            [self showErrorMessage:@"银行卡余额不足"];
            return;
        }
        /// 更新银行卡
        card.money -= money;
        if ([[MNChatHelper helper] updateBankCard:card]) {
            /// 插入零钱记录
            WXChangeModel *change = [WXChangeModel new];
            change.title = @"零钱充值";
            change.type = @"充值";
            change.note = [NSString stringWithFormat:@"%@ (%@)充值到零钱", card.name, [card.number substringFromIndex:card.number.length - 4]];
            change.timestamp = [NSDate timestamps];
            change.money = money;
            change.channel = WXChangeChannelRecharge;
            if ([[MNDatabase sharedInstance] insertIntoTable:WXChangeTableName model:change]) {
                @PostNotify(WXChangeUpdateNotificationName, nil);
                dispatch_after_main(.5f, ^{
                    [self.view closeDialogWithCompletionHandler:^{
                        UIViewControllerPop(YES);
                    }];
                });
            } else {
                [self showErrorMessage:@"保存零钱记录出错"];
            }
        } else {
            [self showErrorMessage:@"更新银行卡出错"];
        }
    } else {
        /// 提现
        CGFloat cost = [self moneyCost:money].floatValue;
        CGFloat total = money + cost;
        if (total > WXPreference.preference.money.floatValue) {
            [self showErrorMessage:@"零钱不足"];
            return;
        }
        /// 更新银行卡
        card.money += money;
        if ([[MNChatHelper helper] updateBankCard:card]) {
            /// 插入手续费记录
            WXChangeModel *change = [WXChangeModel new];
            change.title = @"提现服务费";
            change.type = @"提现服务费";
            change.note = @"";
            change.timestamp = [NSDate timestamps];
            change.money = -cost;
            change.channel = WXChangeChannelCost;
            if ([[MNDatabase sharedInstance] insertIntoTable:WXChangeTableName model:change]) {
                @PostNotify(WXChangeUpdateNotificationName, nil);
            }
            /// 插入提现记录
            change = [WXChangeModel new];
            change.title = @"提现";
            change.type = @"提现";
            change.note = [NSString stringWithFormat:@"提现到银行卡 %@ (%@)", card.name, [card.number substringFromIndex:card.number.length - 4]];
            change.timestamp = [NSDate timestamps];
            change.money = -money;
            change.channel = WXChangeChannelWithdraw;
            if ([[MNDatabase sharedInstance] insertIntoTable:WXChangeTableName model:change]) {
                @PostNotify(WXChangeUpdateNotificationName, nil);
                dispatch_after_main(.5f, ^{
                    [self.view closeDialogWithCompletionHandler:^{
                        UIViewControllerPop(YES);
                    }];
                });
            } else {
                [self showErrorMessage:@"保存零钱记录出错"];
            }
        } else {
            [self showErrorMessage:@"更新银行卡出错"];
        }
    }
}

- (void)showErrorMessage:(NSString *)msg {
    dispatch_after_main(.3f, ^{
        [self.view showInfoDialog:msg];
    });
}

- (NSString *)moneyCost:(CGFloat)money {
    if (money <= 0.f) return @"0.0";
    CGFloat cost = money*0.001f;
    if (cost <= 0.1f) {
        return @"0.1";
    } else {
        return [NSString stringWithFormat:@"%.2f", cost];
    }
}

#pragma mark - WXMoneyInputDelegate
- (void)inputViewTextDidChange:(WXMoneyInputView *)inputView {
    self.accessButton.enabled = inputView.money.floatValue > 0.f;
    [self layoutSubviews];
}

#pragma mark - WXBankCardAlertViewDelegate
- (void)alertView:(WXBankCardAlertView *)alertView didSelectCard:(WXBankCard *)card {
    self.cardView.card = card;
}

- (void)alertViewNeedsAddNewCard:(WXBankCardAlertView *)alertView {
    WXPasswordViewController *vc = [WXPasswordViewController new];
    vc.title = @"添加银行卡";
    vc.didSucceedHandler = ^(UIViewController *v) {
        UINavigationController *nav = v.navigationController;
        [nav popViewControllerAnimated:NO];
        WXBankCardBindController *vv = [WXBankCardBindController new];
        [nav pushViewController:vv animated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIButton *leftItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 40.f, kNavItemSize)
                                             image:nil
                                             title:@"取消"
                                        titleColor:UIColorWithAlpha([UIColor darkTextColor], .9f)
                                              titleFont:@(17.f)];
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    @weakify(self);
    [[MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) return;
        @strongify(self);
        WXChangeListController *vc = [WXChangeListController new];
        vc.type = WXChangeListWithdraw;
        [self.navigationController pushViewController:vc animated:YES];
    } otherButtonTitles:@"提现记录", nil] show];
}

#pragma mark - Super
- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModel];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModel];
}

@end
