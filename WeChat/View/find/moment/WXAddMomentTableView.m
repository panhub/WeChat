//
//  WXAddMomentTableView.m
//  MNChat
//
//  Created by Vincent on 2019/5/10.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAddMomentTableView.h"
#import "WXDataValueModel.h"
#import "WXAddMomentTableViewCell.h"
#import "WXContactsSelectController.h"
#import "WXLocationViewController.h"
#import "WXMapLocation.h"
#import "MNDatePicker.h"

@interface WXAddMomentTableView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <WXDataValueModel *>*dataSource;
@end

@implementation WXAddMomentTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame]) {
        
        [self loadData];
        
        UITableView *tableView = [UITableView tableWithFrame:self.bounds style:UITableViewStyleGrouped];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        tableView.rowHeight = 55.f;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.scrollEnabled = NO;
        tableView.scrollsToTop = NO;
        tableView.separatorColor = VIEW_COLOR;
        [self addSubview:tableView];
        self.tableView = tableView;
        
        self.height_mn = self.dataSource.count*tableView.rowHeight;
    }
    return self;
}

- (void)loadData {
    [self.dataSource removeAllObjects];
    WXDataValueModel *model0 = [WXDataValueModel new];
    model0.img = self.viewModel.location.length > 0 ? @"wx_moment_add_locationHL" : @"wx_moment_add_location";
    model0.title = @"所在位置";
    model0.desc = self.viewModel.location;
    model0.userInfo = @(WXAddMomentTableViewCellTypeLocation);
    [self.dataSource addObject:model0];
    WXDataValueModel *model1 = [WXDataValueModel new];
    model1.img = @"wx_moment_add_user";
    model1.title = @"谁可以看";
    model1.desc = @"公开";
    model1.userInfo = @(WXAddMomentTableViewCellTypeNormal);
    [self.dataSource addObject:model1];
    WXDataValueModel *model2 = [WXDataValueModel new];
    model2.img = @"wx_moment_add_ owner";
    model2.title = @"发布者";
    model2.desc = @"";
    model2.value = self.viewModel.owner.avatar;
    model2.userInfo = @(WXAddMomentTableViewCellTypeImage);
    [self.dataSource addObject:model2];
    WXDataValueModel *model3 = [WXDataValueModel new];
    model3.img = @"wx_moment_add_time";
    model3.title = @"发布时间";
    model3.desc = [WechatHelper momentCreatedTimeWithTimestamp:self.viewModel.timestamp];
    model3.userInfo = @(WXAddMomentTableViewCellTypeNormal);
    [self.dataSource addObject:model3];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXAddMomentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.add.moment.table.view.cell.id"];
    if (!cell) {
        cell = [[WXAddMomentTableViewCell alloc] initWithReuseIdentifier:@"com.add.moment.table.view.cell.id" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
    }
    cell.model = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [UIWindow endEditing:YES];
    if (indexPath.row == 0) {
        /// 位置
        WXLocationViewController *vc = [WXLocationViewController new];
        @weakify(self);
        vc.didSelectHandler = ^(WXMapLocation *location) {
            @strongify(self);
            NSString *string = [NSString replacingEmptyCharacters:location.name];
            if (string.length > 0 && location.address.length > 0) string = [string stringByAppendingString:[NSString stringWithFormat:@"·%@", location.address]];
            self.viewModel.location = string;
            self.viewModel.point = location;
            WXDataValueModel *model = self.dataSource[0];
            model.desc = string;
            model.img = string.length > 0 ? @"wx_moment_add_locationHL" : @"wx_moment_add_location";
            [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.viewController.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 1) {
        /// 隐私
        @weakify(self);
        [[MNActionSheet actionSheetWithTitle:@"" cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == actionSheet.cancelButtonIndex) return;
            @strongify(self);
            self.viewModel.privacy = buttonIndex;
            WXDataValueModel *model = self.dataSource[1];
            model.desc = buttonIndex ? @"部分人可见" : @"公开";
            [self.tableView reloadRow:1 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        } otherButtonTitles:@"公开", @"部分人可见", nil] showInView:self.viewController.view];
    } else if (indexPath.row == 2) {
        /// 选择发布者
        @weakify(self);
        WXContactsSelectController *viewController = [[WXContactsSelectController alloc] initWithSelectedHandler:^(UIViewController *vc, NSArray <WXUser *>*users) {
            @strongify(self);
            [vc.navigationController popViewControllerAnimated:YES];
            self.viewModel.owner = users.firstObject;
            WXDataValueModel *model = self.dataSource[2];
            model.value = users.firstObject.avatar;
            [self.tableView reloadRow:2 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.viewController.navigationController pushViewController:viewController animated:YES];
    } else {
        /// 选择时间
        [[MNDatePicker datePickerWithHandler:^(MNDatePicker *datePicker) {
            if (datePicker.type == MNDatePickerTypeCancel) return;
            if (datePicker.type == MNDatePickerTypeNow) {
                self.viewModel.timestamp = [NSDate timestamps];
            } else {
                NSUInteger interval = [datePicker.date timeIntervalSince1970];
                self.viewModel.timestamp = NSStringFromNumber(@(interval));
            }
            WXDataValueModel *model = self.dataSource[3];
            model.desc = [WechatHelper momentCreatedTimeWithTimestamp:self.viewModel.timestamp];
            [self.tableView reloadRow:3 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }] show];
    }
}

#pragma mark - Getter
- (WXAddMomentTableViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [WXAddMomentTableViewModel new];
    }
    return _viewModel;
}

- (NSMutableArray <WXDataValueModel *>*)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:4];
    }
    return _dataSource;
}

@end
