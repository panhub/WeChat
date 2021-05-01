//
//  MNMenuView.h
//  MNKit
//
//  Created by Vincent on 2019/4/3.
//  Copyright © 2019 Vincent. All rights reserved.
//  菜单弹窗

#import <UIKit/UIKit.h>
#import "MNAlertProtocol.h"
@class MNMenuView, MNMenuConfiguration;

typedef NS_ENUM(NSInteger, MNMenuArrowDirection) {
    MNMenuArrowUp = 0,
    MNMenuArrowDown,
    MNMenuArrowLeft,
    MNMenuArrowRight
};

typedef NS_ENUM(NSInteger, MNMenuAlignment) {
    MNMenuAlignmentVertical = 0,
    MNMenuAlignmentHorizontal
};

typedef NS_ENUM(NSInteger, MNMenuAnimation) {
    MNMenuAnimationZoom = 0,
    MNMenuAnimationMove,
    MNMenuAnimationFade
};

UIKIT_EXTERN const NSInteger MNMenuViewTag;

typedef void (^_Nullable MNMenuShowHandler)(UIView *_Nonnull view, BOOL animated);
typedef void ( ^_Nullable MNMenuDismissHandler)(UIView *_Nonnull view, BOOL animated, void (^ _Nonnull finishHandler)(void));
typedef void (^_Nullable MNMenuConfigurationHandler)(MNMenuConfiguration *_Nonnull configuration);
typedef void (^_Nullable MNMenuClickedHandler)(MNMenuView *_Nonnull menuView, UIView *_Nonnull item);
typedef void (^_Nullable MNMenuCreatedHandler)(MNMenuView *_Nonnull menuView, NSUInteger idx, UIButton *_Nonnull item);

NS_ASSUME_NONNULL_BEGIN

@interface MNMenuConfiguration : NSObject
/**
 箭头大下
 */
@property (nonatomic) CGSize arrowSize;
/**
 箭头偏移<默认指向目标视图>根据方向, 调整纵横向偏移
 */
@property (nonatomic) UIOffset arrowOffset;
/**
 圆角半径
 */
@property (nonatomic) CGFloat contentRadius;
/**
 内容视图四周边距
 */
@property (nonatomic) UIEdgeInsets contentInsets;
/**
 动画时长
 */
@property (nonatomic) NSTimeInterval animationDuration;
/**
 颜色可视颜色
 */
@property (nonatomic, strong) UIColor *fillColor;
/**
 边框颜色
 */
@property (nonatomic, strong) UIColor *borderColor;
/**
 边框线宽度
 */
@property (nonatomic) CGFloat borderWidth;
/**
 箭头指向
 */
@property (nonatomic) MNMenuArrowDirection arrowDirection;
/**
 动画类型
 */
@property (nonatomic) MNMenuAnimation animationType;

@end

@interface MNMenuView : UIView<MNAlertProtocol>
/**
 目标视图<箭头将指向目标视图, 默认基准线为中线, 配合方向>
 */
@property (nonatomic, weak) UIView *targetView;
/**
 内容视图
 */
@property (nonatomic, strong) UIView *contentView;
/**
 标记是否展开
 */
@property (nonatomic, getter=isExpanded, readonly) BOOL expanded;
/**
 配置信息
 */
@property (nonatomic, strong, readonly) MNMenuConfiguration *configuration;
/**
 展示动画回调
 */
@property (nonatomic, copy) MNMenuShowHandler showHandler;
/**
 关闭动画回调
 */
@property (nonatomic, copy) MNMenuDismissHandler dismissHandler;
/**
 按钮点击回调
 */
@property (nonatomic, copy) MNMenuClickedHandler clickedHandler;
/**
 配置信息回调
 */
@property (nonatomic, copy) MNMenuConfigurationHandler configurationHandler;


#pragma mark - 菜单钮样样式快捷实例化入口
- (instancetype)initWithTitles:(NSArray <NSString *>*)titles alignment:(MNMenuAlignment)alignment createdHandler:(MNMenuCreatedHandler)createdHandler;

+ (instancetype)menuWithAlignment:(MNMenuAlignment)alignment createdHandler:(MNMenuCreatedHandler)createdHandler titles:(NSString *)title,...NS_REQUIRES_NIL_TERMINATION;

- (instancetype)initWithAlignment:(MNMenuAlignment)alignment items:(NSArray <UIView *>*)items;

+ (instancetype)menuWithAlignment:(MNMenuAlignment)alignment items:(UIView *)item,...NS_REQUIRES_NIL_TERMINATION;


#pragma mark - 更新视图
/**
 更新视图
 */
- (BOOL)updateIfNeeded;

#pragma mark - 显示与隐藏
/**
 展示菜单视图
 @param animated 是否动态展出
 */
- (void)showWithAnimated:(BOOL)animated;
/**
 展示菜单视图
 @param animated 是否动态展出
 @param clickedHandler 按钮点击回调
 */
- (void)showWithAnimated:(BOOL)animated clickedHandler:(MNMenuClickedHandler)clickedHandler;
/**
 展示菜单视图
 @param superview 指定父视图<与window同大小>
 @param animated 是否动态展出
 @param clickedHandler 按钮点击回调
 */
- (void)showInView:(UIView *_Nullable)superview animated:(BOOL)animated
    clickedHandler:(MNMenuClickedHandler _Nullable)clickedHandler;
/**
 取消展示
 @param animated 是否动态
 */
- (void)dismissWithAnimated:(BOOL)animated;

@end


@interface UIButton (MNMenuSeparator)

/**按钮分割线*/
@property (nonatomic, strong, nullable) UIView *separator;

@end

@interface UIView (MNMenuClose)

/**
 关闭自身菜单视图
 */
- (void)closeMenuView;

/**
 关闭自身菜单视图
 @param animated 是否动态
 */
- (void)closeMenuWithAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
