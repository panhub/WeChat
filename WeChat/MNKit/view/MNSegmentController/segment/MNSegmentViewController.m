//
//  MNSegmentViewController.m
//  MNKit
//
//  Created by Vincent on 2018/12/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNSegmentViewController.h"

@interface MNSegmentViewController ()
@property (nonatomic, assign) CGRect frame;
@end

@implementation MNSegmentViewController
- (instancetype)init {
    if (self = [super init]) {
        [self initialized];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initialized];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
        self.frame = frame;
        self.childController = YES;
        [self initialized];
    }
    return self;
}

- (void)initialized {
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 11.0, *)) {
        self.additionalSafeAreaInsets = UIEdgeInsetsZero;
    }
    #endif
}

- (void)loadView {
    UIView *view = [[UIView alloc]initWithFrame:self.frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor clearColor];
    view.userInteractionEnabled = YES;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma Getter
- (CGRect)frame {
    return CGRectEqualToRect(_frame, CGRectZero) ? [[UIScreen mainScreen] bounds] : _frame;
}

#pragma mark - 禁止自动更新
- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

#pragma mark - 屏幕旋转与支持方向
/**YES允许旋转, NO禁止*/
- (BOOL)shouldAutorotate {
    return NO;
}

/**返回支持的方向*/
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

/**由模态推出的视图控制器 优先支持的屏幕方向*/
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - 子控制器
- (BOOL)isChildViewController {
    return self.childController;
}

@end
