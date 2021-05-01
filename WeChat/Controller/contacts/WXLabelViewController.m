//
//  WXLabelViewController.m
//  WeChat
//
//  Created by Vicent on 2021/3/29.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXLabelViewController.h"
#import "WXLabelCell.h"
#import "WXLabel.h"
#import "WXLabelHeader.h"
#import "WXNewLabelController.h"

@interface WXLabelViewController ()
@property (nonatomic, strong) NSMutableArray <WXLabel *>*dataSource;
@end

@implementation WXLabelViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"标签";
        self.dataSource = @[].mutableCopy;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowView.hidden = YES;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.rowHeight = 65.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, MN_TAB_SAFE_HEIGHT)];
    
    WXLabelHeader *tableHeaderView = [[WXLabelHeader alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, self.tableView.rowHeight)];
    [tableHeaderView addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = tableHeaderView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    @weakify(self);
    [self handNotification:WXLabelUpdateNotificationName eventHandler:^(id  _Nonnull sender) {
        @strongify(self);
        [self loadData];
    }];
}

- (void)loadData {
    [self.contentView showWechatDialog];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray <WXLabel *>*dataSource = @[].mutableCopy;
        NSArray <WXLabel *>*labels = [MNDatabase.database selectRowsModelFromTable:WXLabelTableName class:WXLabel.class];
        [labels enumerateObjectsUsingBlock:^(WXLabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray <WXUser *>*result = [MNDatabase.database selectRowsModelFromTable:WXContactsTableName where:@{@"label":sql_pair(obj.name)}.sqlQueryValue limit:NSRangeZero class:WXUser.class];
            [obj.users addObjectsFromArray:result];
            [dataSource addObject:obj];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:dataSource];
            [self reloadList];
            [self.contentView closeDialog];
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.label.cell"];
    if (!cell) {
        cell = [[WXLabelCell alloc] initWithReuseIdentifier:@"com.wx.label.cell" size:tableView.rowSize];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXLabelCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataSource.count) return;
    cell.label = self.dataSource[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataSource.count) return;
    WXLabel *label = self.dataSource[indexPath.row];
    WXNewLabelController *vc = [[WXNewLabelController alloc] initWithLabel:label];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Event
- (void)add {
    UIViewControllerPush(@"WXNewLabelController", YES);
}

@end
