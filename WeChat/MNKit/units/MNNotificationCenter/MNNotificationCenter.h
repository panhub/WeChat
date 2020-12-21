//
//  MNNotificationCenter.h
//  MNKit
//
//  Created by Vicent on 2020/11/19.
//  通知中心

#import <Foundation/Foundation.h>
#import "MNNotification.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNNotificationCenter : NSObject

/**提供全局唯一实例*/
@property (class, readonly, strong) MNNotificationCenter *defaultCenter;

/**
 发送通知
 @param notification 指定通知
 @return 是否发送成功
 */
- (BOOL)postNotification:(MNNotification *)notification;
/**
 发送指定通知
 @param aName 通知名称
 @return 是否发送成功
 */
- (BOOL)postNotificationName:(MNNotificationName)aName;
/**
 发送指定通知
 @param aName 通知名称
 @param anObject 通知参数
 @return 是否发送成功
 */
- (BOOL)postNotificationName:(MNNotificationName)aName object:(nullable id)anObject;
/**
 发送指定通知
 @param aName 通知名称
 @param anObject 通知参数
 @param userInfo 通知信息
 @return 是否发送成功
 */
- (BOOL)postNotificationName:(MNNotificationName)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)userInfo;

/**
 添加通知观察者
 @param observer 监听者
 @param aSelector 响应方法
 @param aName 通知名称
 @return 是否添加成功
 */
- (BOOL)addObserver:(id)observer selector:(SEL)aSelector name:(MNNotificationName)aName;

/**
 删除通知观察者
 @param observer 观察者
 */
- (void)removeObserver:(id)observer;
/**
 删除通知观察者
 @param observer 观察者
 @param aName 通知名称
 */
- (void)removeObserver:(id)observer name:(nullable MNNotificationName)aName;

@end

NS_ASSUME_NONNULL_END
