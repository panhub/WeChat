//
//  WXMineMoreInfoController.m
//  WeChat
//
//  Created by Vincent on 2019/5/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMineMoreInfoController.h"
#import "WXEditingViewController.h"
#import "WXDataValueModel.h"
#import "WXMineInfoListCell.h"

@interface WXMineMoreInfoController ()
@property (nonatomic, strong) NSMutableArray <WXDataValueModel *>*dataArray;
@end

@implementation WXMineMoreInfoController
- (instancetype)init {
    if (self = [super init]) {
        self.dataArray = [NSMutableArray arrayWithCapacity:3];
    }
    return self;
}
- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowView.backgroundColor = VIEW_COLOR;
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
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
    WXUser *user = WXUser.shareInfo;
    NSString *gender = @"";
    if (user.gender == WechatGenderUnknown) {
        gender = @"保密";
    } else {
        gender = user.gender == WechatGenderMale ? @"男" : @"女";
    }
    NSArray <NSString *>*titles = @[@"性别", @"地区", @"个性签名"];
    NSArray <NSString *>*descs = @[gender , [NSString replacingEmptyCharacters:user.location withCharacters:@""], [NSString replacingEmptyCharacters:user.signature withCharacters:@""]];
    [self.dataArray removeAllObjects];
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        WXDataValueModel *model = [WXDataValueModel new];
        model.title = title;
        model.desc = descs[idx];
        [self.dataArray addObject:model];
    }];
    @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
}

#pragma mark - UITableViewDataDelegate&Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXMineInfoListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.mine.more.info.list.cell"];
    if (!cell) {
        cell = [[WXMineInfoListCell alloc] initWithReuseIdentifier:@"com.wx.mine.more.info.list.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
        cell.type = WXMineInfoTypeMore;
    }
    WXDataValueModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row == 0) {
        /// 性别
        @weakify(self);
        [[MNActionSheet actionSheetWithTitle:@"选择性别" cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == actionSheet.cancelButtonIndex) return;
            @strongify(self);
            WXDataValueModel *model = self.dataArray[row];
            model.desc = [actionSheet buttonTitleOfIndex:buttonIndex];
            [WXUser performReplacingHandler:^(WXUser *userInfo) {
                if (buttonIndex == 2) {
                    userInfo.gender = WechatGenderUnknown;
                } else {
                    userInfo.gender = buttonIndex ? WechatGenderFemale : WechatGenderMale;
                }
            }];
            [self.tableView reloadRow:row inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        } otherButtonTitles:@"男", @"女", @"保密", nil] show];
    } else if (row == 1) {
        /// 地区
        @weakify(self);
        [MNCityPicker.new showInView:self.view selectHandler:^(MNCityPicker *picker) {
            @strongify(self);
            WXDataValueModel *model = self.dataArray[row];
            model.desc = [NSString stringWithFormat:@"%@ %@", picker.province, picker.city];
            [WXUser performReplacingHandler:^(WXUser *userInfo) {
                userInfo.location = model.desc;
            }];
            [self.tableView reloadRow:row inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }];
    } else {
        /// 个性签名
        WXEditingViewController *vc = [WXEditingViewController new];
        vc.title = @"设置个性签名";
        vc.numberOfLines = 0;
        vc.numberOfWords = 30;
        vc.text = WXUser.shareInfo.signature;
        vc.completionHandler = ^(NSString *result, WXEditingViewController *v) {
            [v.navigationController popViewControllerAnimated:YES];
            WXDataValueModel *model = self.dataArray[row];
            if ([model.desc isEqualToString:result]) return;
            model.desc = result;
            [WXUser performReplacingHandler:^(WXUser *userInfo) {
                userInfo.signature = result;
            }];
            [self.tableView reloadRow:row inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
