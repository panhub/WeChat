//
//  WXCookViewController.m
//  WeChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookViewController.h"
#import "WXCookListController.h"
#import "WXCookSortRequest.h"
#import "WXCookHeaderView.h"

@interface WXCookViewController ()<MNSegmentControllerDelegate, MNSegmentControllerDataSource>
@property (nonatomic) NSInteger sortIndex;
@property (nonatomic, strong) MNSegmentController *segmentController;
@end

@implementation WXCookViewController
- (instancetype)init {
    if (self = [super init]) {
        self.httpRequest = WXCookSortRequest.new;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = UIColor.whiteColor;
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.rightBarItem.hidden = YES;
}

#pragma mark - MNSegmentControllerDelegate && MNSegmentControllerDataSource
- (UIView *)segmentControllerShouldLoadHeaderView:(MNSegmentController *)segmentController {
    return [[WXCookHeaderView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, 0.f)];
}

- (NSArray <NSString *>*)segmentControllerShouldLoadPageTitles:(MNSegmentController *)segmentController {
    WXCookSort *sort = [self.httpRequest.dataArray objectAtIndex:self.sortIndex];
    self.title = sort.title;
    NSMutableArray <NSString *>*titles = [NSMutableArray arrayWithCapacity:sort.list.count];
    [sort.list enumerateObjectsUsingBlock:^(WXCookMenu * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [titles addObject:obj.name];
    }];
    return titles.copy;
}

- (UIViewController *)segmentController:(MNSegmentController *)segmentController childControllerOfPageIndex:(NSUInteger)pageIndex {
    WXCookSort *sort = [self.httpRequest.dataArray objectAtIndex:self.sortIndex];
    WXCookMenu *menu = sort.list[pageIndex];
    WXCookListController *vc = [[WXCookListController alloc] initWithFrame:segmentController.view.bounds menu:menu];
    return vc;
}

- (void)segmentControllerInitializedConfiguration:(MNSegmentConfiguration *)configuration {
    configuration.height = 43.f;
    configuration.titleMargin = 45.f;
    configuration.contentMode = MNSegmentContentModeFill;
    configuration.shadowMask = MNSegmentShadowMaskFit;
    configuration.backgroundColor = UIColor.whiteColor;
    configuration.titleFont = [UIFont systemFontOfSize:17.f];
    configuration.selectedTitleFont = [UIFont systemFontOfSize:17.f];
    configuration.titleColor = [UIColor.darkTextColor colorWithAlphaComponent:.9f];
    configuration.selectedColor = THEME_COLOR;
    configuration.shadowColor = THEME_COLOR;
    configuration.separatorColor = [UIColor.grayColor colorWithAlphaComponent:.15f];
}

- (void)segmentControllerProfileViewDidScroll:(MNSegmentController *)segmentController {
    [self setNavigationBarHidden:(segmentController.contentOffset.y < (segmentController.headerView.height_mn - self.navigationBar.height_mn))];
}

- (void)setNavigationBarHidden:(BOOL)hidden {
    if (self.navigationBar.alpha == (1.f - hidden)) return;
    [UIView animateWithDuration:.3f animations:^{
        self.navigationBar.alpha = 1.f - hidden;
    }];
}

#pragma mark - Getter
- (MNSegmentController *)segmentController {
    if (!_segmentController) {
        MNSegmentController *segmentController = [[MNSegmentController alloc] initWithFrame:self.contentView.bounds];
        segmentController.delegate = self;
        segmentController.dataSource = self;
        segmentController.fixedHeight = self.navigationBar.height_mn;
        _segmentController = segmentController;
    }
    return _segmentController;
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIView *rightBarItem = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 30.f)];
    rightBarItem.backgroundColor = [UIColor whiteColor];
    rightBarItem.layer.cornerRadius = rightBarItem.height_mn/2.f;
    rightBarItem.clipsToBounds = YES;
    UIImage *moreImage = [UIImage imageNamed:@"wx_applet_more"];
    CGSize moreSize = CGSizeMultiplyToHeight(moreImage.size, rightBarItem.height_mn);
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(0.f, 0.f, moreSize.width, moreSize.height);
    [moreButton setBackgroundImage:moreImage forState:UIControlStateNormal];
    [moreButton setBackgroundImage:moreImage forState:UIControlStateHighlighted];
    [moreButton addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [rightBarItem addSubview:moreButton];
    UIImage *exitImage = [UIImage imageNamed:@"wx_applet_exit"];
    CGSize exitSize = CGSizeMultiplyToHeight(exitImage.size, rightBarItem.height_mn);
    UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    exitButton.tag = 1;
    exitButton.frame = CGRectMake(moreButton.right_mn, moreButton.top_mn, exitSize.width, exitSize.height);
    [exitButton setBackgroundImage:exitImage forState:UIControlStateNormal];
    [exitButton setBackgroundImage:exitImage forState:UIControlStateHighlighted];
    [exitButton addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [rightBarItem addSubview:exitButton];
    rightBarItem.width_mn = exitButton.right_mn;
    return rightBarItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    if (!_segmentController) return;
    NSMutableArray <NSString *>*sorts = [NSMutableArray arrayWithCapacity:self.httpRequest.dataArray.count];
    [self.httpRequest.dataArray enumerateObjectsUsingBlock:^(WXCookSort  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sorts addObject:obj.name];
    }];
    if (sorts.count <= 0) return;
    MNActionSheet *actionSheet = [[MNActionSheet alloc] initWithTitle:nil cancelButtonTitle:@"取消" otherButtonTitles:sorts.copy handler:^(MNActionSheet * _Nonnull ac, NSInteger buttonIndex) {
        if (buttonIndex == ac.cancelButtonIndex || buttonIndex == self.sortIndex) return;
        self.sortIndex = buttonIndex;
        [self.segmentController reloadData];
    }];
    actionSheet.cancelButtonTitleColor = TEXT_COLOR;
    [actionSheet setButtonTitleColor:TEXT_COLOR ofIndex:self.sortIndex];
    [actionSheet show];
}

#pragma mark - Super
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (void)prepareLoadData:(__kindof MNHTTPDataRequest *)request {
    if (!self.contentView.isDialoging) [self.contentView showWechatDialog];
}

- (BOOL)loadDataFinishWithRequest:(__kindof MNHTTPDataRequest *)request {
    if ([super loadDataFinishWithRequest:request]) {
        self.navigationBar.alpha = 0.f;
        [self addChildViewController:self.segmentController inView:self.contentView];
    }
    self.navigationBar.rightBarItem.hidden = NO;
    return YES;
}

- (void)showEmptyViewNeed:(BOOL)isNeed image:(UIImage *)image message:(NSString *)message title:(NSString *)title type:(MNEmptyEventType)type {
    [super showEmptyViewNeed:isNeed image:[MNBundle imageForResource:@"empty_data_jd"] message:message title:@"点击重试" type:MNEmptyEventTypeReload];
}

@end
