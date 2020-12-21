//
//  MNLock.m
//  MNKit
//
//  Created by Vincent on 2018/11/5.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNLock.h"
#import <pthread.h>

@implementation MNLock
#pragma mark - 互斥锁
inline NSLock * dispatch_mutex_create (void) {
    return [[NSLock alloc] init];
}

inline void dispatch_mutex_lock (NSLock *lock) {
    if (!lock) return;
    [lock lock];
}

inline void dispatch_mutex_unlock (NSLock *lock) {
    if (!lock) return;
    [lock unlock];
}

inline pthread_mutex_t dispatch_pthread_mutex_create (void) {
    /*
    pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
     */
    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    return mutex;
}

#pragma mark - 递归锁
inline NSRecursiveLock * dispatch_recursive_create (void) {
    return [[NSRecursiveLock alloc] init];
}

inline void dispatch_recursive_lock (NSRecursiveLock *lock) {
    if (!lock) return;
    [lock lock];
}

inline void dispatch_recursive_unlock (NSRecursiveLock *lock) {
    if (!lock) return;
    [lock unlock];
}

inline pthread_mutex_t dispatch_pthread_recursive_create (void) {
    pthread_mutex_t lock;
    pthread_mutexattr_t mutexattr;
    pthread_mutexattr_init(&mutexattr);
    pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&lock, &mutexattr);
    return lock;
}

#pragma mark - semaphore 信号量
dispatch_semaphore_t dispatch_semaphore_once (void) {
    static dispatch_semaphore_t mnkit_semaphore_once;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mnkit_semaphore_once = dispatch_semaphore_create(1);
    });
    return mnkit_semaphore_once;
}

inline dispatch_semaphore_t dispatch_semaphore_signal_create (void) {
    return dispatch_semaphore_create(1);
}

inline void dispatch_semaphore_lock (dispatch_semaphore_t semaphore) {
    if (!semaphore) return;
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

inline void dispatch_semaphore_unlock (dispatch_semaphore_t semaphore) {
    if (!semaphore) return;
    dispatch_semaphore_signal(semaphore);
}

inline pthread_cond_t dispatch_pthread_cond_init (void) {
    pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
    return cond;
}

inline void dispatch_pthread_cond_unlock (pthread_cond_t cond) {
    pthread_cond_signal(&cond);
}

inline void dispatch_pthread_semaphore_lock (pthread_cond_t cond, pthread_mutex_t semaphore) {
    pthread_cond_wait(&cond, &semaphore);
}

#pragma mark - 条件锁
inline NSCondition * dispatch_condition_create (void) {
    return [[NSCondition alloc] init];
}

inline void dispatch_condition_lock (NSCondition *condition) {
    if (!condition) return;
    [condition lock];
}

inline void dispatch_condition_unlock (NSCondition *condition) {
    if (!condition) return;
    [condition unlock];
}

inline void dispatch_condition_wait (NSCondition *condition) {
    if (!condition) return;
    [condition wait];
}

inline void dispatch_condition_broadcast (NSCondition *condition) {
    if (!condition) return;
    [condition broadcast];
}

inline void dispatch_condition_signal (NSCondition *condition) {
    if (!condition) return;
    [condition signal];
}

#pragma mark - pthread 加/解 锁
inline void dispatch_pthread_lock (pthread_mutex_t lock) {
    pthread_mutex_lock(&lock);
}

inline void dispatch_pthread_unlock (pthread_mutex_t lock) {
    pthread_mutex_unlock(&lock);
}

@end
