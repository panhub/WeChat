//
//  WXTransferDoneController.m
//  WeChat
//
//  Created by Vincent on 2019/6/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXTransferDoneController.h"
#import "WXRedpacket.h"
#import "WXMoneyLabel.h"
#import "WXTransferChangeView.h"
#import "WXChangeViewController.h"

@interface WXTransferDoneController ()
@property (nonatomic, strong) WXRedpacket *redpacket;
@end

@implementation WXTransferDoneController
- (instancetype)initWithRedpacket:(WXRedpacket *)redpacket {
    if (self = [super init]) {
        self.networking = YES;
        self.redpacket = redpacket;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationBar.shadowView.hidden = YES;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *doneView = [UIImageView imageViewWithFrame:CGRectMake(0.f, MN_TOP_BAR_HEIGHT + 52.f, 56.f, 56.f) image:UIImageNamed(@"wx_transfer_success")];
    doneView.centerX_mn = self.contentView.width_mn/2.f;
    [self.contentView addSubview:doneView];
    
    BOOL isMine = [self.redpacket.toUser.uid isEqualToString:[WXUser.shareInfo uid]];
    NSString *text = isMine ? @"已收款" : [self.redpacket.toUser.name stringByAppendingString:@"已收款"];
    UILabel *doneLabel = [UILabel labelWithFrame:CGRectMake(0.f, doneView.bottom_mn + 40.f, self.contentView.width_mn, 16.f) text:text alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor darkTextColor], .9f) font:UIFontRegular(16.f)];
    [self.contentView addSubview:doneLabel];
    
    WXMoneyLabel *moneyLabel = [[WXMoneyLabel alloc] initWithFrame:CGRectMake(15.f, doneLabel.bottom_mn + 20.f, self.contentView.width_mn - 30.f, 49.f)];
    moneyLabel.money = self.redpacket.money;
    moneyLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:moneyLabel];
    
    if (isMine) {
        UIButton *changeButton = [UIButton buttonWithFrame:CGRectMake(MEAN(self.contentView.width_mn - 80.f), moneyLabel.bottom_mn + 20.f, 80.f, 30.f) image:nil title:@"查看零钱" titleColor:TEXT_COLOR titleFont:UIFontRegular(14.f)];
        [changeButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:changeButton];
        
        WXTransferChangeView *changeView = [[WXTransferChangeView alloc] initWithFrame:CGRectMake(0.f, changeButton.bottom_mn + 45.f, self.contentView.width_mn, 0.f)];
        [self.contentView addSubview:changeView];
    }
    
    /// 收款时间
    NSString *time = [NSDate stringValueWithTimestamp:self.redpacket.draw_time format:@"yyyy-MM-dd HH:mm:ss"];
    UILabel *timeLabel = [UILabel labelWithFrame:CGRectMake(0.f, self.contentView.height_mn - 75.f, self.contentView.width_mn, 12.f) text:[@"收款时间: " stringByAppendingString:time] alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor darkTextColor], .5f) font:[UIFont systemFontOfSize:12.f]];
    [self.contentView addSubview:timeLabel];
    
    /// 转账时间
    time = [NSDate stringValueWithTimestamp:self.redpacket.create_time format:@"yyyy-MM-dd HH:mm:ss"];
    timeLabel = [UILabel labelWithFrame:CGRectMake(0.f, self.contentView.height_mn - 97.f, self.contentView.width_mn, 12.f) text:[@"转账时间: " stringByAppendingString:time] alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor darkTextColor], .5f) font:[UIFont systemFontOfSize:12.f]];
    [self.contentView addSubview:timeLabel];
    
    [self.contentView.subviews setValue:@(self.networking) forKeyPath:@"hidden"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.networking) {
        self.networking = NO;
        [self.view showWechatDialogDelay:.5f completionHandler:^{
            [self.contentView.subviews setValue:@(NO) forKeyPath:@"hidden"];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactiveTransitionEnabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactiveTransitionEnabled = YES;
}

#pragma mark - 查看零钱
- (void)buttonClicked {
    [self.view showWechatDialogDelay:.5f completionHandler:^{
        WXChangeViewController *vc = [WXChangeViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - MNNavigationBarDelegate
- (void)navigationBarLeftBarItemTouchUpInside:(UIView *)leftBarItem {
    if (self.cls.length) {
        [self.navigationController popToViewController:[self.navigationController seekViewControllerOfClass:NSClassFromString(self.cls)] animated:YES];
    } else {
        [super navigationBarLeftBarItemTouchUpInside:leftBarItem];
    }
}

#pragma mark - Super
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

@end
