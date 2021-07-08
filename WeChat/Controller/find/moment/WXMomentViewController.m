//
//  WXMomentViewController.m
//  WeChat
//
//  Created by Vincent on 2019/4/27.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentViewController.h"
#import "WXNewMomentController.h"
#import "WXContactsSelectController.h"
#import "WXUserViewController.h"
#import "WXMapViewController.h"
#import "WXNotifyViewController.h"
#import "WXTimelineViewModel.h"
#import "WXMomentReplyViewModel.h"
#import "WXMomentProfileView.h"
#import "WXMomentHeaderView.h"
#import "WXMomentFooterView.h"
#import "WXMomentContentCell.h"
#import "WXMomentInputView.h"
#import "WXMomentBrowser.h"
#import "WXContactsSelectController.h"
#import "WXMomentCommentViewModel.h"
#import "WXMomentRefreshView.h"

#define WXMomentObserveKeyPath    @"contentOffset"

@interface WXMomentViewController ()
{
    UIStatusBarStyle WXMomentStatusBarStyle;
}
@property (nonatomic, strong) UIImageView *shadowView;
@property (nonatomic, strong) WXTimelineViewModel *viewModel;
@property (nonatomic, strong) WXMomentInputView *commentBar;
@property (nonatomic, strong) WXMomentProfileView *headerView;
@property (nonatomic, strong) WXMomentRefreshView *refreshView;
@end

@implementation WXMomentViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"朋友圈";
        self.viewModel = [WXTimelineViewModel new];
        WXMomentStatusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.alpha = 0.f;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.alwaysBounceVertical = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, MN_TAB_SAFE_HEIGHT)];
    
    [self.tableView addObserver:self forKeyPath:WXMomentObserveKeyPath options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
    
    WXMomentProfileView *headerView = [[WXMomentProfileView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 0.f)];
    [headerView bindViewModel:self.viewModel];
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
    
    /// 编辑框
    WXMomentInputView *commentBar = [[WXMomentInputView alloc] init];
    [self.view addSubview:commentBar];
    self.commentBar = commentBar;
    
    // 导航
    UIImageView *shadowView = [UIImageView imageViewWithFrame:self.navigationBar.frame image:[[UIImage imageNamed:@"moment_nav_shadow"] stretchableImageWithLeftCapWidth:30.f topCapHeight:20.f]];
    shadowView.userInteractionEnabled = YES;
    shadowView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:shadowView];
    self.shadowView = shadowView;
    
    UIView *leftBarItem = self.navigationBar.leftBarItem;
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarButton.frame = leftBarItem.frame;
    leftBarButton.touchInset = leftBarItem.touchInset;
    [leftBarButton setBackgroundImage:UIImageNamed(@"wx_common_back_white") forState:UIControlStateNormal];
    [leftBarButton addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [shadowView addSubview:leftBarButton];
    
    UIView *rightBarItem = self.navigationBar.rightBarItem;
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarButton.frame = rightBarItem.frame;
    rightBarButton.touchInset = rightBarItem.touchInset;
    [rightBarButton setBackgroundImage:UIImageNamed(@"wx_moment_camera_white") forState:UIControlStateNormal];
    [rightBarButton addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [shadowView addSubview:rightBarButton];
    
    WXMomentRefreshView *refreshView = WXMomentRefreshView.new;
    [refreshView observeScrollView:self.tableView];
    [refreshView setTarget:self forRefreshAction:@selector(refresh)];
    [self.view addSubview:refreshView];
    self.refreshView = refreshView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //// 事件处理
    [self handEvents];
}

- (void)willFinishTransitionAnimation {
    [super willFinishTransitionAnimation];
    self.commentBar.userInteractionEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.headerView updateUserInfo];
    self.commentBar.userInteractionEnabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view bringSubviewToFront:self.refreshView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.commentBar.userInteractionEnabled = NO;
}

#pragma mark - HandEvents
- (void)handEvents {
    @weakify(self);
    /// 刷新列表
    self.viewModel.reloadTableHandler = ^{
        [UIView performWithoutAnimation:^{
            @strongify(self);
            @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
        }];
    };
    
    /// 加载结束
    self.viewModel.didLoadFinishHandler = ^(BOOL hasMore) {
        @strongify(self);
        if (hasMore) {
            [self resetLoadFooter];
        } else {
            [self removeLoadFooter];
        }
        [self.refreshView endRefreshing];
    };
    
    /// 滑动到顶部
    self.viewModel.scrollToTopHandler = ^(BOOL animated) {
        @strongify(self);
        [self.tableView scrollToTopWithAnimated:animated];
    };
    
    /// 刷新区事件
    self.viewModel.reloadMomentEventHandler = ^(WXMomentViewModel *viewModel, BOOL animated) {
        @strongify(self);
        if ([self.viewModel.dataSource containsObject:viewModel]) {
            NSInteger index = [self.viewModel.dataSource indexOfObject:viewModel];
            if (animated) {
                [self.tableView reloadSection:index withRowAnimation:UITableViewRowAnimationNone];
            } else {
                [UIView performWithoutAnimation:^{
                    [self.tableView reloadSection:index withRowAnimation:UITableViewRowAnimationNone];
                }];
            }
        }
    };
    
    /// 刷新表头事件
    self.viewModel.reloadProfileHandler = ^{
        @strongify(self);
        UIView *headerView = self.tableView.tableHeaderView;
        self.tableView.tableHeaderView = headerView;
    };
    
    /// 刷新提醒事项
    self.viewModel.notifyViewEventHandler = ^{
        WXNotifyViewController *vc = [[WXNotifyViewController alloc] init];
        vc.didDeleteNotifyHandler = ^{
            @strongify(self);
            if (self.viewModel.reloadNotifyHandler) {
                self.viewModel.reloadNotifyHandler();
            }
        };
        [weakself.navigationController pushViewController:vc animated:YES];
    };
    
    /// 赞/评论
    self.viewModel.moreViewEventHandler = ^(WXMomentViewModel *viewModel, NSUInteger idx) {
        @strongify(self);
        if (!viewModel || ![self.viewModel.dataSource containsObject:viewModel]) return;
        if (idx == 0) {
            // 点赞
            [viewModel updateLike];
        } else {
            // 评论
            NSInteger section = [self.viewModel.dataSource indexOfObject:viewModel];
            [self replyFrom:WXUser.shareInfo to:nil withIndexPath:[NSIndexPath indexPathForRow:NSIntegerMin inSection:section]];
        }
    };
    
    /// 删除事件
    self.viewModel.deleteButtonEventHandler = ^(WXMomentViewModel *viewModel) {
        MNActionSheet *actionSheet = [MNActionSheet actionSheetWithTitle:@"确定删除朋友圈?" cancelButtonTitle:@"取消" handler:^(MNActionSheet *sheet, NSInteger buttonIndex) {
            if (buttonIndex == sheet.cancelButtonIndex) return;
            [weakself.view showWechatDialogDelay:.3f eventHandler:^{
                @strongify(self);
                [self.viewModel deleteMomentViewModel:viewModel];
            } completionHandler:nil];
        } otherButtonTitles:@"删除", nil];
        actionSheet.buttonTitleColor = BADGE_COLOR;
        [actionSheet show];
    };
    
    /// 分享视图点击事件
    self.viewModel.webViewEventHandler = ^(WXMomentViewModel *viewModel) {
        @strongify(self);
        MNWebViewController *vc = [[MNWebViewController alloc] initWithUrl:viewModel.moment.webpage.url];
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    /// 配图点击事件
    self.viewModel.pictureViewEventHandler = ^(WXMomentViewModel *viewModel, NSArray<MNAsset *> *assets, NSInteger index) {
        @strongify(self);
        [UIWindow endEditing:YES];
        WXMomentBrowser *browser = [[WXMomentBrowser alloc] initWithViewModel:viewModel];
        browser.assets = assets;
        browser.allowsAutoPlaying = YES;
        browser.backgroundColor = UIColor.blackColor;
        [browser presentInView:self.view fromIndex:index animated:YES completion:nil];
    };
    
    /// 头像昵称点击事件
    self.viewModel.avatarClickedEventHandler = ^(WXMomentViewModel *viewModel) {
        @strongify(self);
        WXUserViewController *vc = [[WXUserViewController alloc] initWithUser:viewModel.moment.user];
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    /// 位置信息点击事件
    self.viewModel.locationViewEventHandler = ^(WXMomentViewModel *viewModel) {
        if (!viewModel.locationViewModel.extend) return;
        @strongify(self);
        WXMapViewController *vc = [[WXMapViewController alloc] initWithLocation:viewModel.locationViewModel.extend];
        [self.navigationController pushViewController:vc animated:YES];
    };

    /// 开始编辑事件
    self.commentBar.beginEditingHandler = ^(WXMomentReplyViewModel *viewModel, BOOL animated) {
        @strongify(self);
        [self scrollToBottomWithIndexPath:viewModel.indexPath animated:animated];
    };
    
    /// 结束编辑事件
    self.commentBar.endEditingHandler = ^(WXMomentReplyViewModel *viewModel, BOOL animated) {
        @strongify(self);
        if (self.tableView.isDragging || self.tableView.isDecelerating) return;
        [self scrollToVisibleWithAnimated:animated];
    };
}

#pragma mark - LoadData
- (void)loadData {
    [self.viewModel reload];
}

- (void)beginLoadMore {
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself.viewModel loadMore];
    });
}

- (void)refresh {
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself.viewModel reload];
    });
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
/// 区数<朋友圈条数>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.dataSource.count;
}

/// 行数<点赞, 评论数量>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    WXMomentViewModel *viewModel =  self.viewModel.dataSource[section];
    return viewModel.dataSource.count;
}

/// 区头视图<正文>
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WXMomentHeaderView *headerView = [WXMomentHeaderView headerViewWithTableView:tableView];
    headerView.viewModel = self.viewModel.dataSource[section];
    return headerView;
}

/// 区尾视图<无内容>
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [WXMomentFooterView footerViewWithTableView:tableView];
}

/// 区头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    WXMomentViewModel *viewModel = self.viewModel.dataSource[section];
    return viewModel.height;
}

/// 区尾高度<固定>
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15.f;
}

/// Cell高度 点赞,评论高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    WXMomentViewModel *viewModel =  self.viewModel.dataSource[indexPath.section];
    WXMomentEventViewModel *model = viewModel.dataSource[indexPath.row];
    return model.height;
}

/// Cell 点赞,评论视图
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXMomentContentCell *cell = [WXMomentContentCell cellWithTableView:tableView];
    WXMomentViewModel *viewModel =  self.viewModel.dataSource[indexPath.section];
    cell.viewModel = viewModel.dataSource[indexPath.row];
    return cell;
}

/// 表格点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([[MNConfiguration configuration] keyboardVisible]) {
        [UIWindow endEditing:YES];
        return;
    }
    /// 回复操作
    NSUInteger section = indexPath.section;
    if (section >= self.viewModel.dataSource.count) return;
    WXMomentViewModel *viewModel = self.viewModel.dataSource[section];
    NSUInteger row = indexPath.row;
    if (row >= viewModel.dataSource.count) return;
    WXMomentEventViewModel *itemModel = viewModel.dataSource[row];
    if (itemModel.type == WXMomentEventTypeLiked) {
        // 修改点赞联系人
        [self updateLikesForViewModel:viewModel];
        return;
    }
    // 评论或删除
    @weakify(self);
    WXMomentCommentViewModel *vm = (WXMomentCommentViewModel *)itemModel;
    MNActionSheet *actionSheet = [MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *sheet, NSInteger buttonIndex) {
        if (buttonIndex == sheet.cancelButtonIndex) return;
        @strongify(self);
        if (buttonIndex == 0) {
            // 回复
            WXContactsSelectController *viewController = [[WXContactsSelectController alloc] initWithSelectedHandler:^(WXContactsSelectController *vc) {
                [vc.navigationController popViewControllerAnimated:YES];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self replyFrom:vc.users.firstObject to:vm.comment.fromUser withIndexPath:indexPath];
                });
            }];
            viewController.title = @"选择联系人";
            viewController.allowsUnselected = NO;
            viewController.multipleSelectEnabled = NO;
            viewController.expelUsers = @[vm.comment.fromUser];
            [self.navigationController pushViewController:viewController animated:YES];
        } else {
            // 删除
            [viewModel deleteComment:vm];
        }
    } otherButtonTitles:@"回复", @"删除", nil];
    [actionSheet setButtonTitleColor:BADGE_COLOR ofIndex:1];
    [actionSheet showInView:self.view];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.tableView && scrollView.isDragging) {
        [self.commentBar resignFirstResponder];
    }
}

#pragma mark - Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.tableView && [keyPath isEqualToString:WXMomentObserveKeyPath]) {
        
        CGFloat offsetY = [change[NSKeyValueChangeNewKey] CGPointValue].y;
        
        CGFloat alpha = (self.headerView ? (offsetY >= (self.headerView.offsetY - self.navigationBar.height_mn) ? 1.f : 0.f) : 0.f);
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
            WXMomentStatusBarStyle = statusBarStyle;
            [UIApplication.sharedApplication setStatusBarStyle:statusBarStyle animated:YES];
            [UIView animateWithDuration:.3f animations:^{
                self.navigationBar.alpha = alpha;
                self.shadowView.alpha = (1.f - alpha);
            }];
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - 点赞
- (void)updateLikesForViewModel:(WXMomentViewModel *)viewModel {
    if (!viewModel) return;
    @weakify(viewModel);
    NSMutableArray <NSString *>*uids = @[].mutableCopy;
    [viewModel.moment.likes enumerateObjectsUsingBlock:^(WXLike * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [uids addObject:obj.uid];
    }];
    WXContactsSelectController *viewController = [[WXContactsSelectController alloc] init];
    viewController.title = @"选择点赞联系人";
    viewController.allowsUnselected = YES;
    viewController.multipleSelectEnabled = YES;
    viewController.users = [WechatHelper.helper usersForUids:uids];
    viewController.selectedHandler = ^(WXContactsSelectController *vc) {
        [vc.navigationController popViewControllerAnimated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(viewModel);
            [viewModel reloadLikes:vc.users];
        });
    };
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - 评论/回复
- (void)replyFrom:(WXUser *)fromUser to:(WXUser *)toUser withIndexPath:(NSIndexPath *)indexPath {
    WXMomentViewModel *viewModel = self.viewModel.dataSource[indexPath.section];
    WXMomentReplyViewModel *replyModel = [WXMomentReplyViewModel new];
    replyModel.indexPath = indexPath;
    replyModel.viewModel = viewModel;
    replyModel.fromUser = fromUser;
    replyModel.toUser = toUser;
    [self.commentBar bindViewModel:replyModel];
    [self.commentBar becomeFirstResponder];
}

#pragma mark - 发起评论时配置列表偏移
- (void)scrollToBottomWithIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    CGRect rect = CGRectZero;
    if (indexPath.row == NSIntegerMin) {
        // 说明是评论所需偏移, 只要区尾显示即可
        rect = [self.tableView rectForFooterInSection:indexPath.section];
    } else {
        // 说明是回复所需偏移, 要让对应的cell显示
        rect = [self.tableView rectForRowAtIndexPath:indexPath];
    }
    // 修改tableView的偏移
    CGPoint contentOffset = self.tableView.contentOffset;
    rect.origin.y -= contentOffset.y;
    CGFloat delay = self.commentBar.top_mn - CGRectGetMaxY(rect);
    contentOffset.y = MAX(0.f, contentOffset.y - delay);
    [self.tableView setContentOffset:contentOffset animated:animated];
}

/// 结束编辑时, 避免底部偏移留白
- (void)scrollToVisibleWithAnimated:(BOOL)animated {
    CGPoint contentOffset = self.tableView.contentOffset;
    CGFloat contentHeight = self.tableView.contentSize.height;
    if (contentHeight <= self.tableView.height_mn) {
        contentOffset.y = 0.f;
        [self.tableView setContentOffset:contentOffset animated:animated];
    } else if (contentOffset.y > (contentHeight - self.tableView.height_mn)) {
        contentOffset.y = contentHeight - self.tableView.height_mn;
        [self.tableView setContentOffset:contentOffset animated:animated];
    }
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIImage *image = UIImageNamed(@"wx_common_back_black");
    CGSize leftItemSize = CGSizeMultiplyToWidth(image.size, kNavItemSize);
    UIButton *leftItem = [UIButton buttonWithType:UIButtonTypeCustom];
    leftItem.frame = (CGRect){CGPointZero, leftItemSize};
    leftItem.touchInset = UIEdgeInsetWith(-10.f);
    [leftItem setBackgroundImage:image forState:UIControlStateNormal];
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIImage *image = UIImageNamed(@"wx_moment_camera_black");
    CGSize rightItemSize = CGSizeMultiplyToWidth(image.size, kNavItemSize);
    UIButton *rightItem = [UIButton buttonWithType:UIButtonTypeCustom];
    rightItem.frame = (CGRect){CGPointZero, rightItemSize};
    rightItem.touchInset = UIEdgeInsetWith(-10.f);
    [rightItem setBackgroundImage:image forState:UIControlStateNormal];
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    @weakify(self);
    [self.view endEditing:YES];
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
        picker.configuration.exportURL = [NSURL fileURLWithPath:[WechatHelper.helper.momentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", NSString.identifier]]];
        [picker presentWithPickingHandler:^(MNAssetPicker * _Nonnull picker, NSArray<MNAsset *> * _Nullable assets) {
            WXNewMomentController *vc = [[WXNewMomentController alloc] initWithAssets:assets];
            [weakself.navigationController pushViewController:vc animated:YES];
        } cancelHandler:nil];
    } otherButtonTitles:attributedString.copy, @"从手机相册选择", nil] showInView:self.view];
}

#pragma mark - Super
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return WXMomentStatusBarStyle;
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

#pragma mark - dealloc
- (void)dealloc {
    [self.refreshView observeScrollView:nil];
    [self.tableView removeObserver:self forKeyPath:WXMomentObserveKeyPath];
}

@end
