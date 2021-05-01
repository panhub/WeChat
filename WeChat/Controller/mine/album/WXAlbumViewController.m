//
//  WXAlbumViewController.m
//  WeChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAlbumViewController.h"
#import "WXMyMomentController.h"
#import "WXPhotoViewController.h"
#import "WXAlbumViewModel.h"
#import "WXAlbumHeaderView.h"
#import "WXAlbumSectionHeader.h"
#import "WXAlbumCell.h"
#import "MNRefreshFooter.h"
#import "WXAlbumFooterView.h"
#import "WXAlbumDateView.h"

#define WXAlbumObserveKeyPath    @"contentOffset"

@interface WXAlbumViewController ()
@property (nonatomic) WXScrollDirection scrollDirection;
@property (nonatomic, strong) WXAlbumDateView *dateView;
@property (nonatomic, strong) WXAlbumViewModel *viewModel;
@property (nonatomic, strong) WXAlbumFooterView *footerView;
@end

@implementation WXAlbumViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"朋友圈相册";
        self.viewModel = [WXAlbumViewModel new];
        self.loadMoreEnabled = YES;
        [self handEvents];
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[WXAlbumFooterView alloc] initWithFrame:self.tableView.bounds];
    
    [self.tableView addObserver:self forKeyPath:WXAlbumObserveKeyPath options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
    
    WXAlbumHeaderView *headerView = [[WXAlbumHeaderView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 0.f)];
    self.tableView.tableHeaderView = headerView;
    @weakify(self);
    headerView.touchEventHandler = ^{
        WXMyMomentController *vc = [[WXMyMomentController alloc] init];
        [weakself.navigationController pushViewController:vc animated:YES];
    };
    
    WXAlbumFooterView *footerView = [[WXAlbumFooterView alloc] initWithFrame:self.tableView.bounds];
    self.footerView = footerView;
    
    WXAlbumDateView *dateView = [[WXAlbumDateView alloc] initWithFrame:self.contentView.bounds];
    dateView.alpha = 0.f;
    [self.contentView addSubview:dateView];
    self.dateView = dateView;
}

- (void)loadData {
    [self.viewModel loadData];
}

#pragma mark - Events
- (void)handEvents {
    @weakify(self);
    /// 刷新表事件
    self.viewModel.reloadTableHandler = ^{
        @strongify(self);
        [UIView performWithoutAnimation:^{
            [self reloadList];
        }];
        if (self.viewModel.dataSource.count && self.dateView.alpha == 0.f) {
            [self updateDateInSection:0 row:0];
        }
    };
    /// 加载结束事件
    self.viewModel.didLoadFinishHandler = ^(BOOL hasMore) {
        @strongify(self);
        if (hasMore) {
            [self resetLoadFooter];
            self.tableView.tableFooterView = nil;
        } else {
            [self relieveLoadFooter];
            self.tableView.tableFooterView = self.footerView;
        }
    };
    /// 配图点击事件
    self.viewModel.touchEventHandler = ^(WXProfile *picture) {
        @strongify(self);
        NSMutableArray <WXProfile *>*pictures = @[].mutableCopy;
        [self.viewModel.dataSource enumerateObjectsUsingBlock:^(WXYearViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.dataSource enumerateObjectsUsingBlock:^(WXMonthViewModel * _Nonnull month, NSUInteger idx, BOOL * _Nonnull stop) {
                [pictures addObjectsFromArray:month.pictures];
            }];
        }];
        WXPhotoViewController *vc = [[WXPhotoViewController alloc] initWithPhotos:pictures startIndex:[pictures indexOfObject:picture]];
        vc.user = WXUser.shareInfo;
        vc.backgroundImage = self.view.snapshotImage;
        [self.navigationController pushViewController:vc animated:YES];
    };
}

#pragma mark - UITableViewDataSource&UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataSource[section].dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.viewModel.dataSource[indexPath.section].dataSource[indexPath.row].rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    WXYearViewModel *viewModel = self.viewModel.dataSource[section];
    return viewModel.headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WXYearViewModel *viewModel = self.viewModel.dataSource[section];
    if (viewModel.headerHeight <= 0.f) return nil;
    WXAlbumSectionHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.album.header"];
    if (!header) {
        header = [[WXAlbumSectionHeader alloc] initWithReuseIdentifier:@"com.wx.album.header"];
    }
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(WXAlbumSectionHeader *)view forSection:(NSInteger)section {
    view.viewModel = self.viewModel.dataSource[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.album.cell"];
    if (!cell) {
        cell = [[WXAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"com.wx.album.cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXAlbumCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.viewModel = self.viewModel.dataSource[indexPath.section].dataSource[indexPath.row];
    if (self.scrollDirection == WXScrollDirectionDown) {
        // 下滑
        [self updateDateInSection:indexPath.section row:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.scrollDirection == WXScrollDirectionUp) {
        // 上滑
        WXYearViewModel *yvm = self.viewModel.dataSource[indexPath.section];
        if (indexPath.row < yvm.dataSource.count - 1) {
            // 下一月
            [self updateDateInSection:indexPath.section row:indexPath.row + 1];
        } else if (indexPath.section < self.viewModel.dataSource.count - 1) {
            // 下一年
            [self updateDateInSection:indexPath.section + 1 row:0];
        }
    }
}

#pragma mark - Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.tableView && [keyPath isEqualToString:WXAlbumObserveKeyPath]) {
        CGFloat lastOffsetY = [change[NSKeyValueChangeOldKey] CGPointValue].y;
        CGFloat currentOffsetY = [change[NSKeyValueChangeNewKey] CGPointValue].y;
        if (currentOffsetY == lastOffsetY) {
            self.scrollDirection = WXScrollDirectionUnknown;
        } else {
            self.scrollDirection = currentOffsetY > lastOffsetY ? WXScrollDirectionUp : WXScrollDirectionDown;
        }
        CGFloat alpha = currentOffsetY >= self.tableView.tableHeaderView.height_mn ? 1.f : 0.f;
        if (self.dateView.alpha != alpha) {
            [UIView animateWithDuration:.2f animations:^{
                self.dateView.alpha = alpha;
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Update
- (void)updateDateInSection:(NSInteger)section row:(NSInteger)row {
    WXYearViewModel *yvm = self.viewModel.dataSource[section];
    WXMonthViewModel *mvm = yvm.dataSource[row];
    NSString *title = ((NSAttributedString *)mvm.monthViewModel.content).string;
    self.dateView.date = (title.length && [[title substringToIndex:1] integerValue] == 0) ? title : [yvm.year stringByAppendingFormat:@"/%@", mvm.month];
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

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

#pragma mark - dealloc
- (void)dealloc {
    [self.tableView removeObserver:self forKeyPath:WXAlbumObserveKeyPath];
}

@end
