//
//  WXAboutViewController.m
//  MNChat
//
//  Created by Vincent on 2019/7/22.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAboutViewController.h"
#import "WXAboutHeaderView.h"
#import "WXAboutListCell.h"
#import "WXDataValueModel.h"

@interface WXAboutViewController ()
@property (nonatomic, strong) NSArray <WXDataValueModel *> *dataArray;
@end

@implementation WXAboutViewController
- (void)createView {
    [super createView];
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationBar.shadowColor = [UIColor whiteColor];
    
    self.tableView.frame = CGRectMake(40.f, 0.f, self.contentView.width_mn - 80.f, self.contentView.height_mn);
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.rowHeight = 55.f;
    
    WXAboutHeaderView *headerView = [[WXAboutHeaderView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 0.f)];
    self.tableView.tableHeaderView = headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadData {
    NSArray <NSString *>*titles = @[@"去评分", @"功能介绍", @"投诉", @"版本更新"];
    NSMutableArray <WXDataValueModel *>*dataArray = [NSMutableArray arrayWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXDataValueModel *model = [WXDataValueModel new];
        model.title = obj;
        [dataArray addObject:model];
    }];
    self.dataArray = dataArray.copy;
}

#pragma mark - UITableViewDataDelegate&Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXAboutListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.mn.about.cell"];
    if (!cell) {
        cell = [[WXAboutListCell alloc] initWithReuseIdentifier:@"com.mn.about.cell" size:tableView.rowSize];
    }
    WXDataValueModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        /// 评分
        [UIApplication handOpenProductScore:AppleID type:AppStoreLoadInlay completion:^(BOOL succeed) {
            
        }];
    } else if (indexPath.row == 1) {
        /// 功能介绍
        [UIApplication handOpenProduct:AppleID type:AppStoreLoadOpen completion:^(BOOL succeed) {
            
        }];
    } else if (indexPath.row == 2) {
        /// 投诉
    } else {
        /// 版本更新
        [self.view showWechatDialog];
        [MNAppRequest requestContent:AppleID timeoutInterval:10.f completion:^(NSString * _Nullable version, NSDictionary * _Nullable result, NSError * _Nullable error) {
            [self.view closeDialog];
            if (error) {
                [[MNAlertView alertViewWithTitle:nil message:@"获取版本信息失败!" handler:nil ensureButtonTitle:@"确定" otherButtonTitles:nil] show];
            } else {
                [[MNAlertView alertViewWithTitle:nil message:@"当前已是最新版本!" handler:nil ensureButtonTitle:@"确定" otherButtonTitles:nil] show];
            }
        }];
    }
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
