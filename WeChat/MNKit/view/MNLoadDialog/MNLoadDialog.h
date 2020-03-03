//
//  MNLoadDialog.h
//  MNKit
//
//  Created by Vincent on 2018/7/20.
//  Copyright © 2018年 小斯. All rights reserved.
//  HUD抽象类
//  拒绝直接实例化, 请使用指定入口方法调用

#import <UIKit/UIKit.h>

/**
 HUD类型
 - MNLoadDialogStyleInfo: 提示信息
 - MNLoadDialogStyleActivity: 菊花样式
 - MNLoadDialogStyleShape: 半圆
 - MNLoadDialogStyleRotation: 旋转环
 - MNLoadDialogStyleBall: 小球
 - MNLoadDialogStyleDot: 圆点
 - MNLoadDialogStyleCompletion: 完成
 - MNLoadDialogStyleProgress: 进度
 - MNLoadDialogStyleMask: 旋转Mask Layer
 - MNLoadDialogStylePay: 微信支付样式
 - MNLoadDialogStyleWeChat: 微信加载弹窗
 */
typedef NS_ENUM(NSInteger, MNLoadDialogStyle) {
    MNLoadDialogStyleInfo = 0,
    MNLoadDialogStyleActivity,
    MNLoadDialogStyleShape,
    MNLoadDialogStyleRotation,
    MNLoadDialogStyleBall,
    MNLoadDialogStyleDot,
    MNLoadDialogStyleError,
    MNLoadDialogStyleCompletion,
    MNLoadDialogStyleProgress,
    MNLoadDialogStyleMask,
    MNLoadDialogStylePay,
    MNLoadDialogStyleWeChat
};

/**
 HUD背景
 - MNLoadDialogContentLight: 高亮背景
 - MNLoadDialogContentDark: 黑色背景
*/
typedef NS_ENUM(NSInteger, MNLoadDialogContentStyle) {
    MNLoadDialogContentDark = 0,
    MNLoadDialogContentLight
};

/**设置默认内容类型*/
void MNLoadDialogSetContentStyle (MNLoadDialogContentStyle type);
MNLoadDialogContentStyle MNLoadDialogGetContentStyle (void);

/**设置默认弹窗类型*/
void MNLoadDialogSetDefaultStyle (MNLoadDialogStyle style);
MNLoadDialogStyle MNLoadDialogGetDefaultStyle (void);

/**获取弹窗内容颜色*/
UIColor *MNLoadDialogContentColor (void);

UIKIT_EXTERN const CGFloat MNLoadDialogMargin;
UIKIT_EXTERN const CGFloat MNLoadDialogFontSize;
UIKIT_EXTERN const CGFloat MNLoadDialogMaxWidth;
UIKIT_EXTERN const CGFloat MNLoadDialogTextMargin;
UIKIT_EXTERN NSString *const MNLoadDialogAnimationKey;

@interface MNLoadDialog : UIView
/**弹窗类型*/
@property (nonatomic, readonly) MNLoadDialogStyle style;
/**提示信息, 'MNLoadDialogStyleDot' 无效*/
@property (nonatomic, copy, readonly) NSString *message;
/**子视图放置区*/
@property (nonatomic, strong, readonly) UIView *contentView;
/**提示图*/
@property (nonatomic, strong, readonly) UIView *containerView;
/**提示信息*/
@property (nonatomic, strong, readonly) UILabel *textLabel;
/**提示信息富文本描述*/
@property (nonatomic, strong, readonly) NSDictionary *attributes;
/**提示信息富文本*/
@property (nonatomic, strong, readonly) NSAttributedString *attributedString;

#pragma mark ==========废弃方法, 放弃使用===========
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
#pragma mark ==========废弃方法, 放弃使用===========

/**
 无提示信息的HUD
 @param style HUD类型
 @return HUD实例
 */
+ (instancetype)loadDialogWithStyle:(MNLoadDialogStyle)style;

/**
 HUD实例化入口
 @param style 类型
 @param message 提示信息
 @return HUD实例
 */
+ (instancetype)loadDialogWithStyle:(MNLoadDialogStyle)style message:(NSString *)message;

/**
 将HUD在Key Window上弹出
 @return 是否成功弹出
 */
- (BOOL)show;

/**
 将HUD在指定视图上弹出
 @param superview 指定视图
 @return 是否成功弹出
 */
- (BOOL)showInView:(UIView *)superview;

#pragma mark - 子类可重写具体逻辑
/**
 初始化变量等
 */
- (void)initialized;
/**
 创建子视图
 */
- (void)createView;
/**
 布局子视图
*/
- (void)layoutSubviewIfNeeded;
/**
 开启交互动画
 */
- (void)startAnimation;
/**
 结束动画-消失
 */
- (void)dismiss;
/**
 更新提示信息
*/
- (BOOL)updateMessage:(NSString *)message;
/**
 更新进度 仅'MNLoadDialogStyleProgress' 有效
 @param progress 进度值
 */
- (BOOL)updateProgress:(float)progress;
/**
 弹出期间是否允许交互<默认 MNLoadDialogStyleInfo YES>
 @return 是否可交互
 */
- (BOOL)interactionEnabled;
/**
 是否允许添加毛玻璃效果
 @return 是否添加毛玻璃效果
 */
- (BOOL)blurEffectEnabled;
/**
是否允许添加视觉效果
@return 是否添加视觉效果
*/
- (BOOL)motionEffectEnabled;
/**
 后台通知
 */
- (void)didEnterBackgroundNotification;
/**
 前台通知
 */
- (void)willEnterForegroundNotification;

@end
