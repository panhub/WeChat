//
//  MNAlertView.h
//  MNKit
//
//  Created by Vincent on 2018/5/16.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MNAlertView;

@protocol MNAlertViewDelegate<NSObject>
@optional
- (void)alertViewEnsureButtonClicked:(MNAlertView *)alertView;
- (void)alertView:(MNAlertView *)alertView buttonClickedAtIndex:(NSInteger)buttonIndex;
@end

typedef void(^MNAlertViewHandler)(MNAlertView *alertView, NSInteger buttonIndex);

@interface MNAlertView : UIView
/**
 标题
 */
@property (nonatomic, readonly) NSString *titleText;
/**
 提示信息
 */
@property (nonatomic, readonly) NSString *messageText;
/**
 提示图片
 */
@property (nonatomic, readonly, strong) UIImage *image;
/**
 确定按钮索引
 */
@property (nonatomic, readonly) NSInteger ensureButtonIndex;
/**
 获取当前显示弹窗
 */
@property (nonatomic, readonly, class) MNAlertView *currentAlertView;

/**
 提示弹窗初始化<代理, 可变参数>
 @param title 标题
 @param message 信息
 @param delegate 交互代理
 @param ensureButtonTitle 确定按钮标题
 @param otherButtonTitle 其他按钮
 @return 弹窗实例
 */
+ (instancetype)alertViewWithTitle:(id)title
                           message:(id)message
                          delegate:(id<MNAlertViewDelegate>)delegate
                 ensureButtonTitle:(NSString *)ensureButtonTitle
                 otherButtonTitles:(NSString *)otherButtonTitle,...NS_REQUIRES_NIL_TERMINATION;

/**
 提示弹窗初始化<Block, 可变参数>
 @param title 标题
 @param message 提示信息
 @param handler 按钮事件回调
 @param ensureButtonTitle 确定按钮标题
 @param otherButtonTitle 其他按钮标题
 @return 提示弹窗实例
 */
+ (instancetype)alertViewWithTitle:(id)title
                           message:(id)message
                           handler:(MNAlertViewHandler)handler
                 ensureButtonTitle:(NSString *)ensureButtonTitle
                 otherButtonTitles:(NSString *)otherButtonTitle,...NS_REQUIRES_NIL_TERMINATION;

/**
 提示弹窗初始化<代理, 可变参数>
 @param title 标题
 @param image 图片
 @param message 信息
 @param delegate 交互代理
 @param ensureButtonTitle 确定按钮标题
 @param otherButtonTitle 其他按钮
 @return 弹窗实例
 */
+ (instancetype)alertViewWithTitle:(id)title
                             image:(UIImage *)image
                           message:(id)message
                          delegate:(id<MNAlertViewDelegate>)delegate
                 ensureButtonTitle:(NSString *)ensureButtonTitle
                 otherButtonTitles:(NSString *)otherButtonTitle,...NS_REQUIRES_NIL_TERMINATION;

/**
 提示弹窗初始化<Block, 可变参数>
 @param title 标题
 @param image 图片
 @param message 提示信息
 @param handler 事件回调
 @param ensureButtonTitle 确定按钮标题
 @param otherButtonTitle 其他按钮标题
 @return 提示弹窗实例
 */
+ (instancetype)alertViewWithTitle:(id)title
                             image:(UIImage *)image
                           message:(id)message
                           handler:(MNAlertViewHandler)handler
                 ensureButtonTitle:(NSString *)ensureButtonTitle
                 otherButtonTitles:(NSString *)otherButtonTitle,...NS_REQUIRES_NIL_TERMINATION;

/**
 提示弹窗便捷方式
 @param title 标题
 @param message 信息
 @param ensureButtonTitle 确定按钮
 */
+ (void)showAlertViewWithTitle:(id)title
                       message:(id)message
             ensureButtonTitle:(NSString *)ensureButtonTitle;

/**
 调整图片高度
 @param height 指定高度<内部会根据图片自适应>
 */
- (void)resizingImageToHeight:(CGFloat)height;

/**
 获取指定索引按钮标题
 @param buttonIndex 按钮索引
 @return 按钮标题
 */
- (NSString *)buttonTitleOfIndex:(NSUInteger)buttonIndex;

/**
 设置按钮标题颜色
 @param buttonTitleColor 标题颜色
 @param index 索引
 */
- (void)setButtonTitleColor:(UIColor *)buttonTitleColor ofIndex:(NSInteger)index;

/**
 设置当前显示的弹出窗按钮标题颜色
 @param buttonTitleColor 标题颜色
 @param index 索引
 */
+ (void)setAlertViewButtonTitleColor:(UIColor *)buttonTitleColor ofIndex:(NSInteger)index;

/**
 弹出弹窗
 */
- (void)show;

/**
 强制关闭所有弹窗
 */
+ (void)closeAlertView;

@end

