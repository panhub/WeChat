//
//  MNOperation.h
//  MNKit
//
//  Created by Vincent on 2018/11/26.
//  Copyright © 2018年 小斯. All rights reserved.
//  事务处理

#import <Foundation/Foundation.h>

typedef void(^operation_block_t)(void);

@interface MNOperation : NSOperation

#pragma mark - initialize

+ (instancetype)operationWithCallback:(operation_block_t)callback;

- (instancetype)initWithInvocation:(NSInvocation *)invocation;

- (instancetype)initWithTarget:(id)target
                      selector:(SEL)selector
                       objects:(id)obj,...NS_REQUIRES_NIL_TERMINATION;

#pragma mark - 添加任务回调
/**
 添加事件回调<增加回调>
 @param callback 回调
 */
- (void)addExecutionCallback:(operation_block_t)callback;

/**
 设置回调<删除之前的回调>
 @param callback 回调
 */
- (void)setExecutionCallback:(operation_block_t)callback;

#pragma mark - 同步/异步执行
/**
 开启线程执行
 */
- (void)async;

/**
 当前线程执行
 */
- (void)sync;

#pragma mark - 防GCD样式
/**
 创建事务
 @param callback 回调
 @return 事务对象
 */
MNOperation * dispatch_operation_create (operation_block_t callback);

/**
 添加任务回调
 @param operation 事务对象
 @param callback 任务回调
 */
void dispatch_operation_add_execution (MNOperation *operation, operation_block_t callback);

/**
 设置任务回调
 @param operation 事务对象
 @param callback 任务回调
 */
void dispatch_operation_set_execution (MNOperation *operation, operation_block_t callback);

/**
 立即执行
 @param operation 事务对象
 */
void dispatch_operation_sync (MNOperation *operation);

/**
 异步执行
 @param operation 事务对象
 */
void dispatch_operation_async (MNOperation *operation);

/**
 事务结束通知
 @param operation 事务对象
 @param queue 回调线程
 @param callback 结束回调
 */
void dispatch_operation_notify (MNOperation *operation, dispatch_queue_t queue, operation_block_t callback);

@end

