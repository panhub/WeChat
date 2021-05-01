//
//  WXAppletViewController.m
//  WeChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAppletViewController.h"
#import "WXAppletResultController.h"
#import "WXSelectCoverController.h"
#import "WXDataValueModel.h"
#import "WXAppletCell.h"
#import "MNAssetExporter.h"

@interface WXAppletViewController ()<UITextFieldDelegate, WXAppletResultDelegate>
@property (nonatomic, strong) NSArray <NSArray <WXDataValueModel *>*>*dataArray;
@end

#define WXLivePhotoControllerName   @"WXSelectCoverController"

@implementation WXAppletViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"小程序";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.view.backgroundColor = VIEW_COLOR;
    self.contentView.backgroundColor = VIEW_COLOR;

    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowView.backgroundColor = SEPARATOR_COLOR;
    self.navigationBar.shadowView.hidden = YES;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 52.f;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    
    [self.searchBar setTitleColor:TEXT_COLOR forState:UIControlStateNormal];
    [self.searchBar setTitleColor:TEXT_COLOR forState:UIControlStateHighlighted];
    self.searchBar.frame = CGRectMake(0.f, 5.f, self.tableView.width_mn, MN_NAV_BAR_HEIGHT);
    @weakify(self);
    self.searchBar.textFieldConfigurationHandler = ^(MNSearchBar *searchBar, MNTextField *textField) {
        @strongify(self);
        textField.delegate = self;
        textField.tintColor = THEME_COLOR;
        textField.frame = CGRectMake(10.f, MEAN(searchBar.height_mn - 35.f), searchBar.width_mn - 20.f, 35.f);
    };
    MNAdsorbView *headerView = [[MNAdsorbView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, self.searchBar.height_mn + 10.f)];
    headerView.imageView.backgroundColor = VIEW_COLOR;
    [headerView.contentView addSubview:self.searchBar];
    self.tableView.tableHeaderView = headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ///
    NSMutableArray <WXDataValueModel *>*dataSource = [NSMutableArray arrayWithCapacity:5];
    [self.dataArray enumerateObjectsUsingBlock:^(NSArray<WXDataValueModel *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dataSource addObjectsFromArray:obj];
    }];
    /// 检索结果展示
    WXAppletResultController *resultController = [[WXAppletResultController alloc] initWithFrame:CGRectMake(0.f, self.navigationBar.height_mn + self.tableView.tableHeaderView.height_mn, self.view.width_mn, self.view.height_mn - MN_STATUS_BAR_HEIGHT - self.searchBar.height_mn)];
    resultController.delegate = self;
    resultController.dataSource = dataSource.copy;
    self.updater = resultController;
    self.searchResultController = resultController;
}

- (void)loadData {
    NSMutableArray <NSString *>*titleArray = @[@"九宫格切图"].mutableCopy;
    NSMutableArray <NSString *>*imageArray = @[@"wx_find_see"].mutableCopy;
    NSMutableArray <NSString *>*valueArray = @[@"WXCropViewController"].mutableCopy;
#if __has_include(<Photos/PHLivePhoto.h>)
    if (@available(iOS 9.1, *)) {
        [titleArray addObject:@"制作LivePhoto"];
        [imageArray addObject:@"wx_find_search"];
        [valueArray addObject:WXLivePhotoControllerName];
    }
#endif
    NSArray <NSArray <NSString *>*>*titles = @[@[@"百达钟表"], @[@"菜谱大全", @"天气查询"], titleArray, @[@"视频去水印"]];
    NSArray <NSArray <NSString *>*>*imgs = @[@[@"wx_find_timeline"], @[@"wx_find_scanning", @"wx_find_shake"], imageArray, @[@"wx_find_shake"]];
    NSArray <NSArray <NSString *>*>*values = @[@[@"WXWatchViewController"], @[@"WXCookViewController", @"WXCityViewController"], valueArray, @[@"WXErasureViewController"]];
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *listArray = [NSMutableArray arrayWithCapacity:obj.count];
        [obj enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger index, BOOL * _Nonnull _stop) {
            WXDataValueModel *model = [WXDataValueModel new];
            model.title = title;
            model.img = imgs[idx][index];
            model.value = values[idx][index];
            [listArray addObject:model];
        }];
        [dataArray addObject:listArray];
    }];
    self.dataArray = dataArray.copy;
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 0 ? .01f : 10.f);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.applet.header"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.wx.applet.header"];
        header.contentView.backgroundColor = VIEW_COLOR;
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXAppletCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.applet.cell"];
    if (!cell) {
        cell = [[WXAppletCell alloc] initWithReuseIdentifier:@"com.wx.applet.cell" size:tableView.rowSize];
    }
    WXDataValueModel *model = self.dataArray[indexPath.section][indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.dataArray.count) return;
    NSArray <WXDataValueModel *>*listArray = self.dataArray[indexPath.section];
    if (indexPath.row >= listArray.count) return;
    WXDataValueModel *model = listArray[indexPath.row];
    [self execute:model];
}

#pragma mark - WXAppletResultDelegate
- (void)appletResultDidSelectModel:(WXDataValueModel *)model {
    [self execute:model];
}

- (void)execute:(WXDataValueModel *)model {
    NSString *value = kTransform(NSString *, model.value);
    if ([value isEqualToString:WXLivePhotoControllerName]) {
        @weakify(self);
        [self selectAsset:^(MNAssetPickConfiguration *configuration) {
            configuration.allowsPickingGif = NO;
            configuration.allowsPickingPhoto = NO;
            configuration.allowsPickingVideo = YES;
            configuration.allowsPickingLivePhoto = NO;
        } resultHandler:^(MNAssetPicker *picker, NSArray<MNAsset *> *assets) {
            @strongify(self);
            WXSelectCoverController *vc = [[WXSelectCoverController alloc] initWithVideoPath:assets.firstObject.content];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    } else {
        Class cls = NSClassFromString(value);
        if (cls) UIViewControllerPush(model.value, YES);
    }
}

- (void)selectAsset:(void(^)(MNAssetPickConfiguration *))configurationHandler resultHandler:(void(^)(MNAssetPicker *, NSArray <MNAsset *>*))resultHandler {
    MNAssetPicker *imagePicker = [[MNAssetPicker alloc] init];
    imagePicker.configuration.maxPickingCount = 1;
    imagePicker.configuration.allowsEditing = NO;
    imagePicker.configuration.allowsTakeAsset = NO;
    imagePicker.configuration.allowsPreviewing = NO;
    if (configurationHandler) configurationHandler(imagePicker.configuration);
    [imagePicker presentWithPickingHandler:resultHandler cancelHandler:nil];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navigationBar.shadowView.hidden = offsetY <= 0.f;
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
