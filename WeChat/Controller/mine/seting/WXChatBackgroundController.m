//
//  WXChatBackgroundController.m
//  MNChat
//
//  Created by Vincent on 2019/7/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChatBackgroundController.h"
#import "WXDataValueModel.h"
#import "WXSetingListCell.h"

@interface WXChatBackgroundController ()
@property (nonatomic, strong) NSArray <NSArray <WXDataValueModel *> *>*dataArray;
@end

@implementation WXChatBackgroundController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"聊天背景";
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
    NSArray <NSArray <NSString *>*>*titles = @[@[@"选择背景图"], @[@"从手机相册选择", @"拍一张"], @[@"将背景应用到所有聊天场景"]];
    NSMutableArray <NSArray *>*dataArray = [NSMutableArray arrayWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isLast = idx == titles.count - 1;
        NSMutableArray <WXDataValueModel *>*listArray = [NSMutableArray arrayWithCapacity:obj.count];
        [obj enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger index, BOOL * _Nonnull stop) {
            WXDataValueModel *model = [WXDataValueModel new];
            model.title = title;
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
    return 8.f;
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
        UIViewControllerPush(@"WXSelectBackgroundController", YES);
    } else if (indexPath.section == 1) {
        MNAssetPicker *picker = [[MNAssetPicker alloc] initWithType:indexPath.row];
        picker.configuration.maxExportPixel = 0.f;
        picker.configuration.allowsTakeAsset = NO;
        picker.configuration.allowsEditing = NO;
        picker.configuration.allowsPickingGif = NO;
        picker.configuration.allowsPickingVideo = NO;
        picker.configuration.allowsPickingLivePhoto = NO;
        [picker presentWithPickingHandler:^(MNAssetPicker * _Nonnull picker, NSArray<MNAsset *> * _Nullable assets) {
            if (assets.count <= 0) return;
            [self handSaveChatBackgroundImage:assets.firstObject.content];
        } cancelHandler:nil];
    }
}

- (void)handSaveChatBackgroundImage:(UIImage *)image {
    image = [image resizingToPix:1000];
    BOOL succeed = NO;
    if (image) {
        succeed = YES;
        [[NSUserDefaults standardUserDefaults] setImage:image forKey:WXChatBackgroundKey];
    }
    [MNAlertView showAlertWithTitle:nil message:(succeed ? @"设置聊天背景成功" : @"操作失败") cancelButtonTitle:@"确定"];
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
