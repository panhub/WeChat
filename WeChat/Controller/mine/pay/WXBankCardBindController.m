//
//  WXBankCardBindController.m
//  MNChat
//
//  Created by Vincent on 2019/6/4.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXBankCardBindController.h"
#import "WXDataValueModel.h"
#import "WXBankCardBindCell.h"

@interface WXBankCardBindController ()
@property (nonatomic, strong) WXBankCard *card;
@property (nonatomic, strong) NSArray <NSString *>*imgArray;
@property (nonatomic, strong) NSArray <NSString *>*watermarks;
@property (nonatomic, strong) NSArray <WXDataValueModel *>*dataArray;
@end

@implementation WXBankCardBindController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"绑定银行卡";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.contentView.backgroundColor = UIColorWithSingleRGB(237.f);
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = UIColorWithSingleRGB(237.f);
    self.navigationBar.shadowView.hidden = YES;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 50.f;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.backgroundColor = UIColorWithSingleRGB(237.f);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *footerButton = [UIButton buttonWithFrame:CGRectMake(15.f, self.tableView.rowHeight*self.dataArray.count + 100.f, self.tableView.width_mn - 30.f, 48.f) image:[UIImage imageWithColor:THEME_COLOR] title:@"下一步" titleColor:[UIColor whiteColor] titleFont:UIFontMedium(18.f)];
    UIViewSetCornerRadius(footerButton, 4.f);
    [footerButton addTarget:self action:@selector(nextButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:footerButton];
}

- (void)loadData {
    WXDataValueModel *model0 = [WXDataValueModel new];
    model0.title = @"选择银行";
    model0.desc = @"建设银行";
    model0.value = @(NO);
    WXDataValueModel *model1 = [WXDataValueModel new];
    model1.title = @"银行图标";
    model1.img = @"wx_pay_bank_ccb";
    model1.value = @(YES);
    WXDataValueModel *model2 = [WXDataValueModel new];
    model2.title = @"卡片类型";
    model2.desc = self.type ? @"信用卡" : @"储蓄卡";
    model2.value = @(YES);
    self.dataArray = @[model0, model1, model2];
    self.imgArray = @[@"wx_pay_bank_ccb", @"wx_pay_bank_boc", @"wx_pay_bank_abc", @"wx_pay_bank_cmb", @"wx_pay_bank_icbc", @"wx_pay_bank_psbc"];
    self.watermarks = @[MNFontUnicodeCCB, MNFontUnicodeBOC, MNFontUnicodeABC, MNFontUnicodeCMBC, MNFontUnicodeICBC, MNFontUnicodePSBC];
}

- (void)nextButtonClicked {
    [self.view showWechatDialog];
    [WechatHelper insertBankCard:self.card completion:^(BOOL succeed) {
        if (succeed) {
            dispatch_after_main(.3f, ^{
                [self.view closeDialogWithCompletionHandler:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            });
        } else {
            [self.view showInfoDialog:@"添加银行卡出错"];
        }
    }];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MNTableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.bind.card.header"];
    if (!header) {
        header = [[MNTableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.bind.card.header"];
        header.contentView.backgroundColor = tableView.backgroundColor;
        header.titleLabel.frame = CGRectMake(15.f, MEAN(35.f - 16.f), tableView.width_mn - 30.f, 16.f);
        header.titleLabel.font = [UIFont systemFontOfSize:header.titleLabel.height_mn];
        header.titleLabel.textColor = UIColorWithAlpha([UIColor grayColor], .9f);
        header.titleLabel.text = @"完善银行卡信息";
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXBankCardBindCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.bind.card.id"];
    if (!cell) {
        cell = [[WXBankCardBindCell alloc] initWithReuseIdentifier:@"com.wx.bind.card.id" size:tableView.rowSize];
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        /// 选择银行
        [[MNActionSheet actionSheetWithTitle:@"选择银行" cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == actionSheet.cancelButtonIndex) return;
            WXDataValueModel *model0 = self.dataArray[0];
            model0.desc = [actionSheet buttonTitleOfIndex:buttonIndex];
            WXDataValueModel *model1 = self.dataArray[1];
            model1.img = self.imgArray[buttonIndex];
            self.card.name = model0.desc;
            self.card.img = model1.img;
            self.card.watermark = self.watermarks[buttonIndex];
            [tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
            [tableView reloadRow:1 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        } otherButtonTitles:@"建设银行", @"中国银行", @"农业银行", @"招商银行", @"工商银行", @"邮政储蓄", nil] show];
    }
}

#pragma mark - Getter
- (WXBankCard *)card {
    if (!_card) {
        WXBankCard *card = [WXBankCard new];
        card.name = @"建设银行";
        card.img = @"wx_pay_bank_ccb";
        card.type = _type;
        card.watermark = MNFontUnicodeCCB;
        _card = card;
    }
    return _card;
}

#pragma mark - Setter
- (void)setType:(WXBankCardType)type {
    _type = type;
    self.title = type == WXBankCardTypeCredit ? @"绑定信用卡" : @"绑定银行卡";
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

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
