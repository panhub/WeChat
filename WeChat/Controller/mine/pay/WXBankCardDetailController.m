//
//  WXBankCardDetailController.m
//  MNChat
//
//  Created by Vincent on 2019/6/6.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXBankCardDetailController.h"
#import "WXBankCard.h"

@interface WXBankCardDetailController ()
@property (nonatomic, strong) WXBankCard *card;
@property (nonatomic, strong) MNWebProgressView *progressView;
@end

@implementation WXBankCardDetailController
- (instancetype)initWithCard:(WXBankCard *)card {
    if (self = [super init]) {
        self.card = card;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationBar.shadowView.hidden = YES;
    
    MNWebProgressView *progressView = [[MNWebProgressView alloc] initWithFrame:CGRectMake(0.f, self.navigationBar.height_mn - 2.5f, self.navigationBar.width_mn, 2.5f)];
    progressView.tintColor = THEME_COLOR;
    [self.navigationBar addSubview:progressView];
    self.progressView = progressView;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 0.f;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.backgroundColor = [UIColor colorNamed:[self.card.img stringByAppendingString:@"_color"]];
    } else {
        self.tableView.backgroundColor = [self.card.img.image colorAtPoint:CGPointZero];
    }
    
    UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(MEAN(self.tableView.width_mn - 37.f), MN_TOP_BAR_HEIGHT + 5.f, 37.f, 37.f)];
    iconView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    iconView.layer.cornerRadius = iconView.height_mn/2.f;
    iconView.clipsToBounds = YES;
    [self.tableView addSubview:iconView];
    
    UIImageView *iconImageView = [UIImageView imageViewWithFrame:UIEdgeInsetsInsetRect(iconView.bounds, UIEdgeInsetWith(5.f)) image:self.card.img.image];
    [iconView addSubview:iconImageView];
    
    UILabel *nameLabel = [UILabel labelWithFrame:CGRectMake(0.f, iconView.bottom_mn + 15.f, self.tableView.width_mn, 16.f) text:self.card.name alignment:NSTextAlignmentCenter textColor:[UIColor whiteColor] font:UIFontMedium(16.f)];
    [self.tableView addSubview:nameLabel];
    
    UILabel *numberLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, 0.f, 14.f) text:[self.card.number substringFromIndex:self.card.number.length - 4] textColor:UIColorWithAlpha([UIColor whiteColor], .9f) font:UIFontRegular(14.f)];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    [numberLabel sizeToFit];
    UIImage *image = [UIImage imageNamed:@"wx_pay_card_number"];
    CGSize size = CGSizeMultiplyToHeight(image.size, 6.f);
    CGFloat x = (self.tableView.width_mn - size.width*3.f - 5.f*3.f - numberLabel.width)/2.f;
    for (int idx = 0; idx < 3; idx++) {
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(x + (size.width + 5.f)*idx, nameLabel.bottom_mn + 12.f, size.width, size.height) image:image];
        [self.tableView addSubview:imageView];
        if (idx == 2) {
            numberLabel.left_mn = imageView.right_mn + 7.f;
            numberLabel.centerY_mn = imageView.centerY_mn - 1.f;
            [self.tableView addSubview:numberLabel];
        }
    }
    
    /// 限额
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(10.f, numberLabel.bottom_mn + 30.f, self.tableView.width_mn - 20.f, 100.f)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.layer.cornerRadius = 4.f;
    backgroundView.clipsToBounds = YES;
    [self.tableView addSubview:backgroundView];
    
    UIButton *quotaButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, backgroundView.width_mn, 26.f) image:nil title:@"    银行支付限额" titleColor:UIColorWithAlpha([UIColor darkTextColor], .5f) titleFont:UIFontRegular(12.f)];
    quotaButton.backgroundColor = UIColorWithSingleRGB(244.f);
    quotaButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backgroundView addSubview:quotaButton];
    
    NSArray <NSString *>*titles = @[@"单笔限额", @"每日限额"];
    NSArray <NSString *>*moneys = @[@"¥10000", (self.card.type == WXBankCardTypeDeposit ? @"¥50000" : @"无")];
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(15.f, quotaButton.bottom_mn + 20.f + 40.f*idx, 0.f, 16.f) text:obj textColor:UIColorWithAlpha([UIColor darkTextColor], .85f) font:UIFontRegular(16.f)];
        [titleLabel sizeToFit];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [backgroundView addSubview:titleLabel];
        
        UILabel *moneyLabel = [UILabel labelWithFrame:CGRectMake(0.f, titleLabel.top_mn, 0.f, titleLabel.height_mn) text:moneys[idx] alignment:NSTextAlignmentRight textColor:UIColorWithAlpha([UIColor darkGrayColor], .75f) font:UIFontMedium(15.f)];
        [moneyLabel sizeToFit];
        moneyLabel.textAlignment = NSTextAlignmentCenter;
        moneyLabel.right_mn = backgroundView.width_mn - titleLabel.left_mn;
        [backgroundView addSubview:moneyLabel];
        
        backgroundView.height_mn = moneyLabel.bottom_mn + 20.f;
    }];
    
    if (self.card.type == WXBankCardTypeCredit) {
        UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(0.f, backgroundView.height_mn, backgroundView.width_mn, 13.f)];
        shadow.backgroundColor = UIColorWithSingleRGB(244.f);
        [backgroundView addSubview:shadow];
        backgroundView.height_mn = shadow.bottom_mn;
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(15.f, shadow.bottom_mn + 15.f, 50.f, 16.f) text:@"还款" textColor:UIColorWithAlpha([UIColor darkTextColor], .85f) font:UIFontRegular(16.f)];
        [backgroundView addSubview:titleLabel];

        UIImage *image = UIImageWithUnicode(@"\U0000e63e", UIColorWithAlpha([UIColor grayColor], .55f), 17.f);
        CGSize size = CGSizeMultiplyToHeight(image.size, 17.f);
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(backgroundView.width_mn - size.width - titleLabel.left_mn, 0.f, size.width, size.height) image:image];
        arrowView.centerY_mn = titleLabel.centerY_mn;
        [backgroundView addSubview:arrowView];

        backgroundView.height_mn = titleLabel.bottom_mn + 15.f;
    }
    
    UILabel *hintLabel = [UILabel labelWithFrame:CGRectMake(0.f, self.tableView.height_mn - 33.f, self.tableView.width_mn, 13.f) text:@"交易限额咨询: 95017" alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor whiteColor], .45f) font:[UIFont systemFontOfSize:13.f]];
    [self.tableView addSubview:hintLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.progressView.progress = 0.f;
    [self.tableView.subviews setValue:@(YES) forKeyPath:@"hidden"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateProgressIfNeeds];
}

- (void)updateProgressIfNeeds {
    [self.progressView setProgress:(self.progressView.progress + .2f) animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.progressView.progress >= .6f) {
            self.navigationBar.rightBarItem.hidden = NO;
            [self.progressView setProgress:1.f animated:YES];
            [self.tableView.subviews setValue:@(NO) forKeyPath:@"hidden"];
        } else {
            [self updateProgressIfNeeds];
        }
    });
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIControl *leftItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 15.f, 15.f)];
    leftItem.touchInset = UIEdgeInsetWith(-7.f);
    leftItem.backgroundImage = UIImageNamed(@"wx_common_close_white");
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIControl *rightItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, kNavItemSize, kNavItemSize)];
    rightItem.hidden = YES;
    rightItem.touchInset = UIEdgeInsetWith(-5.f);
    rightItem.backgroundImage = UIImageNamed(@"wx_common_more_white");
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    MNActionSheet *actionSheet = [MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *ac, NSInteger buttonIndex) {
        if (buttonIndex == ac.cancelButtonIndex) return;
        [self.view showWechatDialog];
        [WechatHelper deleteBankCard:self.card completion:^(BOOL succeed) {
            dispatch_after_main(.5f, ^{
                [self.view closeDialogWithCompletionHandler:^{
                    if (succeed) {
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        [self.view showInfoDialog:@"操作失败"];
                    }
                }];
            });
        }];
    } otherButtonTitles:@"解除绑定", nil];
    [actionSheet setButtonTitleColor:BADGE_COLOR ofIndex:0];
    [actionSheet show];
}

#pragma mark - Super
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

@end
