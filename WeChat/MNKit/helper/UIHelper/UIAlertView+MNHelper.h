//
//  UIAlertView+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/12/8.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertView (MNHelper)

/**
 显示系统弹窗
 @param message 弹窗信息
 */
+ (void)showMessage:(NSString *)message;

/**
 显示系统弹窗
 @param message 弹窗信息
 @param cancelButtonTitle 取消按钮标题
 */
+ (void)showMessage:(NSString *)message cancelButtonTitle:(NSString * _Nullable)cancelButtonTitle;

/**
 显示系统弹窗
 @param title 标题
 @param message 提示信息
 @param cancelButtonTitle 取消按钮标题
 */
+ (void)showAlertWithTitle:(NSString * _Nullable)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString * _Nullable)cancelButtonTitle;

@end

NS_ASSUME_NONNULL_END
