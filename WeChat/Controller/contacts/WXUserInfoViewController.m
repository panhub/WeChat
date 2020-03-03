//
//  WXUserInfoViewController.m
//  MNChat
//
//  Created by Vincent on 2019/3/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXUserInfoViewController.h"
#import "WXDataValueModel.h"
#import "WXUserInfoHeaderView.h"
#import "WXUserInfoValueCell.h"
#import "WXUserSettingViewController.h"
#import "WXEditUserInfoViewController.h"
#import "WXChatViewController.h"
#import "WXChatViewController.h"
#import "WXSession.h"
#import "WXUser.h"

@interface WXUserInfoViewController ()
@property (nonatomic, strong) WXUser *user;
@property (nonatomic, getter=isContainsUser) BOOL containsUser;
@property (nonatomic, strong) WXUserInfoHeaderView *headerView;
@property (nonatomic, strong) NSMutableArray <NSArray <WXDataValueModel *>*>*dataArray;
@end

@implementation WXUserInfoViewController
- (instancetype)initWithUser:(WXUser *)user {
    if (self = [super init]) {
        self.user = user;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.backgroundColor = UIColor.whiteColor;
    self.navigationBar.rightBarItem.touchInset = UIEdgeInsetWith(-5.f);
    self.navigationBar.rightItemImage = UIImageNamed(@"wx_common_more_black");
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.rowHeight = 55.f;
    
    WXUserInfoHeaderView *headerView = [[WXUserInfoHeaderView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 0.f)];
    headerView.imageView.image = [UIImage imageWithColor:[UIColor whiteColor]];
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    [self handNotification:WXUserUpdateNotificationName object:nil eventHandler:^(NSNotification *notify) {
        @strongify(self);
        if (![kTransform(WXUser *, notify.object).uid isEqualToString:self.user.uid]) return;
        [self loadData];
    }];
}

#pragma mark - 更新用户数据
- (void)loadData {
    self.containsUser = ([MNChatHelper.helper containsUser:self.user] && ![self.user.uid isEqualToString:WXUser.shareInfo.uid]);
    self.navigationBar.rightBarItem.hidden = !self.isContainsUser;
    self.headerView.user = self.user;
    [self.dataArray removeAllObjects];
    [self.dataArray addObject:self.listArray];
    [self.dataArray addObject:self.defaultArray];
    @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
}

#pragma mark - TableViewDataSource&Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 0 || self.dataArray[section].count <= 0) ? .01f : 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 || self.dataArray[section].count <= 0) return nil;
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.user.info.list.header"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.user.info.list.header"];
        header.contentView.backgroundColor = VIEW_COLOR;
        header.clipsToBounds = YES;
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXDataValueModel *model = self.dataArray[indexPath.section][indexPath.row];
    return [WXUserInfoValueCell dequeueReusableCellWithTableView:tableView model:model];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXUserInfoValueCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    WXDataValueModel *model = self.dataArray[indexPath.section][indexPath.row];
    cell.separatorInset = UIEdgeInsetsZero;
    if (kTransform(NSNumber *, model.userInfo).intValue == 1) {
        cell.imgView.hidden = !self.isContainsUser;
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.titleLabel.left, 0.f, 0.f);
    }
    cell.model = model;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.isContainsUser) {
            WXEditUserInfoViewController *vc = [[WXEditUserInfoViewController alloc] initWithUser:self.user];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        if (!self.isContainsUser) {
            /// 添加到通讯录
            __block BOOL isSucceed = NO;
            [self.view showWeChatDialogDelay:.35f eventHandler:^{
                isSucceed = [[MNChatHelper helper] insertUserToContacts:self.user];
            } completionHandler:^{
                if (isSucceed) {
                    [self loadData];
                } else {
                    [self.view showInfoDialog:@"操作失败"];
                }
            }];
        } else if (indexPath.row == 0) {
            /// 发消息, 先检查导航内是否有聊天, 再判断是否是与此用户的聊天
            __block UIViewController *viewController;
            [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:WXChatViewController.class]) {
                    WXChatViewController *vc = (WXChatViewController *)obj;
                    if ([vc.viewModel.session.user.uid isEqualToString:self.user.uid]) {
                        viewController = obj;
                        *stop = YES;
                    }
                }
            }];
            if (viewController) {
                [self.navigationController popToViewController:viewController animated:YES];
            } else {
                /// 创建聊天控制器
                WXSession *session = [WXSession sessionForUser:self.user];
                if (session) {
                    WXChatViewController *vc = [[WXChatViewController alloc] initWithSession:session];
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    [self.view showInfoDialog:@"获取会话失败"];
                }
            }
        } else {
            /// 音视频, 拨打电话, 插入语音, 视频电话消息
            if (self.user.number.length != 11) {
                [self.view showInfoDialog:@"电话号码错误"];
            } else {
                [UIApplication handOpenUrl:[NSString stringWithFormat:@"facetime://%@", self.user.number] completion:^(BOOL succeed) {
                    if (!succeed) [self.view showInfoDialog:[NSString stringWithFormat:@"%@打不开通话", NSBundleDisplayName()]];
                }];
            }
        }
    }
}

#pragma mark - MNNavigationBarDelegate
- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    WXUserSettingViewController *vc = [[WXUserSettingViewController alloc] initWithUser:self.user];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Getter
- (NSMutableArray <NSArray <WXDataValueModel *>*>*)dataArray {
    if (!_dataArray) {
        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:2];
        _dataArray = dataArray;
    }
    return _dataArray;
}

- (NSArray <WXDataValueModel *>*)listArray {
    NSMutableArray <WXDataValueModel *>*sectionArray = [NSMutableArray arrayWithCapacity:1];
    if (self.user.label.length > 0) {
        WXDataValueModel *model = [WXDataValueModel new];
        model.title = @"标签";
        model.value = self.user.label;
        model.userInfo = @(1);
        [sectionArray addObject:model];
    }
    if (self.user.desc.length > 0) {
        WXDataValueModel *model = [WXDataValueModel new];
        model.title = @"描述";
        model.value = self.user.desc;
        model.userInfo = @(1);
        [sectionArray addObject:model];
    }
    if (self.user.location.length > 0) {
        WXDataValueModel *model = [WXDataValueModel new];
        model.title = @"地区";
        model.value = self.user.location;
        model.userInfo = @(1);
        [sectionArray addObject:model];
    }
    if (sectionArray.count <= 0 && self.isContainsUser) {
        WXDataValueModel *model = [WXDataValueModel new];
        model.title = @"设置备注和标签";
        model.value = @"";
        model.userInfo = @(1);
        [sectionArray addObject:model];
    }
    return sectionArray.copy;
}

- (NSArray <WXDataValueModel *>*)defaultArray {
    NSMutableArray <WXDataValueModel *>*defaultArray = [NSMutableArray arrayWithCapacity:2];
    if (self.isContainsUser) {
        /// 聊天 音视频
        WXDataValueModel *model1 = [WXDataValueModel new];
        model1.title = @"发消息";
        model1.value = @"发消息";
        model1.img = @"wx_contacts_msg";
        model1.userInfo = @(2);
        WXDataValueModel *model2 = [WXDataValueModel new];
        model2.title = @"音视频通话";
        model2.value = @"音视频通话";
        model2.img = @"wx_contacts_video";
        model2.userInfo = @(2);
        [defaultArray addObject:model1];
        [defaultArray addObject:model2];
    } else if (![self.user.uid isEqualToString:WXUser.shareInfo.uid]) {
        /// 添加到通讯录
        WXDataValueModel *model = [WXDataValueModel new];
        model.title = @"添加到通讯录";
        model.value = @"添加到通讯录";
        model.userInfo = @(2);
        [defaultArray addObject:model];
    }
    return defaultArray.copy;
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
