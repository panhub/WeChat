//
//  WXPaySetingController.m
//  MNChat
//
//  Created by Vincent on 2019/6/6.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXPaySetingController.h"
#import "WXPasswordViewController.h"
#import "WXEditingViewController.h"
#import "WXDataValueModel.h"
#import "WXPaySetingListCell.h"

@interface WXPaySetingController ()
@property (nonatomic, strong) NSArray <NSArray <WXDataValueModel *>*>*dataArray;
@end

@implementation WXPaySetingController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"支付管理";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowView.hidden = YES;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 50.f;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.backgroundColor = VIEW_COLOR;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadData {
    NSArray <NSArray <NSString *>*>*titles = @[@[@"实名认证"], @[@"修改支付密码", @"忘记支付密码"], @[@"指纹支付"], @[@"转账到账时间"]];
    NSArray <NSArray *>*values = @[@[@"已认证"], @[@"", @""], @[@(WXPreference.preference.isAllowsLocalEvaluation)], @[@"实时到账"]];
    NSMutableArray <NSArray <WXDataValueModel *>*>*dataArray = [NSMutableArray arrayWithCapacity:3];
    [titles enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull obj, NSUInteger index, BOOL * _Nonnull sp) {
        NSMutableArray <WXDataValueModel *>*listArray = [NSMutableArray arrayWithCapacity:obj.count];
        [obj enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
            WXDataValueModel *model = [WXDataValueModel new];
            model.title = title;
            model.value = values[index][idx];
            [listArray addObject:model];
        }];
        [dataArray addObject:listArray.copy];
    }];
    self.dataArray = dataArray.copy;
}

#pragma mark - TableViewDelegate & TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.dataArray.count - 1) {
        return CGFLOAT_MIN;
    } else if (section == self.dataArray.count - 2) {
        return 50.f;
    }
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == self.dataArray.count - 1) return nil;
    MNTableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.mn.pay.setting.footer.id"];
    if (!footer) {
        footer = [[MNTableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.mn.pay.setting.footer.id"];
        footer.contentView.backgroundColor = VIEW_COLOR;
        footer.titleLabel.frame = CGRectMake(15.f, 0.f, tableView.width_mn - 30.f, 50.f);
        footer.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .4f);
        footer.titleLabel.font = [UIFont systemFontOfSize:14.f];
        footer.titleLabel.text = @"开启后, 转账或消费时, 可使用Touch ID 验证指纹快速完成付款";
        footer.titleLabel.textAlignment = NSTextAlignmentLeft;
        footer.titleLabel.numberOfLines = 0;
    }
    footer.titleLabel.hidden = section != self.dataArray.count - 2;
    return footer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXPaySetingListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.mn.pay.setting.cell.id"];
    if (!cell) {
        cell = [[WXPaySetingListCell alloc] initWithReuseIdentifier:@"com.mn.pay.setting.cell.id" size:tableView.rowSize];
        @weakify(self);
        cell.valueDidChangeHandler = ^(BOOL isOn) {
            @strongify(self);
            [self switchValueDidChange:isOn];
        };
    }
    cell.model = self.dataArray[indexPath.section][indexPath.row];
    return cell;
}

- (void)switchValueDidChange:(BOOL)isOn {
    if (isOn) {
        /// 开启指纹支付
        @weakify(self);
        WXPasswordViewController *vc = [WXPasswordViewController new];
        vc.title = @"开启指纹支付";
        vc.didSucceedHandler = ^(UIViewController *v) {
            @strongify(self);
            [v.navigationController popViewControllerAnimated:YES];
            WXPreference.preference.allowsLocalEvaluation = YES;
            WXDataValueModel *model = [self.dataArray[2] firstObject];
            model.value = @(YES);
            [self.tableView reloadRow:0 inSection:2 withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.navigationController pushViewController:vc animated:YES];
        WXDataValueModel *model = [self.dataArray[2] firstObject];
        model.value = @(NO);
        [self.tableView reloadRow:0 inSection:2 withRowAnimation:UITableViewRowAnimationNone];
    } else {
        /// 关闭指纹支付
        @weakify(self);
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:@"确定暂停指纹支付功能?" actions:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self);
            [self.tableView reloadRow:0 inSection:2 withRowAnimation:UITableViewRowAnimationNone];
        }], [UIAlertAction actionWithTitle:@"暂停使用" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self);
            WXPreference.preference.allowsLocalEvaluation = NO;
            WXDataValueModel *model = [self.dataArray[2] firstObject];
            model.value = @(NO);
            [self.tableView reloadRow:0 inSection:2 withRowAnimation:UITableViewRowAnimationNone];
        }],nil];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        UIViewControllerPush(@"WXAuthViewController", YES);
    } else if (section == 1) {
        if (row == 0) {
            /// 修改密码
            WXPasswordViewController *vc = [WXPasswordViewController new];
            vc.title = @"修改支付密码";
            vc.didSucceedHandler = ^(UIViewController *v) {
                UINavigationController *nav = v.navigationController;
                [nav popViewControllerAnimated:NO];
                WXEditingViewController *vv = [WXEditingViewController new];
                vv.title = @"修改支付密码";
                vv.numberOfLines = 1;
                vv.numberOfWords = 6;
                vv.keyboardType = UIKeyboardTypeNumberPad;
                vv.completionHandler = ^(NSString *result, WXEditingViewController *evc) {
                    if (result.length == 6) {
                        WXPreference.preference.payword = result;
                        [evc.navigationController popViewControllerAnimated:YES];
                    } else {
                        [evc.view showInfoDialog:@"请输入6位支付密码"];
                    }
                };
                [nav pushViewController:vv animated:YES];
            };
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            /// 忘记密码
            MNAlertView *alertView = [MNAlertView alertViewWithTitle:@"支付密码" message:WXPreference.preference.payword handler:nil ensureButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView setButtonTitleColor:TEXT_COLOR ofIndex:0];
            [alertView show];
        }
    }
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
