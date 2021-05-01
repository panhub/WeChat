//
//  WXChangeViewController.m
//  WeChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChangeViewController.h"
#import "WXChangeListController.h"
#import "WXChangeAccessController.h"
#import "WXMoneyLabel.h"

@interface WXChangeViewController ()
@property (nonatomic, strong) WXMoneyLabel *moneyLabel;
@end

@implementation WXChangeViewController
- (instancetype)init {
    if (self = [super init]) {
        self.networking = YES;
    }
    return self;
}
- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationBar.shadowView.hidden = YES;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 0.f;
    
    UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(MEAN(self.tableView.width_mn - 75.f), MN_TOP_BAR_HEIGHT + 40.f, 75.f, 75.f) image:[UIImage imageNamed:@"wx_pay_money_icon"]];
    [self.tableView addSubview:imageView];
    
    UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(0.f, imageView.bottom_mn + 30.f, self.tableView.width_mn, 16.f) text:@"我的零钱" alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor darkTextColor], .85f) font:UIFontRegular(16.5f)];
    [self.tableView addSubview:titleLabel];
    
    WXMoneyLabel *moneyLabel = [[WXMoneyLabel alloc] initWithFrame:CGRectMake(15.f, titleLabel.bottom_mn + 20.f, self.tableView.width_mn - 30.f, 49.f)];
    moneyLabel.textColor = [UIColor blackColor];
    moneyLabel.money = WXPreference.preference.money;
    [self.tableView addSubview:moneyLabel];
    self.moneyLabel = moneyLabel;
    
    UILabel *earnLabel = [UILabel labelWithFrame:CGRectMake(titleLabel.left_mn, moneyLabel.bottom_mn + 40.f, titleLabel.width_mn, 16.f) text:@"转入零钱通 给自己加加薪 >" alignment:NSTextAlignmentCenter textColor:MN_R_G_B(249.f, 156.f, 56.f) font:UIFontRegular(16.f)];
    [self.tableView addSubview:earnLabel];
    
    NSArray <NSString *>*titles = @[@"充值", @"提现"];
    //NSArray <UIColor *>*colors = @[UIColorWithRGB(26.f, 173.f, 25.f), UIColorWithSingleRGB(247.f)];
    NSArray <UIColor *>*colors = @[THEME_COLOR, UIColorWithSingleRGB(229.f)];
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithFrame:CGRectMake(MEAN(self.tableView.width_mn - 185.f), self.tableView.height_mn/3.f*2.f + 50.f*idx, 185.f, 40.f) image:nil title:obj titleColor:(idx == 0 ? UIColor.whiteColor : THEME_COLOR) titleFont:UIFontMedium(17.f)];
        button.tag = idx;
        button.backgroundColor = colors[idx];
        button.layer.cornerRadius = 4.f;
        button.clipsToBounds = YES;
        [button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:button];
    }];
    
    NSString *text = @"常见问题\n本服务由财付通提供";
    NSMutableAttributedString *string = text.attributedString.mutableCopy;
    string.alignment = NSTextAlignmentCenter;
    string.font = UIFontRegular(13.f);
    string.color = UIColorWithSingleRGB(132.f);
    [string setColor:TEXT_COLOR range:[text rangeOfString:@"常见问题"]];
    CGSize size = [string sizeOfLimitWidth:self.tableView.width_mn];
    UILabel *hintLabel = [UILabel labelWithFrame:CGRectMake(MEAN(self.tableView.width_mn - size.width), 0.f, size.width, size.height) text:string textColor:nil font:nil];
    hintLabel.bottom_mn = self.tableView.height_mn - 10.f - MN_TAB_SAFE_HEIGHT;
    hintLabel.numberOfLines = 0;
    [self.tableView addSubview:hintLabel];
    
    [self.contentView.subviews setValue:@(self.networking) forKeyPath:@"hidden"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    @weakify(self);
    [self handNotification:WXChangeRefreshNotificationName eventHandler:^(id sender) {
        @strongify(self);
        self.moneyLabel.money = WXPreference.preference.money;
    }];
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
}

- (void)buttonTouchUpInside:(UIButton *)button {
    WXChangeAccessController *vc = [[WXChangeAccessController alloc] initWithType:button.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MNNavigationBarDelegate
- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 75.f, kNavItemSize)
                                              image:nil
                                              title:@"零钱明细"
                                         titleColor:UIColorWithAlpha([UIColor darkTextColor], .85f)
                                               titleFont:UIFontRegular(17.f)];
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    WXChangeListController *vc = [WXChangeListController new];
    vc.type = WXChangeListAll;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Super
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

@end
