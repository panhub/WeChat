//
//  WXMineInfoController.m
//  MNChat
//
//  Created by Vincent on 2019/4/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMineInfoController.h"
#import "WXMineInfoListCell.h"
#import "WXDataValueModel.h"
#import "WXMineInfoHeaderView.h"
#import "WXQRCodeViewController.h"
#import "WXEditingViewController.h"
#import "WXMineMoreInfoController.h"

@interface WXMineInfoController ()
@property (nonatomic, strong) WXMineInfoHeaderView *headerView;
@property (nonatomic, strong) NSMutableArray <NSArray <WXDataValueModel *> *>*dataArray;
@end

@implementation WXMineInfoController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"个人信息";
        self.dataArray = [NSMutableArray arrayWithCapacity:2];
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
    
    WXMineInfoHeaderView *headerView = [[WXMineInfoHeaderView alloc] initWithReuseIdentifier:@"com.wx.mine.info.header" frame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 83.f)];
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /// 修改头像
    @weakify(self);
    [self.headerView handTapConfiguration:nil eventHandler:^(id sender) {
        [[MNActionSheet actionSheetWithTitle:@"修改头像" cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == actionSheet.cancelButtonIndex) return;
            MNAssetPicker *picker = [[MNAssetPicker alloc] initWithType:buttonIndex];
            picker.configuration.cropScale = 1.f;
            picker.configuration.maxExportPixel = 100.f;
            picker.configuration.allowsCapturing = NO;
            picker.configuration.allowsEditing = YES;
            picker.configuration.allowsPickingGif = NO;
            picker.configuration.allowsPickingVideo = NO;
            picker.configuration.allowsPickingLivePhoto = NO;
            [picker presentWithPickingHandler:^(MNAssetPicker * _Nonnull picker, NSArray<MNAsset *> * _Nullable assets) {
                if (assets.count <= 0) return;
                @strongify(self);
                UIImage *image = assets.firstObject.content;
                if (image) {
                    [WXUser performReplacingHandler:^(WXUser *userInfo) {
                        [userInfo setValue:image forKey:kPath(userInfo.avatar)];
                        [userInfo setValue:image.PNGData.base64EncodedString forKey:kPath(userInfo.avatarString)];
                    }];
                    [self.headerView updateUserInfo];
                } else {
                    [self.view showInfoDialog:@"获取图片资源出错"];
                }
            } cancelHandler:nil];
        } otherButtonTitles:@"打开相册", @"拍照", nil] show];
    }];
}

- (void)loadData {
    WXUser *user = [WXUser shareInfo];
    NSArray <NSArray <NSString *>*>*titles = @[@[@"名字", @"微信号", @"更多"], @[@"我的二维码"]];
    NSArray <NSArray <NSString *>*>*descs = @[@[@"", user.wechatId, @""], @[@""]];
    [self.dataArray removeAllObjects];
    [titles enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *listArray = [NSMutableArray arrayWithCapacity:obj.count];
        [obj enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger index, BOOL * _Nonnull stop) {
            WXDataValueModel *model = [WXDataValueModel new];
            model.title = titles[idx][index];
            model.desc = descs[idx][index];
            if (idx == 1) model.img = @"wx_mine_qrcode";
            [listArray addObject:model];
        }];
        [self.dataArray addObject:listArray.copy];
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
    if (section == 1) return 15.f;
    return .01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) return nil;
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.mine.info.header"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.mine.info.header"];
        header.clipsToBounds = YES;
        header.contentView.backgroundColor = VIEW_COLOR;
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXMineInfoListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.mine.info.list.cell"];
    if (!cell) {
        cell = [[WXMineInfoListCell alloc] initWithReuseIdentifier:@"com.wx.mine.info.list.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
        cell.type = WXMineInfoTypeDefault;
    }
    WXDataValueModel *model = self.dataArray[indexPath.section][indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataArray.count) return;
    NSArray <WXDataValueModel *>*listArray = self.dataArray[indexPath.section];
    if (indexPath.row >= listArray.count) return;
    if (indexPath.section == 1) {
        /// 二维码
        WXQRCodeViewController *vc = [WXQRCodeViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 2) {
        /// 更多
        WXMineMoreInfoController *vc = [WXMineMoreInfoController new];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        /// 微信号, 昵称等
        NSInteger row = indexPath.row;
        WXEditingViewController *vc = [WXEditingViewController new];
        vc.title = row == 0 ? @"设置名字" : @"设置微信号";
        vc.numberOfWords = 15;
        vc.numberOfLines = 1;
        vc.keyboardType = row == 0 ? UIKeyboardTypeDefault : UIKeyboardTypeNamePhonePad;
        vc.text = row == 0 ? [[WXUser shareInfo] nickname] : [[WXUser shareInfo] wechatId];
        vc.completionHandler = ^(NSString *result, WXEditingViewController *v) {
            NSArray *array = [self.dataArray firstObject];
            WXDataValueModel *model = array[row];
            if ([model.desc isEqualToString:result]) {
                [v.navigationController popViewControllerAnimated:YES];
                return;
            }
            if (row == 0) {
                /// 名字
                if (result.length <= 0) {
                    [v.view showInfoDialog:@"昵称不合法"];
                    return;
                }
                [WXUser performReplacingHandler:^(WXUser *userInfo) {
                    userInfo.nickname = result;
                }];
            } else {
                /// 微信号
                if (result.length < 6) {
                    [v.view showInfoDialog:@"微信号不合法"];
                    return;
                }
                model.desc = result;
                [self reloadList];
                [WXUser performReplacingHandler:^(WXUser *userInfo) {
                    userInfo.wechatId = result;
                }];
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
