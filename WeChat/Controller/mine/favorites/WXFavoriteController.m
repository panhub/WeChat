//
//  WXFavoriteController.m
//  WeChat
//
//  Created by Vincent on 2019/4/29.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXFavoriteController.h"
#import "WXEditingViewController.h"
#import "WXMapViewController.h"
#import "WXCollectViewModel.h"
#import "MNRefreshFooter.h"
#import "WXLocation.h"
#import "WXFavoriteCell.h"

#define WXFavoriteEditSelector  @selector(menuEdit:)
#define WXFavoriteDeleteSelector  @selector(menuDelete:)
#define WXFavoriteSelectSelector  @selector(menuSelect:)

@interface WXFavoriteController () <MNSearchControllerDelegate, UIScrollViewDelegate, MNTableViewCellDelegate, UITextFieldDelegate>
@property (nonatomic, strong) WXCollectViewModel *viewModel;
@end

@implementation WXFavoriteController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"收藏";
        self.delegate = self;
        self.loadMoreEnabled = YES;
        self.viewModel = WXCollectViewModel.new;
        [self handEvents];
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.view.backgroundColor = VIEW_COLOR;
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowView.hidden = YES;

    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, MN_TAB_SAFE_HEIGHT)];
    
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

- (void)handEvents {

    @weakify(self);
    
    /// 刷新表
    self.viewModel.reloadTableHandler = ^{
        [UIView performWithoutAnimation:^{
            @strongify(self);
            [self reloadList];
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
    
    /// 图片点击
    self.viewModel.imageViewClickedHandler = ^(WXFavoriteViewModel * _Nonnull viewModel) {
        //@strongify(self);
        WXFavorite *favorite = viewModel.favorite;
        if (favorite.type != WXFavoriteTypeImage && favorite.type != WXFavoriteTypeVideo) return;
        MNAsset *asset = [[MNAsset alloc] init];
        asset.content = favorite.type == WXFavoriteTypeImage ? favorite.image : favorite.filePath;
        asset.thumbnail = favorite.image;
        asset.type = favorite.type == WXFavoriteTypeImage ? MNAssetTypePhoto : MNAssetTypeVideo;
        asset.containerView = viewModel.imageViewModel.containerView;
        MNAssetBrowser *browser = [MNAssetBrowser new];
        browser.assets = @[asset];
        browser.allowsAutoPlaying = YES;
        browser.backgroundColor = UIColor.blackColor;
        [browser presentFromIndex:0 animated:YES];
    };
    
    // 背景长按事件
    self.viewModel.backgroundLongPressHandler = ^(WXFavoriteViewModel * _Nonnull viewModel) {
        @strongify(self);
        NSInteger index = [self.viewModel.dataSource indexOfObject:viewModel];
        CGRect frame = [viewModel.containerView.superview convertRect:viewModel.containerView.frame toView:self.view];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        if (menuController.isMenuVisible) [menuController setMenuVisible:NO animated:NO];
        NSMutableArray <UIMenuItem *>*menuItems = @[].mutableCopy;
        [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"编辑" action:WXFavoriteEditSelector]];
        [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"删除" action:WXFavoriteDeleteSelector]];
        if (self.selectedHandler) [menuItems addObject:[[UIMenuItem alloc] initWithTitle:@"选择" action:WXFavoriteSelectSelector]];
        menuController.menuItems = menuItems;
        menuController.arrowDirection = CGRectGetMinY(frame) < self.navigationBar.bottom_mn ? UIMenuControllerArrowUp : UIMenuControllerArrowDown;
        [menuController setTargetRect:frame inView:self.view];
        menuController.user_info = [NSIndexPath indexPathForRow:0 inSection:index];
        [menuController setMenuVisible:YES animated:YES];
    };
}

- (void)loadData {
    [self.viewModel loadData];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0.f : WXFavoriteSeparatorHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MNTableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.favorite.header"];
    if (!header) {
        header = [[MNTableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.favorite.header"];
        header.clipsToBounds = YES;
        header.contentView.backgroundColor = VIEW_COLOR;
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.viewModel.dataSource.count) return 0.f;
    WXFavoriteViewModel *viewModel = self.viewModel.dataSource[indexPath.section];
    return CGRectGetHeight(viewModel.frame);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.viewModel.dataSource.count) return nil;
    WXFavoriteViewModel *viewModel = self.viewModel.dataSource[indexPath.section];
    WXFavoriteCell *cell = [WXFavoriteCell dequeueReusableCellWithTableView:tableView model:viewModel delegate:self];
    cell.viewModel = viewModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.viewModel.dataSource.count) return;
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.isMenuVisible) [menuController setMenuVisible:NO animated:NO];
    
    WXFavoriteCell *cell = (WXFavoriteCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.isEdit) {
        [cell endEditingUsingAnimation];
        return;
    }
    
    WXFavoriteViewModel *viewModel = self.viewModel.dataSource[indexPath.section];
    WXFavorite *favorite = viewModel.favorite;
    
    if (self.selectedHandler) {
        self.selectedHandler(viewModel.favorite);
        return;
    }
    
    if (favorite.type == WXFavoriteTypeWeb) {
        MNWebViewController *vc = [[MNWebViewController alloc] initWithUrl:favorite.url];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (favorite.type == WXFavoriteTypeLocation) {
        WXLocation *location = [WXLocation locationWithCoordinate:favorite.url.coordinate2DValue];
        location.name = favorite.title;
        location.address = favorite.subtitle;
        WXMapViewController *vc = [[WXMapViewController alloc] initWithLocation:location];
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
    action0.image = UIImageNamed(@"favorite_edit");
    action0.inset = UIEdgeInsetsMake(0.f, 5.f, 0.f, 15.f);
    action0.backgroundColor = [UIColor clearColor];
    
    MNTableViewCellEditAction *action1 = [MNTableViewCellEditAction new];
    action1.width = 70.f;
    action1.image = UIImageNamed(@"favorite_delete");
    action1.inset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 15.f);
    action1.backgroundColor = [UIColor clearColor];
    
    return @[action0, action1];
}

- (UIView *)tableViewCell:(MNTableViewCell *)cell commitEditingAction:(MNTableViewCellEditAction *)action forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.viewModel.dataSource.count) return nil;
    if (action.index == 0) {
        /// 编辑标签
        [self __edit:indexPath];
        return nil;
    }
    __weak typeof(self) weakself = self;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.width_mn = cell.editingView.width_mn;
    button.backgroundColor = UIColor.clearColor;
    [button setImage:[UIImage imageNamed:@"favorite_confirm_delete"] forState:UIControlStateNormal];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button handTouchEventHandler:^(id  _Nonnull sender) {
        [weakself __delete:indexPath];
    }];
    return button;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navigationBar.shadowView.hidden = offsetY <= 0.f;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return self.viewModel.dataSource.count;
}

#pragma mark - MNNavigationBarDelegate
- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightBarItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 21.f, 21.f)
                                                 image:[UIImage imageNamed:@"session_nav_more"]
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

#pragma mark - UIMenuController
- (void)menuEdit:(UIMenuController *)controller {
    [self __edit:controller.user_info];
}

- (void)__edit:(NSIndexPath *)indexPath {
    WXFavoriteCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    WXFavoriteViewModel *viewModel = [self.viewModel.dataSource objectAtIndex:indexPath.section];
    WXEditingViewController *vc = [WXEditingViewController new];
    vc.title = @"编辑标签";
    vc.numberOfLines = 1;
    vc.numberOfWords = 10;
    vc.text = viewModel.favorite.label;
    vc.completionHandler = ^(NSString *result, WXEditingViewController *v) {
        [v.navigationController popViewControllerAnimated:YES];
        viewModel.favorite.label = result;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [MNDatabase updateTable:WXFavoriteTableName where:@{@"identifier":sql_pair(viewModel.favorite.identifier)}.sqlQueryValue model:viewModel.favorite completion:nil];
    };
    [self.navigationController pushViewController:vc animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [cell setEdit:NO animated:NO];
    });
}

- (void)menuSelect:(UIMenuController *)controller {
    [self __select:controller.user_info];
}

- (void)__select:(NSIndexPath *)indexPath {
    WXFavoriteViewModel *viewModel = [self.viewModel.dataSource objectAtIndex:indexPath.section];
    if (self.selectedHandler) self.selectedHandler(viewModel.favorite);
}

- (void)menuDelete:(UIMenuController *)controller {
    [self __delete:controller.user_info];
}

- (void)__delete:(NSIndexPath *)indexPath {
    WXFavoriteViewModel *viewModel = [self.viewModel.dataSource objectAtIndex:indexPath.section];
    [self.viewModel.dataSource removeObject:viewModel];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
    [MNDatabase deleteRowFromTable:WXFavoriteTableName where:@{@"identifier":sql_pair(viewModel.favorite.identifier)}.sqlQueryValue completion:nil];
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself reloadList];
    });
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == WXFavoriteEditSelector || action == WXFavoriteDeleteSelector || action == WXFavoriteSelectSelector) {
        return YES;
    }
    return NO;
}

#pragma mark - Super
- (void)reloadList {
    [super reloadList];
    self.tableView.backgroundColor = self.viewModel.dataSource.count <= 0 ? UIColor.whiteColor : VIEW_COLOR;
    [self showEmptyViewNeed:self.viewModel.dataSource.count <= 0 image:[UIImage imageNamed:@"common_empty"] message:nil title:nil type:MNEmptyEventTypeLoad];
}

- (void)beginLoadMore {
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself reloadData];
    });
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

- (UIView *)loadFooter {
    return [[MNRefreshFooter alloc] initWithType:MNRefreshFooterTypeMargin];
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    if (self.selectedHandler) return nil;
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    if (self.selectedHandler) return nil;
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
