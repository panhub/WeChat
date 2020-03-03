//
//  MNTabBarController.m
//  MNKit
//
//  Created by Vincent on 2017/11/9.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "MNTabBarController.h"
#import "UIViewController+MNInterface.h"
#import "UIViewController+MNHelper.h"
#import "MNTransitionAnimator.h"
#import <objc/message.h>
#import "UIImage+MNHelper.h"
#import "UIView+MNHelper.h"
#import "MNExtern.h"
#import "MNTransitionAnimator.h"

@interface MNTabBarController () 

@end

static MNTabBarController *_tabBarController;

@implementation MNTabBarController

- (instancetype)init {
    if (self = [super init]) {
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutExtendAdjustEdges];
    
    MNTabBar *tabView = [MNTabBar tabBar];
    tabView.delegate = self;
    [self.view addSubview:tabView];
    self.tabView = tabView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBar setHidden:YES];
    [self.view bringSubviewToFront:self.tabView];
}

#pragma mark - 设置子控制器
- (void)setControllers:(NSArray<NSString *> *)controllers {
    if (controllers.count <= 0) return;
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    _controllers = [controllers copy];
    [self addChildViewControllers:controllers];
}

- (void)addChildViewControllers:(NSArray<NSString *> *)childControllers {
    NSMutableArray <UIViewController *>*viewControllers = [NSMutableArray arrayWithCapacity:childControllers.count];
    [childControllers enumerateObjectsUsingBlock:^(NSString * _Nonnull controller, NSUInteger idx, BOOL * _Nonnull stop) {
        const char *class = [controller cStringUsingEncoding:NSUTF8StringEncoding];
    
        UIViewController *viewController = ((UIViewController *(*)(id,SEL))objc_msgSend)(objc_getClass(class), sel_registerName("alloc"));
        viewController = ((UIViewController *(*)(UIViewController *, SEL))objc_msgSend)(viewController, sel_registerName("init"));
        NSString *title = [viewController tabBarItemTitle] ? : viewController.title;
        viewController.tabBarItem.title = title;
        viewController.tabBarItem.image = [[viewController tabBarItemImage] originalImage];
        viewController.tabBarItem.selectedImage = [[viewController tabBarItemSelectedImage] originalImage];
        
        UINavigationController *navigationController = ((UINavigationController *(*)(id, SEL))objc_msgSend)([[self class] navigationClass], sel_registerName("alloc"));
        navigationController = ((UINavigationController *(*)(UINavigationController *, SEL, UIViewController *))objc_msgSend)(navigationController, @selector(initWithRootViewController:), viewController);
        
        [viewControllers addObject:navigationController];
    }];
    
    self.viewControllers = viewControllers;
}

#pragma mark - Setter
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    self.tabView.selectedIndex = selectedIndex;
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    [super setSelectedViewController:selectedViewController];
    NSUInteger selectedIndex = [self.viewControllers indexOfObject:selectedViewController];
    self.tabView.selectedIndex = selectedIndex;
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    [super setViewControllers:viewControllers];
    self.tabView.viewControllers = viewControllers;
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    self.tabView.viewControllers = viewControllers;
}

#pragma mark - MNTabBarDelegate
- (BOOL)tabBar:(MNTabBar *)tabBar shouldSelectItemOfIndex:(NSUInteger)index {
    return YES;
}

- (void)tabBar:(MNTabBar *)tabBar didSelectItemOfIndex:(NSUInteger)selectedIndex {
    self.selectedIndex = selectedIndex;
}

- (void)tabBar:(MNTabBar *)tabBar didRepeatSelectItemOfIndex:(NSUInteger)selectedIndex {
    if (self.viewControllers.count <= selectedIndex) return;
    UIViewController *vc = self.viewControllers[selectedIndex];
    do {
        if ([vc isKindOfClass:UINavigationController.class]) {
            UINavigationController *nav = (UINavigationController *)vc;
            vc = nav.viewControllers.count ? nav.viewControllers.lastObject : nil;
        } else if ([vc isKindOfClass:UITabBarController.class]) {
            UITabBarController *tab = (UITabBarController *)vc;
            vc = tab.selectedViewController;
        } else break;
    } while (vc);
    if (vc && [vc respondsToSelector:@selector(tabBarControllerDidRepeatSelectItem:)]) {
        [vc performSelector:@selector(tabBarControllerDidRepeatSelectItem:) withObject:self];
    }
}

#pragma mark - UITabBarControllerDelegate
/**交互式过渡动画*/
- (nullable id <UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController
                               interactionControllerForAnimationController: (id <UIViewControllerAnimatedTransitioning>)animationController {
    return nil;
};

/**非交互式过渡动画*/
- (nullable id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
                     animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                                       toViewController:(UIViewController *)toVC {
    NSUInteger fromVCIndex = [tabBarController.viewControllers indexOfObject:fromVC];
    NSUInteger toVCIndex = [tabBarController.viewControllers indexOfObject:toVC];
    if (fromVCIndex == toVCIndex) return nil;
    MNControllerTransitionOperation operation = fromVCIndex < toVCIndex ? MNControllerTransitionOperationPush : MNControllerTransitionOperationPop;
    MNTransitionAnimator *animator = [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeSoluble];
    animator.transitionOperation = operation;
    animator.tabBarTransitionType = MNTabBarTransitionTypeNone;
    return animator;
};

#pragma mark - 控制屏幕旋转方法
- (BOOL)shouldAutorotate {
    if (self.selectedViewController) {
        return [self.selectedViewController shouldAutorotate];
    }
    return YES;
}
- (UIInterfaceOrientationMask)tabBarControllerSupportedInterfaceOrientations:(UITabBarController *)tabBarController {
    if (self.selectedViewController) {
        return [self.selectedViewController supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskAll;
}
- (UIInterfaceOrientation)tabBarControllerPreferredInterfaceOrientationForPresentation:(UITabBarController *)tabBarController {
    return IS_IPAD ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait;
}

#pragma mark - 导航类
+ (Class)navigationClass {
    return NSClassFromString(@"MNNavigationController");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
