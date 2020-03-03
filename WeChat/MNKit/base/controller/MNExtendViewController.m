//
//  MNExtendViewController.m
//  MNKit
//
//  Created by Vincent on 2017/11/15.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "MNExtendViewController.h"
#import "MNNavBarTitleView.h"
#import "UIView+MNHelper.h"
#import "UIViewController+MNHelper.h"

@interface MNExtendViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) MNNavigationBar *navigationBar;
@end

@implementation MNExtendViewController
- (void)initialized {
    [super initialized];
    if (self.isChildViewController || !self.transitionAnimationStyle) {
        self.contentEdges = MNContentEdgeNone;
    } else {
        self.contentEdges = self.isRootViewController ? MNContentEdgeTop|MNContentEdgeBottom : MNContentEdgeTop;
    }
}

- (void)createView {
    [super createView];
    if (self.contentEdges & MNContentEdgeTop) {
        CGRect frame = self.contentView.frame;
        frame.origin.y += ([self navigationBarHeight] + UIStatusBarHeight());
        frame.size.height -= ([self navigationBarHeight] + UIStatusBarHeight());
        UIViewAutoresizing autoresizingMask = self.contentView.autoresizingMask;
        self.contentView.autoresizingMask = UIViewAutoresizingNone;
        self.contentView.frame = frame;
        self.contentView.autoresizingMask = autoresizingMask;
    }
    if (self.isChildViewController || !self.transitionAnimationStyle) return;
    CGFloat margin = ((IS_IPAD && (self.contentEdges & MNContentEdgeBottom)) ? TAB_BAR_HEIGHT : 0.f);
    CGRect frame = CGRectMake(margin, 0.f, self.view.width_mn - margin, ([self navigationBarHeight] + UIStatusBarHeight()));
    MNNavigationBar *navigationBar = [[MNNavigationBar alloc] initWithFrame:frame delegate:self];
    navigationBar.title = self.title;
    [self.view addSubview:navigationBar];
    _navigationBar = navigationBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isFirstAppear && _navigationBar) {
        [self.view bringSubviewToFront:_navigationBar];
    }
}

#pragma mark - 获取导航栏
- (MNNavigationBar *)navigationBar {
    if (_navigationBar) return _navigationBar;
    if ([self transitionAnimationStyle] == MNControllerTransitionStyleModel) return nil;
    if ([self isChildViewController]) {
        UIViewController *viewController = self.parentController;
        if ([viewController isKindOfClass:[MNExtendViewController class]]) {
            MNExtendViewController *parentController = (MNExtendViewController *)viewController;
            return parentController.navigationBar;
        }
        return nil;
    }
    return nil;
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return ![self isRootViewController];
}
- (void)navigationBarLeftBarItemTouchUpInside:(UIView *)leftBarItem {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {}

#pragma mark - 标题设置
- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.navigationBar.title = title;
}

#pragma mark - controller config
- (CGFloat)navigationBarHeight {
    return UINavBarHeight();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
