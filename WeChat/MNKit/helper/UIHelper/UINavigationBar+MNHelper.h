//
//  UINavigationBar+MNHelper.h
//  MNKit
//
//  Created by Vicent on 2020/8/27.
//  导航条分类

#import <UIKit/UIKit.h>

#define MN_TOP_BAR_HEIGHT  UINavigationBar.height
#define MN_NAV_BAR_HEIGHT  UINavigationBar.barHeight

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationBar (MNHelper)

/**导航栏高度*/
@property (nonatomic, class, readonly) CGFloat height;

/**线程安全的获取系统导航条高度*/
@property (nonatomic, class, readonly) CGFloat barHeight;

@end

NS_ASSUME_NONNULL_END
