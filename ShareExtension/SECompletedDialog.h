//
//  SECompletedDialog.h
//  ShareExtension
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  分享完成弹窗

#import <UIKit/UIKit.h>

@interface SECompletedDialog : UIView
/**
 显示弹窗
 @param superview 父视图
 @param delay 延迟时间
 @param completionHandler 结束回调
 */
- (void)showInView:(UIView *)superview delay:(NSTimeInterval)delay completionHandler:(void(^)(void))completionHandler;
/**
 显示弹窗
 @param superview 父视图
 @param message 提示信息
 @param delay 延迟时间
 @param completionHandler 结束回调
 */
- (void)showInView:(UIView *)superview message:(NSString *)message delay:(NSTimeInterval)delay completionHandler:(void(^)(void))completionHandler;

@end
