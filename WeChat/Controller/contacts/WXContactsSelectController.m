//
//  WXContactsSelectController.m
//  MNChat
//
//  Created by Vincent on 2020/1/21.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXContactsSelectController.h"
#import "WXContactsResultController.h"
#import "WXUser.h"
#import "WXSession.h"
#import "WXContactsCell.h"
#import "WXContactsPageCell.h"
#import "WXContactsSectionHeaderView.h"

@interface WXContactsSelectController ()<UITextFieldDelegate, MNPageControlDataSource, MNPageControlDelegate>
{
    BOOL _isExistsRecently;
    CGFloat _lastOffsetY;
    CGFloat _currentOffsetY;
}
@property (nonatomic, strong) MNPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray <NSDictionary <MNContactLocalizedKey, id>*>*dataArray;
@end

@implementation WXContactsSelectController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"选择联系人";
        _lastOffsetY = _currentOffsetY = 0.f;
        self.selectedArray = @[].mutableCopy;
    }
    return self;
}

- (instancetype)initWithSelectedHandler:(void(^)(UIViewController *, NSArray <WXUser *>*))selectedHandler {
    if (self = [self init]) {
        self.selectedHandler = selectedHandler;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.view.backgroundColor = VIEW_COLOR;

    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowColor = SEPARATOR_COLOR;
    self.navigationBar.shadowView.hidden = YES;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.rowHeight = 55.f;
    
    MNAdsorbView *headerView = [[MNAdsorbView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 0.f)];
    headerView.imageView.backgroundColor = VIEW_COLOR;
    if (!self.isMultipleSelectEnabled) {
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
        headerView.height_mn = self.searchBar.height_mn + 10.f;
        [headerView.contentView addSubview:self.searchBar];
    }
    self.tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, .5f)];
    footerView.backgroundColor = SEPARATOR_COLOR;
    self.tableView.tableFooterView = footerView;
    
    MNPageControl *pageControl = [MNPageControl pageControlWithFrame:CGRectMake(self.contentView.width_mn - 20.f, 0.f, 20.f, self.contentView.height_mn) handler:nil];
    pageControl.dataSource = self;
    pageControl.delegate = self;
    pageControl.direction = MNPageControlDirectionVertical;
    pageControl.pageInterval = 2.f;
    pageControl.pageTouchInset = UIEdgeInsetsZero;
    pageControl.pageSize = CGSizeMake(14.f, 14.f);
    pageControl.pageIndicatorTintColor = UIColor.clearColor;
    pageControl.currentPageIndicatorTintColor = THEME_COLOR;
    [self.contentView addSubview:pageControl];
    self.pageControl = pageControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 检索结果展示
    WXContactsResultController *searchResultController = [[WXContactsResultController alloc] initWithFrame:CGRectMake(0.f, self.navigationBar.height_mn + self.tableView.tableHeaderView.height_mn, self.view.width_mn, self.view.height_mn - MN_STATUS_BAR_HEIGHT - self.searchBar.height_mn)];
    self.updater = searchResultController;
    self.searchResultController = searchResultController;
    
    // 搜索结果点击回调
    @weakify(self);
    searchResultController.selectedHandler = ^(WXUser *user) {
        @strongify(self);
        if (!user) return;
        [self.searchBar resignFirstResponder];
        if (self.selectedHandler) self.selectedHandler(self, @[user]);
    };
    // 联系人信息更新
    [self handNotification:WXUserUpdateNotificationName eventHandler:^(NSNotification *notify) {
        @strongify(self);
        if (![notify.object isKindOfClass:WXUser.class]) return;
        WXUser *user = notify.object;
        __block NSIndexPath *indexPath;
        [self.dataArray enumerateObjectsUsingBlock:^(NSDictionary<MNContactLocalizedKey,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray <WXUser *>*users = obj[MNContactLocalizedDataKey];
            [users enumerateObjectsUsingBlock:^(WXUser * _Nonnull u, NSUInteger i, BOOL * _Nonnull s) {
                if (u == user) {
                    indexPath = [NSIndexPath indexPathForRow:i inSection:idx];
                    *stop = YES;
                }
            }];
        }];
        if (indexPath) [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
    }];
    // 删除联系人
    [self handNotification:WXUserDeleteNotificationName eventHandler:^(NSNotification *notify) {
        @strongify(self);
        if (![notify.object isKindOfClass:WXUser.class]) return;
        WXUser *user = notify.object;
        __block NSIndexPath *indexPath;
        [self.dataArray enumerateObjectsUsingBlock:^(NSDictionary<MNContactLocalizedKey,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray <WXUser *>*users = obj[MNContactLocalizedDataKey];
            [users enumerateObjectsUsingBlock:^(WXUser * _Nonnull u, NSUInteger i, BOOL * _Nonnull s) {
                if (u == user) {
                    indexPath = [NSIndexPath indexPathForRow:i inSection:idx];
                    *stop = YES;
                }
            }];
        }];
        if (!indexPath) return;
        NSDictionary<MNContactLocalizedKey,id>*dic = self.dataArray[indexPath.section];
        NSArray <WXUser *>*array = dic[MNContactLocalizedDataKey];
        if (array.count <= 1) {
            [self.dataArray removeObjectAtIndex:indexPath.section];
            if (indexPath.section == 0) self -> _isExistsRecently = NO;
        } else {
            NSMutableDictionary *dictionary = dic.mutableCopy;
            NSMutableArray *users = array.mutableCopy;
            [users removeObjectAtIndex:indexPath.row];
            dictionary[MNContactLocalizedDataKey] = users.copy;
            [self.dataArray replaceObjectAtIndex:indexPath.section withObject:dictionary.copy];
        }
        [self reloadList];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}

- (void)loadData {
    [self.view showWechatDialog];
    dispatch_async_default(^{
        NSArray <WXUser *>*contacts = [[[WechatHelper helper] contacts] copy];
        NSArray <WXSession *>*sessions = [[[WechatHelper helper] sessions] copy];
        NSMutableArray <WXUser *>*recentlyArray = @[].mutableCopy;
        NSMutableArray <WXUser *>*contactsArray = @[].mutableCopy;
        NSMutableArray <NSDictionary <MNContactLocalizedKey, id>*>*dataArray = @[].mutableCopy;
        [contacts enumerateObjectsUsingBlock:^(WXUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self.expelUsers containsObject:obj]) return;
            [sessions enumerateObjectsUsingBlock:^(WXSession * _Nonnull session, NSUInteger i, BOOL * _Nonnull s) {
                if ([session.uid isEqualToString:obj.uid]) {
                    [recentlyArray addObject:obj];
                    *s = YES;
                }
            }];
            if (![recentlyArray containsObject:obj]) [contactsArray addObject:obj];
        }];
        if (recentlyArray.count) {
            _isExistsRecently = YES;
            NSMutableDictionary *recentlyItems = [NSMutableDictionary dictionaryWithCapacity:2];
            recentlyItems[MNContactLocalizedIndexedKey] = @"最近聊天";
            recentlyItems[MNContactLocalizedDataKey] = recentlyArray.copy;
            [dataArray addObject:recentlyItems];
        }
        if (contactsArray.count) {
            [dataArray addObjectsFromArray:[MNAddressBook localizedIndexedContacts:contactsArray sortKey:@"name"]];
        }
        dispatch_async_main(^{
            self.dataArray = dataArray;
            [self reloadList];
            [self.view closeDialog];
        });
    });
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
    return 30.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WXContactsSectionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.contact.select.header"];
    if (!header) {
        header = [[WXContactsSectionHeaderView alloc] initWithReuseIdentifier:@"com.wx.contact.select.header"];
    }
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(WXContactsSectionHeaderView *)view forSection:(NSInteger)section {
    view.titleLabel.text = self.dataArray[section][MNContactLocalizedIndexedKey];
    if (self.pageControl.isSelected) return;
    if (_currentOffsetY < _lastOffsetY) self.pageControl.currentPageIndex = section + (_isExistsRecently ? 0 : 1);
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (self.pageControl.isSelected) return;
    if (_currentOffsetY > _lastOffsetY) {
        section += (_isExistsRecently ? 1 : 2);
        self.pageControl.currentPageIndex = section;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.contact.select.cell"];
    if (!cell) {
        cell = [[WXContactsCell alloc] initWithReuseIdentifier:@"com.wx.contact.select.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
        cell.multipleSelectEnabled = self.isMultipleSelectEnabled;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXContactsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataArray.count) return;
    NSDictionary *dic = self.dataArray[indexPath.section];
    NSArray *array = dic[MNContactLocalizedDataKey];
    if (indexPath.row >= array.count) return;
    cell.user = array[indexPath.row];
    if (self.isMultipleSelectEnabled) cell.selected = [self.selectedArray containsObject:cell.user];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataArray.count) {
        [self.view showInfoDialog:@"数据错误"];
        return;
    }
    NSDictionary *dic = self.dataArray[indexPath.section];
    NSArray <WXUser *>*users = dic[MNContactLocalizedDataKey];
    if (indexPath.row >= users.count) {
        [self.view showInfoDialog:@"数据错误"];
        return;
    }
    if (self.isMultipleSelectEnabled) {
        WXUser *user = users[indexPath.row];
        if ([self.selectedArray containsObject:user]) {
            [self.selectedArray removeObject:user];
        } else {
            [self.selectedArray addObject:user];
        }
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        if (self.selectedHandler) self.selectedHandler(self, @[users[indexPath.row]]);
    }
}

#pragma mark - MNPageControlDataSource
- (NSUInteger)numberOfPagesInPageControl:(MNPageControl *)pageControl {
    return self.dataArray.count + (_isExistsRecently ? 0 : 1);
}

- (UIView *)pageControl:(MNPageControl *)pageControl cellForPageOfIndex:(NSUInteger)index {
    WXContactsPageCell *cell = [WXContactsPageCell new];
    cell.index = index;
    return cell;
}

#pragma mark - MNPageControlDelegate
- (void)pageControl:(MNPageControl *)pageControl didEndLayoutCell:(UIView *)cell forPageOfIndex:(NSUInteger)index {
    WXContactsPageCell *pageCell = (WXContactsPageCell *)cell;
    pageCell.imageView.hidden = index != 0;
    pageCell.textLabel.text = index == 0 ? @"" : self.dataArray[(index - (_isExistsRecently ? 0 : 1))][MNContactLocalizedIndexedKey];
}

- (void)pageControl:(MNPageControl *)pageControl didSelectPageOfIndex:(NSUInteger)index {
    if (index == 0) {
        [self scrollToTopWithAnimated:NO];
    } else {
        [self.tableView scrollToRow:0 inSection:(index - (_isExistsRecently ? 0 : 1)) atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navigationBar.shadowView.hidden = offsetY <= 0.f;
    _lastOffsetY = _currentOffsetY;
    _currentOffsetY = offsetY;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return self.dataArray.count > 0;
}

#pragma mark - Getter
- (NSMutableArray <WXUser *>*)selectedArray {
    if (!_selectedArray) {
        NSMutableArray <WXUser *>*selectedArray = @[].mutableCopy;
        _selectedArray = selectedArray;
    }
    return _selectedArray;
}

#pragma mark - Overwrite
- (void)reloadList {
    [super reloadList];
    [self.pageControl reloadData];
}

- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    if (!self.isMultipleSelectEnabled) return nil;
    UIButton *leftBarItem = [UIButton buttonWithFrame:CGRectZero
                                                 image:nil
                                                 title:@"关闭"
                                            titleColor:UIColorWithAlpha(UIColor.darkTextColor, .9f)
                                             titleFont:UIFontRegular(16.f)];
    leftBarItem.size_mn = CGSizeMake(48.f, 35.f);
    [leftBarItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftBarItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    if (self.isMultipleSelectEnabled) {
        UIButton *rightBarItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 50.f, 31.f)
                                                     image:nil
                                                     title:@"确定"
                                                titleColor:UIColor.whiteColor
                                                 titleFont:UIFontRegular(16.f)];
        rightBarItem.backgroundColor = THEME_COLOR;
        UIViewSetCornerRadius(rightBarItem, 3.f);
        [rightBarItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        return rightBarItem;
    } else {
        UIButton *rightBarItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 48.f, 35.f)
                                                     image:nil
                                                     title:@"关闭"
                                                titleColor:UIColorWithAlpha(UIColor.darkTextColor, .9f)
                                                 titleFont:UIFontRegular(16.f)];
        [rightBarItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        return rightBarItem;
    }
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    if (!self.allowsUnselected && self.selectedArray.count <= 0) {
        [self.view showInfoDialog:@"未选择联系人"];
        return;
    }
    if (self.selectedHandler) self.selectedHandler(self, self.selectedArray.copy);
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStylePlain;
}

@end
