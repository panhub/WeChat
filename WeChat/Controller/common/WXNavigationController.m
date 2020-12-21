//
//  WXNavigationController.m
//  MNChat
//
//  Created by Vincent on 2019/2/23.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "WXNavigationController.h"

@interface WXNavigationController ()

@end

@implementation WXNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:MNExtendViewController.class]) {
        MNExtendViewController *vc = (MNExtendViewController *)viewController;
        if ([vc respondsToSelector:@selector(navigationBarShouldDrawBackBarItem)] && [vc navigationBarShouldDrawBackBarItem] && ![vc respondsToSelector:@selector(navigationBarShouldCreateLeftBarItem)]) {
            if (vc.isFirstAppear) vc.navigationBar.leftItemImage = [UIImage imageNamed:@"wx_common_back_black"];
        }
    }
}

@end
