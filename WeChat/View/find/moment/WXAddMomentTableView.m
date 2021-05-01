//
//  WXAddMomentTableView.m
//  WeChat
//
//  Created by Vincent on 2019/5/10.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAddMomentTableView.h"
#import "WXDataValueModel.h"
#import "WXAddMomentTableViewCell.h"
#import "WXContactsSelectController.h"
#import "WXLocationViewController.h"
#import "WXLocation.h"
#import "WXDatePicker.h"

@interface WXAddMomentTableView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <WXDataValueModel *>*dataSource;
@end

@implementation WXAddMomentTableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.user = WXUser.shareInfo;
        self.timestamp = NSDate.timestamps;
        
        self.dataSource = @[].mutableCopy;
        
        WXDataValueModel *model0 = [WXDataValueModel new];
        model0.img = @"wx_moment_add_location";
        model0.title = @"所在位置";
        model0.desc = @"";
        model0.userInfo = @(WXAddMomentTableViewCellTypeLocation);
        [self.dataSource addObject:model0];
        WXDataValueModel *model1 = [WXDataValueModel new];
        model1.img = @"wx_moment_add_user";
        model1.title = @"谁可以看";
        model1.desc = @"公开";
        model1.userInfo = @(WXAddMomentTableViewCellTypeNormal);
        [self.dataSource addObject:model1];
        WXDataValueModel *model2 = [WXDataValueModel new];
        model2.img = @"wx_moment_add_owner";
        model2.title = @"发布者";
        model2.desc = @"";
        model2.value = self.user.avatar;
        model2.userInfo = @(WXAddMomentTableViewCellTypeImage);
        [self.dataSource addObject:model2];
        
        
        WXDataValueModel *model3 = [WXDataValueModel new];
        model3.img = @"wx_moment_add_time";
        model3.title = @"发布时间";
        model3.desc = [WechatHelper momentTimeWithTimestamp:self.timestamp];
        model3.userInfo = @(WXAddMomentTableViewCellTypeNormal);
        [self.dataSource addObject:model3];
        
        
        UITableView *tableView = [UITableView tableWithFrame:self.bounds style:UITableViewStylePlain];
        tableView.rowHeight = 56.f;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.bounces = NO;
        tableView.scrollEnabled = NO;
        tableView.scrollsToTop = NO;
        tableView.separatorColor = [VIEW_COLOR colorWithAlphaComponent:.88f];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.autoresizingMask = UIViewAutoresizingNone;
        [self addSubview:tableView];
        self.tableView = tableView;
        
        [tableView reloadData];
        [tableView setNeedsLayout];
        [tableView layoutIfNeeded];
        
        tableView.height_mn = tableView.contentSize.height;
        
        self.height_mn = tableView.height_mn;
    }
    return self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXAddMomentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.add.moment.table.view.cell.id"];
    if (!cell) {
        cell = [[WXAddMomentTableViewCell alloc] initWithReuseIdentifier:@"com.add.moment.table.view.cell.id" size:tableView.rowSize];
        cell.bottomSeparatorInset = UIEdgeInsetsZero;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXAddMomentTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.model = self.dataSource[indexPath.row];
    cell.topSeparatorInset = indexPath.row == 0 ? cell.bottomSeparatorInset : UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.contentView.width_mn);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.superview endEditing:YES];
    if (indexPath.row == 0) {
        /// 位置
        WXLocationViewController *vc = [WXLocationViewController new];
        @weakify(self);
        vc.didSelectHandler = ^(WXLocation *location) {
            @strongify(self);
            self.location = location;
            WXDataValueModel *model = self.dataSource.firstObject;
            model.desc = location ? location.debugDescription : @"";
            model.img = model.desc.length > 0 ? @"wx_moment_add_locationHL" : @"wx_moment_add_location";
            [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.viewController.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 1) {
        /// 隐私
        @weakify(self);
        [[MNActionSheet actionSheetWithTitle:@"" cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == actionSheet.cancelButtonIndex) return;
            @strongify(self);
            self.privacy = buttonIndex;
            WXDataValueModel *model = self.dataSource[1];
            model.desc = buttonIndex ? @"部分人可见" : @"公开";
            [self.tableView reloadRow:1 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        } otherButtonTitles:@"公开", @"部分人可见", nil] showInView:self.viewController.view];
    } else if (indexPath.row == 2) {
        /// 选择发布者
        @weakify(self);
        WXContactsSelectController *viewController = [[WXContactsSelectController alloc] initWithSelectedHandler:^(WXContactsSelectController *vc) {
            @strongify(self);
            [vc.navigationController popViewControllerAnimated:YES];
            self.user = vc.users.firstObject;
            WXDataValueModel *model = self.dataSource[2];
            model.value = vc.users.firstObject.avatar;
            [self.tableView reloadRow:2 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.viewController.navigationController pushViewController:viewController animated:YES];
    } else {
        /// 选择时间
        __weak typeof(self) weakself = self;
        [[[WXDatePicker alloc] initWithPickHandler:^(NSDate * _Nonnull date) {
            weakself.timestamp = [NSNumber numberWithInteger:date.timeIntervalSince1970].stringValue;
            WXDataValueModel *model = weakself.dataSource[3];
            model.desc = [WechatHelper momentTimeWithTimestamp:weakself.timestamp];
            [weakself.tableView reloadRow:3 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }] show];
    }
}

@end
