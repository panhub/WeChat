//
//  MNAuthenticator.h
//  MNKit
//
//  Created by Vincent on 2018/10/17.
//  Copyright © 2018年 小斯. All rights reserved.
//  权限获取

#import <Foundation/Foundation.h>

typedef void(^MNAuthorizationStatusHandler)(BOOL allowed);

@interface MNAuthenticator : NSObject

/**
 获取相册权限
 @param handler 是否允许
 */
+ (void)requestAlbumAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler;

/**
 获取相机权限
 @param handler 是否允许
 */
+ (void)requestCameraAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler;

/**
 获取麦克风权限 一
 @param handler 是否允许
 */
+ (void)requestMicrophoneAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler;

/**
 获取麦克风权限 二
 @param handler 是否允许
 */
+ (void)requestMicrophonePermissionWithHandler:(MNAuthorizationStatusHandler)handler;

/**
 获取通讯录权限
 @param handler 是否允许
 */
+ (void)requestAddressBookAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler;

/**
获取日历权限
 @param handler 是否允许
 */
+ (void)requestEntityAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler;

/**
 获取提醒权限
 @param handler 是否允许
 */
+ (void)requestRemindAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler;

/**
获取网络权限
@param handler 是否允许
*/
+ (void)requestNetworkAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler;

/**
获取定位权限
@param handler 是否允许
*/
+ (void)requestLocationAuthorizationStatusWithHandler:(MNAuthorizationStatusHandler)handler;

@end

