//
//  MNMenuView.h
//  MNKit
//
//  Created by Vincent on 2019/4/3.
//  Copyright © 2019 Vincent. All rights reserved.
//  菜单弹窗

#import <UIKit/UIKit.h>
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

NS_ASSUME_NONNULL_BEGIN

typedef void (^ _Nullable MNMenuShowHandler)(UIView *view, BOOL animated);
typedef void ( ^ _Nullable MNMenuDismissHandler)(UIView *view, BOOL animated, void (^ _Nullable finishedHandler)(void));
typedef void (^ _Nullable MNMenuConfigurationHandler)(MNMenuConfiguration *configuration);
typedef void (^ _Nullable MNMenuClickedHandler)(MNMenuView *menuView, UIView *item);

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

@interface MNMenuView : UIView
/**
 目标视图<箭头将指向目标视图, 默认基准线为中线, 配合方向>
 */
@property (nonatomic, weak) UIView *targetView;
/**
 内容视图
 */
@property (nonatomic, strong) UIView *contentView;
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
 配置信息回调
 */
@property (nonatomic, copy) MNMenuConfigurationHandler configurationHandler;


#pragma mark - 菜单钮样样式快捷实例化入口
- (instancetype)initWithTitles:(NSArray <NSString *>*)titles alignment:(MNMenuAlignment)alignment handler:(MNMenuClickedHandler)handler;

+ (instancetype)menuWithAlignment:(MNMenuAlignment)alignment handler:(MNMenuClickedHandler)handler titles:(NSString *)title,...NS_REQUIRES_NIL_TERMINATION;

- (instancetype)initWithAlignment:(MNMenuAlignment)alignment items:(NSArray <UIView *>*)items;

+ (instancetype)menuWithAlignment:(MNMenuAlignment)alignment items:(UIView *)item,...NS_REQUIRES_NIL_TERMINATION;


#pragma mark - 更新视图
/**
 更新视图
 */
- (void)updateIfNeeded;

#pragma mark - 显示与隐藏
- (void)show;

- (void)showWithAnimated:(BOOL)animated;

- (void)dismiss;

- (void)dismissWithAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
