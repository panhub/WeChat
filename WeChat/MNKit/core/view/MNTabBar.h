//
//  MNTabBar.h
//  MNKit
//
//  Created by Vincent on 2018/12/15.
//  Copyright © 2018年 小斯. All rights reserved.
//  取代UITabBar

#import <UIKit/UIKit.h>
#import "MNTabBarItem.h"
@class MNTabBar;

@protocol MNTabBarDelegate <NSObject>
@optional
- (BOOL)tabBar:(MNTabBar *)tabBar shouldSelectItemOfIndex:(NSUInteger)index;
- (void)tabBar:(MNTabBar *)tabBar didRepeatSelectItemOfIndex:(NSUInteger)selectedIndex;
@required
- (void)tabBar:(MNTabBar *)tabBar didSelectItemOfIndex:(NSUInteger)selectedIndex;
@end

@interface MNTabBar : UIView <UIAppearance, UIAppearanceContainer>

/**
 交互代理
 */
@property (nonatomic, weak) id<MNTabBarDelegate> delegate;
/**
 子控制器
 */
@property (nonatomic, weak) NSArray<UIViewController *>* viewControllers;
/**
 选择索引
 */
@property (nonatomic) NSUInteger selectedIndex;
/**
 阴影颜色
 */
@property (nonatomic, strong) UIColor *shadowColor UI_APPEARANCE_SELECTOR;
/**
 是否需要遮罩
 */
@property (nonatomic, getter=isTranslucent) BOOL translucent UI_APPEARANCE_SELECTOR;
/**
 按钮大小
 */
@property (nonatomic) CGSize itemSize UI_APPEARANCE_SELECTOR;
/**
 按钮偏移
*/
@property (nonatomic) UIOffset itemOffset UI_APPEARANCE_SELECTOR;
/**
 按钮触发区域
*/
@property (nonatomic) UIEdgeInsets itemTouchInset UI_APPEARANCE_SELECTOR;

/**
 唯一实例化入口
 @return 自定义TabBar实例
 */
+ (instancetype)tabBar;

@end
