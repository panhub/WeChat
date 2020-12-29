//
//  WXTabBarController.m
//  MNChat
//
//  Created by Vincent on 2019/2/23.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "WXTabBarController.h"
#import "WXLoginViewController.h"

@interface WXTabBarController ()

@end

static WXTabBarController *_tabBarController;

@implementation WXTabBarController
+ (WXTabBarController *)tabBarController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_tabBarController) {
            _tabBarController = [[self alloc]init];
        }
    });
    return _tabBarController;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tabBarController = [super allocWithZone:zone];
    });
    return _tabBarController;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tabBarController = [super init];
    });
    return _tabBarController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabView.translucent = YES;
    self.tabView.backgroundColor = [UIColor whiteColor];
    self.tabView.itemSize = CGSizeMake(48.f, 36.f);
    self.tabView.itemOffset = UIOffsetZero;
    self.tabView.shadowColor = [UIColor.darkGrayColor colorWithAlphaComponent:.13f];
    [MNTabBarItem appearanceWhenContainedIn:WXTabBarController.class, nil].badgeAlignment = MNTabBadgeAlignmentLeft;
    [MNTabBarItem appearanceWhenContainedIn:WXTabBarController.class, nil].badgeOffset = UIOffsetMake(-2.f, 2.f);
    [MNTabBarItem appearanceWhenContainedIn:WXTabBarController.class, nil].titleFont = UIFontRegular(10.f);
    [MNTabBarItem appearanceWhenContainedIn:WXTabBarController.class, nil].titleOffset = UIOffsetMake(0.f, 5.f);
    [MNTabBarItem appearanceWhenContainedIn:WXTabBarController.class, nil].badgeColor = BADGE_COLOR;
    [MNTabBarItem appearanceWhenContainedIn:WXTabBarController.class, nil].selectedTitleColor = UIColorWithHex(@"#00c25f");
}

- (void)reset {
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UINavigationController.class]) {
            UINavigationController *nav = (UINavigationController *)obj;
            [nav popToRootViewControllerAnimated:NO];
        }
    }];
    self.selectedIndex = 0;
}

- (NSInteger)updateMomentBadgeValue {
    __block UIViewController *vc;
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UINavigationController.class]) {
            UINavigationController *nav = (UINavigationController *)obj;
            if (nav.viewControllers.count > 0 && [nav.viewControllers.firstObject isKindOfClass:NSClassFromString(@"WXFindViewController")]) {
                vc = nav.viewControllers.firstObject;
                *stop = YES;
            }
        }
    }];
    if (!vc) return 0;
    NSInteger count = MIN([[MNDatabase database] selectCountFromTable:WXMomentRemindTableName where:nil], 99);
    vc.badgeValue = NSStringWithFormat(@"%@", @(count));
    return count;
}

#pragma mark - Super
- (Class)navigationClassAtIndex:(NSInteger)index {
    return NSClassFromString(@"WXNavigationController");
}

- (MNTransitionAnimator *)tabBarControllerTransitionForOperation:(MNControllerTransitionOperation)operation fromViewController:(__kindof UIViewController *)fromVC toViewController:(__kindof UIViewController *)toVC {
    return nil;
}

@end
