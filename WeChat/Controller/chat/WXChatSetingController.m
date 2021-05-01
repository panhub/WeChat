//
//  WXChatSetingController.m
//  WeChat
//
//  Created by Vincent on 2019/3/31.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChatSetingController.h"
#import "WXSession.h"
#import "WXDataValueModel.h"
#import "WXDataValueCell.h"
#import "WXChatSettingHeaderView.h"
#import "WXUserViewController.h"
#import "WXEditingViewController.h"

NSNotificationName const WXChatTableDeleteNotificationName = @"com.wx.chat.table.delete.notification.name";

@interface WXChatSetingController ()<WXChatSettingHeaderDelegate>
@property (nonatomic, strong) WXSession *session;
@property (nonatomic, strong) WXChatSettingHeaderView *headerView;
@property (nonatomic, strong) NSArray <NSArray <WXDataValueModel *>*>*dataArray;
@end

@implementation WXChatSetingController
- (instancetype)initWithSession:(WXSession *)session {
    if (!session) return nil;
    if (self = [super init]) {
        self.title = @"聊天详情";
        self.session = session;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowView.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.rowHeight = 53.f;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    WXChatSettingHeaderView *headerView = [[WXChatSettingHeaderView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 100.f)];
    headerView.delegate = self;
    headerView.user = self.session.user;
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
}

- (void)loadData {
    WXDataValueModel *model0 = [WXDataValueModel new];
    model0.title = @"置顶聊天";
    model0.value = @(self.session.front).stringValue;
    model0.desc = @"";
    WXDataValueModel *model1 = [WXDataValueModel new];
    model1.title = @"消息免打扰";
    model1.value = @(self.session.mute).stringValue;
    model1.desc = @"";
    WXDataValueModel *model2 = [WXDataValueModel new];
    model2.title = @"消息未读数";
    model2.value = @"0";
    model2.desc = @(self.session.unread_count).stringValue;
    WXDataValueModel *model3 = [WXDataValueModel new];
    model3.title = @"清空聊天记录";
    model3.value = @"";
    model3.desc = @"";
    self.dataArray = @[@[model0, model1], @[model2, model3]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /// 用户资料编辑
    @weakify(self);
    [self handNotification:WXUserUpdateNotificationName eventHandler:^(NSNotification *notify) {
        @strongify(self);
        if (![kTransform(WXUser *, notify.object).uid isEqualToString:self.session.user.uid]) return;
        self.headerView.user = self.session.user;
    }];
}

#pragma mark - UITableViewDataDelegate&Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.chat.setting.header"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.chat.setting.header"];
        header.contentView.backgroundColor = VIEW_COLOR;
        header.clipsToBounds = YES;
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXDataValueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.chat.setting.list.cell"];
    if (!cell) {
        cell = [[WXDataValueCell alloc] initWithReuseIdentifier:@"com.wx.chat.setting.list.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
        @weakify(self);
        cell.valueChangedHandler = ^(NSIndexPath *indexPath, BOOL isOn) {
            @strongify(self);
            [self updateSetingAtIndexPath:indexPath isOn:isOn];
        };
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXDataValueCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    WXDataValueModel *model = self.dataArray[indexPath.section][indexPath.row];
    cell.model = model;
    cell.switchButton.hidden = indexPath.section != 0;
    cell.detailLabel.hidden = !cell.switchButton.hidden;
    cell.imgView.hidden = !(indexPath.section == 1 && indexPath.row == 0);
    if (indexPath.row == [self.dataArray[indexPath.section] count] - 1) {
        cell.separatorInset = UIEdgeInsetsZero;
    } else {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.titleLabel.left_mn, 0.f, 0.f);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return;
    if (indexPath.row == 0) {
        /// 消息未读数
        WXDataValueModel *model = [[self.dataArray lastObject] firstObject];
        WXEditingViewController *vc = [WXEditingViewController new];
        vc.numberOfLines = 1;
        vc.keyboardType = UIKeyboardTypeNumberPad;
        vc.placeholder = @"0";
        vc.text = model.desc;
        vc.numberOfWords = 3;
        vc.title = @"设置消息未读数";
        vc.completionHandler = ^(NSString *result, WXEditingViewController *v) {
            [v.navigationController popViewControllerAnimated:YES];
            if (v.text.unsignedIntegerValue == model.desc.unsignedIntegerValue) return;
            model.desc = v.text;
            [self reloadList];
            self.session.unread_count = v.text.unsignedIntegerValue;
            @PostNotify(WXSessionUpdateNotificationName, self.session);
            @PostNotify(WXSessionTableReloadNotificationName, self.session);
        };
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        /// 清空聊天记录
        @weakify(self);
        MNActionSheet *actionSheet = [MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *sheet, NSInteger buttonIndex) {
            if (buttonIndex == sheet.cancelButtonIndex) return;
            @strongify(self);
            @PostNotify(WXChatTableDeleteNotificationName, self.session);
            [self.navigationController popViewControllerAnimated:YES];
        } otherButtonTitles:@"清空聊天记录", nil];
        actionSheet.buttonTitleColor = BADGE_COLOR;
        actionSheet.cancelButtonTitleColor = UIColorWithAlpha([UIColor darkTextColor], .7f);;
        [actionSheet show];
    }
}

#pragma mark - 更新设置
- (void)updateSetingAtIndexPath:(NSIndexPath *)indexPath isOn:(BOOL)isOn {
    if (indexPath.section >= self.dataArray.count) return;
    WXDataValueModel *model = self.dataArray[indexPath.section][indexPath.row];
    model.value = NSStringFromNumber(@(isOn));
    if (indexPath.row == 0) {
        self.session.front = isOn;
        @PostNotify(WXSessionBringFrontNotificationName, self.session);
    } else {
        self.session.mute = isOn;
        @PostNotify(WXSessionUpdateNotificationName, self.session);
        @PostNotify(WXSessionTableReloadNotificationName, self.session);
    }
}

#pragma mark - WXChatSettingHeaderDelegate
- (void)headerViewAvatarButtonTouchUpInside:(WXChatSettingHeaderView *)headerView {
    WXUserViewController *vc = [[WXUserViewController alloc] initWithUser:self.session.user];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Overwrite
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
