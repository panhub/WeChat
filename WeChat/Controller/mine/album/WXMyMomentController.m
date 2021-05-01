//
//  WXMyMomentController.m
//  WeChat
//
//  Created by Vicent on 2021/4/16.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXMyMomentController.h"
#import "WXPhotoViewController.h"
#import "WXNotifyViewController.h"
#import "WXNewMomentController.h"
#import "WXMyTimelineViewModel.h"
#import "WXMyMomentHeaderView.h"
#import "WXMyMomentSectionHeader.h"
#import "WXAlbumFooterView.h"
#import "MNRefreshFooter.h"
#import "WXAlbumDateView.h"
#import "WXMyMomentCell.h"
#import "WXMoment.h"

#define WXMyMomentObserveKeyPath    @"contentOffset"

@interface WXMyMomentController ()
{
    UIStatusBarStyle WXMyMomentStatusBarStyle;
}
@property (nonatomic, strong) UIImageView *shadowView;
@property (nonatomic, strong) WXAlbumDateView *dateView;
@property (nonatomic, strong) WXAlbumFooterView *footerView;
@property (nonatomic, strong) WXMyTimelineViewModel *viewModel;
@property (nonatomic, strong) WXMyMomentHeaderView *headerView;
@end

@implementation WXMyMomentController
- (instancetype)init {
    return [self initWithUser:WXUser.shareInfo];
}

- (instancetype)initWithUser:(WXUser *)user {
    if (self = [super init]) {
        self.title = @"相册";
        self.viewModel = [[WXMyTimelineViewModel alloc] initWithUser:user];
        [self handEvents];
        [self.viewModel loadToday];
        self.loadMoreEnabled = YES;
        WXMyMomentStatusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.alpha = 0.f;
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[WXAlbumFooterView alloc] initWithFrame:self.tableView.bounds];
    
    [self.tableView addObserver:self forKeyPath:WXMyMomentObserveKeyPath options:NSKeyValueObservingOptionNew context:NULL];
    
    WXMyMomentHeaderView *headerView = [[WXMyMomentHeaderView alloc] initWithFrame:self.tableView.bounds];
    headerView.user = self.viewModel.user;
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
    
    WXAlbumFooterView *footerView = [[WXAlbumFooterView alloc] initWithFrame:self.tableView.bounds];
    self.footerView = footerView;
    
    UIImageView *shadowView = [UIImageView imageViewWithFrame:self.navigationBar.frame image:[[UIImage imageNamed:@"moment_nav_shadow"] stretchableImageWithLeftCapWidth:30.f topCapHeight:20.f]];
    shadowView.userInteractionEnabled = YES;
    shadowView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:shadowView];
    self.shadowView = shadowView;
    
    UIView *leftBarItem = self.navigationBar.leftBarItem;
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarButton.frame = leftBarItem.frame;
    leftBarButton.touchInset = leftBarItem.touchInset;
    [leftBarButton setBackgroundImage:[UIImage imageNamed:@"wx_common_back_white"] forState:UIControlStateNormal];
    [leftBarButton addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [shadowView addSubview:leftBarButton];
    
    UIView *rightBarItem = self.navigationBar.rightBarItem;
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarButton.frame = rightBarItem.frame;
    rightBarButton.hidden = rightBarItem.isHidden;
    rightBarButton.touchInset = rightBarItem.touchInset;
    [rightBarButton setBackgroundImage:[UIImage imageNamed:@"wx_common_more_white"] forState:UIControlStateNormal];
    [rightBarButton addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [shadowView addSubview:rightBarButton];
    
    WXAlbumDateView *dateView = [[WXAlbumDateView alloc] initWithFrame:self.contentView.bounds];
    dateView.alpha = 0.f;
    dateView.top_mn = self.navigationBar.bottom_mn;
    [self.contentView addSubview:dateView];
    self.dateView = dateView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)loadData {
    [self.viewModel loadData];
}

#pragma mark - Hand Events
- (void)handEvents {
    @weakify(self);
    // 刷新表事件
    self.viewModel.reloadTableHandler = ^{
        @strongify(self);
        [UIView performWithoutAnimation:^{
            [self reloadList];
        }];
        if (self.viewModel.dataSource.count && self.dateView.alpha == 0.f) {
            [self updateDateInSection:0 row:0];
        }
    };
    // 加载结束事件
    self.viewModel.didLoadFinishHandler = ^(BOOL hasMore) {
        @strongify(self);
        if (hasMore) {
            [self resetLoadFooter];
            self.tableView.tableFooterView = nil;
        } else {
            [self relieveLoadFooter];
            self.tableView.tableFooterView = self.footerView;
        }
    };
    // 点击事件
    self.viewModel.touchEventHandler = ^(WXMoment * _Nonnull moment) {
        if (moment.isNewMoment) {
            // 新朋友圈
            NSString *s1 = @"拍摄";
            NSString *s2 = @"照片或视频";
            NSString *string = [NSString stringWithFormat:@"%@\n%@", s1, s2];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
            [attributedString addAttribute:NSFontAttributeName value:UIFontWithNameSize(MNFontNameRegular, 17.f) range:[string rangeOfString:s1]];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor.darkTextColor colorWithAlphaComponent:.85f] range:[string rangeOfString:s1]];
            [attributedString addAttribute:NSFontAttributeName value:UIFontWithNameSize(MNFontNameRegular, 12.f) range:[string rangeOfString:s2]];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor.darkGrayColor colorWithAlphaComponent:.7f] range:[string rangeOfString:s2]];
            NSMutableParagraphStyle *style = NSMutableParagraphStyle.new;
            style.alignment = NSTextAlignmentCenter;
            [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:string.rangeOfAll];
            [[MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == actionSheet.cancelButtonIndex) return;
                MNAssetPickerType type = buttonIndex == 0 ? MNAssetPickerTypeCapturing : MNAssetPickerTypeNormal;
                MNAssetPicker *picker = [[MNAssetPicker alloc] initWithType:type];
                picker.configuration.maxPickingCount = 9;
                picker.configuration.maxCaptureDuration = 30.f;
                picker.configuration.allowsMixPicking = NO;
                picker.configuration.allowsPreviewing = NO;
                picker.configuration.allowsPickingGif = YES;
                picker.configuration.allowsPickingVideo = YES;
                picker.configuration.allowsPickingPhoto = YES;
                picker.configuration.allowsResizeVideoSize = NO;
                picker.configuration.allowsPickingLivePhoto = YES;
                picker.configuration.allowsOptimizeExporting = YES;
                picker.configuration.allowsMultiplePickingVideo = NO;
                picker.configuration.requestGifUseingPhotoPolicy = YES;
                picker.configuration.requestLivePhotoUseingPhotoPolicy = YES;
                picker.configuration.allowsEditing = type == MNAssetPickerTypeNormal;
                picker.configuration.exportURL = [NSURL fileURLWithPath:[WechatHelper.helper.momentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", MNFileHandle.fileName]]];
                [picker presentWithPickingHandler:^(MNAssetPicker * _Nonnull picker, NSArray<MNAsset *> * _Nullable assets) {
                    WXNewMomentController *vc = [[WXNewMomentController alloc] initWithAssets:assets];
                    [weakself.navigationController pushViewController:vc animated:YES];
                } cancelHandler:nil];
            } otherButtonTitles:attributedString.copy, @"从手机相册选择", nil] showInView:weakself.view];
        } else if (moment.profiles.count) {
            // 图片
            @strongify(self);
            WXProfile *picture = moment.profiles.firstObject;
            NSMutableArray <WXProfile *>*pictures = @[].mutableCopy;
            [self.viewModel.dataSource enumerateObjectsUsingBlock:^(WXMyMomentYearModel * _Nonnull year, NSUInteger idx, BOOL * _Nonnull stop) {
                [year.dataSource enumerateObjectsUsingBlock:^(WXMyMomentViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.moment.isNewMoment) return;
                    [pictures addObjectsFromArray:obj.moment.profiles];
                    [obj.moment cleanMemory];
                }];
            }];
            WXPhotoViewController *vc = [[WXPhotoViewController alloc] initWithPhotos:pictures startIndex:[pictures indexOfObject:picture]];
            vc.user = self.viewModel.user;
            vc.backgroundImage = [self.view snapshotImage];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            // 详情
        }
    };
}

#pragma mark - UITableViewDataSource&UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataSource[section].dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //CGFloat s = self.viewModel.dataSource[indexPath.section].dataSource[indexPath.row].rowHeight;
    return self.viewModel.dataSource[indexPath.section].dataSource[indexPath.row].rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    WXMyMomentYearModel *viewModel = self.viewModel.dataSource[section];
    return viewModel.headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WXMyMomentYearModel *viewModel = self.viewModel.dataSource[section];
    if (viewModel.headerHeight <= 0.f) return nil;
    WXMyMomentSectionHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.my.album.header"];
    if (!header) {
        header = [[WXMyMomentSectionHeader alloc] initWithReuseIdentifier:@"com.wx.my.album.header"];
    }
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(WXMyMomentSectionHeader *)view forSection:(NSInteger)section {
    view.viewModel = self.viewModel.dataSource[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXMyMomentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.my.album.cell"];
    if (!cell) {
        cell = [[WXMyMomentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"com.wx.my.album.cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXMyMomentCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.viewModel = self.viewModel.dataSource[indexPath.section].dataSource[indexPath.row];
}

#pragma mark - Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.tableView && [keyPath isEqualToString:WXMyMomentObserveKeyPath]) {
        
        CGFloat offsetY = [change[NSKeyValueChangeNewKey] CGPointValue].y;
        
        // 导航显示
        CGFloat alpha = (self.headerView ? (offsetY >= self.headerView.offsetY ? 1.f : 0.f) : 0.f);
        if (self.navigationBar.alpha != alpha) {
            UIStatusBarStyle statusBarStyle = UIStatusBarStyleLightContent;
            if (alpha == 1.f) {
                statusBarStyle = UIStatusBarStyleDefault;
    #ifdef __IPHONE_13_0
                if (@available(iOS 13.0, *)) {
                    statusBarStyle = UIStatusBarStyleDarkContent;
                }
    #endif
            }
            WXMyMomentStatusBarStyle = statusBarStyle;
            [UIApplication.sharedApplication setStatusBarStyle:statusBarStyle animated:YES];
            [UIView animateWithDuration:.3f animations:^{
                self.navigationBar.alpha = alpha;
                self.shadowView.alpha = (1.f - alpha);
            }];
        }
        
        // 日期显示
        CGFloat height = self.tableView.tableHeaderView.height_mn;
        if (self.viewModel.dataSource.count) {
            WXMyMomentYearModel *vm = self.viewModel.dataSource.firstObject;
            if (vm.dataSource.firstObject.moment.isNewMoment) {
                height += (vm.headerHeight + vm.dataSource.firstObject.rowHeight);
            }
        }
        height -= (self.navigationBar.height_mn + self.dateView.height_mn + 5.f);
        alpha = offsetY >= height ? 1.f : 0.f;
        if (self.dateView.alpha != alpha) {
            [UIView animateWithDuration:.2f animations:^{
                self.dateView.alpha = alpha;
            }];
        }
        
        // 日期更新
        if (self.dateView.alpha == 1.f) {
            for (UITableViewCell *cell in self.tableView.visibleCells) {
                NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
                rect = [self.tableView convertRect:rect toView:self.contentView];
                if (CGRectContainsPoint(rect, CGPointMake(self.dateView.width_mn/2.f, self.dateView.bottom_mn))) {
                    [self updateDateInSection:indexPath.section row:indexPath.row];
                }
            }
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Update
- (void)updateDateInSection:(NSInteger)section row:(NSInteger)row {
    WXMyMomentYearModel *yvm = self.viewModel.dataSource[section];
    WXMyMomentViewModel *mvm = yvm.dataSource[row];
    self.dateView.date = [yvm.year stringByAppendingFormat:@"/%@/%@", mvm.month, mvm.day];
}

#pragma mark - Navigation
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIControl *leftBarItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, kNavItemSize, kNavItemSize)];
    leftBarItem.touchInset = UIEdgeInsetWith(-5.f);
    leftBarItem.backgroundImage = [UIImage imageNamed:@"wx_common_back_black"];
    [leftBarItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftBarItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIControl *rightBarItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, kNavItemSize, kNavItemSize)];
    rightBarItem.touchInset = UIEdgeInsetWith(-5.f);
    rightBarItem.backgroundImage = [UIImage imageNamed:@"wx_common_more_black"];
    rightBarItem.hidden = ![self.viewModel.user.uid isEqualToString:WXUser.shareInfo.uid];
    [rightBarItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightBarItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    @weakify(self);
    [[MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        @strongify(self);
        if (buttonIndex == actionSheet.cancelButtonIndex) return;
        WXNotifyViewController *vc = WXNotifyViewController.new;
        [self.navigationController pushViewController:vc animated:YES];
    } otherButtonTitles:@"消息列表", nil] showInView:self.view];
}

#pragma mark - Super
- (UIView *)loadFooter {
    return [[MNRefreshFooter alloc] initWithType:MNRefreshFooterTypeMargin];
}

- (void)beginLoadMore {
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself.viewModel loadData];
    });
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return WXMyMomentStatusBarStyle;
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

#pragma mark - dealloc
- (void)dealloc {
    [self.tableView removeObserver:self forKeyPath:WXMyMomentObserveKeyPath];
}

@end
