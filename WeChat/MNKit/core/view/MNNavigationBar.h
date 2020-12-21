//
//  MNNavigationBar.h
//  MNKit
//
//  Created by Vincent on 2017/12/23.
//  Copyright © 2017年 小斯. All rights reserved.
//  自定义的导航条
//  导航栏+状态栏部分(状态栏会空出来不放置任何内容)
//  导航条是以 左 -> 右 -> 标题 的顺序来安放Item
//  左,右Item可根据暴露的方法定制, titleView可放置定制控件(如搜索框等)

#import <UIKit/UIKit.h>
#import "MNNavBarTitleView.h"
@class MNNavigationBar;

UIKIT_EXTERN const CGFloat kNavItemSize; //导航按钮默认大小
UIKIT_EXTERN const CGFloat kNavItemMargin;  //导航按钮间隔

@protocol MNNavigationBarDelegate <NSObject>
@optional
/**获取导航左右按钮*/
- (UIView *)navigationBarShouldCreateLeftBarItem;
- (UIView *)navigationBarShouldCreateRightBarItem;
/**是否显示返回按钮*/
- (BOOL)navigationBarShouldDrawBackBarItem;
/**左按钮点击事件*/
- (void)navigationBarLeftBarItemTouchUpInside:(UIView *)leftBarItem;
/**右按钮点击事件*/
- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem;
/**制作完成*/
- (void)navigationBarDidCreateBarItem:(MNNavigationBar *)navigationBar;
@end

@interface MNNavigationBar : UIView <UIAppearance>
/**导航左按钮*/
@property(nonatomic,strong,readonly) UIView *leftBarItem;
/**导航右按钮*/
@property(nonatomic,strong,readonly) UIView *rightBarItem;
/**导航标题*/
@property(nonatomic,strong,readonly) MNNavBarTitleView *titleView;
/**阴影线*/
@property(nonatomic,strong,readonly) UIImageView *shadowView;
/**是否显示遮罩<毛玻璃> default YES*/
@property(nonatomic) BOOL translucent UI_APPEARANCE_SELECTOR;
/**设置标题*/
@property(nonatomic, copy) NSString *title;
/**标题字体*/
@property(nonatomic, weak) UIFont *titleFont UI_APPEARANCE_SELECTOR;
/**标题颜色*/
@property(nonatomic, weak) UIColor *titleColor UI_APPEARANCE_SELECTOR;
/**阴影线颜色*/
@property(nonatomic, weak) UIColor *shadowColor UI_APPEARANCE_SELECTOR;
/**设置返回按钮颜色, 使用框架内部字体渲染*/
@property(nonatomic, weak) UIColor *backItemColor UI_APPEARANCE_SELECTOR;
/**设置左按钮图片*/
@property(nonatomic, weak) UIImage *leftItemImage UI_APPEARANCE_SELECTOR;
/**设置右按钮图片*/
@property(nonatomic, weak) UIImage *rightItemImage UI_APPEARANCE_SELECTOR;

/**
 *自定义导航图实例化
 *@param frame 位置
 *@param delegate 代理
 *@return 自定义导航视图
 */
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<MNNavigationBarDelegate>)delegate;

@end
