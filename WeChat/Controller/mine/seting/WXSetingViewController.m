//
//  WXSetingViewController.m
//  MNChat
//
//  Created by Vincent on 2019/7/20.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXSetingViewController.h"
#import "WXDataValueModel.h"
#import "WXSetingListCell.h"

@interface WXSetingViewController ()
@property (nonatomic, strong) NSArray <NSArray <WXDataValueModel *> *>*dataArray;
@end

#define WXSetingDebugTitle  @"调试模式"
#define WXSetingCacheTitle  @"清理缓存"

@implementation WXSetingViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"设置";
    }
    return self;
}

- (void)createView {
    [super createView];
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.rowHeight = 55.f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadData {
    NSArray <NSArray <NSString *>*>*titles = @[@[@"账号与安全"], @[@"聊天背景", @"我的表情"], @[WXSetingCacheTitle, NSStringWithFormat(@"关于%@", [NSBundle displayName])], @[@"退出登录"]];
    NSArray <NSArray <NSString *>*>*descs = @[@[@""], @[@"", @""], @[self.cacheSize, NSStringWithFormat(@"版本%@", [NSBundle bundleVersion])], @[@""]];
    if (MN_IS_DEBUG) {
        titles = @[@[@"账号与安全"], @[@"聊天背景", @"我的表情"], @[WXSetingDebugTitle, WXSetingCacheTitle,  NSStringWithFormat(@"关于%@", [NSBundle displayName])], @[@"退出登录"]];
        descs = @[@[@""], @[@"", @""], @[WXPreference.preference.isAllowsDebug ? @"开启":@"关闭", self.cacheSize,  NSStringWithFormat(@"版本%@", [NSBundle bundleVersion])], @[@""]];
    }
    NSMutableArray <NSArray *>*dataArray = [NSMutableArray arrayWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isLast = idx == titles.count - 1;
        NSMutableArray <WXDataValueModel *>*listArray = [NSMutableArray arrayWithCapacity:obj.count];
        [obj enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger index, BOOL * _Nonnull stop) {
            WXDataValueModel *model = [WXDataValueModel new];
            model.title = title;
            model.desc = descs[idx][index];
            model.userInfo = isLast ? BADGE_COLOR : (([title isEqualToString:WXSetingDebugTitle] || [title isEqualToString:WXSetingCacheTitle]) ? @"" : nil);
            model.value = isLast ? @"WXSetingFooterCell" : @"WXSetingListCell";
            [listArray addObject:model];
        }];
        [dataArray addObject:listArray.copy];
    }];
    self.dataArray = dataArray.copy;
}

#pragma mark - UITableViewDataDelegate&Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section > 0 ? 8.f : .1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.seting.header"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.seting.header"];
        header.contentView.backgroundColor = VIEW_COLOR;
        header.clipsToBounds = YES;
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXDataValueModel *model = self.dataArray[indexPath.section][indexPath.row];
    WXSetingListCell *cell = [WXSetingListCell dequeueReusableCellWithTableView:tableView model:model];
    if (indexPath.row == [self.dataArray[indexPath.section] count] - 1) {
        cell.separatorInset = UIEdgeInsetsZero;
    } else {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.titleLabel.left_mn, 0.f, 0.f);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UIViewControllerPush(@"WXAccountViewController", YES);
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UIViewControllerPush(@"WXChatBackgroundController", YES);
        } else {
            UIViewControllerPush(@"WXEmoticonViewController", YES);
        }
    } else if (indexPath.section == 2) {
        NSArray <WXDataValueModel *>*array = self.dataArray[indexPath.section];
        WXDataValueModel *model = array[indexPath.row];
        if ([model.title isEqualToString:WXSetingDebugTitle]) {
            [AppDelegate changeDebugState];
            model.desc = WXPreference.preference.isAllowsDebug ? @"开启" : @"关闭";
            [tableView reloadRow:indexPath.row inSection:indexPath.section withRowAnimation:UITableViewRowAnimationNone];
        } else if ([model.title isEqualToString:WXSetingCacheTitle]) {
            [[MNAlertView alertViewWithTitle:nil message:@"确定要清除本地缓存?" handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex != alertView.ensureButtonIndex) return;
                [self.view showWechatDialogDelay:.5f eventHandler:^{
                    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
                    [MNFileManager removeAllItemsAtPath:MNCacheDirectory() error:nil];
                } completionHandler:^{
                    model.desc = @"0.0M";
                    [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                }];
            } ensureButtonTitle:@"确定" otherButtonTitles:@"取消", nil] show];
        } else {
            UIViewControllerPush(@"WXAboutViewController", YES);
        }
    } else {
        /// 退出登录
        MNActionSheet *actionSheet = [MNActionSheet actionSheetWithTitle:@"退出登录后, 将清空用户数据" cancelButtonTitle:@"取消" handler:^(MNActionSheet *ac, NSInteger buttonIndex) {
            if (buttonIndex == ac.cancelButtonIndex) return;
            [self.view showWechatDialogDelay:.5f completionHandler:^{
                [NSNotificationCenter.defaultCenter postNotificationName:LOGOUT_NOTIFY_NAME object:nil];
            }];
        } otherButtonTitles:@"退出登录", nil];
        actionSheet.buttonTitleColor = BADGE_COLOR;
        [actionSheet show];
    }
}

#pragma mark - Getter
- (NSString *)cacheSize {
    CGFloat sdCacheSize = [[SDImageCache sharedImageCache] getSize]/1000.f/1000.f;
    CGFloat mnCacheSize = [MNFileManager itemSizeAtPath:MNCacheDirectory()];
    return [NSString stringWithFormat:@"%.1fM", sdCacheSize + mnCacheSize];
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
