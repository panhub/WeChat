//
//  WXFindViewController.m
//  MNChat
//
//  Created by Vincent on 2019/2/24.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "WXFindViewController.h"
#import "WXMusicPlayController.h"
#import "WXFindListCell.h"
#import "WXDataValueModel.h"
#import "WXTabBarController.h"
#import "WXSong.h"

@interface WXFindViewController ()
{
    BOOL _needReloadBadgeValue;
}
@property (nonatomic, strong) NSArray <NSArray <WXDataValueModel *>*>*dataArray;
@end

@implementation WXFindViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"发现";
        _needReloadBadgeValue = YES;
    }
    return self;
}

- (void)createView {
    [super createView];
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowColor = [UIColor clearColor];
    self.navigationBar.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.rowHeight = 55.f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /// 刷新角标通知
    @weakify(self);
    [self handNotification:WXMomentRemindReloadNotificationName eventHandler:^(id sender) {
        @strongify(self);
        self->_needReloadBadgeValue = YES;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_needReloadBadgeValue) {
        _needReloadBadgeValue = NO;
        NSInteger count = [WXTabBarController.tabBarController updateMomentBadgeValue];
        if (self.dataArray.count) {
            WXDataValueModel *model = self.dataArray.firstObject.firstObject;
            model.userInfo = NSStringWithFormat(@"%@", @(count));
            [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)loadData {
    NSArray <NSArray <NSString *>*>*titles = @[@[@"朋友圈"], @[@"扫一扫", @"摇一摇"], @[@"看一看", @"搜一搜"], @[@"附近的人"], @[@"音乐", @"游戏"], @[@"小程序"]];
    NSArray <NSArray <NSString *>*>*imgs = @[@[@"wx_find_timeline"], @[@"wx_find_scanning", @"wx_find_shake"], @[@"wx_find_see", @"wx_find_search"], @[@"wx_find_nearby"], @[@"wx_find_shopping", @"wx_find_game"], @[@"wx_find_program"]];
    NSArray <NSArray <NSString *>*>*values = @[@[@"WXMomentViewController"], @[@"WXScanViewController", @"WXShakeViewController"], @[@"WXWatchViewController", @""], @[@"WXNearbyViewController"], @[@"WXMusicViewController", @""], @[@"WXAppletViewController"]];
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *listArray = [NSMutableArray arrayWithCapacity:obj.count];
        [obj enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger index, BOOL * _Nonnull _stop) {
            WXDataValueModel *model = [WXDataValueModel new];
            model.title = title;
            model.img = imgs[idx][index];
            model.value = values[idx][index];
            [listArray addObject:model];
        }];
        [dataArray addObject:listArray];
    }];
    self.dataArray = dataArray.copy;
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return (section == self.dataArray.count - 1) ? .1f : 8.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UITableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.find.footer"];
    if (!footer) {
        footer = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.find.footer"];
        footer.contentView.backgroundColor = VIEW_COLOR;
    }
    return footer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXFindListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.find.cell"];
    if (!cell) {
        cell = [[WXFindListCell alloc] initWithReuseIdentifier:@"com.wx.find.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
    }
    WXDataValueModel *model = self.dataArray[indexPath.section][indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataArray.count) return;
    NSArray <WXDataValueModel *>*listArray = self.dataArray[indexPath.section];
    if (indexPath.row >= listArray.count) return;
    WXDataValueModel *model = listArray[indexPath.row];
    if (kTransform(NSString *, model.value).length > 0) {
        Class cls = NSClassFromString(model.value);
        if (!cls) return;
        UIViewControllerPush(model.value, YES);
    }
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

- (BOOL)isRootViewController {
    return YES;
}

- (NSString *)tabBarItemTitle {
    return @"发现";
}

- (UIImage *)tabBarItemImage {
    return UIImageNamed(@"wx_tabbar_find");
}

- (UIImage *)tabBarItemSelectedImage {
    return UIImageNamed(@"wx_tabbar_findHL");
}

@end
