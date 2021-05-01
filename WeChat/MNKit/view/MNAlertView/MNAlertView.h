//
//  MNAlertView.h
//  MNKit
//
//  Created by Vincent on 2018/5/16.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNAlertProtocol.h"
@class MNAlertView;

@protocol MNAlertViewDelegate<NSObject>
@optional
- (void)alertViewEnsureButtonClicked:(MNAlertView *_Nonnull)alertView;
- (void)alertView:(MNAlertView *_Nonnull)alertView buttonClickedAtIndex:(NSInteger)buttonIndex;
@end

UIKIT_EXTERN const NSInteger MNAlertViewTag;

typedef void(^_Nullable MNAlertViewHandler)(MNAlertView *_Nonnull alertView, NSInteger buttonIndex);

NS_ASSUME_NONNULL_BEGIN

@interface MNAlertView : UIView<MNAlertProtocol>
/**
 标题
 */
@property (nonatomic, readonly, nullable) id title;
/**
 提示信息
 */
@property (nonatomic, readonly, nullable) id message;
/**
 提示信息
 */
@property (nonatomic, readonly, nullable) NSString *messageText;
/**
 提示图片
 */
@property (nonatomic, readonly, nullable) UIImage *image;
/**
 确定按钮索引
 */
@property (nonatomic, readonly) NSInteger ensureButtonIndex;
/**
 获取当前显示弹窗
 */
@property (nonatomic, readonly, class, nullable) MNAlertView *currentAlertView;

/**
 提示弹窗初始化<代理, 可变参数>
 @param title 标题<NSString, NSAttributedString>
 @param message 提示信息<NSString, NSAttributedString>
 @param delegate 交互代理
 @param ensureButtonTitle 确定按钮标题
 @param otherButtonTitle 其他按钮
 @return 弹窗实例
 */
+ (instancetype)alertViewWithTitle:(id _Nullable)title
                           message:(id _Nullable)message
                          delegate:(id<MNAlertViewDelegate> _Nullable)delegate
                 ensureButtonTitle:(id _Nullable)ensureButtonTitle
                 otherButtonTitles:(id _Nullable)otherButtonTitle,...NS_REQUIRES_NIL_TERMINATION;

/**
 提示弹窗初始化<Block, 可变参数>
 @param title 标题<NSString, NSAttributedString>
 @param message 提示信息<NSString, NSAttributedString>
 @param handler 按钮事件回调
 @param ensureButtonTitle 确定按钮标题
 @param otherButtonTitle 其他按钮标题
 @return 提示弹窗实例
 */
+ (instancetype)alertViewWithTitle:(id _Nullable)title
                           message:(id _Nullable)message
                           handler:(MNAlertViewHandler _Nullable)handler
                 ensureButtonTitle:(id _Nullable)ensureButtonTitle
                 otherButtonTitles:(id _Nullable)otherButtonTitle,...NS_REQUIRES_NIL_TERMINATION;

/**
 提示弹窗初始化<代理, 可变参数>
 @param title 标题<NSString, NSAttributedString>
 @param image 图片
 @param message 提示信息<NSString, NSAttributedString>
 @param delegate 交互代理
 @param ensureButtonTitle 确定按钮标题
 @param otherButtonTitle 其他按钮
 @return 弹窗实例
 */
+ (instancetype)alertViewWithTitle:(id _Nullable)title
                             image:(UIImage *_Nullable)image
                           message:(id _Nullable)message
                          delegate:(id<MNAlertViewDelegate> _Nullable)delegate
                 ensureButtonTitle:(id _Nullable)ensureButtonTitle
                 otherButtonTitles:(id _Nullable)otherButtonTitle,...NS_REQUIRES_NIL_TERMINATION;

/**
 提示弹窗初始化<Block, 可变参数>
 @param title 标题<NSString, NSAttributedString>
 @param image 图片
 @param message 提示信息<NSString, NSAttributedString>
 @param handler 事件回调
 @param ensureButtonTitle 确定按钮标题
 @param otherButtonTitle 其他按钮标题
 @return 提示弹窗实例
 */
+ (instancetype)alertViewWithTitle:(id _Nullable)title
                             image:(UIImage *_Nullable)image
                           message:(id _Nullable)message
                           handler:(MNAlertViewHandler _Nullable)handler
                 ensureButtonTitle:(id _Nullable)ensureButtonTitle
                 otherButtonTitles:(id _Nullable)otherButtonTitle,...NS_REQUIRES_NIL_TERMINATION;

/**
 提示弹窗便捷方式
 @param title 标题<NSString, NSAttributedString>
 @param message 提示信息<NSString, NSAttributedString>
 @param cancelButtonTitle 确定按钮标题
 */
+ (void)showAlertWithTitle:(id _Nullable)title
                   message:(id _Nullable)message
         cancelButtonTitle:(id)cancelButtonTitle;

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
- (NSString *_Nullable)buttonTitleOfIndex:(NSUInteger)buttonIndex;

/**
 设置按钮标题颜色
 @param buttonTitleColor 标题颜色
 @param index 索引
 */
- (void)setButtonTitleColor:(UIColor *_Nullable)buttonTitleColor ofIndex:(NSInteger)index;

/**
 设置当前显示的弹出窗按钮标题颜色
 @param buttonTitleColor 标题颜色
 @param index 索引
 */
+ (void)setAlertViewButtonTitleColor:(UIColor *_Nullable)buttonTitleColor ofIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
