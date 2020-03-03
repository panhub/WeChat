//
//  UIViewController+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/1/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UIViewController+MNHelper.h"

@implementation UIViewController (MNHelper)
#pragma mark - 添加子控制器
- (void)addChildViewController:(UIViewController *)childController inView:(UIView *)view {
    if (!childController) return;
    if ([self.childViewControllers containsObject:childController]) return;
    if (!view) view = self.view;
    [childController willMoveToParentViewController:self];
    [self addChildViewController:childController];
    [view addSubview:childController.view];
    [childController didMoveToParentViewController:self];
}

#pragma mark - 从父控制器中删除自身
- (void)removeFromParentController {
    if (!self.parentViewController) return;
    [self willMoveToParentViewController:nil];
    [self.view willMoveToSuperview:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [self didMoveToParentViewController:nil];
}

#pragma mark - 禁止对滚动视图进行布局
- (void)layoutExtendAdjustEdges {
    /**view的边缘允许额外布局的情况，默认为UIRectEdgeAll，意味着全屏布局(带穿透效果)*/
    self.edgesForExtendedLayout = UIRectEdgeAll;
    /**额外布局是否包括不透明的Bar，默认为NO*/
    self.extendedLayoutIncludesOpaqueBars = YES;
    /**是否自动调整滚动视图的内边距,默认YES;
     系统将会根据导航条和TabBar的情况自动增加上下内边距以防止被Bar遮挡*/
    self.automaticallyAdjustsScrollViewInsets = NO;
    /**iOS11 后 additionalSafeAreaInsets 可抵消系统的安全区域*/
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 11.0, *)) {
        self.additionalSafeAreaInsets = UIEdgeInsetsZero;
    }
    #endif
}

@end


@implementation UINavigationController (MNHelper)
#pragma mark - 寻找栈内指定类型控制器
- (UIViewController *)findViewControllerOfClass:(Class)cls {
    if (!cls) return nil;
    __block UIViewController *viewController;
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:cls]) {
            viewController = obj;
            *stop = YES;
        }
    }];
    return viewController;
}

@end
