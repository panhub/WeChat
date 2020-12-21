//
//  UITabBar+MNHelper.h
//  MNKit
//
//  Created by Vicent on 2020/8/27.
//  标签条分类

#import <UIKit/UIKit.h>

#define MN_TAB_BAR_HEIGHT   UITabBar.height
#define MN_TAB_SAFE_HEIGHT  UITabBar.safeHeight

NS_ASSUME_NONNULL_BEGIN

@interface UITabBar (MNHelper)

/**线程安全的获取系统标签栏高度*/
@property (nonatomic, class, readonly) CGFloat height;

/**获取安全区域高度*/
@property (nonatomic, class, readonly) CGFloat safeHeight;

@end

NS_ASSUME_NONNULL_END
