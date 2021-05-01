//
//  WXMineViewController.m
//  WeChat
//
//  Created by Vincent on 2019/2/24.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "WXMineViewController.h"
#import "WXMineHeaderView.h"
#import "WXMineCell.h"
#import "WXDataValueModel.h"
#import "WXMineInfoController.h"
#import "WXPayViewController.h"
#import "WXLocalEvaluationController.h"
#import "WXPasswordViewController.h"

@interface WXMineViewController ()
@property (nonatomic, strong) WXMineHeaderView *headerView;
@property (nonatomic, strong) NSArray <NSArray <WXDataValueModel *> *>*dataArray;
@end

@implementation WXMineViewController

- (void)createView {
    [super createView];
    
    self.navigationBar.hidden = YES;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 55.f;
    
    WXMineHeaderView *headerView = [[WXMineHeaderView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 0.f)];
    headerView.imageView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
}

- (void)loadData {
    NSArray <NSArray <NSString *>*>*imgs = @[@[@"wx_mine_pay"], @[@"wx_mine_collect", @"wx_mine_album", @"wx_mine_wallet", @"wx_mine_emoji"], @[@"wx_mine_setting"]];
    NSArray <NSArray <NSString *>*>*titles = @[@[@"支付"], @[@"收藏", @"朋友圈", @"卡包", @"表情"], @[@"设置"]];
    NSArray <NSArray <NSString *>*>*descs = @[@[@"支付"], @[@"收藏", @"朋友圈相册", @"卡包", @"表情"], @[@"设置"]];
    NSArray <NSArray <NSString *>*>*values = @[@[@"WXPayViewController"], @[@"WXFavoriteController", @"WXAlbumViewController", @"WXBankCardController", @"WXEmoticonViewController"], @[@"WXSetingViewController"]];
    NSMutableArray <NSArray *>*dataArray = [NSMutableArray arrayWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray <WXDataValueModel *>*listArray = [NSMutableArray arrayWithCapacity:obj.count];
        [obj enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger index, BOOL * _Nonnull stop) {
            WXDataValueModel *model = [WXDataValueModel new];
            model.title = title;
            model.desc = descs[idx][index];
            model.img = imgs[idx][index];
            model.value = values[idx][index];
            [listArray addObject:model];
        }];
        [dataArray addObject:listArray.copy];
    }];
    self.dataArray = dataArray.copy;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    @weakify(self);
    [self.headerView handTapConfiguration:nil eventHandler:^(id sender) {
        @strongify(self);
        WXMineInfoController *vc = [WXMineInfoController new];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.headerView updateUserInfo];
}

#pragma mark - UITableViewDataDelegate&Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.mine.header"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.mine.header"];
        header.contentView.backgroundColor = VIEW_COLOR;
        header.clipsToBounds = YES;
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXMineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.mine.list.cell"];
    if (!cell) {
        cell = [[WXMineCell alloc] initWithReuseIdentifier:@"com.wx.mine.list.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXMineCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataArray.count) return;
    NSArray <WXDataValueModel *>*section = self.dataArray[indexPath.section];
    cell.model = section[indexPath.row];
    if (indexPath.row == 0) {
        cell.topSeparatorInset = UIEdgeInsetsZero;
    } else {
        cell.topSeparatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.contentView.width_mn);
    }
    if (indexPath.row == section.count - 1) {
        cell.bottomSeparatorInset = UIEdgeInsetsZero;
    } else {
        cell.bottomSeparatorInset = UIEdgeInsetsMake(0.f, cell.titleLabel.left_mn, 0.f, 0.f);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section + indexPath.row == 0) {
        
        if (WXPreference.preference.isAllowsLocalEvaluation && MNLocalEvaluation.isTouchEnabled) {
            /// 指纹验证可用
            WXLocalEvaluationController *vc = [WXLocalEvaluationController new];
            vc.title = @"验证支付密码";
            vc.didSucceedHandler = ^(UIViewController *v) {
                UINavigationController *nav = v.navigationController;
                [nav popToViewController:self animated:NO];
                WXPayViewController *vv = [WXPayViewController new];
                [nav pushViewController:vv animated:YES];
            };
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            WXPasswordViewController *vc = [WXPasswordViewController new];
            vc.title = @"验证支付密码";
            vc.didSucceedHandler = ^(UIViewController *v) {
                UINavigationController *nav = v.navigationController;
                [nav popToViewController:self animated:NO];
                WXPayViewController *vv = [WXPayViewController new];
                [nav pushViewController:vv animated:YES];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
        return;
    }
    if (indexPath.section >= self.dataArray.count) return;
    NSArray *listArray = self.dataArray[indexPath.section];
    if (indexPath.row >= listArray.count) return;
    WXDataValueModel *model = listArray[indexPath.row];
    if (kTransform(NSString *, model.value).length <= 0) return;
    UIViewController *vc = [NSClassFromString(model.value) new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - controller config
- (BOOL)isRootViewController {
    return YES;
}

- (NSString *)tabBarItemTitle {
    return @"我";
}

- (UIImage *)tabBarItemImage {
    return [UIImage imageNamed:@"tabbar_mine"];
}

- (UIImage *)tabBarItemSelectedImage {
    return [UIImage imageNamed:@"tabbar_mineHL"];
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

@end
