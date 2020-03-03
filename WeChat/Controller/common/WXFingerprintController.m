//
//  WXFingerprintController.m
//  MNChat
//
//  Created by Vincent on 2019/4/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXFingerprintController.h"
#import "WXPasswordViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface WXFingerprintController () <UIAlertViewDelegate>

@end

@implementation WXFingerprintController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"验证密码";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.titleView.hidden = YES;
    
    UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(0.f, 100.f, self.contentView.width_mn, 24.f)
                                             text:@"验证指纹以继续"
                                    textAlignment:NSTextAlignmentCenter
                                        textColor:UIColorWithAlpha([UIColor darkTextColor], .8f)
                                             font:UIFontWithNameSize(MNFontNameLight, 24.f)];
    [self.contentView addSubview:titleLabel];
    
    UIImageView *touchView = [UIImageView imageViewWithFrame:CGRectMake(MEAN(self.contentView.width_mn - 70.f), titleLabel.bottom_mn + titleLabel.top_mn, 70.f, 70.f)
                                                       image:UIImageNamed(@"wx_mine_pay_touch")];
    [self.contentView addSubview:touchView];
    
    UIButton *authButton = [UIButton buttonWithFrame:CGRectMake(70.f, touchView.bottom_mn + titleLabel.top_mn, self.contentView.width_mn - 140.f, 47.f)
                                               image:[UIImage imageWithColor:THEME_COLOR]
                                               title:@"点击验证指纹"
                                          titleColor:[UIColor whiteColor]
                                                titleFont:UIFontWithNameSize(MNFontNameMedium, 17.5f)];
    authButton.layer.cornerRadius = 4.f;
    authButton.clipsToBounds = YES;
    [authButton addTarget:self action:@selector(evaluateTouchID) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:authButton];
    
    UIButton *hintButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hintButton.frame = CGRectMake(MEAN(self.contentView.width_mn - 150.f), self.contentView.height_mn - 50.f, 150.f, 35.f);
    [hintButton setTitleColor:TEXT_COLOR forState:UIControlStateNormal];
    hintButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    hintButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [hintButton setTitle:@"支付密码解锁" forState:UIControlStateNormal];
    hintButton.titleLabel.font = [UIFont systemFontOfSize:13.5f];
    [hintButton addTarget:self action:@selector(pushPasswordController) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:hintButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstAppear) {
        [self evaluateTouchID];
    }
}

- (void)evaluateTouchID {
    [MNTouchContext touchEvaluateLocalizedReason:@"验证指纹以继续" password:^{
        [self pushPasswordController];
    } reply:^(BOOL succeed, NSError *error) {
        if (succeed) {
            [self.view showWeChatDialogDelay:.5f completionHandler:^{
                if (self.didSucceedHandler) {
                    self.didSucceedHandler(self);
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }];
}

#pragma mark - 密码验证
- (void)pushPasswordController {
    WXPasswordViewController *vc = [[WXPasswordViewController alloc] init];
    vc.title = self.title;
    vc.didSucceedHandler = self.didSucceedHandler;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
