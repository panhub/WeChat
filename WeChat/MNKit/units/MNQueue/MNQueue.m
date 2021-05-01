//
//  MNQueue.m
//  MNKit
//
//  Created by Vincent on 2018/10/27.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNQueue.h"

DISPATCH_INLINE NSString *dispatch_queue_name_valid (NSString *name) {
    if (name.length > 0) return name;
    return [NSString stringWithFormat:@"com.mn.queue.%@", [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]*1000]];
}

DISPATCH_INLINE void dispatch_timer_save (_Nullable dispatch_source_t timer, NSString *name) {
    if (name.length <= 0) return;
    static CFMutableDictionaryRef _containerRef;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _containerRef = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    });
    dispatch_source_t _timer = CFDictionaryGetValue(_containerRef, (__bridge const void*)(name));
    if (_timer) {
        /**停止并释放定时器*/
        dispatch_source_cancel(_timer);
        CFDictionaryRemoveValue(_containerRef, (__bridge const void*)(name));
    }
    if (!timer) return;
    /**添加timer*/
    CFDictionarySetValue(_containerRef, (__bridge const void*)(name), (__bridge const void*)(timer));
}

#pragma mark - 获取系统并发队列
inline dispatch_queue_t dispatch_get_default_queue (void) {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

inline dispatch_queue_t dispatch_get_low_queue (void) {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

inline dispatch_queue_t dispatch_get_high_queue (void) {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
}

#pragma mark - 创建队列
dispatch_queue_t dispatch_create_queue (NSString *name, dispatch_queue_attr_t attr) {
    return dispatch_queue_create(dispatch_queue_name_valid(name).UTF8String, attr);
}

#pragma mark - 创建串行队列
dispatch_queue_t dispatch_create_serial_queue (NSString *name) {
    return dispatch_queue_create(dispatch_queue_name_valid(name).UTF8String, DISPATCH_QUEUE_SERIAL);
}

#pragma mark - 创建并行队列
dispatch_queue_t dispatch_create_concurrent_queue (NSString *name) {
    return dispatch_queue_create(dispatch_queue_name_valid(name).UTF8String, DISPATCH_QUEUE_CONCURRENT);
}

#pragma mark - 释放手动创建的队列
void dispatch_queue_release (dispatch_queue_t queue) OBJC_ARC_UNAVAILABLE {
#if __has_feature(objc_arc)
#else
    dispatch_release(queue);
# endif
}

#pragma mark - 异步主队列执行
inline void dispatch_async_main (dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}

#pragma mark - 异步默认并发队列执行
inline void dispatch_async_default (dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

#pragma mark - 异步后台并发队列执行
inline void dispatch_async_background (dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
}

#pragma mark - 异步完成回调执行
void dispatch_async_group (dispatch_block_t task, dispatch_block_t completion) {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (task) task();
        dispatch_group_leave(group);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), completion);
}

#pragma mark - 同步主队列执行
inline void dispatch_sync_main (dispatch_block_t block) {
    dispatch_sync(dispatch_get_main_queue(), block);
}

#pragma mark - 同步默认并发队列执行
inline void dispatch_sync_default (dispatch_block_t block) {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

#pragma mark - 同步后台并发队列执行
inline void dispatch_sync_background (dispatch_block_t block) {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
}

#pragma mark - 延迟执行
inline void dispatch_after_time (NSTimeInterval when, dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(when*NSEC_PER_SEC)), queue, block);
}

#pragma mark - 延迟主队列执行
inline void dispatch_after_main (NSTimeInterval when, dispatch_block_t block) {
    dispatch_after_time(when, dispatch_get_main_queue(), block);
}

#pragma mark - 延迟默认并发队列执行
inline void dispatch_after_default (NSTimeInterval when, dispatch_block_t block) {
    dispatch_after_time(when, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

#pragma mark - 创建/开启定时器
inline void dispatch_timer_source (NSString *name, NSTimeInterval timeInterval, dispatch_queue_t queue, dispatch_block_t block) {
    if (name.length <= 0) return;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_timer_save(timer, name);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, timeInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, block);
    dispatch_resume(timer);
}

#pragma mark - 主队列定时器
inline void dispatch_timer_main (NSString *name, NSTimeInterval timeInterval, dispatch_block_t block) {
    dispatch_timer_source(name, timeInterval, dispatch_get_main_queue(), block);
}

#pragma mark - 默认并发队列定时器
inline void dispatch_timer_default (NSString *name, NSTimeInterval timeInterval, dispatch_block_t block) {
    dispatch_timer_source(name, timeInterval, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

#pragma mark - 取消定时器
inline void dispatch_timer_cancel (NSString *name) {
    dispatch_timer_save(nil, name);
}
