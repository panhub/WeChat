//
//  WXUserPermissionController.m
//  WeChat
//
//  Created by Vicent on 2021/4/29.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXUserPermissionController.h"
#import "WXUserPermissionFooterView.h"
#import "WXUserPermissionHeaderView.h"
#import "WXDataValueCell.h"
#import "WXDataValueModel.h"
#import "WXUser.h"

@interface WXUserPermissionController ()
@property (nonatomic, strong) WXUser *user;
@property (nonatomic, strong) NSArray <WXDataValueModel *>*permissions;
@property (nonatomic, strong) NSMutableArray <NSArray <WXDataValueModel *>*>*dataSource;
@end

@implementation WXUserPermissionController
- (instancetype)initWithUser:(WXUser *)user {
    if (!user) return nil;
    if (self = [super init]) {
        self.title = @"朋友权限";
        self.user = user;
        self.dataSource = @[].mutableCopy;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowView.hidden = YES;
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.rowHeight = 55.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = VIEW_COLOR;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadData {
    WXDataValueModel *model1 = [WXDataValueModel new];
    model1.title = @"聊天、朋友圈、微信运动等";
    model1.desc = @"";
    model1.selected = !self.user.only;
    WXDataValueModel *model2 = [WXDataValueModel new];
    model2.title = @"仅聊天";
    model2.desc = @"";
    model2.selected = self.user.only;
    [self.dataSource removeAllObjects];
    [self.dataSource addObject:@[model1, model2]];
    if (!self.user.only) [self.dataSource addObject:self.permissions];
    [self reloadList];
}

#pragma mark - UITableViewDataDelegate&Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 37.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.dataSource.count == 1 ? 37.f : 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WXUserPermissionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.user.permission.header"];
    if (!header) {
        header = [[WXUserPermissionHeaderView alloc] initWithReuseIdentifier:@"com.wx.user.permission.header"];
        header.contentView.backgroundColor = VIEW_COLOR;
    }
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.dataSource.count != 1) return nil;
    WXUserPermissionFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.user.permission.footer"];
    if (!footer) {
        footer = [[WXUserPermissionFooterView alloc] initWithReuseIdentifier:@"com.wx.user.permission.footer"];
        footer.contentView.backgroundColor = VIEW_COLOR;
    }
    return footer;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(WXUserPermissionHeaderView *)view forSection:(NSInteger)section {
    view.titleLabel.text = section == 0 ? @"设置朋友权限" : @"朋友圈和状态";
    [view setNeedsLayout];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXDataValueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.user.info.permission.cell"];
    if (!cell) {
        cell = [[WXDataValueCell alloc] initWithReuseIdentifier:@"com.wx.user.info.permission.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
        cell.imgView.image = [[UIImage imageNamed:@"contacts_moment_permission_selected"] imageWithColor:THEME_COLOR];
        cell.imgView.width_mn = 23.f;
        [cell.imgView sizeFitToWidth];
        cell.imgView.centerX_mn = cell.switchButton.centerX_mn;
        cell.imgView.centerY_mn = cell.contentView.height_mn/2.f;
        @weakify(self);
        cell.valueChangedHandler = ^(NSIndexPath *indexPath, BOOL isOn) {
            [weakself updateUser:indexPath isOn:isOn];
        };
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXDataValueCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataSource.count) return;
    NSArray <WXDataValueModel *>*section = self.dataSource[indexPath.section];
    if (indexPath.row >= section.count) return;
    WXDataValueModel *model = section[indexPath.row];
    cell.model = model;
    cell.switchButton.hidden = indexPath.section <= 0;
    cell.imgView.hidden = (indexPath.section > 0 || !model.isSelected);
    if (indexPath.row == self.dataSource[indexPath.section].count - 1) {
        cell.separatorInset = UIEdgeInsetsZero;
    } else {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.titleLabel.left_mn, 0.f, 0.f);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataSource.count || indexPath.section > 0) return;
    NSArray <WXDataValueModel *>*section = self.dataSource[indexPath.section];
    if (indexPath.row >= section.count) return;
    WXDataValueModel *model = section[indexPath.row];
    if (model.isSelected) return;
    WXUser *user = self.user;
    BOOL only = indexPath.row == 1;
    @weakify(self);
    [self.view showWechatDialogDelay:.3f eventHandler:^{
        if ([MNDatabase.database updateTable:WXContactsTableName where:@{sql_field(user.uid):sql_pair(user.uid)}.sqlQueryValue fields:@{sql_field(user.only):@(only)}]) {
            user.only = only;
            @PostNotify(WXUserUpdateNotificationName, user);
            weakself.dataSource.firstObject.firstObject.selected = !only;
            weakself.dataSource.firstObject.lastObject.selected = only;
            if (only) {
                if (weakself.dataSource.count > 1) {
                    [weakself.dataSource removeLastObject];
                }
            } else {
                if (weakself.dataSource.count <= 1) {
                    [weakself.dataSource addObject:weakself.permissions];
                }
            }
            [weakself reloadList];
        }
    } completionHandler:nil];
}

- (void)updateUser:(NSIndexPath *)indexPath isOn:(BOOL)isOn {
    @weakify(self);
    WXUser *user = self.user;
    [self.view showWechatDialogDelay:.3f eventHandler:^{
        if ([MNDatabase.database updateTable:WXContactsTableName where:@{sql_field(user.uid):sql_pair(user.uid)}.sqlQueryValue fields:@{(indexPath.row == 0 ? sql_field(user.privacy) : sql_field(user.looked)):@(isOn).stringValue}]) {
            if (indexPath.row == 0) {
                user.privacy = isOn;
                weakself.dataSource.lastObject.firstObject.value = @(isOn).stringValue;
            } else {
                user.looked = isOn;
                weakself.dataSource.lastObject.lastObject.value = @(isOn).stringValue;
            }
            @PostNotify(WXUserUpdateNotificationName, user);
            [weakself.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    } completionHandler:nil];
}

#pragma mark - Getter
- (NSArray <WXDataValueModel *>*)permissions {
    if (!_permissions) {
        WXDataValueModel *model1 = [WXDataValueModel new];
        model1.title = @"不让他看";
        model1.desc = @"";
        model1.value = @(self.user.privacy).stringValue;
        WXDataValueModel *model2 = [WXDataValueModel new];
        model2.title = @"不看他";
        model2.desc = @"";
        model2.value = @(self.user.looked).stringValue;
        _permissions = @[model1, model2];
    }
    return _permissions;
}

#pragma mark - controller config
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
