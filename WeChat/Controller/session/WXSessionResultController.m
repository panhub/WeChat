//
//  WXSessionResultController.m
//  WeChat
//
//  Created by Vincent on 2019/4/27.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXSessionResultController.h"
#import "WXSessionCell.h"
#import "WXChatViewController.h"
#import "WXSession.h"

@interface WXSessionResultController ()
@property (nonatomic, strong) NSMutableArray <WXSession *>*dataArray;
@end

@implementation WXSessionResultController
- (void)initialized {
    [super initialized];
    self.dataArray = [NSMutableArray array];
}

- (void)createView {
    [super createView];
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 70.f;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.separatorColor = SEPARATOR_COLOR;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needDeleteSessionNotification:)
                                                 name:WXSessionDeleteNotificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needUpdateSessionNotification:)
                                                 name:WXSessionUpdateNotificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needReloadSessionNotification:)
                                                 name:WXSessionTableReloadNotificationName
                                               object:nil];
}

- (void)needDeleteSessionNotification:(NSNotification *)notification {
    if (notification.object && [notification.object isKindOfClass:NSArray.class]) {
        __block BOOL contains = NO;
        NSArray <WXSession *>*deletes = notification.object;
        [deletes enumerateObjectsUsingBlock:^(WXSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self.dataArray containsObject:obj]) {
                contains = YES;
                [self.dataArray removeObject:obj];
            }
        }];
        if (contains) @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
    }
}

- (void)needUpdateSessionNotification:(NSNotification *)notification {
    if (notification.object && [self.dataArray containsObject:notification.object]) {
        @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
    }
}

- (void)needReloadSessionNotification:(NSNotification *)notification {
    if (notification.object && [self.dataArray containsObject:notification.object]) {
        @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
    }
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MNTableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.home.result.header"];
    if (!header) {
        header = [[MNTableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.home.result.header"];
        header.clipsToBounds = YES;
        header.contentView.backgroundColor = VIEW_COLOR;
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.home.result.cell"];
    if (!cell) {
        cell = [[WXSessionCell alloc] initWithReuseIdentifier:@"com.wx.home.result.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
    }
    if (indexPath.section >= self.dataArray.count) return cell;
    WXSession *session = self.dataArray[indexPath.section];
    cell.session = session;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataArray.count) return;
    WXSession *session = self.dataArray[indexPath.section];
    WXChatViewController *vc = [[WXChatViewController alloc] initWithSession:session];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MNSearchResultUpdating
- (void)updateSearchResultText:(NSString *)text forSearchController:(MNSearchViewController *)searchController {
    [self.dataArray removeAllObjects];
    if (text.length > 0) {
        [[[WechatHelper helper] sessions] enumerateObjectsUsingBlock:^(WXSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.user.name containsString:text]) {
                [self.dataArray addObject:obj];
            }
        }];
    }
    [self reloadList];
}

- (void)resetSearchResults {
    [self.dataArray removeAllObjects];
    [self reloadList];
}

#pragma mark - Super
- (BOOL)isChildViewController {
    return YES;
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
