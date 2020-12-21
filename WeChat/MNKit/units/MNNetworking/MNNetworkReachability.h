//
//  MNNetworkReachability.h
//  MNKit
//
//  Created by Vincent on 2019/11/29.
//  Copyright © 2019 Vincent. All rights reserved.
//  网络可达性监测

#import <Foundation/Foundation.h>
#if !TARGET_OS_WATCH
/**
 网络类型
 - MNNetworkReachabilityStatusUnknown: 未知
 - MNNetworkReachabilityStatusNotReachable: 无网络
 - MNNetworkReachabilityStatusWWAN: 自带网络
 - MNNetworkReachabilityStatusWiFi: WiFi
 */
typedef NS_ENUM(NSInteger, MNNetworkReachabilityStatus) {
    MNNetworkReachabilityStatusUnknown          = -1,
    MNNetworkReachabilityStatusNotReachable     = 0,
    MNNetworkReachabilityStatusWWAN = 1,
    MNNetworkReachabilityStatusWiFi = 2,
};

FOUNDATION_EXPORT NSNotificationName const MNNetworkReachabilityStatusDidChangeNotification;
FOUNDATION_EXPORT NSString * MNStringFromNetworkReachabilityStatus(MNNetworkReachabilityStatus status);

@class MNNetworkReachability;
@protocol MNNetworkReachabilityDelegate <NSObject>
@optional;
- (void)networkReachabilityStatusDidChange:(MNNetworkReachability *)reachability;
@end

@interface MNNetworkReachability : NSObject
/**
 当前的网络状态
 */
@property (nonatomic, readonly) MNNetworkReachabilityStatus status;
/**
 当前的网络状态
 */
@property (nonatomic, readonly) NSString *reachabilityStatusString;
/**
 网络是否可访问
 */
@property (nonatomic, readonly, getter = isReachable) BOOL reachable;
/**
 当前是否可以通过WWAN访问网络
 */
@property (nonatomic, readonly, getter = isReachableWWAN) BOOL reachableWWAN;
/**
 当前是否可以通过WiFi访问网络
 */
@property (nonatomic, readonly, getter = isReachableWiFi) BOOL reachableWiFi;
/**
 状态变化代理
 */
@property (nonatomic, weak) id<MNNetworkReachabilityDelegate> delegate;

/**
 实例化本机检测实例
 @return 检测实例
 */
+ (instancetype)reachability;

/**
 依据主机名实例化<默认www.apple.com>
 @param hostname 主机名
 @return 检测实例
 */
- (instancetype)initWithHostname:(NSString *)hostname;

/**
 依据主机地址实例化
 @param hostAddress 主机地址
 @return 检测实例
 */
- (instancetype)initWithAddress:(const struct sockaddr *)hostAddress;

/**
 开始监视网络可达性状态的变化
 */
- (void)startMonitoring;

/**
 停止监视网络可达性状态的变化
 */
- (void)stopMonitoring;

/**
 设置网络可达性变化回调者
 @param handler 回调者
 */
- (void)registerStatusChangeHandler:(void (^)(MNNetworkReachabilityStatus status))handler;

@end
#endif
