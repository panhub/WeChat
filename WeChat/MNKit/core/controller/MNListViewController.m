//
//  MNTableViewController.m
//  MNKit
//
//  Created by Vincent on 2017/6/6.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "MNListViewController.h"
#import "MJRefreshNormalHeader.h"
#import "MJRefreshBackNormalFooter.h"

@interface MNListViewController ()
{
    @private
    BOOL _needReloadList;
}
@property (nonatomic, unsafe_unretained) UIScrollView *listView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;
@end
@implementation MNListViewController

- (void)initialized {
    [super initialized];
    _pullRefreshEnabled = NO;
    _loadMoreEnabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadListIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - 加载数据
- (void)loadData {
    if (!self.httpRequest || self.httpRequest.isLoading) return;
    __weak typeof(self) weakself = self;
    [self.httpRequest loadData:^{
        [weakself prepareLoadData:weakself.httpRequest];
    } completion:^(MNURLResponse *response) {
        [weakself reloadList];
        [weakself endRefreshing];
        [weakself.contentView closeDialog];
        [weakself loadDataFinishWithRequest:weakself.httpRequest];
    }];
}

#pragma mark - 结束刷新
- (void)endRefreshing {
    if (!_listView.mj_header && !_listView.mj_footer) return;
    if (_listView.mj_header.isRefreshing) {
        [self endPullRefresh];
    }
    if (!self.httpRequest) return;
    if (self.httpRequest.hasMore) {
        if (_listView.mj_footer && _listView.mj_footer.isRefreshing) {
            [self endLoadMore];
        } else {
            [self resetLoadMoreFooter];
        }
    } else {
        [self relieveLoadMoreFooter];
    }
}

#pragma mark - 下拉刷新
- (void)mj_pullRefresh {
    if ((self.httpRequest && self.httpRequest.isLoading) || (_listView.mj_footer && _listView.mj_footer.isRefreshing)) {
        [_listView.mj_header endRefreshing];
    } else {
        [self beginPullRefresh];
    }
}

- (void)beginPullRefresh {
    [self reloadData];
}

- (void)endPullRefresh {
    if (_listView.mj_header && _listView.mj_header.isRefreshing) {
        [_listView.mj_header endRefreshing];
    }
}

- (void)removeRefreshHeader {
    if (_listView.mj_header) {
        [self endPullRefresh];
        [_listView.mj_header removeFromSuperview];
        _listView.mj_header = nil;
    }
    self.pullRefreshEnabled = NO;
}

#pragma mark - 加载更多
- (void)mj_loadMore {
    if ((self.httpRequest && self.httpRequest.isLoading) || (_listView.mj_header && _listView.mj_header.isRefreshing)) {
        [_listView.mj_footer endRefreshing];
    } else {
        [self beginLoadMore];
    }
}

- (void)beginLoadMore {
    [self loadData];
}

- (void)endLoadMore {
    if (_listView.mj_footer && _listView.mj_footer.isRefreshing) {
        [_listView.mj_footer endRefreshing];
    }
}

- (void)removeLoadMoreFooter {
    if (_listView.mj_footer) {
        [self endLoadMore];
        [_listView.mj_footer removeFromSuperview];
        _listView.mj_footer = nil;
    }
    self.loadMoreEnabled = NO;
}

- (void)resetLoadMoreFooter {
    if (_listView.mj_footer && _listView.mj_footer.state == MJRefreshStateNoMoreData) {
        [_listView.mj_footer resetNoMoreData];
        [_listView.mj_footer setRefreshingTarget:self refreshingAction:@selector(mj_loadMore)];
    }
}

- (void)relieveLoadMoreFooter {
    if (_listView.mj_footer && _listView.mj_footer.state != MJRefreshStateNoMoreData) {
        [_listView.mj_footer endRefreshingWithNoMoreData];
    }
}

#pragma mark - 设置刷新控件
- (void)displayPullHeaderIfNeeded {
    if (!_pullRefreshEnabled || _listView.mj_header) return;
    MJRefreshHeader *header = [[NSClassFromString(self.refreshHeaderClass) alloc] init];
    [header setRefreshingTarget:self refreshingAction:@selector(mj_pullRefresh)];
    _listView.mj_header = header;
}

- (void)displayLoadFooterIfNeeded {
    if (!_loadMoreEnabled || _listView.mj_footer) return;
    MJRefreshFooter *footer = [[NSClassFromString(self.loadMoreFooterClass) alloc] init];
    [footer setRefreshingTarget:self refreshingAction:@selector(mj_loadMore)];
    footer.state = MJRefreshStateNoMoreData;
    _listView.mj_footer = footer;
}

#pragma mark - ScrollView
- (UIScrollView *)listView {
    if (!_listView) {
        _listView = [self listViewType] == MNListViewTypeTable ? self.tableView : self.collectionView;
        [self displayPullHeaderIfNeeded];
        [self displayLoadFooterIfNeeded];
    }
    return _listView;
}

#pragma mark - TableView
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [UITableView tableWithFrame:CGRectZero style:[self tableViewStyle]];
        [tableView setDataSource:self];
        [tableView setDelegate:self];
        [self.contentView addSubview:_tableView = tableView];
        _listView = tableView;
        [self displayPullHeaderIfNeeded];
        [self displayLoadFooterIfNeeded];
    }
    return _tableView;
}

#pragma mark - CollectionView
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionView *collectionView = [UICollectionView collectionViewWithFrame:CGRectZero
                                                                              layout:[self collectionViewLayout]];
        [collectionView setDataSource:self];
        [collectionView setDelegate:self];
        [self.contentView addSubview:_collectionView = collectionView];
        _listView = collectionView;
        [self displayPullHeaderIfNeeded];
        [self displayLoadFooterIfNeeded];
    }
    return _collectionView;
}

#pragma mark - TableViewDelegate & UICollectionViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - MNDragViewDelegate
- (void)dragViewDidClicking:(MNDragView *)dragView {
    [self scrollToTopWithAnimated:YES];
}

#pragma mark - ReloadList
- (void)reloadList {
    if ([self listViewType] == MNListViewTypeTable) {
        [_tableView reloadData];
    } else {
        [_collectionView reloadData];
    }
}

- (void)setNeedsReloadList {
    _needReloadList = YES;
}

- (void)reloadListIfNeeded {
    if (_needReloadList) {
        _needReloadList = NO;
        [self reloadList];
    }
}

#pragma mark - Scrolls
- (BOOL)scrollToTopWithAnimated:(BOOL)animated {
    if (!_listView || !_listView.isScrollEnabled) return NO;
    [_listView scrollToTopWithAnimated:animated];
    return YES;
}

- (BOOL)scrollToBottomWithAnimated:(BOOL)animated {
    if (!_listView.isScrollEnabled || _listView.contentSize.height <= _listView.bounds.size.height) return NO;
    [_listView scrollToBottomWithAnimated:animated];
    return YES;
}

#pragma mark - Getter
- (__kindof UICollectionViewLayout *)collectionLayout {
    if (_collectionView.collectionViewLayout) return _collectionView.collectionViewLayout;
    return [self collectionViewLayout];
}

- (BOOL)isLoadMore {
    return (_listView.mj_footer && _listView.mj_footer.isRefreshing);
}

- (BOOL)isRefreshing {
    return (_listView.mj_header && _listView.mj_header.isRefreshing);
}

- (BOOL)isNeedsLoadMoreReset {
    return (_listView.mj_footer && _listView.mj_footer.state == MJRefreshStateNoMoreData);
}

#pragma mark - controller config
- (UICollectionViewLayout *)collectionViewLayout {
    MNCollectionVerticalLayout *layout = [MNCollectionVerticalLayout layout];
    layout.numberOfFormation = 2;
    layout.minimumLineSpacing = 7.f;
    layout.minimumInteritemSpacing = 7.f;
    layout.itemSize = CGSizeMake(1.f, 1.f);
    return layout;
}
- (MNListViewType)listViewType {
    return MNListViewTypeTable;
}
- (UITableViewStyle)tableViewStyle {
    return UITableViewStylePlain;
}
- (void)adaptHeaderInsetBehavior {
    if (!_listView.mj_header) return;
    [_listView.mj_header setIgnoredScrollViewContentInsetTop:_listView.contentInset.top];
}
- (void)adaptFooterInsetBehavior {
    if (!_listView.mj_footer) return;
    [_listView.mj_footer setIgnoredScrollViewContentInsetBottom:_listView.contentInset.bottom];
}
- (void)didMoveEmptyView:(MNEmptyView *)emptyView toView:(__kindof UIView *)superview {
    [super didMoveEmptyView:emptyView toView:superview];
    if (_listView.mj_header && superview == _listView) [_listView bringSubviewToFront:_listView.mj_header];
}
- (void)prepareLoadData:(__kindof MNHTTPDataRequest *)request {
    if (self.isRefreshing || self.loadMore || self.contentView.isDialoging) return;
    [self.contentView showLoadDialog:MN_LOADING];
}
- (CGRect)emptyViewFrame {
    return UIEdgeInsetsInsetRect(_listView.bounds, _listView.contentInset);
}
- (UIView *)emptyViewSuperview {
    return _listView;
}
- (NSString *)refreshHeaderClass {
    return @"MNRefreshNormalHeader";
}
- (NSString *)loadMoreFooterClass {
    //return @"MJRefreshBackNormalFooter";
    return @"MNRefreshNormalFooter";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - dealloc
- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

@end
