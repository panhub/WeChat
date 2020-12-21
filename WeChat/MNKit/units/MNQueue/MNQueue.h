//
//  MNQueue.h
//  MNKit
//
//  Created by Vincent on 2018/10/27.
//  Copyright © 2018年 小斯. All rights reserved.
//  线程/定时器

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 获取系统默认并发队列
 @return 系统默认并发队列
 */
DISPATCH_EXPORT dispatch_queue_t dispatch_get_default_queue (void);

/**
 获取系统低并发队列
 @return 系统低并发队列
 */
DISPATCH_EXPORT dispatch_queue_t dispatch_get_low_queue (void);

/**
 获取系统高并发队列
 @return 系统高并发队列
 */
DISPATCH_EXPORT dispatch_queue_t dispatch_get_high_queue (void);

/**
 创建队列
 @param name 队列标识
 @param attr 队列描述串/并行
 @return 队列
 */
DISPATCH_EXPORT dispatch_queue_t dispatch_create_queue (NSString * _Nullable name, dispatch_queue_attr_t _Nullable attr);

/**
 创建串行队列
 @param name 队列描述
 @return 串行队列
 */
DISPATCH_EXPORT dispatch_queue_t dispatch_create_serial_queue (NSString * _Nullable name);

/**
 创建并行队列
 @param name 队列描述
 @return 并行队列
 */
DISPATCH_EXPORT dispatch_queue_t dispatch_create_concurrent_queue (NSString * _Nullable name);

/**
 释放手动创建的队列
 @param queue 队列
 */
DISPATCH_EXPORT void dispatch_queue_release (dispatch_queue_t queue) OBJC_ARC_UNAVAILABLE;

/**
 异步主线程队列执行
 @param block 任务回调
 */
DISPATCH_EXPORT void dispatch_async_main (dispatch_block_t block);

/**
 异步默认并发队列执行
 @param block 任务回调
 */
DISPATCH_EXPORT void dispatch_async_default (dispatch_block_t block);

/**
 异步后台并发队列执行
 @param block 任务回调
 */
DISPATCH_EXPORT void dispatch_async_background (dispatch_block_t block);

/**
 异步提交任务结束后回调
 @param task 回调队列
 @param completion 回调代码块
 */
DISPATCH_EXPORT void dispatch_async_group (dispatch_block_t task, dispatch_block_t completion);

/**
 同步主线程队列执行
 @param block 任务回调
 */
DISPATCH_EXPORT void dispatch_sync_main (dispatch_block_t block);

/**
 同步默认并发队列执行
 @param block 任务回调
 */
DISPATCH_EXPORT void dispatch_sync_default (dispatch_block_t block);

/**
 异步后台并发队列执行
 @param block 任务回调
 */
DISPATCH_EXPORT void dispatch_sync_background (dispatch_block_t block);

#pragma mark - 延迟提交<异步>
/**
 延迟执行
 @param when 延迟时间
 @param queue 队列
 @param block 代码块
 */
DISPATCH_EXPORT void dispatch_after_time (NSTimeInterval when, dispatch_queue_t queue, dispatch_block_t block);

/**
 主队列延迟执行
 @param when 延迟时间
 @param block 执行任务
 */
DISPATCH_EXPORT void dispatch_after_main (NSTimeInterval when, dispatch_block_t block);

/**
 默认并发队列延迟执行
 @param when 延迟时间
 @param block 执行任务
 */
DISPATCH_EXPORT void dispatch_after_default (NSTimeInterval when, dispatch_block_t block);

#pragma mark - 定时器
/**
 创建并开启定时器
 @param name 定时器Name<作为key存储>
 @param timeInterval 间隔
 @param queue 队列
 @param block 事件回调
 */
DISPATCH_EXPORT void dispatch_timer_source (NSString *name, NSTimeInterval timeInterval, dispatch_queue_t queue, dispatch_block_t block);

/**
 主队列定时器
 @param name 定时器Name<作为key存储>
 @param timeInterval 间隔
 @param block 事件回调
 */
DISPATCH_EXPORT void dispatch_timer_main (NSString *name, NSTimeInterval timeInterval, dispatch_block_t block);

/**
 默认并发队列定时器
 @param name 定时器Name<作为key存储>
 @param timeInterval 间隔
 @param block 事件回调
 */
DISPATCH_EXPORT void dispatch_timer_default (NSString *name, NSTimeInterval timeInterval, dispatch_block_t block);

/**
 取消定时器
 @param name 定时器Name<作为key存储>
 */
DISPATCH_EXPORT void dispatch_timer_cancel (NSString *name);

NS_ASSUME_NONNULL_END

