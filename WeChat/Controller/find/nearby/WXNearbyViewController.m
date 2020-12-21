//
//  WXNearbyViewController.m
//  MNChat
//
//  Created by Vincent on 2020/2/10.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXNearbyViewController.h"
#import "WXUserInfoViewController.h"
#import "WXShakeHistoryCell.h"
#import "WXShakeHistory.h"

#define WXNearbyMaxCount    50
#define WXNearbyPageCount   15

@interface WXNearbyViewController ()
/**性别限制*/
@property (nonatomic) WechatGender gender;
/**判断是否在刷新*/
@property (nonatomic, getter=isLoading) BOOL loading;
/**是否第一次加载数据*/
@property (nonatomic, getter=isFirstLoading) BOOL firstLoading;
/**数据源*/
@property (nonatomic, strong) NSMutableArray <WXShakeHistory *>*dataArray;
/**数据筛选缓存*/
@property (nonatomic, strong) NSMutableArray <WXShakeHistory *>*dataCache;
@end

@implementation WXNearbyViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"附近的人";
        self.firstLoading = YES;
        self.loadMoreEnabled = YES;
        self.pullRefreshEnabled = YES;
        self.dataArray = @[].mutableCopy;
        self.dataCache = @[].mutableCopy;
    }
    return self;
}

- (void)createView {
    [super createView];
    // 创建视图
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowColor = VIEW_COLOR;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 64.f;
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadData {
    if (self.isFirstLoading) [self.view showLoadDialog:@"加载中"];
    dispatch_async_default(^{
        NSInteger count = self.dataArray.count >= WXNearbyMaxCount ? 0 : MIN(WXNearbyMaxCount - self.dataArray.count, WXNearbyPageCount);
        NSMutableArray <WXShakeHistory *>*array = @[].mutableCopy;
        for (int i = 0; i < count; i++) {
            WXUser *user = WechatHelper.user;
            if (self.gender != WechatGenderUnknown) user.gender = self.gender;
            [array addObject:[[WXShakeHistory alloc] initWithUser:user]];
        }
        dispatch_async_main(^{
            [self.dataArray addObjectsFromArray:array];
            [self reloadList];
            [self endRefreshing];
            if (self.isFirstLoading) {
                self.firstLoading = NO;
                [self.view closeDialog];
            }
        });
    });
}

#pragma mark - UITableViewDataDelegate&Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXShakeHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.nearby.cell"];
    if (!cell) {
        cell = [[WXShakeHistoryCell alloc] initWithReuseIdentifier:@"com.wx.nearby.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXShakeHistoryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.history = self.dataArray[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isLoading || indexPath.row >= self.dataArray.count) return;
    WXShakeHistory *history = self.dataArray[indexPath.row];
    WXUser *user = [WXUser userWithInfo:history.extend.JsonValue];
    if (user) {
        user.avatarData = history.thumbnailData;
        [user setValue:history.thumbnailImage forKey:kPath(user.avatar)];
        WXUserInfoViewController *vc = [[WXUserInfoViewController alloc] initWithUser:user];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self.view showInfoDialog:@"数据错误"];
    }
}

#pragma mark - 数据更新
- (void)filterDataWithGender:(WechatGender)gender {
    @weakify(self);
    [self.view showWechatDialogDelay:.5f eventHandler:^{
        @strongify(self);
        [self repayDataWithGender:gender];
    } completionHandler:^{
        @strongify(self);
        [self reloadList];
        [self endRefreshing];
    }];
}

- (void)repayDataWithGender:(WechatGender)gender {
    // 先挑出不合格数据
    NSArray *filterArray = gender == WechatGenderUnknown ? @[] : [self.dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.gender != %d", gender]];
    [self.dataArray removeObjectsInArray:filterArray];
    NSArray *cacheArray = gender == WechatGenderUnknown ? self.dataCache.copy : [self.dataCache filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.gender == %d", gender]];
    [self.dataCache removeObjectsInArray:cacheArray];
    [self.dataCache addObjectsFromArray:filterArray];
    if (cacheArray.count) {
        [cacheArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.dataArray insertObject:obj atIndex:self.dataArray.randomIndex];
        }];
    }
}

#pragma mark - Overwrite
- (void)reloadList {
    [super reloadList];
    if (self.dataArray.count <= 0) {
        [self showEmptyViewNeed:YES image:nil message:@"暂无匹配数据" title:nil type:MNEmptyEventTypeReload];
    } else {
        [self dismissEmptyView];
    }
}

- (void)beginPullRefresh {
    @weakify(self);
    dispatch_after_main(.8f, ^{
        @strongify(self);
        [self.dataArray removeAllObjects];
        [self loadData];
    });
}

- (void)beginLoadMore {
    @weakify(self);
    dispatch_after_main(.8f, ^{
        @strongify(self);
        [self loadData];
    });
}

- (void)endRefreshing {
    if (self.listView.mj_header.isRefreshing) {
        [self.listView.mj_header endRefreshing];
    }
    if (self.dataArray.count < WXNearbyMaxCount) {
        if (self.listView.mj_footer.isRefreshing) {
            [self endLoadMore];
        } else if (self.listView.mj_footer.state == MJRefreshStateNoMoreData) {
            [self resetLoadMoreFooter];
        }
    } else {
        [self relieveLoadMoreFooter];
    }
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIControl *rightBarItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, kNavItemSize, kNavItemSize)];
    rightBarItem.touchInset = UIEdgeInsetWith(-5.f);
    rightBarItem.backgroundImage = [UIImage imageNamed:@"wx_common_more_black"];
    [rightBarItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightBarItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    if (self.isLoading) return;
    @weakify(self);
    [[MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
        if (actionSheet.cancelButtonIndex == buttonIndex) return;
        @strongify(self);
        self.gender = WechatGenderFemale - buttonIndex;
    } otherButtonTitles:@"只看女生", @"只看男生", @"不限", nil] show];
}

#pragma mark - Setter
- (void)setGender:(WechatGender)gender {
    if (gender == _gender) return;
    _gender = gender;
    [self filterDataWithGender:gender];
}

#pragma mark - Getter
- (BOOL)isLoading {
    return self.listView.mj_header.isRefreshing || self.listView.mj_footer.isRefreshing;
}

@end
