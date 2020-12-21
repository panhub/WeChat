//
//  WechatDelegate.h
//  MNChat
//
//  Created by Vincent on 2019/2/20.
//  Copyright © 2019年 小斯. All rights reserved.
//  程序代理入口
//  requestLocationAuthorizationStatusWithHandler
//  timeMonitorInterval
//  timeMonitorInterval
#import <UIKit/UIKit.h>

@interface WechatDelegate : UIResponder <UIApplicationDelegate>

/**窗口*/
@property (strong, nonatomic) UIWindow *window;

/**
 修改调试状态
 */
- (void)changeDebugState;

/**
 在调试状态打开的情况下使调试按钮可见
 @param isVisible 是否可见
 */
- (void)makeDebugVisible:(BOOL)isVisible;

@end

