//
//  WXPasswordViewController.m
//  MNChat
//
//  Created by Vincent on 2019/4/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXPasswordViewController.h"

@interface WXPasswordViewController ()<MNNumberKeyboardDelegate, MNPasswordViewDelegate>
@property (nonatomic, weak) MNPasswordView *passwordView;
@property (nonatomic, weak) MNNumberKeyboard *keyboard;
@end

@implementation WXPasswordViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"验证支付密码";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.titleView.hidden = YES;
    
    
    UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(0.f, 85.f, self.contentView.width_mn, 30.f)
                                             text:self.title
                                    textAlignment:NSTextAlignmentCenter
                                        textColor:UIColorWithAlpha([UIColor darkTextColor], .9f)
                                             font:[UIFont systemFontOfSize:30.f]];
    [self.contentView addSubview:titleLabel];
    
    UILabel *hintLabel = [UILabel labelWithFrame:CGRectMake(0.f, titleLabel.bottom_mn + 30.f, self.contentView.width_mn, 16.5f)
                                            text:@"请输入支付密码, 以验证身份"
                                   textAlignment:NSTextAlignmentCenter
                                       textColor:UIColorWithAlpha([UIColor darkTextColor], .85f)
                                            font:[UIFont systemFontOfSize:16.5f]];
    [self.contentView addSubview:hintLabel];
    
    MNPasswordView *passwordView = [[MNPasswordView alloc] initWithFrame:CGRectMake(MEAN(self.contentView.width_mn - 50.f*6.f), hintLabel.bottom_mn + 55.f, 50.f*6.f, 50.f) capacity:6];
    passwordView.delegate = self;
    passwordView.borderWidth = .8f;
    passwordView.normalColor = UIColorWithSingleRGB(185.f);
    passwordView.highlightColor = UIColorWithSingleRGB(185.f);
    MNNumberKeyboard *keyboard = [MNNumberKeyboard new];
    keyboard.delegate = self;
    passwordView.inputView = keyboard;
    [passwordView reloadInputViews];
    [self.contentView addSubview:passwordView];
    self.passwordView = passwordView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactiveTransitionEnabled = NO;
    [self.passwordView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactiveTransitionEnabled = YES;
}

#pragma mark - MNNumberKeyboardDelegate
- (void)numberKeyboardDidClickDeleteButton:(MNNumberKeyboard *)keyboard {
    [self.passwordView deleteBackward];
}

- (void)numberKeyboardDidSelectNumber:(NSString *)number {
    [self.passwordView shouldInputPasswordCharacter:number];
}

- (void)numberKeyboardTextDidChange:(MNNumberKeyboard *)keyboard {
    NSLog(@"===%@", keyboard.text);
}

#pragma mark - MNPasswordViewDelegate
- (void)passwordView:(MNPasswordView *)passwordView didChangePassword:(NSString *)password {
    if (password.length < passwordView.capacity) return;
    [passwordView resignFirstResponder];
    [self.view showWeChatDialogDelay:.5f completionHandler:^{
        if ([password isEqualToString:WXPreference.preference.payword]) {
            /// 密码匹配
            if (self.didSucceedHandler) {
                self.didSucceedHandler(self);
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
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
    }];
}

- (UIRectEdge)passwordView:(MNPasswordView *)passwordView itemBorderEdgeOfIndex:(NSUInteger)index {
    return index == passwordView.capacity - 1 ? UIRectEdgeAll : UIRectEdgeLeft|UIRectEdgeTop|UIRectEdgeBottom;
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIButton *leftBarItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 45.f, 30.f)
                                                image:nil
                                                title:@"取消"
                                           titleColor:UIColorWithAlpha([UIColor darkTextColor], .9f)
                                                 titleFont:[UIFont systemFontOfSize:17.f]];
    [leftBarItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftBarItem;
}

@end
