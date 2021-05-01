//
//  WXContactsResultController.m
//  WeChat
//
//  Created by Vincent on 2019/4/27.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXContactsResultController.h"
#import "WXContactsCell.h"

@interface WXContactsResultController ()
@property (nonatomic, strong) NSMutableArray <WXUser *>*users;
@end

@implementation WXContactsResultController
- (void)initialized {
    [super initialized];
    self.dataSource = @[];
    self.users = @[].mutableCopy;
}

- (void)createView {
    [super createView];
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.tableView.rowHeight = 55.f;
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, MN_TAB_SAFE_HEIGHT)];
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
    if ([notification.object isKindOfClass:WXUser.class] && [self.users containsObject:notification.object]) {
        [self.users removeObject:(WXUser *)notification.object];
        @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
    }
}

- (void)needUpdateContactsInfoNotification:(NSNotification *)notification {
    if ([notification.object isKindOfClass:WXUser.class] && [self.users containsObject:notification.object]) {
        @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
    }
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.contacts.result.cell"];
    if (!cell) {
        cell = [[WXContactsCell alloc] initWithReuseIdentifier:@"com.wx.contacts.result.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
        cell.multipleSelectEnabled = self.isMultipleSelectEnabled;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXContactsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.users.count) return;
    cell.user = self.users[indexPath.row];
    if (self.isMultipleSelectEnabled) cell.selected = [self.selectedUsers containsObject:cell.user];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.users.count) return;
    WXUser *user = self.users[indexPath.row];
    if (self.isMultipleSelectEnabled) {
        if ([self.selectedUsers containsObject:user]) {
            [self.selectedUsers removeObject:user];
        } else {
            [self.selectedUsers addObject:user];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    if (self.selectedHandler) self.selectedHandler(user);
}

#pragma mark - MNSearchResultUpdating
- (void)updateSearchResultText:(NSString *)text forSearchController:(MNSearchViewController *)searchController {
    [self.users removeAllObjects];
    if (text.length > 0) {
        [self.dataSource enumerateObjectsUsingBlock:^(WXUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.name containsString:text]) {
                [self.users addObject:obj];
            }
        }];
    }
    [self reloadList];
}

- (void)resetSearchResults {
    [self.users removeAllObjects];
    [self reloadList];
}

#pragma mark - Super
- (BOOL)isChildViewController {
    return YES;
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
