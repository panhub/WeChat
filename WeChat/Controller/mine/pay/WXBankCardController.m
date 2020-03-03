//
//  WXBankCardController.m
//  MNChat
//
//  Created by Vincent on 2019/6/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXBankCardController.h"
#import "WXBankCard.h"
#import "WXBankCardListCell.h"
#import "WXBankCardFooterView.h"
#import "WXBankCardDetailController.h"
#import "WXBankCardBindController.h"

@interface WXBankCardController ()
@property (nonatomic, strong) NSArray <WXBankCard *>*dataArray;
@property (nonatomic, strong) UIVisualEffectView *blurEffect;
@end

@implementation WXBankCardController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"银行卡";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.titleColor = [UIColor whiteColor];
    
    UIVisualEffectView *blurEffect = UIBlurEffectCreate(self.navigationBar.bounds, UIBlurEffectStyleDark);
    blurEffect.alpha = 0.f;
    [self.navigationBar insertSubview:blurEffect atIndex:0];
    self.blurEffect = blurEffect;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = UIColorWithSingleRGB(51.f);
    self.tableView.rowHeight = 115.f;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, TOP_BAR_HEIGHT + 10.f)];
    self.tableView.tableHeaderView = headerView;
    
    @weakify(self);
    WXBankCardFooterView *footerView = [[WXBankCardFooterView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 0.f)];
    footerView.didClickedHandler = ^(NSInteger type) {
        @strongify(self);
        WXBankCardBindController *vc = [WXBankCardBindController new];
        vc.type = type;
        [self.navigationController pushViewController:vc animated:YES];
    };
    self.tableView.tableFooterView = footerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
    [self reloadList];
}

- (void)loadData {
    self.dataArray = [[[MNChatHelper helper] cards] copy];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXBankCardListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.card.cell.id"];
    if (!cell) {
        cell = [[WXBankCardListCell alloc] initWithReuseIdentifier:@"com.wx.card.cell.id" size:tableView.rowSize];
    }
    cell.card = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataArray.count) return;
    WXBankCard *card = self.dataArray[indexPath.row];
    WXBankCardDetailController *vc = [[WXBankCardDetailController alloc] initWithCard:card];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self setNavigationBarBlurEffectHidden:(scrollView.contentOffset.y <= (self.tableView.tableHeaderView.height_mn - TOP_BAR_HEIGHT))];
}

- (void)setNavigationBarBlurEffectHidden:(BOOL)hidden {
    if (self.blurEffect.alpha == (1.f - hidden)) return;
    [UIView animateWithDuration:.3f animations:^{
        self.blurEffect.alpha = 1.f - hidden;
    }];
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIControl *leftItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, kNavItemSize, kNavItemSize)];
    leftItem.touchInset = UIEdgeInsetWith(-5.f);
    leftItem.backgroundImage = UIImageNamed(@"wx_common_back_white");
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

#pragma mark - Super
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

@end
