//
//  MNLock.h
//  MNKit
//
//  Created by Vincent on 2018/11/5.
//  Copyright © 2018年 小斯. All rights reserved.
//  线程锁
//  https://mp.weixin.qq.com/s/HGsChYxJKWNuQgdP8EkLog

#import <Foundation/Foundation.h>


#define MNThreadLock(...) \
dispatch_semaphore_wait(dispatch_semaphore_once(), DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(dispatch_semaphore_once());

NS_ASSUME_NONNULL_BEGIN

@interface MNLock : NSObject
#pragma mark - 互斥锁
///=============================================================================
/// @name 互斥锁
///=============================================================================

/**
 创建互斥锁
 @return NSLock 互斥锁
 */
NSLock * dispatch_mutex_create (void);

/**
 互斥锁锁定
 @param lock 互斥锁
 */
void dispatch_mutex_lock (NSLock *lock);

/**
 互斥锁解锁
 @param lock 互斥锁
 */
void dispatch_mutex_unlock (NSLock *lock);

/**
 创建互斥锁
 @return 互斥锁
 */
pthread_mutex_t dispatch_pthread_mutex_create (void);

#pragma mark - 递归锁
///=============================================================================
/// @name 递归锁
///=============================================================================

/**
 创建递归锁
 @return NSRecursiveLock 互斥锁
 */
NSRecursiveLock * dispatch_recursive_create (void);

/**
 递归锁锁定
 @param lock 递归锁
 */
void dispatch_recursive_lock (NSRecursiveLock *lock);

/**
 递归锁解锁
 @param lock 递归锁
 */
void dispatch_recursive_unlock (NSRecursiveLock *lock);

/**
 创建递归锁
 @return 递归锁
 */
pthread_mutex_t dispatch_pthread_recursive_create (void);

#pragma mark - 信号量
///=============================================================================
/// @name 信号量
/// @dispatch_semaphore_create 创建一个信号量
/// @dispatch_semaphore_signal  发送一个信号 信号量+1
/// @dispatch_semaphore_wait    等待信号 信号量-1
/// @信号量 >=0 则执行, 否则等待
///=============================================================================

/**
 创建全局唯一的信号量
 @return 唯一信号量
 */
dispatch_semaphore_t dispatch_semaphore_once (void);

/**
 创建信号量锁
 @return 信号量锁
 */
dispatch_semaphore_t dispatch_semaphore_signal_create (void);

/**
 信号量加锁
 @param semaphore 信号量锁
 */
void dispatch_semaphore_lock (dispatch_semaphore_t semaphore);

/**
 信号量解锁
 @param semaphore 信号量锁
 */
void dispatch_semaphore_unlock (dispatch_semaphore_t semaphore);

///=============================================================================
/// @name 信号量 配合互斥锁使用
/// @pthread_mutex_lock(&semaphore);
/// @do something....
/// @pthread_cond_signal(&cond);
/// @pthread_mutex_unlock(&semaphore);
/// @pthread_cond_wait(&cond, &semaphore);
///=============================================================================

/**
 初始化信号量<配合互斥锁使用>
 @return 信号量
 */
pthread_cond_t dispatch_pthread_cond_init (void);

/**
 信号量 +1
 @param cond 信号量
 */
void dispatch_pthread_cond_unlock (pthread_cond_t cond);

/**
 信号量加锁
 @param semaphore pthread 锁
 @param cond 信号量
 */
void dispatch_pthread_semaphore_lock (pthread_cond_t cond, pthread_mutex_t semaphore);

#pragma mark - 条件锁
///=============================================================================
/// @name 条件锁
///=============================================================================

/**
 创建条件锁
 @return 条件锁
 */
NSCondition * dispatch_condition_create (void);

/**
 条件锁加锁
 @param condition 条件锁
 */
void dispatch_condition_lock (NSCondition *condition);

/**
 pthread 条件锁解锁
 @param condition 条件锁
 */
void dispatch_condition_unlock (NSCondition *condition);

/**
 线程会阻塞, 直到其他线程调用该对象的signal方法或broadcast方法来唤醒
 唤醒后该线程从阻塞态改为就绪态, 交由系统进行线程调度
 执行wait方法时内部会自动执行unlock方法释放锁, 并阻塞线程
 @param condition 条件锁
 */
void dispatch_condition_wait (NSCondition *condition);

/**
 唤醒在当前锁对象上阻塞的所有线程
 @param condition 条件锁
 */
void dispatch_condition_broadcast (NSCondition *condition);

/**
 唤醒在当前锁对象上阻塞的一个线程
 如果在该对象上wait的有多个线程则随机挑选一个
 被挑选的线程则从阻塞态进入就绪态
 @param condition 条件锁
 */
void dispatch_condition_signal (NSCondition *condition);

#pragma mark - pthread 加/解 锁
///=============================================================================
/// @name pthread 加/解 锁
///=============================================================================

/**
 pthread 加锁
 @param lock pthread锁
 */
void dispatch_pthread_lock (pthread_mutex_t lock);

/**
 pthread 解锁
 @param lock pthread锁
 */
void dispatch_pthread_unlock (pthread_mutex_t lock);

@end

NS_ASSUME_NONNULL_END
