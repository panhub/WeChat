//
//  UIView+MNLoadDialog.h
//  MNKit
//
//  Created by Vincent on 2020/1/11.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNLoadDialog.h"

@interface UIView (MNLoadDialog)
/**
 *显示Load弹窗<默认样式>
 */
- (void)showDialog;

/**
 *显示Load弹窗<默认样式>
 *@param message 提示信息
 */
- (void)showLoadDialog:(NSString *)message;

/**
 显示加载弹窗<事件回调, 结束回调>
 @param message 提示信息
 @param eventHandler 事件回调
 @param completionHandler 结束回调
 */
- (void)showLoadDialog:(NSString *)message eventHandler:(void(^)(void))eventHandler completionHandler:(void(^)(void))completionHandler;

/**
 显示Mask弹窗
 @param message 提示信息
 */
- (void)showMaskDialog:(NSString *)message;

/**
 显示Activity弹窗
 @param message 提示信息
 */
- (void)showActivityDialog:(NSString *)message;

/**
 显示Rotate弹窗
 @param message 提示信息
 */
- (void)showRotateDialog:(NSString *)message;

/**
 显示Dot弹窗
 */
- (void)showDotDialog;

/**
 *显示错误弹窗
 *@param message 提示信息
 */
- (void)showErrorDialog:(NSString *)message;

/**
 *显示错误弹窗
 *@param message 提示信息
 @param completionHandler 完成回调
 */
- (void)showErrorDialog:(NSString *)message completionHandler:(void(^)(void))completionHandler;

/**
 *显示完成弹窗
 *@param message 提示信息
 */
- (void)showCompletedDialog:(NSString *)message;

/**
 *显示完成弹窗
 *@param message 提示信息
 @param completionHandler 完成回调
 */
- (void)showCompletedDialog:(NSString *)message completionHandler:(void(^)(void))completionHandler;

/**
 *显示错误弹窗
 *@param info 提示信息
 */
- (void)showInfoDialog:(NSString *)info;

/**
 显示进度弹窗
 @param message 提示信息
 */
- (void)showProgressDialog:(NSString *)message;

/**
 更新进度弹窗
 @param progress 进度
 @return 是否更新成功
 */
- (BOOL)updateDialogProgress:(CGFloat)progress;

/**
 *显示加载弹窗
 *@param style 样式
 *@param message 提示信息
 */
- (void)showDialog:(MNLoadDialogStyle)style message:(NSString *)message;

/**
 更新弹窗提示消息
 @param message 新的提示消息<只是简单替换文字>
 @return 是否更新成功
*/
- (BOOL)updateDialogMessage:(NSString *)message;

/**
 *关闭加载辅弹窗
 */
- (void)closeDialog;

/**
 关闭加载弹窗
 @param completion 消失回调
 */
- (void)closeDialogWithCompletionHandler:(void(^)(void))completion;

/**
关闭进度弹窗
@param completion 消失回调
*/
- (void)closeProgressDialogWithCompletionHandler:(void(^)(void))completion;

@end


@interface UIView (MNWeChatDialog)
/**
 显示微信弹窗
 */
- (void)showWeChatDialog;

/**
 微信加载弹窗<延迟结束回调>
 @param delay 等待时间
 @param completionHandler 消失回调
 */
- (void)showWeChatDialogDelay:(NSTimeInterval)delay completionHandler:(void(^)(void))completionHandler;

/**
 微信加载弹窗<事件回调>
 @param delay 延迟时间结束
 @param eventHandler 显示后回调处理事件
 @param completionHandler 消失回调
 */
- (void)showWeChatDialogDelay:(NSTimeInterval)delay eventHandler:(void(^)(void))eventHandler  completionHandler:(void(^)(void))completionHandler;

/**
 微信加载弹窗<判断是否加载>
 @param isShow 是否显示弹窗
 @param delay 等待时间
 @param completionHandler 消失回调
 */
- (void)showWeChatDialog:(BOOL)isShow delay:(NSTimeInterval)delay completionHandler:(void(^)(void))completionHandler;

/**
 显示支付弹窗
 */
- (void)showPayDialog;

/**
 适配微信项目支付弹框
 @param delay 等待时间
 @param completionHandler 消失回调
 */
- (void)showPayDialogDelay:(NSTimeInterval)delay completionHandler:(void(^)(void))completionHandler;

/**
 适配微信项目支付弹框
 @param isShow 是否显示弹窗
 @param delay 等待时间
 @param completionHandler 消失回调
 */
- (void)showPayDialog:(BOOL)isShow delay:(NSTimeInterval)delay completionHandler:(void(^)(void))completionHandler;

/**
 适配微信项目支付弹框
 @param isShow 是否显示弹窗
 @param delay 等待时间
 @param eventHandler 事件
 @param completionHandler 消失回调
 */
- (void)showPayDialog:(BOOL)isShow delay:(NSTimeInterval)delay  eventHandler:(void(^)(void))eventHandler completionHandler:(void(^)(void))completionHandler;

@end
