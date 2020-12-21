//
//  WXSessionViewController.m
//  MNChat
//
//  Created by Vincent on 2019/2/24.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "WXSessionViewController.h"
#import "WXSession.h"
#import "WXSessionListCell.h"
#import "WXChatViewController.h"
#import "WXScanViewController.h"
#import "WXAddUserViewController.h"
#import "WXSessionResultController.h"
#import "MNScaleView.h"
#import "MNRotationGestureRecognizer.h"

@interface WXSessionViewController () <MNTableViewCellDelegate, UITextFieldDelegate>
@property (nonatomic, strong) MNMenuView *menuView;
@property (nonatomic, strong) NSMutableArray <WXSession *>*dataArray;
@end

@implementation WXSessionViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"微信";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.view.backgroundColor = VIEW_COLOR;
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowColor = SEPARATOR_COLOR;
    self.navigationBar.shadowView.hidden = YES;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.rowHeight = 70.f;
    self.tableView.separatorColor = SEPARATOR_COLOR;

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
    /// 检索结果展示
    WXSessionResultController *searchResultController = [[WXSessionResultController alloc] initWithFrame:CGRectMake(0.f, self.navigationBar.height_mn + self.tableView.tableHeaderView.height_mn, self.view.width_mn, self.view.height_mn - MN_STATUS_BAR_HEIGHT - self.searchBar.height_mn)];
    self.updater = searchResultController;
    self.searchResultController = searchResultController;
    
    /// 刷新会话列表
    @weakify(self);
    [self handNotification:WXSessionReloadNotificationName eventHandler:^(id sender) {
        @strongify(self);
        @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
    }];
    
    /// 首次加载, 手动刷新列表
    [self setNeedsReloadList];
}

- (void)loadData {
    [self.dataArray addObjectsFromArray:[[WechatHelper helper] sessions]];
}

- (void)handEvents {
    @weakify(self);
    [self handNotification:WXSessionUpdateNotificationName eventHandler:^(NSNotification *_Nonnull notify) {
        @strongify(self);
        NSArray<WXSession *> *sessions = notify.object;
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:sessions];
        @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
    }];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXSessionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.session.cell"];
    if (!cell) {
        cell = [[WXSessionListCell alloc] initWithReuseIdentifier:@"com.wx.session.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
        cell.editDelegate = self;
        cell.allowsEditing = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXSessionListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataArray.count) return;
    cell.session = self.dataArray[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MNTableViewCell *cell = (MNTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.isEdit) {
        [cell endEditingUsingAnimation];
        return;
    }
    if (indexPath.row >= self.dataArray.count) return;
    WXSession *session = self.dataArray[indexPath.row];
    WXChatViewController *vc = [[WXChatViewController alloc] initWithSession:session];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MNTableViewCellDelegate
- (BOOL)tableViewCell:(MNTableViewCell *)cell canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<MNTableViewCellEditAction *> *)tableViewCell:(MNTableViewCell *)cell editingActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.dataArray.count) return nil;
    WXSession *conversation = self.dataArray[indexPath.row];
    
    MNTableViewCellEditAction *action0 = [MNTableViewCellEditAction new];
    action0.titleFont = [UIFont systemFontOfSize:18.f];
    action0.title = conversation.unread_count ? @"标为已读" : @"标为未读";
    
    MNTableViewCellEditAction *action1 = [MNTableViewCellEditAction new];
    action1.titleFont = [UIFont systemFontOfSize:18.f];
    action1.title = @"删除";
    action1.style = MNTableViewCellEditingStyleDelete;

    return @[action0, action1];
}

- (UIView *)tableViewCell:(MNTableViewCell *)cell commitEditingAction:(MNTableViewCellEditAction *)action forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (action.index == 0) {
        /// 标记
        [cell endEditingUsingAnimation];
        if (indexPath.row >= self.dataArray.count) return nil;
        WXSession *conversation = self.dataArray[indexPath.row];
        conversation.unread_count = conversation.unread_count ? 0 : 1;
        @PostNotify(WXSessionUpdateNotificationName, conversation);
        dispatch_after_main(.4f, ^{
            @PostNotify(WXSessionReloadNotificationName, conversation);
        });
        return nil;
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.width_mn = cell.editingView.width_mn;
    button.backgroundColor = MN_R_G_B(253.f, 61.f, 48.f);
    [button setTitle:@"确认删除" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
    @weakify(self);
    [button handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        /// 删除
        @strongify(self);
        if (indexPath.row >= self.dataArray.count) {
            [cell endEditingUsingAnimation];
            return;
        }
        WXSession *conversation = self.dataArray[indexPath.row];
        [self.dataArray removeObject:conversation];
        [self.tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationTop];
        dispatch_after_main(.3f, ^{
            @PostNotify(WXSessionDeleteNotificationName, conversation);
        });
    }];
    return button;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navigationBar.shadowView.hidden = offsetY >= 0.f;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return self.dataArray.count > 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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
    [self.menuView show];
}

#pragma mark - MNMenuView
- (MNMenuView *)menuView {
    if (!_menuView) {
        @weakify(self);
        MNMenuView *menuView = [MNMenuView menuWithAlignment:MNMenuAlignmentVertical createdHandler:^(MNMenuView * _Nonnull menuView, NSUInteger idx, UIButton * _Nonnull item) {
            @strongify(self);
            if (item.tag == 0) {
                WXAddUserViewController *vc = [WXAddUserViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            } else if (item.tag == 1) {
                WXScanViewController *vc = [WXScanViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            }
        } titles:@"添加朋友", @"扫一扫", @"収付款", nil];
        menuView.configuration.animationType = MNMenuAnimationZoom;
        menuView.configuration.animationDuration = MNMenuArrowUp;
        menuView.configuration.arrowOffset = UIOffsetMake(40.f, 3.f);
        menuView.configuration.contentInsets = UIEdgeInsetsZero;
        menuView.configuration.animationDuration = .25f;
        menuView.targetView = self.navigationBar.rightBarItem;
        _menuView = menuView;
    }
    return _menuView;
}

#pragma mark -
- (void)reloadList {
    [super reloadList];
    [self updateUnreadCount];
    [self showEmptyViewNeed:self.dataArray.count <= 0
                      image:UIImageNamed(@"common_empty")
                    message:nil
                      title:nil
                       type:MNEmptyEventTypeLoad];
}

- (void)updateUnreadCount {
    __block NSUInteger count = 0;
    [self.dataArray enumerateObjectsUsingBlock:^(WXSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        count += obj.unread_count;
    }];
    self.badgeValue = NSStringFromNumber(@(count));
    self.title = count ? [NSString stringWithFormat:@"微信(%@)", @(count)] : @"微信";
}

#pragma mark - Getter
- (NSMutableArray <WXSession *>*)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _dataArray;
}

#pragma mark - controller config
- (BOOL)isRootViewController {
    return YES;
}

- (NSString *)tabBarItemTitle {
    return @"消息";
}

- (UIImage *)tabBarItemImage {
    return UIImageNamed(@"wx_tabbar_home");
}

- (UIImage *)tabBarItemSelectedImage {
    return UIImageNamed(@"wx_tabbar_homeHL");
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
