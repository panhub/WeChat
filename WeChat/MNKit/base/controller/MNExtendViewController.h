//
//  MNExtendViewController.h
//  MNKit
//
//  Created by Vincent on 2017/11/15.
//  Copyright © 2017年 小斯. All rights reserved.
//  带有自定义导航栏基类

#import "MNBaseViewController.h"
#import "MNNavBarTitleView.h"
#import "MNNavigationBar.h"

@interface MNExtendViewController : MNBaseViewController<MNNavigationBarDelegate>

/**
 自定义导航视图
 */
@property(nonatomic, strong, readonly) MNNavigationBar *navigationBar;

/**
 导航栏高度
 */
@property(nonatomic, readonly) CGFloat navigationBarHeight;

@end
