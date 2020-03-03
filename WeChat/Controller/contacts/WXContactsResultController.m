//
//  WXContactsResultController.m
//  MNChat
//
//  Created by Vincent on 2019/4/27.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXContactsResultController.h"
#import "WXContactsCell.h"

@interface WXContactsResultController ()
@property (nonatomic, strong) NSMutableArray <WXUser *>*dataArray;
@end

@implementation WXContactsResultController
- (void)initialized {
    [super initialized];
    self.dataArray = [NSMutableArray array];
}

- (void)createView {
    [super createView];
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 55.f;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.separatorColor = SEPARATOR_COLOR;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needDeleteContactsNotification:)
                                                 name:WXUserDeleteNotificationName
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needUpdateContactsInfoNotification:)
                                                 name:WXUserUpdateNotificationName
                                               object:nil];
}

- (void)needDeleteContactsNotification:(NSNotification *)notification {
    if (notification.object && [self.dataArray containsObject:notification.object]) {
        [self.dataArray removeObject:notification.object];
        @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
    }
}

- (void)needUpdateContactsInfoNotification:(NSNotification *)notification {
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
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MNTableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.contacts.result.header"];
    if (!header) {
        header = [[MNTableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.contacts.result.header"];
        header.clipsToBounds = YES;
        header.contentView.backgroundColor = VIEW_COLOR;
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.contacts.result.cell"];
    if (!cell) {
        cell = [[WXContactsCell alloc] initWithReuseIdentifier:@"com.wx.contacts.result.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
    }
    if (indexPath.section >= self.dataArray.count) return cell;
    cell.user = self.dataArray[indexPath.section];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataArray.count) return;
    WXUser *user = self.dataArray[indexPath.section];
    if (self.selectedHandler) self.selectedHandler(user);
}

#pragma mark - MNSearchResultUpdating
- (void)updateSearchResultText:(NSString *)text forSearchController:(MNSearchViewController *)searchController {
    [self.dataArray removeAllObjects];
    if (text.length > 0) {
        [[[MNChatHelper helper] contacts] enumerateObjectsUsingBlock:^(WXUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.name containsString:text]) {
                [self.dataArray addObject:obj];
            }
        }];
    }
    [self reloadList];
}

- (void)reset {
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
