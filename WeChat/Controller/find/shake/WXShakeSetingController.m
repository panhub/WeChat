//
//  WXShakeSetingController.m
//  MNChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXShakeSetingController.h"
#import "WXDataValueModel.h"
#import "WXShakeSetingCell.h"

@interface WXShakeSetingController ()
@property (nonatomic, strong) NSArray <NSArray <WXDataValueModel *>*>*dataArray;
@end

@implementation WXShakeSetingController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"摇一摇设置";
    }
    return self;
}

- (void)createView {
    [super createView];
    // 创建视图
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowColor = VIEW_COLOR;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.rowHeight = 52.f;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)loadData {
    WXDataValueModel *model0 = [WXDataValueModel new];
    model0.title = @"使用默认背景图片";
    model0.value = @"0";
    model0.desc = @"1";
    model0.userInfo = @"1";
    WXDataValueModel *model1 = [WXDataValueModel new];
    model1.title = @"换张背景图片";
    model1.value = @"0";
    model1.desc = @"0";
    model1.userInfo = @"1";
    WXDataValueModel *model2 = [WXDataValueModel new];
    model2.title = @"音效";
    model2.value = NSStringFromNumber(@(WXPreference.preference.isAllowsShakeSound));
    model2.desc = @"1";
    model2.userInfo = @"0";
    WXDataValueModel *model3 = [WXDataValueModel new];
    model3.title = @"摇到的历史";
    model3.value = @"0";
    model3.desc = @"1";
    model3.userInfo = @"1";
    self.dataArray = @[@[model0, model1, model2], @[model3]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDataDelegate&Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? .01f : 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.shake.seting.header"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.shake.seting.header"];
        header.contentView.backgroundColor = VIEW_COLOR;
        header.clipsToBounds = YES;
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXShakeSetingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.shake.seting.cell"];
    if (!cell) {
        cell = [[WXShakeSetingCell alloc] initWithReuseIdentifier:@"com.wx.shake.seting.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
        cell.valueChangedHandler = ^(BOOL isOn) {
            WXPreference.preference.allowsShakeSound = isOn;
        };
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXShakeSetingCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.model = self.dataArray[indexPath.section][indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UIViewControllerPush(@"WXShakeHistoryController", YES);
    } else if (indexPath.row == 0) {
        WXPreference.preference.shakeBackgroundImage = nil;
        [[MNAlertView alertViewWithTitle:nil
                                 message:@"已恢复默认背景图"
                                 handler:nil
                       ensureButtonTitle:@"确定"
                       otherButtonTitles:nil] show];
    } else if (indexPath.row == 1) {
        MNAssetPicker *picker = MNAssetPicker.new;
        picker.configuration.allowsCapturing = YES;
        picker.configuration.allowsMixPicking = NO;
        picker.configuration.allowsAutoDismiss = YES;
        picker.configuration.allowsPickingPhoto = YES;
        picker.configuration.allowsPickingVideo = NO;
        picker.configuration.requestGifUseingPhotoPolicy = YES;
        picker.configuration.requestLivePhotoUseingPhotoPolicy = YES;
        picker.configuration.allowsEditing = YES;
        picker.configuration.cropScale = 1.45f;
        @weakify(self);
        [picker presentWithPickingHandler:^(NSArray<MNAsset *> *assets) {
            @strongify(self);
            UIImage *image = assets.firstObject.content;
            if (image) {
                WXPreference.preference.shakeBackgroundImage = image;
            } else {
                [self.view showInfoDialog:@"资源错误"];
            }
        } cancelHandler:nil];
    }
}

#pragma mark - Overwrite
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
