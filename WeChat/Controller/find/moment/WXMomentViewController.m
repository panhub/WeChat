//
//  WXMomentViewController.m
//  MNChat
//
//  Created by Vincent on 2019/4/27.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentViewController.h"
#import "WXNewMomentController.h"
#import "WXContactsSelectController.h"
#import "WXUserInfoViewController.h"
#import "WXMapViewController.h"
#import "WXMomentRemindController.h"
#import "WXMomentProfileViewModel.h"
#import "WXMomentReplyViewModel.h"
#import "WXMomentProfileView.h"
#import "WXMomentHeaderView.h"
#import "WXMomentFooterView.h"
#import "WXMomentContentCell.h"
#import "WXMomentInputView.h"
#import "WXMomentBrowser.h"
#import "WXContactsSelectController.h"
#import "WXMomentCommentViewModel.h"

@interface WXMomentViewController ()
{
    BOOL _needsReloadRemindData;
    UIStatusBarStyle WXMomentStatusBarStyle;
}
@property (nonatomic, strong) UIButton *leftBarButton;
@property (nonatomic, strong) UIButton *rightBarButton;
@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) WXMomentInputView *commentBar;
@property (nonatomic, strong) WXMomentProfileView *headerView;
@property (nonatomic, strong) WXMomentProfileViewModel *viewModel;
@end

@implementation WXMomentViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"朋友圈";
        self.viewModel = [WXMomentProfileViewModel new];
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
    
    WXMomentProfileView *headerView = [[WXMomentProfileView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 0.f)];
    [headerView bindViewModel:self.viewModel];
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
    
    /// 编辑框
    WXMomentInputView *commentBar = [[WXMomentInputView alloc] init];
    [self.view addSubview:commentBar];
    self.commentBar = commentBar;
    
    UIImage *maskImage = [UIImage gradientImageWithSize:self.navigationBar.size_mn orientation:MNGradientOrientationVertical colors:@[UIColorWithAlpha([UIColor blackColor], .12f), [UIColor clearColor]]];
    UIImageView *maskView = [UIImageView imageViewWithFrame:self.navigationBar.frame
                                                      image:maskImage];
    [self.view addSubview:maskView];
    self.maskView = maskView;
    
    UIView *leftBarItem = self.navigationBar.leftBarItem;
    CGRect leftRect = [leftBarItem.superview convertRect:leftBarItem.frame toView:self.view];
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarButton.frame = leftRect;
    leftBarButton.touchInset = leftBarItem.touchInset;
    [leftBarButton setBackgroundImage:UIImageNamed(@"wx_common_back_white") forState:UIControlStateNormal];
    [leftBarButton addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBarButton];
    self.leftBarButton = leftBarButton;
    
    UIView *rightBarItem = self.navigationBar.rightBarItem;
    CGRect rightRect = [rightBarItem.superview convertRect:rightBarItem.frame toView:self.view];
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarButton.frame = rightRect;
    rightBarButton.touchInset = rightBarItem.touchInset;
    [rightBarButton setBackgroundImage:UIImageNamed(@"wx_moment_camera_white") forState:UIControlStateNormal];
    [rightBarButton addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBarButton];
    self.rightBarButton = rightBarButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //// 事件处理
    [self handEvents];
}

- (void)mn_transition_viewWillAppear {
    [super mn_transition_viewWillAppear];
    self.commentBar.userInteractionEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.headerView updateUserInfo];
    self.commentBar.userInteractionEnabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_needsReloadRemindData) {
        if (self.viewModel.reloadRemindHandler) {
            _needsReloadRemindData = NO;
            self.viewModel.reloadRemindHandler();
        }
    }
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
    self.viewModel.remindViewEventHandler = ^{
        @strongify(self);
        WXMomentRemindController *vc = [[WXMomentRemindController alloc] initWithViewModel:self.viewModel];
        vc.didDeleteRemindHandler = ^{
            self->_needsReloadRemindData = YES;
        };
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    /// 赞/评论
    self.viewModel.moreButtonEventHandler = ^(WXMomentViewModel *viewModel, NSUInteger idx) {
        @strongify(self);
        if (!viewModel || ![self.viewModel.dataSource containsObject:viewModel]) return;
        if (idx == 0) {
            /// 点赞
            [self updateLikesForViewModel:viewModel];
        } else {
           /// 评论
            NSInteger section = [self.viewModel.dataSource indexOfObject:viewModel];
            @weakify(self);
            WXContactsSelectController *viewController = [[WXContactsSelectController alloc] initWithSelectedHandler:^(UIViewController *vc, NSArray <WXUser *>*users) {
                @strongify(self);
                [vc.navigationController popViewControllerAnimated:YES];
                dispatch_after_main(.5f, ^{
                    [self replyMomentFrom:users.firstObject to:nil withIndexPath:[NSIndexPath indexPathForRow:NSIntegerMin inSection:section]];
                });
            }];
            [self.viewController.navigationController pushViewController:viewController animated:YES];
        }
    };
    
    /// 删除事件
    self.viewModel.deleteButtonEventHandler = ^(WXMomentViewModel *viewModel) {
        MNActionSheet *actionSheet = [MNActionSheet actionSheetWithTitle:@"确定删除朋友圈?" cancelButtonTitle:@"取消" handler:^(MNActionSheet *sheet, NSInteger buttonIndex) {
            if (buttonIndex == sheet.cancelButtonIndex) return;
            @strongify(self);
            [self.viewModel deleteMomentViewModel:viewModel];
            [self reloadList];
        } otherButtonTitles:@"删除", nil];
        actionSheet.buttonTitleColor = BADGE_COLOR;
        actionSheet.cancelButtonTitleColor = UIColorWithAlpha([UIColor darkTextColor], .7f);
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
        browser.allowsSelect = NO;
        browser.backgroundColor = [UIColor blackColor];
        [browser presentInView:self.view fromAsset:assets[index] animated:YES completion:nil];
    };
    
    /// 头像昵称点击事件
    self.viewModel.avatarClickedEventHandler = ^(WXMomentViewModel *viewModel) {
        @strongify(self);
        WXUserInfoViewController *vc = [[WXUserInfoViewController alloc] initWithUser:viewModel.moment.user];
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    /// 位置信息点击事件
    self.viewModel.locationViewEventHandler = ^(WXMomentViewModel *viewModel) {
        if (!viewModel.locationViewModel.extend) return;
        @strongify(self);
        WXMapLocation *point = viewModel.locationViewModel.extend;
        WXMapViewController *vc = [[WXMapViewController alloc] initWithPoint:point];
        [self.navigationController pushViewController:vc animated:YES];
    };

    /// 开始编辑事件
    self.commentBar.beginEditingHandler = ^(NSIndexPath *indexPath, BOOL animated) {
        @strongify(self);
        [self scrollTableToBottomWithIndexPath:indexPath animated:animated];
    };
    
    /// 结束编辑事件
    self.commentBar.endEditingHandler = ^(NSIndexPath *indexPath, BOOL animated) {
        @strongify(self);
        if (self.tableView.isDragging) return;
        [self scrollTableToVisibleIfNeedWithIndexPath:indexPath animated:animated];
    };
}

#pragma mark - LoadData
- (void)loadData {
    [self.viewModel loadData];
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
    //headerView.section = section;
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
    WXMomentItemViewModel *model = viewModel.dataSource[indexPath.row];
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
    WXMomentItemViewModel *itemModel = viewModel.dataSource[row];
    if (itemModel.type == WXMomentItemTypeLiked) {
        // 修改点赞联系人
        [self updateLikesForViewModel:viewModel];
        return;
    }
    // 评论或删除
    @weakify(self);
    MNActionSheet *actionSheet = [MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *sheet, NSInteger buttonIndex) {
        if (buttonIndex == sheet.cancelButtonIndex) return;
        @strongify(self);
        if (buttonIndex == 0) {
           /// 回复
            [self replyCommentAtIndexPath:indexPath];
        } else {
            /// 删除
            [self deleteCommentAtIndexPath:indexPath];
        }
    } otherButtonTitles:@"回复", @"删除" ,nil];
    [actionSheet setButtonTitleColor:BADGE_COLOR ofIndex:1];
    [actionSheet show];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.tableView && scrollView.isDragging) {
        [self.commentBar resignFirstResponder];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY >= (self.headerView.offsetY - self.navigationBar.height_mn)) {
        [self navigationBarAnimatedHidden:NO];
    } else {
        [self navigationBarAnimatedHidden:YES];
    }
}

#pragma mark - 更新点赞人员
- (void)updateLikesForViewModel:(WXMomentViewModel *)viewModel {
    if (!viewModel) return;
    @weakify(viewModel);
    WXContactsSelectController *viewController = [[WXContactsSelectController alloc] init];
    viewController.title = @"选择点赞联系人";
    viewController.multipleSelectEnabled = YES;
    viewController.allowsUnselected = YES;
    viewController.selectedArray = [MNChatHelper.helper usersForUids:viewModel.moment.likes].mutableCopy;
    viewController.selectedHandler = ^(UIViewController *vc, NSArray<WXUser *>*users) {
        [vc.navigationController popViewControllerAnimated:YES];
        dispatch_after_main(.5f, ^{
            @strongify(viewModel);
            [viewModel replacingLikeUsers:users];
        });
    };
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - 导航栏变化
- (void)navigationBarAnimatedHidden:(BOOL)hidden {
    if (WXMomentStatusBarStyle == hidden) return;
    WXMomentStatusBarStyle = hidden ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarStyle:WXMomentStatusBarStyle animated:YES];
    [UIView animateWithDuration:.3f animations:^{
        self.navigationBar.alpha = (1.f - hidden);
        self.maskView.alpha = self.leftBarButton.alpha = self.rightBarButton.alpha = hidden;
    }];
}

#pragma mark - 评论/回复/删除
- (void)replyCommentAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.dataSource.count <= indexPath.section) return;
    WXMomentViewModel *viewModel = self.viewModel.dataSource[indexPath.section];
    WXMomentCommentViewModel *model = (WXMomentCommentViewModel *)(viewModel.dataSource[indexPath.row]);
    WXUser *from_user = model.comment.to_user;
    WXUser *to_user = model.comment.from_user;
    if (!to_user) return;
    if (from_user) {
        [self replyMomentFrom:from_user to:to_user withIndexPath:indexPath];
    } else {
        WXContactsSelectController *viewController = [[WXContactsSelectController alloc] initWithSelectedHandler:^(UIViewController *vc, NSArray <WXUser *>*users) {
            [vc.navigationController popViewControllerAnimated:YES];
            dispatch_after_main(.5f, ^{
                if ([users.firstObject.uid isEqualToString:to_user.uid]) {
                    [self.view showInfoDialog:@"请选择不同用户回复评论"];
                } else {
                    [self replyMomentFrom:users.firstObject to:to_user withIndexPath:indexPath];
                }
            });
        }];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)replyMomentFrom:(WXUser *)from to:(WXUser *)to withIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.dataSource.count <= indexPath.section) return;
    WXMomentViewModel *model = self.viewModel.dataSource[indexPath.section];
    WXMomentReplyViewModel *viewModel = [WXMomentReplyViewModel new];
    viewModel.indexPath = indexPath;
    viewModel.viewModel = model;
    viewModel.from_user = from;
    viewModel.to_user = to;
    [self.commentBar bindViewModel:viewModel];
    [self.commentBar becomeFirstResponder];
}

- (void)deleteCommentAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.dataSource.count <= indexPath.section) return;
    WXMomentViewModel *viewModel = self.viewModel.dataSource[indexPath.section];
    [viewModel deleteCommentAtIndexPath:indexPath];
}

#pragma mark - 发起评论时配置列表偏移
- (void)scrollTableToBottomWithIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
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
- (void)scrollTableToVisibleIfNeedWithIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
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
    WXNewMomentController *vc = [WXNewMomentController new];
    [self.navigationController pushViewController:vc animated:YES];
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

@end
