//
//  WXAlbumViewController.m
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAlbumViewController.h"
#import "WXAlbumProfileViewModel.h"
#import "WXAlbumTableHeaderView.h"
#import "WXAlbumListCell.h"

@interface WXAlbumViewController ()
@property (nonatomic, strong) WXAlbumProfileViewModel *viewModel;
@end

@implementation WXAlbumViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"相册";
        self.viewModel = [WXAlbumProfileViewModel new];
        [self handEvents];
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    WXAlbumTableHeaderView *headerView = [[WXAlbumTableHeaderView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 0.f)];
    self.tableView.tableHeaderView = headerView;
    //@weakify(self);
    headerView.tableHeaderButtonClickedHandler = ^{
        //@strongify(self);
        [[MNAlertView alertViewWithTitle:nil message:@"暂未开发, 敬请期待!" handler:nil ensureButtonTitle:@"确定" otherButtonTitles:nil] show];
    };
}

- (void)loadData {
    [self.viewModel loadData];
}

#pragma mark - Hand Events
- (void)handEvents {
    @weakify(self);
    self.viewModel.reloadTableHandler = ^{
        @strongify(self);
        [UIView performWithoutAnimation:^{
            @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
        }];
    };
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.viewModel.dataSource.count) return 0.001f;
    WXAlbumViewModel *viewModel = self.viewModel.dataSource[indexPath.row];
    return viewModel.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [WXAlbumListCell cellWithTableView:tableView];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXAlbumListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.viewModel.dataSource.count) return;
    cell.viewModel = self.viewModel.dataSource[indexPath.row];
}

@end
