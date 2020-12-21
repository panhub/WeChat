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
        frame.origin.y += ([self navigationBarHeight] + MN_STATUS_BAR_HEIGHT);
        frame.size.height -= ([self navigationBarHeight] + MN_STATUS_BAR_HEIGHT);
        UIViewAutoresizing autoresizingMask = self.contentView.autoresizingMask;
        self.contentView.autoresizingMask = UIViewAutoresizingNone;
        self.contentView.frame = frame;
        self.contentView.autoresizingMask = autoresizingMask;
    }
    if (self.isChildViewController || !self.transitionAnimationStyle) return;
    CGRect frame = CGRectMake(0.f, 0.f, self.view.width_mn, self.navigationBarHeight + MN_STATUS_BAR_HEIGHT);
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
    if ([self transitionAnimationStyle] == MNControllerTransitionStyleModal) return nil;
    if ([self isChildViewController]) {
        UIViewController *viewController = self.parentController;
        if (viewController && [viewController isKindOfClass:[MNExtendViewController class]]) {
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
- (void)navigationBarDidCreateBarItem:(MNNavigationBar *)navigationBar {}

#pragma mark - 标题设置
- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.navigationBar.title = title;
}

#pragma mark - controller config
- (CGFloat)navigationBarHeight {
    return MN_NAV_BAR_HEIGHT;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
