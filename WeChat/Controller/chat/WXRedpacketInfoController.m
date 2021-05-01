//
//  WXRedpacketInfoController.m
//  WeChat
//
//  Created by Vincent on 2019/5/28.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXRedpacketInfoController.h"
#import "WXChangeViewController.h"
#import "WXRedpacketInfoHeader.h"
#import "WXDataValueModel.h"
#import "WXRedpacketInfoCell.h"

@interface WXRedpacketInfoController ()
@property (nonatomic, strong) WXRedpacket *redpacket;
@property (nonatomic, strong) NSArray <WXDataValueModel *>*dataArray;
@end

@implementation WXRedpacketInfoController
- (instancetype)initWithRedpacket:(WXRedpacket *)redpacket {
    if (!redpacket) return nil;
    if (self = [super init]) {
        self.redpacket = redpacket;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = MN_R_G_B(243.f, 85.f, 67.f);
    self.navigationBar.shadowView.hidden = YES;
    
    self.tableView.frame = self.contentView.bounds;
    
    WXRedpacketInfoHeader *headerView = [[WXRedpacketInfoHeader alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, (self.redpacket.isMine ? 210.f : self.tableView.height_mn/2.f))];
    headerView.redpacket = self.redpacket;
    self.tableView.tableHeaderView = headerView;
    
    if (self.redpacket.isMine) {
        self.tableView.rowHeight = 72.f;
        self.tableView.separatorColor = UIColorWithAlpha([UIColor grayColor], .1f);
    } else {
        UIButton *emojiButton = [UIButton buttonWithFrame:CGRectMake(MEAN(self.tableView.width_mn - 85.f), headerView.height_mn + 25.f, 85.f, 85.f) image:[UIImage imageNamed:@"wx_redpacket_add_expression"] title:nil titleColor:nil titleFont:nil];
        [self.tableView addSubview:emojiButton];
        
        UILabel *textLabel = [UILabel labelWithFrame:CGRectMake(0.f, emojiButton.bottom_mn + 15.f, self.tableView.width_mn, 14.f) text:@"回复一个表情到聊天" alignment:NSTextAlignmentCenter textColor:MN_R_G_B(217.f, 175.f, 104.f) font:@(14.f)];
        [self.tableView addSubview:textLabel];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    @weakify(self);
    WXRedpacketInfoHeader *headerView = (WXRedpacketInfoHeader *)(self.tableView.tableHeaderView);
    headerView.changeInfoEventHandler = ^{
        @strongify(self);
        WXChangeViewController *vc = [WXChangeViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    };
}

- (void)loadData {
    if (self.redpacket.isMine == NO) return;
    WXDataValueModel *model = [WXDataValueModel new];
    model.title = self.redpacket.toUser.name;
    model.userInfo = self.redpacket.toUser.avatar;
    model.value = [self.redpacket.money stringByAppendingString:@"元"];
    model.desc = [NSDate stringValueWithTimestamp:self.redpacket.draw_time format:@"MM-dd HH:mm"];
    self.dataArray = @[model];
}

#pragma mark - UITableViewDelegate && DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 70.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MNTableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.redpacket.info.header"];
    if (!header) {
        header = [[MNTableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.redpacket.info.header"];
        header.titleLabel.frame = CGRectMake(13.f, 43.f, tableView.width_mn - 26.f, 14.f);
        header.titleLabel.font = UIFontRegular(14.f);
        header.titleLabel.textColor = UIColorWithAlpha([UIColor darkGrayColor], .5f);
        header.titleLabel.text = [NSString stringWithFormat:@"1个红包共%@元", self.redpacket.money];
        header.contentView.backgroundColor = [UIColor whiteColor];
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXRedpacketInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.redpacket.info.cell"];
    if (!cell) {
        cell = [[WXRedpacketInfoCell alloc] initWithReuseIdentifier:@"com.wx.redpacket.info.cell" size:tableView.rowSize];
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIControl *leftItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, kNavItemSize, kNavItemSize)];
    leftItem.backgroundImage = [UIImage imageNamed:@"wx_common_back_yellow"];
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 75.f, kNavItemSize)
                                             image:nil
                                             title:@"红包记录"
                                        titleColor:MN_R_G_B(254.f, 225.f, 177.f)
                                              titleFont:@(17.f)];
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    
}

#pragma mark - Super
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

@end
