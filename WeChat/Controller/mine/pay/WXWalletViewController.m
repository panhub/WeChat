//
//  WXWalletViewController.m
//  WeChat
//
//  Created by Vincent on 2019/6/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXWalletViewController.h"
#import "WXChangeViewController.h"
#import "WXDataValueModel.h"
#import "WXWalletListCell.h"

@interface WXWalletViewController ()
@property (nonatomic, strong) NSArray <NSArray <WXDataValueModel *>*>*dataArray;
@end

@implementation WXWalletViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"钱包";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = UIColorWithSingleRGB(247.f);
    self.navigationBar.shadowView.hidden = YES;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 55.f;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.backgroundColor = UIColorWithSingleRGB(247.f);
    
    NSString *text = @"帮助中心\n本服务由财付通提供";
    NSMutableAttributedString *string = text.attributedString.mutableCopy;
    string.alignment = NSTextAlignmentCenter;
    string.lineSpacing = 3.f;
    string.font = UIFontRegular(13.f);
    string.color = UIColorWithSingleRGB(132.f);
    [string setColor:TEXT_COLOR range:[text rangeOfString:@"帮助中心"]];
    CGSize size = [string sizeOfLimitWidth:self.tableView.width_mn];
    UILabel *hintLabel = [UILabel labelWithFrame:CGRectMake(MEAN(self.tableView.width_mn - size.width), 0.f, size.width, size.height) text:string textColor:nil font:nil];
    hintLabel.bottom_mn = self.tableView.height_mn - 25.f;
    hintLabel.numberOfLines = 0;
    [self.tableView addSubview:hintLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    WXDataValueModel *model = [[self.dataArray firstObject] firstObject];
    model.desc = [@"¥" stringByAppendingString:WXPreference.preference.money];
    [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
}

- (void)loadData {
    NSArray <NSArray <NSString *>*>*titles = @[@[@"零钱", @"零钱通"], @[@"银行卡", @"亲属卡", @"安全保障"]];
    NSArray <NSArray <NSString *>*>*imgs = @[@[@"wx_wallet_lq", @"wx_wallet_lqt"], @[@"wx_wallet_card-2", @"wx_wallet_qsk", @"wx_wallet_pay"]];
    NSArray <NSArray <NSString *>*>*values = @[@[[@"¥" stringByAppendingString:WXPreference.preference.money], @"收益率2.37%"], @[@"", @"", @""]];
    NSMutableArray <NSArray <WXDataValueModel *>*>*dataArray = [NSMutableArray arrayWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull obj, NSUInteger index, BOOL * _Nonnull sp) {
        NSMutableArray <WXDataValueModel *>*listArray = [NSMutableArray arrayWithCapacity:obj.count];
        [obj enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
            WXDataValueModel *model = [WXDataValueModel new];
            model.title = title;
            model.img = imgs[index][idx];
            model.value = values[index][idx];
            [listArray addObject:model];
        }];
        [dataArray addObject:listArray];
    }];
    self.dataArray = dataArray.copy;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section > 0 ? 10.f : CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) return nil;
    MNTableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.wallet.header.id"];
    if (!header) {
        header = [[MNTableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.wallet.header.id"];
        header.contentView.backgroundColor = tableView.backgroundColor;
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXWalletListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.wallet.cell.id"];
    if (!cell) {
        cell = [[WXWalletListCell alloc] initWithReuseIdentifier:@"com.wx.wallet.cell.id" size:tableView.rowSize];
    }
    cell.model = self.dataArray[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section + indexPath.row == 0) {
        [self.view showWechatDialogDelay:.3f completionHandler:^{
            UIViewControllerPush(@"WXChangeViewController", YES);
        }];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        UIViewControllerPush(@"WXBankCardController", YES);
    }
}

#pragma mark - MNNavigationBarDelegate
- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 40.f, kNavItemSize)
                                             image:nil
                                             title:@"账单"
                                        titleColor:UIColorWithAlpha([UIColor darkTextColor], .9f)
                                              titleFont:@(17.f)];
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    UIViewControllerPush(@"WXChangeListController", YES);
}

@end
