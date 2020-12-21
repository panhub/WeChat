//
//  UIDevice+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/12/12.
//  Copyright © 2018年 小斯. All rights reserved.
//  设备信息

#import <UIKit/UIKit.h>
#import <Foundation/NSString.h>
#import <Foundation/NSObjCRuntime.h>
#import <CoreGraphics/CGBase.h>

@interface UIDevice (MNHelper)
/**
 内部定义 Device.Model
 */
@property (nonatomic, readonly, class) NSString *model;
/**
 是否为越狱设备
 */
@property (nonatomic, readonly, class, getter=isBreakDevice) BOOL breakDevice;

/**
 *获取设备类型(e.g. @"iPhone", @"iPod touch")
 *@return 设备类型
 */
FOUNDATION_EXPORT NSString* UIDeviceModel (void);

/**
 *获取设备名称(用户自定义 e.g. "My iPhone")
 *@return 设备名称(用户自定义)
 */
FOUNDATION_EXPORT NSString* UIDeviceName (void);

/**
 *是否为手机
 *@return 是否为手机
 */
FOUNDATION_EXPORT BOOL UIInterfacePhoneModel (void);

/**
 *是否为Pad
 *@return 是否为Pad
 */
FOUNDATION_EXPORT BOOL UIInterfacePadModel (void);

/**
 *是否是模拟器
 *@return YES真机 NO模拟器
 */
FOUNDATION_EXPORT BOOL UIDeviceSimulator (void);

/**
 *获取 系统版本号(NSString)
 *@return 系统(iOS)版本号
 */
FOUNDATION_EXPORT NSString* IOS_VERSION (void);

/**
 获取 系统版本号(CGFloat)
 @return 系统(iOS)版本号
 */
FOUNDATION_EXPORT CGFloat IOS_VERSION_NUMBER (void);

/**
 当前系统版本是否是某个版本
 @param version 指定版本
 @return 判断结果
 */
FOUNDATION_EXPORT BOOL IOS_VERSION_EQUAL (CGFloat version);

/**
 当前系统版本 >= 某个版本
 @param version 指定版本
 @return 判断结果
 */
FOUNDATION_EXPORT BOOL IOS_VERSION_LATER (CGFloat version);

/**
 当前系统版本 <= 某个版本
 @param version 指定版本
 @return 判断结果
 */
FOUNDATION_EXPORT BOOL IOS_VERSION_UNDER (CGFloat version);

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

@end
