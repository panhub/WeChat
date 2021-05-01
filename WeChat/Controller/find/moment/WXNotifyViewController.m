//
//  WXNotifyViewController.m
//  WeChat
//
//  Created by Vincent on 2019/7/23.
//  Copyright © 2019 AiZhe. All rights reserved.
//

#import "WXNotifyViewController.h"
#import "WXTimelineViewModel.h"
#import "WXNotifyViewModel.h"
#import "WXNotifyCell.h"
#import "WXTimeline.h"
#import "WXMomentNotifyViewModel.h"
#import "MNRefreshFooter.h"

@interface WXNotifyViewController ()<MNTableViewCellDelegate>
@property (nonatomic, strong) WXMomentNotifyViewModel *viewModel;
@end

@implementation WXNotifyViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"消息";
        self.loadMoreEnabled = YES;
        self.viewModel = WXMomentNotifyViewModel.new;
        [self handEvents];
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.separatorColor = VIEW_COLOR;
    self.tableView.rowHeight = WXNotifyCellHeight;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, MN_TAB_SAFE_HEIGHT)];
}

- (void)handEvents {
    @weakify(self);
    /// 刷新表事件
    self.viewModel.reloadTableHandler = ^{
        @strongify(self);
        [UIView performWithoutAnimation:^{
            [self reloadList];
            ((UIButton *)(self.navigationBar.rightBarItem)).enabled = self.viewModel.dataSource.count > 0;
        }];
    };
    /// 加载结束事件
    self.viewModel.didLoadFinishHandler = ^(BOOL hasMore) {
        @strongify(self);
        if (hasMore) {
            [self resetLoadFooter];
        } else {
            [self relieveLoadFooter];
        }
    };
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadData {
    [self.viewModel loadData];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXNotifyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.moment.notify.cell"];
    if (!cell) {
        cell = [[WXNotifyCell alloc] initWithReuseIdentifier:@"com.moment.notify.cell" size:tableView.rowSize];
        cell.editDelegate = self;
        cell.allowsEditing = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXNotifyCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.viewModel = self.viewModel.dataSource[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEdit) [tableView endEditingWithAnimated:YES];
}

#pragma mark - MNTableViewCellDelegate
- (BOOL)tableViewCell:(MNTableViewCell *)cell canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<MNTableViewCellEditAction *> *)tableViewCell:(MNTableViewCell *)cell editingActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNTableViewCellEditAction *action = [MNTableViewCellEditAction new];
    action.title = @"删除";
    action.inset = UIEdgeInsetWith(20.f);
    action.titleFont = [UIFont systemFontOfSize:18.f];
    action.style = MNTableViewCellEditingStyleDelete;
    return @[action];
}

- (UIView *)tableViewCell:(MNTableViewCell *)cell commitEditingAction:(MNTableViewCellEditAction *)action forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.width_mn = cell.editingView.width_mn + 30.f;
    button.backgroundColor = MN_R_G_B(253.f, 61.f, 48.f);
    [button setTitle:@"确认删除" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
    @weakify(self);
    [button handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        /// 删除
        @strongify(self);
        if (indexPath.row >= self.viewModel.dataSource.count) {
            [cell endEditingUsingAnimation];
            return;
        }
        [self deleteNotifyAtIndexPath:indexPath];
    }];
    return button;
}

#pragma mark - 删除提醒事项
- (void)deleteNotifyAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    [self.view showWechatDialogDelay:.3f eventHandler:^{
        WXNotify *notify = weakself.viewModel.dataSource[indexPath.row].notify;
        if ([MNDatabase.database deleteRowFromTable:WXMomentNotifyTableName where:@{sql_field(notify.identifier):sql_pair(notify.identifier)}.sqlQueryValue]) {
            [weakself.viewModel.dataSource removeObjectAtIndex:indexPath.row];
            [weakself.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            kTransform(UIButton *, weakself.navigationBar.rightBarItem).enabled = weakself.viewModel.dataSource.count > 0;
            if (weakself.didDeleteNotifyHandler) {
                weakself.didDeleteNotifyHandler();
            } else {
                @PostNotify(WXMomentNotifyReloadNotificationName, nil);
            }
        }
    } completionHandler:nil];
}

- (void)deleteAllNotifys {
    @weakify(self);
    [self.view showWechatDialogDelay:.3f eventHandler:^{
        if ([MNDatabase.database deleteRowFromTable:WXMomentNotifyTableName where:nil]) {
            [weakself.viewModel.dataSource removeAllObjects];
            [weakself reloadList];
            kTransform(UIButton *, weakself.navigationBar.rightBarItem).enabled = NO;
            if (weakself.didDeleteNotifyHandler) {
                weakself.didDeleteNotifyHandler();
            } else {
                @PostNotify(WXMomentNotifyReloadNotificationName, nil);
            }
        }
    } completionHandler:nil];
}

#pragma mark - Super
- (UIView *)loadFooter {
    return [[MNRefreshFooter alloc] initWithType:MNRefreshFooterTypeMargin];
}

- (void)beginLoadMore {
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself.viewModel loadData];
    });
}

#pragma mark - MNNavigationBarDelegate
- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightItem = [UIButton buttonWithFrame:CGRectZero
                                            image:nil
                                              title:@"清空"
                                         titleColor:[UIColor.darkTextColor colorWithAlphaComponent:.9f]
                                          titleFont:[UIFont systemFontOfSize:17.f]];
    rightItem.enabled = NO;
    [rightItem sizeToFit];
    [rightItem setTitleColor:[UIColor.grayColor colorWithAlphaComponent:.5f] forState:UIControlStateDisabled];
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    @weakify(self);
    MNActionSheet *actionSheet = [MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *ac, NSInteger buttonIndex) {
        if (buttonIndex == ac.cancelButtonIndex) return;
        [weakself deleteAllNotifys];
    } otherButtonTitles:@"删除所有消息", nil];
    actionSheet.buttonTitleColor = BADGE_COLOR;
    [actionSheet showInView:self.view];
}

@end
