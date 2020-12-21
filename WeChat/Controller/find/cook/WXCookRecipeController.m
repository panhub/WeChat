//
//  WXCookRecipeController.m
//  MNChat
//
//  Created by Vincent on 2019/6/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookRecipeController.h"
#import "WXCookRecipeViewModel.h"
#import "WXCookRecipeHeaderView.h"
#import "WXCookRecipeBriefView.h"
#import "WXCookRecipeCell.h"

@interface WXCookRecipeController ()
@property (nonatomic, strong) UIControl *leftBarControl;
@property (nonatomic, strong) UIControl *rightBarControl;
@property (nonatomic, strong) UIView *sectionHeaderView;
@property (nonatomic, strong) WXCookRecipeViewModel *viewModel;
@end

@implementation WXCookRecipeController
- (instancetype)initWithRecipeModel:(WXCookRecipe *)model {
    if (self = [super init]) {
        self.title = model.title;
        self.viewModel = [[WXCookRecipeViewModel alloc] initWithRecipeModel:model];
        [self handEvent];
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.shadowColor = SEPARATOR_COLOR;
    self.navigationBar.alpha = 0.f;
    
    @weakify(self);
    WXCookRecipeHeaderView *tableHeaderView = [WXCookRecipeHeaderView headerWithRecipeModel:self.viewModel.model];
    tableHeaderView.didLoadHandler = ^(UIView *view) {
        @strongify(self);
        self.tableView.tableHeaderView = view;
        self.tableView.tableHeaderView.userInteractionEnabled = YES;
        [self.tableView reloadData];
    };
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.tableHeaderView = tableHeaderView;
    
    WXCookRecipeBriefView *sectionHeaderView = [WXCookRecipeBriefView viewWithRecipeModel:self.viewModel.model];
    self.sectionHeaderView = sectionHeaderView;
    
    UIView *leftBarItem = self.navigationBar.leftBarItem;
    CGRect leftRect = [leftBarItem.superview convertRect:leftBarItem.frame toView:self.view];
    
    UIControl *leftBarControl = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 33.f, 33.f)];
    leftBarControl.center_mn = CGPointMake(CGRectGetMidX(leftRect), CGRectGetMidY(leftRect));
    leftBarControl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7f];
    leftBarControl.layer.cornerRadius = leftBarControl.height_mn/2.f;
    leftBarControl.clipsToBounds = YES;
    [leftBarControl addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBarControl];
    self.leftBarControl = leftBarControl;
    
    UIImageView *leftImageView = [UIImageView imageViewWithFrame:leftBarItem.bounds image:UIImageNamed(@"wx_common_back_white")];
    leftImageView.center_mn = leftBarControl.bounds_center;
    leftImageView.centerX_mn += 2.f;
    leftImageView.userInteractionEnabled = NO;
    [leftBarControl addSubview:leftImageView];
    
    UIView *rightBarItem = self.navigationBar.rightBarItem;
    CGRect rightRect = [rightBarItem.superview convertRect:rightBarItem.frame toView:self.view];
    
    UIControl *rightBarControl = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 33.f, 33.f)];
    rightBarControl.center_mn = CGPointMake(CGRectGetMidX(rightRect), CGRectGetMidY(rightRect));
    rightBarControl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7f];
    rightBarControl.layer.cornerRadius = rightBarControl.height_mn/2.f;
    rightBarControl.clipsToBounds = YES;
    [rightBarControl addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBarControl];
    self.rightBarControl = rightBarControl;
    
    UIImageView *rightImageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 20.f, 20.f) image:UIImageNamed(@"wx_common_share_white")];
    rightImageView.center_mn = rightBarControl.bounds_center;
    rightImageView.userInteractionEnabled = NO;
    [rightBarControl addSubview:rightImageView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadData {
    [self.viewModel loadData];
}

- (void)handEvent {
    @weakify(self);
    /// 即将刷新数据
    self.viewModel.prepareLoadDataHandler = ^{
        @strongify(self);
        [self.contentView showDotDialog];
    };
    /// 刷新列表
    self.viewModel.reloadTableHandler = ^{
        [UIView performWithoutAnimation:^{
            @strongify(self);
            @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
        }];
    };
    /// 已经刷新数据
    self.viewModel.didLoadDataHandler = ^{
        @strongify(self);
        [self.contentView closeDialog];
    };
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.viewModel.dataSource[indexPath.section].height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? self.sectionHeaderView.height_mn : .01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return section == 0 ? self.sectionHeaderView : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [WXCookRecipeCell cellWithTableView:tableView];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXCookRecipeCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.viewModel.dataSource.count) return;
    cell.viewModel = self.viewModel.dataSource[indexPath.section];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self setNavigationBarHidden:(scrollView.contentOffset.y < (self.tableView.tableHeaderView.height_mn - self.navigationBar.height_mn))];
}

- (void)setNavigationBarHidden:(BOOL)hidden {
    if (self.navigationBar.alpha == (1.f - hidden)) return;
   [[UIApplication sharedApplication] setStatusBarStyle:(hidden ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault) animated:YES];
    [UIView animateWithDuration:.3f animations:^{
        self.navigationBar.alpha = 1.f - hidden;
        self.leftBarControl.alpha = self.rightBarControl.alpha = hidden;
    }];
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIControl *leftItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 30.f, 30.f)];
    leftItem.backgroundImage = UIImageNamed(@"wx_common_back_black");
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIControl *rightItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 21.f, 21.f)];
    rightItem.touchInset = UIEdgeInsetWith(-5.f);
    rightItem.backgroundImage = UIImageNamed(@"wx_common_share_black");
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    [self.view showWechatDialog];
    dispatch_async_default(^{
        NSArray <UIImage *>*images = self.viewModel.shareImages;
        dispatch_async_main(^{
            if (images.count <= 0) {
                [self.view showInfoDialog:@"获取资源失败"];
            } else {
                [self.view closeDialog];
                UIActivityViewController *vc = [[UIActivityViewController alloc]initWithActivityItems:images applicationActivities:nil];
                vc.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll];
                [self presentViewController:vc animated:YES completion:nil];
            }
        });
    });
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
