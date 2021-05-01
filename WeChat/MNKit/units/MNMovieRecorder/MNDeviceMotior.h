//
//  MNDeviceMotior.h
//  MNKit
//
//  Created by Vicent on 2021/3/10.
//  Copyright © 2021 Vincent. All rights reserved.
//  检测控制

#import <Foundation/Foundation.h>
#import <UIKit/UIDevice.h>

NS_ASSUME_NONNULL_BEGIN

/**获取通知内设备方向的Key*/
FOUNDATION_EXTERN NSString * const MNDeviceOrientationChangeKey;

/**设备方向变化通知*/
FOUNDATION_EXTERN NSNotificationName const MNDeviceOrientationDidChangeNotification;

@interface MNDeviceMotior : NSObject

/**更新速率*/
@property (nonatomic) NSTimeInterval updateInterval;

/**当前设备方向*/
@property (nonatomic) UIDeviceOrientation orientation;

/**
 开启设备陀螺仪检测
 */
- (void)startMotior;

/**
 停止设备陀螺仪检测
 */
- (void)stopMotior;

/**
 开启设备陀螺仪检测并在必要时发送通知
 */
- (void)beginGeneratingDeviceOrientationNotifications;

/**
 关闭设备陀螺仪检测通知(不关闭检测)
 */
- (void)endGeneratingDeviceOrientationNotifications;

@end

NS_ASSUME_NONNULL_END
