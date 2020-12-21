//
//  WXCityViewController.m
//  MNChat
//
//  Created by Vincent on 2019/5/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCityViewController.h"
#import "WXCityRequest.h"
#import "WXCityModel.h"
#import "WXCityListController.h"

@interface WXCityViewController () <MNLinkTableControllerDelegate, MNLinkTableControllerDataSource>
@property (nonatomic, strong) MNLinkTableController *listViewController;
@end

@implementation WXCityViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"选择城市";
        self.httpRequest = [WXCityRequest new];
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.contentView.backgroundColor = UIColorWithSingleRGB(51.f);
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = UIColorWithSingleRGB(51.f);
    self.navigationBar.shadowColor = UIColorWithSingleRGB(61.f);
    self.navigationBar.titleColor = [UIColor whiteColor];
    
    MNLinkTableController *listViewController = [[MNLinkTableController alloc] initWithFrame:self.contentView.bounds];
    listViewController.delegate = self;
    listViewController.dataSource = self;
    [self addChildViewController:listViewController inView:self.contentView];
    self.listViewController = listViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - MNLinkViewControllerDataSource
- (NSArray <NSString *>*)linkTableControllerTitles {
    NSMutableArray <NSString *>*titles = [NSMutableArray arrayWithCapacity:self.httpRequest.dataArray.count];
    [self.httpRequest.dataArray enumerateObjectsUsingBlock:^(WXProvinceModel *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [titles addObject:obj.name];
    }];
    return titles.copy;
}

- (void)linkTableControllerInitializedConfiguration:(MNLinkTableConfiguration *)configuration {
    configuration.titleColor = [UIColor whiteColor];
    configuration.shadowColor = THEME_COLOR;
    configuration.selectedTitleColor = THEME_COLOR;
    configuration.separatorColor = UIColorWithSingleRGB(71.f);
    configuration.backgroundColor = UIColorWithSingleRGB(51.f);
    configuration.selectedTitleColor = UIColorWithSingleRGB(51.f);
    configuration.titleFont = UIFontRegular(17.f);
}

- (UIViewController *)linkTableControllerPageOfIndex:(NSUInteger)pageIndex frame:(CGRect)frame {
    if (pageIndex >= self.httpRequest.dataArray.count) return nil;
    WXProvinceModel *model = self.httpRequest.dataArray[pageIndex];
    WXCityListController *vc = [[WXCityListController alloc] initWithFrame:frame];
    vc.dataSource = model.dataSource;
    return vc;
}

#pragma mark - MNLinkViewControllerDelegate
- (void)linkViewControllerWillReloadData:(MNLinkViewController *)linkController {
    [self.contentView showDotDialog];
}

- (void)linkViewControllerDidReloadData:(MNLinkViewController *)linkController {
    [self.contentView closeDialog];
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
    if (self.httpRequest.isLoading) return;
    MNActionSheet *actionSheet = [MNActionSheet actionSheetWithTitle:@"" cancelButtonTitle:@"取消" handler:^(MNActionSheet *ac, NSInteger buttonIndex) {
        if (buttonIndex == ac.cancelButtonIndex) return;
        [self reloadData];
    } otherButtonTitles:@"刷新", nil];
    actionSheet.buttonTitleColor = BADGE_COLOR;
    actionSheet.cancelButtonTitleColor = TEXT_COLOR;
    [actionSheet show];
}

#pragma mark - Super
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (BOOL)loadDataFinishWithRequest:(__kindof MNHTTPDataRequest *)request {
    if ([super loadDataFinishWithRequest:request]) {
        [self.listViewController reloadData];
    }
    return YES;
}

- (void)prepareLoadData:(__kindof MNHTTPDataRequest *)request {
    [self.contentView showDotDialog];
}

- (void)showEmptyViewNeed:(BOOL)isNeed image:(UIImage *)image message:(NSString *)message title:(NSString *)title type:(MNEmptyEventType)type {
    [super showEmptyViewNeed:isNeed image:[MNBundle imageForResource:@"empty_data_jd"] message:@"获取数据失败" title:@"点击重试" type:MNEmptyEventTypeReload];
}

@end
