//
//  UIDevice+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/12/12.
//  Copyright © 2018年 小斯. All rights reserved.
//  设备信息

#import <UIKit/UIKit.h>

@interface UIDevice (MNHelper)
/**
 是否为越狱设备
 */
@property (nonatomic, readonly, class, getter=isBreakDevice) BOOL breakDevice;

/**
 *获取设备类型(e.g. @"iPhone", @"iPod touch")
 *@return 设备类型
 */
NSString* UIDeviceModel (void);

/**
 *获取设备名称(用户自定义 e.g. "My iPhone")
 *@return 设备名称(用户自定义)
 */
NSString* UIDeviceName (void);

/**
 *是否为手机
 *@return 是否为手机
 */
BOOL UIInterfacePhoneModel (void);

/**
 *是否为Pad
 *@return 是否为Pad
 */
BOOL UIInterfacePadModel (void);

/**
 *是否是模拟器
 *@return YES真机 NO模拟器
 */
BOOL UIDeviceSimulator (void);

/**
 *获取 系统版本号(NSString)
 *@return 系统(iOS)版本号
 */
NSString* IOS_VERSION (void);

/**
 获取 系统版本号(CGFloat)
 @return 系统(iOS)版本号
 */
CGFloat IOS_VERSION_NUMBER (void);

/**
 当前系统版本 == 某个版本
 @param version 指定版本
 @return 判断结果 IOS_VERSION
 */
BOOL IOS_VERSION_EQUAL (CGFloat version);

/**
 当前系统版本 >= 某个版本
 @param version 指定版本
 @return 判断结果
 */
BOOL IOS_VERSION_LATER (CGFloat version);

/**
 当前系统版本 <= 某个版本
 @param version 指定版本
 @return 判断结果
 */
BOOL IOS_VERSION_UNDER (CGFloat version);

/**
 *屏幕Scale
 *@return 屏幕Scale
 */
CGFloat UIScreenScale (void);

/**
 *屏幕界限
 *@return 屏幕界限
 */
CGRect UIScreenBounds (void);

/**
 *屏幕尺寸
 @return 屏幕尺寸
 */
CGSize UIScreenSize (void);

/**
 *屏幕宽度
 *@return 屏幕宽度
 */
CGFloat UIScreenWidth (void);

/**
 *屏幕高度
 *@return 屏幕高度
 */
CGFloat UIScreenHeight (void);

/**
 *屏幕高宽最大值
 *@return 屏幕宽高最大值
 */
CGFloat UIScreenMax (void);

/**
 *屏幕高宽最小值
 *@return 屏幕宽高最小值
 */
CGFloat UIScreenMin (void);

/**
 底部安全区域高度
 @return 安全区域高度
 */
CGFloat UITabSafeHeight (void);

/**
 底部TabBar高度
 @return TabBar高度
 */
CGFloat UITabBarHeight (void);

/**
 状态栏高度
 @return 状态栏高度
 */
CGFloat UIStatusBarHeight (void);

/**
 导航栏高度
 @return 导航栏高度
 */
CGFloat UINavBarHeight (void);

/**
 状态栏 + 导航栏 高度
 @return 总高度
 */
CGFloat UITopBarHeight (void);


/**
 设备标识符
 @return 设备与应用共同作用下的标识符
 */
+ (NSString *)UUIDString;

/**
 *旋转屏幕(无论手机是否设置锁定屏幕方向)
 *Apple不允许直接调用setOrientation方法,否则有被拒的风险；
 *使用NSInvocation对象给[UIDevice currentDevice]发消息,强制改变设备方向是允许的。
 *@param orientation 屏幕方向
 *@return  是否旋转成功
 */
+ (BOOL)rotateInterfaceToOrientation:(UIInterfaceOrientation)orientation;

/**
 是否为越狱设备
 @return 是否为越狱设备
 */
+ (BOOL)isBreakDevice;

/**
 设备型号 e.g. "iPhone 7"
 @return 设备型号
 */
+ (NSString *)deviceModel;

@end
