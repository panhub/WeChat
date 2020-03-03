//
//  WeAppDelegate.h
//  MNChat
//
//  Created by Vincent on 2019/2/20.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeAppDelegate : UIResponder <UIApplicationDelegate>

/**窗口*/
@property (strong, nonatomic) UIWindow *window;

/**
 显示登录界面
 */
- (void)makeLoginAndVisible;

/**
 显示主界面
 */
- (void)makeKeyAndVisible;

/**
 修改调试状态
 */
- (void)changeDebugState;

/**
 退出登录
 */
- (void)logout;

/**
 在调试状态打开的情况下使调试按钮可见
 @param isVisible 是否可见
 */
- (void)makeDebugVisible:(BOOL)isVisible;

@end

