//
//  WXUserViewController.m
//  WeChat
//
//  Created by Vincent on 2019/3/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXUserViewController.h"
#import "WXUserInfoHeaderView.h"
#import "WXMyMomentController.h"
#import "WXUserMoreController.h"
#import "WXEditUserInfoViewController.h"
#import "WXUserCell.h"
#import "WXChatViewModel.h"
#import "WXUserSettingController.h"
#import "WXUserPermissionController.h"
#import "WXEditUserInfoViewController.h"
#import "WXChatViewController.h"
#import "WXChatViewController.h"
#import "WXSession.h"
#import "WXUser.h"
#import "WXUserInfo.h"
#import "WXLabel.h"
#import "WXMoment.h"

#define WXUserTitileLabel           @"标签"
#define WXUserTitileNote            @"标签和备注"
#define WXUserTitilePermission    @"朋友权限"
#define WXUserTitilePermission2  @""
#define WXUserTitileMoment        @"朋友圈"
#define WXUserTitileMore            @"更多信息"
#define WXUserTitileMessage       @"发消息"
#define WXUserTitileCall              @"音视频通话"
#define WXUserTitileAdd              @"添加到通讯录"

@interface WXUserViewController ()
@property (nonatomic, strong) WXUser *user;
@property (nonatomic, strong) WXUserInfoHeaderView *headerView;
@property (nonatomic, strong) NSMutableArray <NSArray <WXUserInfo *>*>*dataSource;
@end

@implementation WXUserViewController
- (instancetype)init {
    return [self initWithUser:WXUser.shareInfo];
}

- (instancetype)initWithUser:(WXUser *)user {
    if (self = [super init]) {
        self.dataSource = @[].mutableCopy;
        self.user = [WechatHelper.helper userForUid:user.uid] ? : user;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.backgroundColor = UIColor.whiteColor;
    self.navigationBar.rightBarItem.touchInset = UIEdgeInsetWith(-5.f);
    self.navigationBar.rightItemImage = [UIImage imageNamed:@"wx_common_more_black"];
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
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
        if (![self.user isEqualToUser:notify.object]) return;
        self.user = notify.object;
        [self loadData];
    }];
}

#pragma mark - 更新用户数据
- (void)loadData {
    [self updateSubviews];
    [self reloadData];
}

- (void)reloadData {
    @weakify(self);
    NSMutableArray <NSArray <WXUserInfo *>*>*dataSource = @[].mutableCopy;
    [self.contentView showWechatDialogDelay:.3f eventHandler:^{
        // 第一区
        if ([WechatHelper.helper containsUser:weakself.user] && ![weakself.user.uid isEqualToString:WXUser.shareInfo.uid]) {
            NSMutableArray <WXUserInfo *>*section1 = [NSMutableArray arrayWithCapacity:2];
            NSMutableArray <NSString *>*labels = @[].mutableCopy;
            NSArray <WXLabel *>*rows = [MNDatabase.database selectRowsModelFromTable:WXLabelTableName class:WXLabel.class] ? : @[];
            [[weakself.user.label componentsSeparatedByString:@","] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray <WXLabel *>*result = [rows filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.identifier == %@", obj]];
                if (result.count) [labels addObject:result.firstObject.name];
            }];
            NSMutableArray <NSString *>*permissions = @[].mutableCopy;
            if (weakself.user.privacy) [permissions addObject:[NSString stringWithFormat:@"不让%@看朋友圈和状态", (weakself.user.gender == WechatGenderFemale ? @"她" : @"他")]];
            if (weakself.user.looked) [permissions addObject:[NSString stringWithFormat:@"不看%@的朋友圈和视频状态", (weakself.user.gender == WechatGenderFemale ? @"她" : @"他")]];
            if (weakself.user.only) {
                [permissions removeAllObjects];
                [permissions addObject:@"仅朋友圈"];
            }
            // 标签
            WXUserInfo *model1 = WXUserInfo.new;
            model1.title = labels.count ? WXUserTitileLabel : WXUserTitileNote;
            model1.subtitle = [labels componentsJoinedByString:@","];
            model1.cell = @"WXUserNormalCell";
            model1.rowHeight = WXUserCellRowHeight;
            model1.separatorInset = UIEdgeInsetsMake(0.f, WXUserCellTitleMargin, 0.f, 0.f);
            [section1 addObject:model1];
            // 权限
            WXUserInfo *model2 = WXUserInfo.new;
            model2.title = WXUserTitilePermission;
            model2.subtitle = permissions.count ? permissions.firstObject : @"";
            model2.cell = @"WXUserNormalCell";
            model2.rowHeight = WXUserCellRowHeight;
            model2.separatorInset = UIEdgeInsetsZero;
            [section1 addObject:model2];
            if (permissions.count > 1) {
                model2.separatorInset = model1.separatorInset;
                WXUserInfo *model3 = WXUserInfo.new;
                model3.title = WXUserTitilePermission2;
                model3.subtitle = permissions.lastObject;
                model3.cell = @"WXUserNormalCell";
                model3.rowHeight = WXUserCellRowHeight;
                model3.separatorInset = UIEdgeInsetsZero;
                [section1 addObject:model3];
            }
            [dataSource addObject:section1.copy];
        }
        
        // 第二区
        NSMutableArray <WXUserInfo *>*section2 = [NSMutableArray arrayWithCapacity:2];
        NSMutableArray <WXProfile *>*photos = @[].mutableCopy;
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uid = %@ ORDER BY timestamp DESC;", WXMomentTableName, sql_pair(self.user.uid)];
        NSArray <WXMoment *>*moments = [MNDatabase.database selectRowsModelFromTable:WXMomentTableName sql:sql class:WXMoment.class];
        [moments enumerateObjectsUsingBlock:^(WXMoment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray <WXProfile *>*profiles = obj.profiles;
            if (profiles.count <= 0) return;
            NSInteger count = WXUserCellPhotoMaxCount - photos.count;
            NSArray <WXProfile *>*result = profiles.count <= count ? profiles : [profiles subarrayWithRange:NSMakeRange(0, count)];
            [photos addObjectsFromArray:result];
            if (profiles.count >= WXUserCellPhotoMaxCount) {
                *stop = YES;
            }
        }];
        // 朋友圈
        WXUserInfo *momentModel = WXUserInfo.new;
        momentModel.photos = photos;
        momentModel.title = WXUserTitileMoment;
        momentModel.cell = @"WXUserPhotoCell";
        momentModel.rowHeight = WXUserCellPhotoRowHeight;
        momentModel.separatorInset = UIEdgeInsetsMake(0.f, WXUserCellTitleMargin, 0.f, 0.f);
        [section2 addObject:momentModel];
        // 更多信息
        WXUserInfo *moreModel = WXUserInfo.new;
        moreModel.title = WXUserTitileMore;
        moreModel.subtitle = @"";
        moreModel.cell = @"WXUserNormalCell";
        moreModel.rowHeight = WXUserCellRowHeight;
        moreModel.separatorInset = UIEdgeInsetsZero;
        [section2 addObject:moreModel];
        [dataSource addObject:section2.copy];
        
        // 第三区
        if (![weakself.user.uid isEqualToString:WXUser.shareInfo.uid]) {
            NSMutableArray <WXUserInfo *>*section3 = [NSMutableArray arrayWithCapacity:2];
            if ([WechatHelper.helper containsUser:weakself.user]) {
                /// 聊天 音视频
                WXUserInfo *model1 = WXUserInfo.new;
                model1.title = WXUserTitileMessage;
                model1.subtitle = @"发消息";
                model1.cell = @"WXUserTextCell";
                model1.separatorInset = UIEdgeInsetsZero;
                model1.rowHeight = WXUserCellRowHeight;
                model1.image = [UIImage imageNamed:@"wx_contacts_msg"];
                [section3 addObject:model1];
                
                WXUserInfo *model2 = WXUserInfo.new;
                model2.title = WXUserTitileCall;
                model2.subtitle = @"音视频通话";
                model2.cell = @"WXUserTextCell";
                model2.separatorInset = UIEdgeInsetsZero;
                model2.rowHeight = WXUserCellRowHeight;
                model2.image = [UIImage imageNamed:@"wx_contacts_video"];
                [section3 addObject:model2];
            } else {
                /// 添加到通讯录
                WXUserInfo *model1 = WXUserInfo.new;
                model1.title = WXUserTitileAdd;
                model1.subtitle = @"添加到通讯录";
                model1.cell = @"WXUserTextCell";
                model1.separatorInset = UIEdgeInsetsZero;
                model1.rowHeight = WXUserCellRowHeight;
                [section3 addObject:model1];
            }
            [dataSource addObject:section3.copy];
        }
    } completionHandler:^{
        [weakself.dataSource removeAllObjects];
        [weakself.dataSource addObjectsFromArray:dataSource];
        [weakself reloadList];
    }];
}

- (void)updateSubviews {
    self.headerView.user = self.user;
    self.navigationBar.rightBarItem.hidden = (![WechatHelper.helper containsUser:self.user] || [self.user.uid isEqualToString:WXUser.shareInfo.uid]);
}

#pragma mark - TableViewDataSource&Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 0 || self.dataSource[section].count <= 0) ? 0.01f : 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 || self.dataSource[section].count <= 0) return nil;
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.user.info.header"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.user.info.header"];
        header.contentView.backgroundColor = VIEW_COLOR;
        header.clipsToBounds = YES;
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.dataSource[indexPath.section][indexPath.row].rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXUserInfo *model = self.dataSource[indexPath.section][indexPath.row];
    return [WXUserCell dequeueReusableCellWithTableView:tableView model:model];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXUserCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataSource.count) return;
    NSArray <WXUserInfo *>*section = self.dataSource[indexPath.section];
    if (indexPath.row >= section.count) return;
    WXUserInfo *model = section[indexPath.row];
    cell.model = model;
    cell.separatorInset = model.separatorInset;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataSource.count) return;
    NSArray <WXUserInfo *>*section = self.dataSource[indexPath.section];
    if (indexPath.row >= section.count) return;
    WXUserInfo *row = section[indexPath.row];
    if ([row.title isEqualToString:WXUserTitileLabel] || [row.title isEqualToString:WXUserTitileNote]) {
        // 编辑信息
        WXEditUserInfoViewController *vc = [[WXEditUserInfoViewController alloc] initWithUser:self.user];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([row.title isEqualToString:WXUserTitilePermission] || [row.title isEqualToString:WXUserTitilePermission2]) {
        // 权限
        WXUserPermissionController *vc = [[WXUserPermissionController alloc] initWithUser:self.user];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([row.title isEqualToString:WXUserTitileMoment]) {
        // 朋友圈
        WXMyMomentController *vc = [[WXMyMomentController alloc] initWithUser:self.user];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([row.title isEqualToString:WXUserTitileMore]) {
        // 更多
        WXUserMoreController *vc = [[WXUserMoreController alloc] initWithUser:self.user];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([row.title isEqualToString:WXUserTitileMessage]) {
        // 发消息, 先检查导航内是否有聊天, 再判断是否是与此用户的聊天
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
    } else if ([row.title isEqualToString:WXUserTitileCall] || [row.title isEqualToString:WXUserTitileCall]) {
        /// 音视频, 拨打电话, 插入语音, 视频电话消息
        /// 音视频, 拨打电话, 插入语音, 视频电话消息
        if (self.user.phone.length != 11) {
            [self.view showInfoDialog:@"电话号码错误"];
        } else {
            [UIApplication handOpenUrl:[NSString stringWithFormat:@"facetime://%@", self.user.phone] completion:^(BOOL succeed) {
                if (!succeed) [self.view showInfoDialog:[NSString stringWithFormat:@"%@打不开通话", NSBundleDisplayName()]];
            }];
        }
    }
}

#pragma mark - MNNavigationBarDelegate
- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    WXUserSettingController *vc = [[WXUserSettingController alloc] initWithUser:self.user];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
