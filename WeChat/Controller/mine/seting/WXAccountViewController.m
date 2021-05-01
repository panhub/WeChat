//
//  WXAccountViewController.m
//  WeChat
//
//  Created by Vincent on 2019/8/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAccountViewController.h"
#import "WXDataValueModel.h"
#import "WXAccountListCell.h"
#import "WXEditingViewController.h"

@interface WXAccountViewController ()
@property (nonatomic, strong) NSArray <NSArray <WXDataValueModel *> *>*dataArray;
@end

@implementation WXAccountViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"账号与安全";
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
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.rowHeight = 55.f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadData {
    NSMutableArray <NSArray <NSString *>*>*titles = @[@[@"微信号", @"手机号"]].mutableCopy;
    NSMutableArray <NSArray <NSString *>*>*descs = @[@[[WXUser.shareInfo wechatId], [WXUser.shareInfo phone]]].mutableCopy;
    if (WXPreference.preference.loginPolicy != WXLoginPolicyApple) {
        [titles addObject:@[@"微信密码"]];
        [descs addObject:@[@"已设置"]];
    }
    NSMutableArray <NSArray *>*dataArray = [NSMutableArray arrayWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray <WXDataValueModel *>*listArray = [NSMutableArray arrayWithCapacity:obj.count];
        [obj enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger index, BOOL * _Nonnull stop) {
            BOOL isLast = index == obj.count - 1;
            WXDataValueModel *model = [WXDataValueModel new];
            model.title = title;
            model.desc = descs[idx][index];
            model.value = @(isLast);
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
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.account.header"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.account.header"];
        header.contentView.backgroundColor = VIEW_COLOR;
        header.clipsToBounds = YES;
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXAccountListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.account.cell"];
    if (!cell) {
        cell = [[WXAccountListCell alloc] initWithReuseIdentifier:@"com.wx.account.cell" size:tableView.rowSize];
    }
    cell.model = self.dataArray[indexPath.section][indexPath.row];
    if (indexPath.row == [self.dataArray[indexPath.section] count] - 1) {
        cell.separatorInset = UIEdgeInsetsZero;
    } else {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.titleLabel.left_mn, 0.f, 0.f);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > 0) {
        UIViewControllerPush(@"WXChangePasswordController", YES);
    } else if (indexPath.row == 1) {
        WXEditingViewController *vc = [WXEditingViewController new];
        vc.title = @"保存手机号码";
        vc.numberOfWords = 11;
        vc.numberOfLines = 1;
        vc.keyboardType = UIKeyboardTypeNumberPad;
        vc.placeholder = @"请填写手机号码";
        vc.text = [WXUser.shareInfo phone];
        vc.completionHandler = ^(NSString *result, WXEditingViewController *v) {
            if (result.length == 11) {
                [WXUser performReplacingHandler:^(WXUser *userInfo) {
                    userInfo.phone = result;
                }];
                NSArray <WXDataValueModel *> *array = self.dataArray.firstObject;
                WXDataValueModel *model = array.lastObject;
                model.desc = result;
                [self.tableView reloadRow:1 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
            }
            [v.navigationController popViewControllerAnimated:YES];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
