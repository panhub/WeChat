//
//  WXContactsViewController.m
//  WeChat
//
//  Created by Vincent on 2019/2/24.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "WXContactsViewController.h"
#import "WXContactsPageCell.h"
#import "WXContactsCell.h"
#import "WXUserViewController.h"
#import "WXContactsSectionHeaderView.h"
#import "WXEditUserInfoViewController.h"
#import "WXAddUserViewController.h"
#import "WXContactsResultController.h"

@interface WXContactsViewController () <MNPageControlDataSource, MNPageControlDelegate, UITextFieldDelegate, MNTableViewCellDelegate>
{
    CGFloat _lastOffsetY;
    CGFloat _currentOffsetY;
    MNMenuView *_menuView;
}
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) MNPageControl *pageControl;
@property (nonatomic, strong) NSDictionary <MNContactLocalizedKey, id>*defaultItems;
@property (nonatomic, strong) NSMutableArray <NSDictionary <MNContactLocalizedKey, id>*>*dataArray;
@end

@implementation WXContactsViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"通讯录";
        _lastOffsetY = _currentOffsetY = 0.f;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.view.backgroundColor = VIEW_COLOR;
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.rowHeight = 55.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = MN_RGB(232.f);
    
    [self.searchBar setTitleColor:TEXT_COLOR forState:UIControlStateNormal];
    [self.searchBar setTitleColor:TEXT_COLOR forState:UIControlStateHighlighted];
    self.searchBar.frame = CGRectMake(0.f, 5.f, self.tableView.width_mn, MN_NAV_BAR_HEIGHT);
    @weakify(self);
    self.searchBar.textFieldConfigurationHandler = ^(MNSearchBar *searchBar, MNTextField *textField) {
        @strongify(self);
        textField.delegate = self;
        textField.tintColor = THEME_COLOR;
        textField.frame = CGRectMake(10.f, (searchBar.height_mn - 35.f)/2.f, searchBar.width_mn - 20.f, 35.f);
    };
    MNAdsorbView *headerView = [[MNAdsorbView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, self.searchBar.height_mn + 10.f)];
    headerView.imageView.backgroundColor = VIEW_COLOR;
    [headerView.contentView addSubview:self.searchBar];
    self.tableView.tableHeaderView = headerView;

    UILabel *footerLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 50.f)
                                              text:@"0位联系人"
                                     alignment:NSTextAlignmentCenter
                                         textColor:UIColorWithAlpha([UIColor darkTextColor], .7f)
                                              font:UIFontRegular(16.f)];
    UIImageView *shadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moment_more_line"]];
    shadowView.frame = CGRectMake(0.f, 0.f, footerLabel.width_mn, .5f);
    [footerLabel addSubview:shadowView];
    self.tableView.tableFooterView = footerLabel;
    self.footerLabel = footerLabel;
    
    MNPageControl *pageControl = [MNPageControl pageControlWithFrame:CGRectMake(self.contentView.width_mn - 20.f, 0.f, 20.f, self.contentView.height_mn) handler:nil];
    pageControl.dataSource = self;
    pageControl.delegate = self;
    pageControl.direction = MNPageControlDirectionVertical;
    pageControl.pageInterval = 2.f;
    pageControl.pageSize = CGSizeMake(14.f, 14.f);
    pageControl.pageIndicatorTintColor = UIColor.clearColor;
    pageControl.currentPageIndicatorTintColor = THEME_COLOR;
    [self.contentView addSubview:pageControl];
    self.pageControl = pageControl;
}

- (void)loadData {
    // 添加默认列表
    [self.dataArray addObject:self.defaultItems];
    // 加载系统通讯录
    NSArray <WXUser *>*contacts = [[[WechatHelper helper] contacts] copy];
    [self.dataArray addObjectsFromArray:[MNAddressBook localizedIndexedContacts:contacts sortKey:@"name"]];
    @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
}

- (void)handEvents {
    /// 联系人数据重载通知
    @weakify(self);
    [self handNotification:WXContactsDataReloadNotificationName eventHandler:^(NSNotification *_Nonnull notify) {
        @strongify(self);
        NSArray<WXUser *> *contacts = notify.object;
        if (self.dataArray.count > 0) [self.dataArray removeObjectsInRange:NSMakeRange(1, self.dataArray.count - 1)];
        [self.dataArray addObjectsFromArray:[MNAddressBook localizedIndexedContacts:[contacts copy] sortKey:@"name"]];
        @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
    }];
    /// 联系人信息更新通知
    [self handNotification:WXUserUpdateNotificationName eventHandler:^(id sender) {
        @strongify(self);
        @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 检索结果展示
    WXContactsResultController *searchResultController = [[WXContactsResultController alloc] initWithFrame:CGRectMake(0.f, self.navigationBar.height_mn + self.tableView.tableHeaderView.height_mn, self.view.width_mn, self.view.height_mn - MN_STATUS_BAR_HEIGHT - self.searchBar.height_mn)];
    searchResultController.multipleSelectEnabled = NO;
    searchResultController.dataSource = WechatHelper.helper.contacts;
    self.updater = searchResultController;
    self.searchResultController = searchResultController;
    
    // 搜索结果点击回调
    @weakify(self);
    searchResultController.selectedHandler = ^(WXUser *user) {
        @strongify(self);
        if (!user) return;
        [self.searchBar resignFirstResponder];
        WXUserViewController *vc = [[WXUserViewController alloc] initWithUser:user];
        [self.navigationController pushViewController:vc animated:YES];
    };
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = self.dataArray[section];
    return [dic[MNContactLocalizedDataKey] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? .01f : 30.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WXContactsSectionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.contact.header"];
    if (!header) {
        header = [[WXContactsSectionHeaderView alloc] initWithReuseIdentifier:@"com.wx.contact.header"];
    }
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(WXContactsSectionHeaderView *)view forSection:(NSInteger)section {
    view.titleLabel.text = self.dataArray[section][MNContactLocalizedIndexedKey];
    if (self.pageControl.isSelected) return;
    if (_currentOffsetY < _lastOffsetY) self.pageControl.currentPageIndex = section;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (self.pageControl.isSelected) return;
    if (_currentOffsetY > _lastOffsetY) self.pageControl.currentPageIndex = section + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.contact.cell"];
    if (!cell) {
        cell = [[WXContactsCell alloc] initWithReuseIdentifier:@"com.wx.contact.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
        cell.editDelegate = self;
        cell.allowsEditing = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXContactsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataArray.count) return;
    NSDictionary *result = self.dataArray[indexPath.section];
    NSArray <WXUser *>*section = result[MNContactLocalizedDataKey];
    if (indexPath.row >= section.count) return;
    cell.user = section[indexPath.row];
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
    if (indexPath.section >= self.dataArray.count) return;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self navigationBarRightBarItemTouchUpInside:self.navigationBar.rightBarItem];
        } else if (indexPath.row == 2) {
            UIViewControllerPush(@"WXLabelViewController", YES);
        }
        return;
    }
    MNTableViewCell *cell = (MNTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.isEdit) {
        [cell endEditingUsingAnimation];
        return;
    }
    NSDictionary *dic = self.dataArray[indexPath.section];
    NSArray *listArray = dic[MNContactLocalizedDataKey];
    if (indexPath.row >= listArray.count) return;
    WXUser *user = listArray[indexPath.row];
    WXUserViewController *vc = [[WXUserViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MNTableViewCellDelegate
- (BOOL)tableViewCell:(MNTableViewCell *)cell canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section != 0;
}

- (NSArray<MNTableViewCellEditAction *> *)tableViewCell:(MNTableViewCell *)cell editingActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNTableViewCellEditAction *action = [MNTableViewCellEditAction new];
    action.title = @"备注";
    return @[action];
}

- (UIView *)tableViewCell:(MNTableViewCell *)cell commitEditingAction:(MNTableViewCellEditAction *)action forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= self.dataArray.count) return nil;
    NSDictionary *dic = self.dataArray[indexPath.section];
    NSArray *listArray = dic[MNContactLocalizedDataKey];
    if (indexPath.row >= listArray.count) return nil;
    WXUser *user = listArray[indexPath.row];
    WXEditUserInfoViewController *vc = [[WXEditUserInfoViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:vc animated:YES];
    return nil;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navigationBar.shadowView.hidden = offsetY <= 0.f;
    _lastOffsetY = _currentOffsetY;
    _currentOffsetY = offsetY;
}

#pragma mark - MNPageControlDataSource
- (NSUInteger)numberOfPagesInPageControl:(MNPageControl *)pageControl {
    return self.dataArray.count;
}

- (UIView *)pageControl:(MNPageControl *)pageControl cellForPageOfIndex:(NSUInteger)index {
    return WXContactsPageCell.new;
}

#pragma mark - MNPageControlDelegate
- (void)pageControl:(MNPageControl *)pageControl didEndLayoutCell:(UIView *)cell forPageOfIndex:(NSUInteger)index {
    WXContactsPageCell *pageCell = (WXContactsPageCell *)cell;
    pageCell.imageView.hidden = index != 0;
    pageCell.textLabel.text = self.dataArray[index][MNContactLocalizedIndexedKey];
}

- (void)pageControl:(MNPageControl *)pageControl shouldUpdateCell:(WXContactsPageCell *)cell forPageOfIndex:(NSUInteger)index {
    cell.highlighted = index == pageControl.currentPageIndex;
}

- (void)pageControl:(MNPageControl *)pageControl didSelectPageOfIndex:(NSUInteger)index {
    if (index == 0) {
        [self scrollToTopWithAnimated:NO];
    } else {
        [self.tableView scrollToRow:0 inSection:index atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return self.dataArray.count > 1;
}

#pragma mark - MNNavigationBarDelegate
- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 25.f, 25.f)
                                              image:[UIImage imageNamed:@"wx_contacts_add"]
                                              title:nil
                                         titleColor:nil
                                               titleFont:nil];
    rightItem.touchInset = UIEdgeInsetWith(-5.f);
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

#pragma mark - 添加用户
- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    if ([[[WechatHelper helper] contacts] count] >= 300) {
        [self.view showInfoDialog:@"已达到最大联系人数量"];
        return;
    }
    @weakify(self);
    [[MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) return;
        if (buttonIndex == 0) {
            /// 自动添加
            [[MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *sheet, NSInteger index) {
                if (index == sheet.cancelButtonIndex) return;
                @strongify(self);
                [self.view showLoadDialog:@"用户生成中"];
                NSString *count = [sheet buttonTitleOfIndex:index];
                count = [count stringByReplacingOccurrencesOfString:@"个联系人" withString:@""];
                if (count.length <= 0) return;
                [[WechatHelper helper] createContacts:[count unsignedIntegerValue] completion:^(BOOL result) {
                    if (result) {
                        [self.view closeDialog];
                    } else {
                        [self.view showInfoDialog:@"添加用户失败"];
                    }
                }];
            } otherButtonTitles:@"1个联系人", @"10个联系人", @"30个联系人", @"50个联系人", nil] show];
        } else {
            /// 手动添加
            [self.navigationController pushViewController:[WXAddUserViewController new] animated:YES];
        }
    } otherButtonTitles:@"自动添加", @"手动添加", nil] show];
}

#pragma mark - 刷新表
- (void)reloadList {
    [super reloadList];
    [self.pageControl reloadData];
    self.footerLabel.text = NSStringWithFormat(@"%@位联系人", @([[[WechatHelper helper] contacts] count]));
}

#pragma mark - Getter
- (NSMutableArray <NSDictionary <MNContactLocalizedKey, id>*>*)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _dataArray;
}

- (NSDictionary <MNContactLocalizedKey, id>*)defaultItems {
    if (!_defaultItems) {
        NSMutableDictionary *defaultItems = [NSMutableDictionary dictionaryWithCapacity:2];
        defaultItems[MNContactLocalizedIndexedKey] = @"";
        defaultItems[MNContactLocalizedDataKey] = [NSMutableArray arrayWithCapacity:4];
        NSArray *imgArray = @[@"wx_contacts_friend", @"wx_contacts_group", @"wx_contacts_tag", @"wx_contacts_offical"];
        NSArray *titleArray = @[@"新的朋友", @"群组", @"标签", @"公众号"];
        [imgArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WXUser *user = [WXUser new];
            user.notename = titleArray[idx];
            user.nickname = titleArray[idx];
            [user setValue:[UIImage imageNamed:obj] forKey:@"avatar"];
            [defaultItems[MNContactLocalizedDataKey] addObject:user];
        }];
        _defaultItems = defaultItems.copy;
    }
    return _defaultItems;
}

#pragma mark - Super
- (BOOL)isRootViewController {
    return YES;
}

- (NSString *)tabBarItemTitle {
    return @"通讯录";
}

- (UIImage *)tabBarItemImage {
    return [UIImage imageNamed:@"tabbar_contacts"];
}

- (UIImage *)tabBarItemSelectedImage {
    return [UIImage imageNamed:@"tabbar_contactsHL"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
