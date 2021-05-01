//
//  UIView+MNLoadDialog.h
//  MNKit
//
//  Created by Vincent on 2020/1/11.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNLoadDialog.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (MNLoadDialog)

/**判断是否正在提示*/
@property (nonatomic, readonly, getter=isDialoging) BOOL dialoging;

/**
 *显示Load弹窗<默认样式>
 */
- (void)showDialog;

/**
 *显示Load弹窗<默认样式>
 *@param message 提示信息
 */
- (void)showLoadDialog:(NSString *_Nullable)message;

/**
 显示加载弹窗<事件回调, 结束回调>
 @param message 提示信息
 @param eventHandler 事件回调
 @param completionHandler 结束回调
 */
- (void)showLoadDialog:(NSString *_Nullable)message eventHandler:(void(^_Nullable)(void))eventHandler completionHandler:(void(^_Nullable)(void))completionHandler;

/**
 显示Mask弹窗
 @param message 提示信息
 */
- (void)showMaskDialog:(NSString *_Nullable)message;

/**
 显示Activity弹窗
 @param message 提示信息
 */
- (void)showActivityDialog:(NSString *_Nullable)message;

/**
 显示Rotate弹窗
 @param message 提示信息
 */
- (void)showRotateDialog:(NSString *_Nullable)message;

/**
 显示Dot弹窗
 */
- (void)showDotDialog;

/**
 *显示错误弹窗
 *@param message 提示信息
 */
- (void)showErrorDialog:(NSString *_Nullable)message;

/**
 *显示错误弹窗
 *@param message 提示信息
 @param completionHandler 完成回调
 */
- (void)showErrorDialog:(NSString *_Nullable)message completionHandler:(void(^_Nullable)(void))completionHandler;

/**
 *显示完成弹窗
 *@param message 提示信息
 */
- (void)showCompletedDialog:(NSString *_Nullable)message;

/**
 *显示完成弹窗
 *@param message 提示信息
 @param completionHandler 完成回调
 */
- (void)showCompletedDialog:(NSString *_Nullable)message completionHandler:(void(^_Nullable)(void))completionHandler;

/**
 *显示错误弹窗
 *@param info 提示信息
 */
- (void)showInfoDialog:(NSString *)info;

/**
 显示进度弹窗
 @param message 提示信息
 */
- (void)showProgressDialog:(NSString *_Nullable)message;

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
- (void)showDialog:(MNLoadDialogStyle)style message:(NSString *_Nullable)message;

/**
 更新弹窗提示消息
 @param message 新的提示消息<只是简单替换文字>
 @return 是否更新成功
*/
- (BOOL)updateDialogMessage:(NSString *_Nullable)message;

/**
 *关闭加载辅弹窗
 */
- (void)closeDialog;

/**
 关闭加载弹窗
 @param completion 消失回调
 */
- (void)closeDialogWithCompletionHandler:(void(^_Nullable)(void))completion;

/**
关闭进度弹窗
@param completion 消失回调
*/
- (void)closeProgressDialogWithCompletionHandler:(void(^_Nullable)(void))completion;

@end

@interface UIView (MNWechatLoading)
/**
 显示微信弹窗
 */
- (void)showWechatDialog;

/**
 微信加载弹窗<延迟结束回调>
 @param delay 等待时间
 @param completionHandler 消失回调
 */
- (void)showWechatDialogDelay:(NSTimeInterval)delay completionHandler:(void(^_Nullable)(void))completionHandler;

/**
 微信加载弹窗<事件回调>
 @param delay 延迟时间结束
 @param eventHandler 显示后回调处理事件
 @param completionHandler 消失回调
 */
- (void)showWechatDialogDelay:(NSTimeInterval)delay eventHandler:(void(^_Nullable)(void))eventHandler  completionHandler:(void(^_Nullable)(void))completionHandler;

/**
 微信加载弹窗<判断是否加载>
 @param isNeed 是否显示弹窗
 @param delay 等待时间
 @param completionHandler 消失回调
 */
- (void)showWechatDialogNeeds:(BOOL)isNeed delay:(NSTimeInterval)delay completionHandler:(void(^_Nullable)(void))completionHandler;

/**
 微信加载弹窗<判断是否加载>
 @param isNeed 是否显示弹窗
 @param delay 等待时间
 @param eventHandler 事件回调
 @param completionHandler 消失回调
 */
- (void)showWechatDialogNeeds:(BOOL)isNeed delay:(NSTimeInterval)delay  eventHandler:(void(^_Nullable)(void))eventHandler completionHandler:(void(^_Nullable)(void))completionHandler;

/**
 显示微信错误弹窗
 @param message 提示信息
 */
- (void)showWechatError:(NSString *)message;

/**
 显示微信完成弹窗
 @param message 提示信息
 */
- (void)showWechatComplete:(NSString *_Nullable)message;

/**
 显示支付弹窗
 */
- (void)showPayDialog;

/**
 适配微信项目支付弹框
 @param delay 等待时间
 @param completionHandler 消失回调
 */
- (void)showPayDialogDelay:(NSTimeInterval)delay completionHandler:(void(^_Nullable)(void))completionHandler;

/**
 适配微信项目支付弹框
 @param delay 等待时间
 @param eventHandler 事件回调
 @param completionHandler 消失回调
 */
- (void)showPayDialogDelay:(NSTimeInterval)delay eventHandler:(void(^_Nullable)(void))eventHandler  completionHandler:(void(^_Nullable)(void))completionHandler;

/**
 适配微信项目支付弹框
 @param isNeed 是否显示弹窗
 @param delay 等待时间
 @param completionHandler 消失回调
 */
- (void)showPayDialogNeeds:(BOOL)isNeed delay:(NSTimeInterval)delay completionHandler:(void(^_Nullable)(void))completionHandler;

/**
 适配微信项目支付弹框
 @param isNeed 是否显示弹窗
 @param delay 等待时间
 @param eventHandler 事件
 @param completionHandler 消失回调
 */
- (void)showPayDialogNeeds:(BOOL)isNeed delay:(NSTimeInterval)delay  eventHandler:(void(^_Nullable)(void))eventHandler completionHandler:(void(^_Nullable)(void))completionHandler;

@end

NS_ASSUME_NONNULL_END
