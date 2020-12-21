//
//  WXCollectViewController.m
//  MNChat
//
//  Created by Vincent on 2019/4/29.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCollectViewController.h"
#import "WXCollectListCell.h"

@interface WXCollectViewController () <MNSearchControllerDelegate, UIScrollViewDelegate, MNTableViewCellDelegate, UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray <WXWebpage *>*dataArray;
@end

@implementation WXCollectViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"收藏";
        self.delegate = self;
        self.dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.view.backgroundColor = VIEW_COLOR;
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowColor = UIColorWithAlpha([UIColor darkTextColor], .1f);
    self.navigationBar.shadowView.hidden = YES;

    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.rowHeight = 115.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.searchBar setTitleColor:TEXT_COLOR forState:UIControlStateNormal];
    [self.searchBar setTitleColor:TEXT_COLOR forState:UIControlStateHighlighted];
    self.searchBar.frame = CGRectMake(0.f, 5.f, self.tableView.width_mn, MN_NAV_BAR_HEIGHT);
    @weakify(self);
    self.searchBar.textFieldConfigurationHandler = ^(MNSearchBar *searchBar, MNTextField *textField) {
        @strongify(self);
        textField.delegate = self;
        textField.tintColor = THEME_COLOR;
        textField.frame = CGRectMake(10.f, MEAN(searchBar.height_mn - 35.f), searchBar.width_mn - 20.f, 35.f);
    };
    MNAdsorbView *headerView = [[MNAdsorbView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, self.searchBar.height_mn + 10.f)];
    headerView.imageView.backgroundColor = VIEW_COLOR;
    [headerView.contentView addSubview:self.searchBar];
    self.tableView.tableHeaderView = headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /// ShareExtension 引发事件
    @weakify(self);
    [self handNotification:WXWebpageReloadNotificationName eventHandler:^(id sender) {
        @strongify(self);
        [self loadData];
    }];
}

- (void)loadData {
    [MNDatabase selectRowsModelFromTable:WXWebpageTableName class:[WXWebpage class] completion:^(NSArray<id> * _Nonnull rows) {
        dispatch_async_main(^{
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:rows];
            @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
        });
    }];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0.f : 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MNTableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.mine.collect.header"];
    if (!header) {
        header = [[MNTableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.mine.collect.header"];
        header.clipsToBounds = YES;
        header.contentView.backgroundColor = VIEW_COLOR;
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXCollectListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.mine.collect.cell"];
    if (!cell) {
        cell = [[WXCollectListCell alloc] initWithReuseIdentifier:@"com.wx.mine.collect.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
        cell.editDelegate = self;
        cell.allowsEditing = YES;
    }
    if (indexPath.section >= self.dataArray.count) return cell;
    cell.model = self.dataArray[indexPath.section];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WXCollectListCell *cell = (WXCollectListCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.isEdit) {
        [cell endEditingUsingAnimation];
        return;
    }
    if (indexPath.section >= self.dataArray.count) return;
    WXWebpage *page = self.dataArray[indexPath.section];
    if (page.url.length <= 0) return;
    if (self.selectedHandler) {
        self.selectedHandler(page);
    } else {
        MNWebViewController *vc = [[MNWebViewController alloc] initWithUrl:page.url];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - MNTableViewCellDelegate
- (BOOL)tableViewCell:(MNTableViewCell *)cell canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<MNTableViewCellEditAction *> *)tableViewCell:(MNTableViewCell *)cell editingActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MNTableViewCellEditAction *action0 = [MNTableViewCellEditAction new];
    action0.width = 75.f;
    action0.image = UIImageNamed(@"wx_collect_tag");
    action0.inset = UIEdgeInsetsMake(0.f, 5.f, 0.f, 15.f);
    action0.backgroundColor = [UIColor clearColor];
    
    MNTableViewCellEditAction *action1 = [MNTableViewCellEditAction new];
    action1.width = 70.f;
    action1.image = UIImageNamed(@"wx_collect_delete");
    action1.inset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 15.f);
    action1.backgroundColor = [UIColor clearColor];
    
    return @[action0, action1];
}

- (UIView *)tableViewCell:(MNTableViewCell *)cell commitEditingAction:(MNTableViewCellEditAction *)action forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!action.index) return nil;
    if (indexPath.section >= self.dataArray.count) return nil;
    WXWebpage *model = self.dataArray[indexPath.section];
    [self.dataArray removeObject:model];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
    [MNDatabase deleteRowFromTable:WXWebpageTableName where:[@{sql_field(model.url):sql_pair(model.url)} componentString] completion:nil];
    dispatch_after_main(.3f, ^{
        [self reloadList];
    });
    return nil;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navigationBar.shadowView.hidden = offsetY <= 0.f;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return self.dataArray.count > 0;
}

#pragma mark - MNNavigationBarDelegate
- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightBarItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 21.f, 21.f)
                                                 image:UIImageNamed(@"wx_home_more")
                                                 title:nil
                                            titleColor:nil
                                                  titleFont:nil];
    rightBarItem.touchInset = UIEdgeInsetWith(-10.f);
    [rightBarItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightBarItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    [[MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) return;
        [UIApplication handOpenUrl:@"https://www.baidu.com" completion:nil];
    } otherButtonTitles:@"打开系统浏览器", nil] show];
}

#pragma mark - Super
- (void)reloadList {
    [super reloadList];
    self.tableView.backgroundColor = self.dataArray.count <= 0 ? [UIColor whiteColor] : VIEW_COLOR;
    [self showEmptyViewNeed:self.dataArray.count <= 0
                      image:UIImageNamed(@"common_empty")
                    message:nil
                      title:nil
                       type:MNEmptyEventTypeLoad];
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    if (self.type == WXCollectControllerMine) return nil;
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    if (self.type == WXCollectControllerMine) return nil;
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
