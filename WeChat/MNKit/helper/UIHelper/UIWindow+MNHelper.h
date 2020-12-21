//
//  UIWindow+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2019/1/31.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (MNHelper)
/**
 KeyWindow
 <命名keyWindow 会崩溃, 估计与内部冲突>
 */
@property (nonatomic, weak, readonly, class) UIWindow *mainWindow;
/**
 正在显示的控制器
 */
@property (nonatomic, weak, readonly, class) UIViewController *presentedViewController;
/**
 正在显示的导航控制器
 */
@property (nonatomic, weak, readonly, class) UINavigationController *presentedNavigationController;

/**
 取消键盘, 结束输入响应
 @param force 是否
 @return 是否成功关闭
 */
+ (BOOL)endEditing:(BOOL)force;

@end

