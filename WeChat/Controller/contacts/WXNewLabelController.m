//
//  WXNewLabelController.m
//  WeChat
//
//  Created by Vicent on 2021/3/29.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXNewLabelController.h"
#import "WXEditingViewController.h"
#import "WXNewLabelHeader.h"
#import "WXContactsSelectController.h"
#import "WXContactsPageCell.h"
#import "WXContactsSectionHeaderView.h"
#import "WXContactsCell.h"
#import "WXLabel.h"

@interface WXNewLabelController ()<WXNewLabelHeaderDelegate, MNPageControlDelegate, MNPageControlDataSource>
{
    CGFloat _lastOffsetY;
    CGFloat _currentOffsetY;
}
@property (nonatomic, copy) WXLabel *label;
@property (nonatomic, strong) MNPageControl *pageControl;
@property (nonatomic, strong) NSArray <NSDictionary <MNContactLocalizedKey, id>*>*dataSource;
@end

@implementation WXNewLabelController
- (instancetype)init {
    return [self initWithLabel:nil];
}

- (instancetype)initWithLabel:(WXLabel *)label {
    if (self = [super init]) {
        self.label = label;
        self.title = label ? @"设置标签" : @"新建标签";
        self.dataSource = [MNAddressBook localizedIndexedContacts:label.users sortKey:sql_field(label.name)] ? : @[];
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowView.hidden = YES;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 50.f;
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, MN_TAB_SAFE_HEIGHT)];
    
    WXNewLabelHeader *tableHeaderView = [[WXNewLabelHeader alloc] initWithFrame:self.tableView.bounds];
    tableHeaderView.imageView.backgroundColor = VIEW_COLOR;
    tableHeaderView.number = self.label ? self.label.users.count : 0;
    tableHeaderView.name = self.label ? self.label.name : @"";
    tableHeaderView.delegate = self;
    self.tableView.tableHeaderView = tableHeaderView;
    
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
    
    ((UIButton *)self.navigationBar.rightBarItem).enabled = tableHeaderView.name.length > 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = self.dataSource[section];
    return [dic[MNContactLocalizedDataKey] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WXContactsSectionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.new.label.header"];
    if (!header) {
        header = [[WXContactsSectionHeaderView alloc] initWithReuseIdentifier:@"com.wx.new.label.header"];
    }
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(WXContactsSectionHeaderView *)view forSection:(NSInteger)section {
    view.titleLabel.text = self.dataSource[section][MNContactLocalizedIndexedKey];
    if (self.pageControl.isSelected) return;
    if (_currentOffsetY < _lastOffsetY) self.pageControl.currentPageIndex = section;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (self.pageControl.isSelected) return;
    if (_currentOffsetY > _lastOffsetY) self.pageControl.currentPageIndex = section;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.new.label.cell"];
    if (!cell) {
        cell = [[WXContactsCell alloc] initWithReuseIdentifier:@"com.wx.new.label.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXContactsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataSource.count) return;
    NSDictionary *dic = self.dataSource[indexPath.section];
    NSArray *array = dic[MNContactLocalizedDataKey];
    if (indexPath.row >= array.count) return;
    cell.user = array[indexPath.row];
    if (indexPath.row == 0) {
        cell.topSeparatorInset = UIEdgeInsetsZero;
    } else {
        cell.topSeparatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.contentView.width_mn);
    }
    if (indexPath.row == array.count - 1) {
        cell.bottomSeparatorInset = UIEdgeInsetsZero;
    } else {
        cell.bottomSeparatorInset = UIEdgeInsetsMake(0.f, cell.titleLabel.left_mn, 0.f, 0.f);
    }
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
    return self.dataSource.count;
}

- (UIView *)pageControl:(MNPageControl *)pageControl cellForPageOfIndex:(NSUInteger)index {
    WXContactsPageCell *cell = [WXContactsPageCell new];
    cell.imageView.hidden = YES;
    return cell;
}

#pragma mark - MNPageControlDelegate
- (void)pageControl:(MNPageControl *)pageControl didEndLayoutCell:(UIView *)cell forPageOfIndex:(NSUInteger)index {
    WXContactsPageCell *pageCell = (WXContactsPageCell *)cell;
    pageCell.textLabel.text = self.dataSource[index][MNContactLocalizedIndexedKey];
}

- (void)pageControl:(MNPageControl *)pageControl shouldUpdateCell:(WXContactsPageCell *)cell forPageOfIndex:(NSUInteger)index {
    cell.highlighted = index == pageControl.currentPageIndex;
}

- (void)pageControl:(MNPageControl *)pageControl didSelectPageOfIndex:(NSUInteger)index {
    [self.tableView scrollToRow:0 inSection:index atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark - WXNewLabelHeaderDelegate
- (void)newLabelHeaderNameButtonTouchUpInside:(WXNewLabelHeader *)newLabelHeader {
    /// 消息未读数
    WXEditingViewController *vc = [WXEditingViewController new];
    vc.title = @"设置标签名字";
    vc.numberOfLines = 1;
    vc.keyboardType = UIKeyboardTypeDefault;
    vc.placeholder = @"例如家人、朋友";
    vc.text = newLabelHeader.name;
    vc.numberOfWords = 10;
    vc.minOfWordInput = 1;
    vc.shieldCharacters = @[@" "];
    vc.completionHandler = ^(NSString *result, WXEditingViewController *v) {
        newLabelHeader.name = result;
        ((UIButton *)self.navigationBar.rightBarItem).enabled = result.length > 0;
        [v.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)newLabelHeaderAddUserButtonTouchUpInside:(WXNewLabelHeader *)newLabelHeader {
    @weakify(self);
    WXContactsSelectController *viewController = [[WXContactsSelectController alloc] initWithSelectedHandler:^(WXContactsSelectController *vc) {
        NSArray <WXUser *>*users = vc.users;
        [vc.navigationController popViewControllerAnimated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.contentView showWechatDialog];
            @weakify(self);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSArray <NSDictionary <MNContactLocalizedKey, id>*>*dataSource = [MNAddressBook localizedIndexedContacts:users sortKey:@"name"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [self.label.users removeAllObjects];
                    [self.label.users addObjectsFromArray:users];
                    ((WXNewLabelHeader *)self.tableView.tableHeaderView).number = users.count;
                    self.dataSource = dataSource;
                    [self reloadList];
                    [self.pageControl reloadData];
                    [self.contentView closeDialog];
                });
            });
        });
    }];
    viewController.users = self.label.users.copy;
    viewController.expelUsers = @[WXUser.shareInfo];
    viewController.allowsUnselected = YES;
    viewController.multipleSelectEnabled = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIButton *leftItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 40.f, kNavItemSize)
                                             image:nil
                                             title:@"取消"
                                        titleColor:[UIColor.darkTextColor colorWithAlphaComponent:.9f]
                                         titleFont:[UIFont systemFontOfSize:17.f]];
    [leftItem sizeToFit];
    leftItem.height_mn = 20.f;
    leftItem.touchInset = UIEdgeInsetWith(-5.f);
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightBarItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 53.f, 32.f)
                                              image:[UIImage imageWithColor:THEME_COLOR]
                                              title:@"完成"
                                         titleColor:UIColor.whiteColor
                                          titleFont:[UIFont systemFontOfSizes:17.f weights:.15f]];
    rightBarItem.enabled = NO;
    UIViewSetCornerRadius(rightBarItem, 3.f);
    [rightBarItem setTitleColor:MN_RGB(183.f) forState:UIControlStateDisabled];
    [rightBarItem setBackgroundImage:[UIImage imageWithColor:MN_RGB(225.f)] forState:UIControlStateDisabled];
    [rightBarItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightBarItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    @weakify(self);
    [self.view showWechatDialog];
    WXLabel *label = self.label;
    NSString *original = label.name;
    NSString *name = ((WXNewLabelHeader *)self.tableView.tableHeaderView).name;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // 修改用户标签
        label.name = name;
        label.identifier = name.md5String32;
        label.timestamp = NSDate.timestamps;
        // 可能携带了标签
        NSArray *result = [MNDatabase.database selectRowsModelFromTable:WXLabelTableName where:@{sql_field(label.identifier):sql_pair(label.identifier)}.sqlQueryValue limit:NSRangeZero class:WXLabel.class];
        if (result.count <= 0) {
            // 插入数据
            if (![MNDatabase.database insertToTable:WXLabelTableName model:label]) {
                label.name = original;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.view showWechatError:@"保存失败"];
                });
                return;
            }
        }
        // 删除原标签及相关用户
        NSMutableArray <WXUser *>*users = @[].mutableCopy;
        if (original && original.length) {
            [MNDatabase.database deleteRowFromTable:WXLabelTableName where:@{sql_field(label.identifier):sql_pair(original.md5String32)}.sqlQueryValue];
            [WechatHelper.helper.contacts.copy enumerateObjectsUsingBlock:^(WXUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.label isEqualToString:original]) {
                    [users addObject:obj];
                }
            }];
            if (users.count) {
                [users setValue:nil forKey:@"label"];
                NSMutableString *sql = [NSString stringWithFormat:@"UPDATE %@ SET label = '' WHERE uid in ", sql_pair(WXContactsTableName)].mutableCopy;
                [users enumerateObjectsUsingBlock:^(WXUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [sql appendString:idx == 0 ? @"(" : @","];
                    [sql appendString:sql_pair(obj.uid)];
                }];
                [sql appendString:@");"];
                [MNDatabase.database execute:sql];
            }
        }
        // 更新数据 从通讯录获取
        [users removeAllObjects];
        [label.users enumerateObjectsUsingBlock:^(WXUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray <WXUser *>*result = [WechatHelper.helper.contacts.copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.uid == %@", obj.uid]];
            [users addObjectsFromArray:result];
        }];
        if (users.count) {
            NSMutableString *sql = [NSString stringWithFormat:@"UPDATE %@ SET label = '%@' WHERE uid in ", sql_pair(WXContactsTableName), name].mutableCopy;
            [users enumerateObjectsUsingBlock:^(WXUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [sql appendString:idx == 0 ? @"(" : @","];
                [sql appendString:sql_pair(obj.uid)];
            }];
            [sql appendString:@");"];
            if ([MNDatabase.database execute:sql]) {
                [users setValue:name forKey:@"label"];
            }
        }
        // 关闭
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.view closeDialogWithCompletionHandler:^{
                @PostNotify(WXLabelUpdateNotificationName, nil);
                [weakself.navigationController popViewControllerAnimated:YES];
            }];
        });
    });
}

#pragma mark - Getter
- (WXLabel *)label {
    if (!_label) {
        _label = WXLabel.new;
    }
    return _label;
}

#pragma mark - Super
- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

@end
