//
//  UIAlertController+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2019/2/26.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (MNHelper)

/**
 获取弹窗控制器实例
 @param title 标题
 @param message 信息
 @param action 动作按钮
 @return 弹窗控制器
 */
+ (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message actions:(UIAlertAction *)action,...NS_REQUIRES_NIL_TERMINATION;

/**
 获取弹窗控制器实例

 @param title 标题
 @param message 信息
 @param handler 输入框配置回调
 @param action 动作按钮
 @return 弹窗控制器
 */
+ (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message textFieldHandler:(void (^)(UITextField *textField))handler actions:(UIAlertAction *)action,...NS_REQUIRES_NIL_TERMINATION;

/**
 弹出提示弹窗控制器
 @param message 提示信息
 */
+ (void)showMessage:(NSString *)message;

/**
 弹出弹窗控制器
 @param title 标题
 @param message 提示信息
 @param action 动作按钮
 */
+ (void)showTitle:(NSString *)title message:(NSString *)message action:(UIAlertAction *)action;

/**
 在Window最上层控制器present弹窗
 */
- (void)show;

@end

