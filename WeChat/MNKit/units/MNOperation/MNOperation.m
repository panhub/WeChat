//
//  MNOperation.m
//  MNKit
//
//  Created by Vincent on 2018/11/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNOperation.h"

@interface MNOperation ()
@property (nonatomic, strong) NSInvocation *invocation;
@property (nonatomic, copy) dispatch_queue_t finish_notify_queue;
@property (nonatomic, copy) operation_block_t finish_notify_callback;
@property (nonatomic, strong) NSMutableArray <operation_block_t>*callbackArray;
@end

@implementation MNOperation
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize concurrent = _concurrent;

#pragma mark - Instantiation
- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    _finished = NO;
    _executing = NO;
    _concurrent = NO;
    return self;
}

+ (instancetype)operationWithCallback:(operation_block_t)callback {
    MNOperation *operation = [[MNOperation alloc] init];
    [operation addExecutionCallback:callback];
    return operation;
}

- (nullable instancetype)initWithTarget:(id)target selector:(SEL)selector objects:(id)obj,...NS_REQUIRES_NIL_TERMINATION
{
    if (!target || !selector) return nil;
    //方法签名
    NSMethodSignature *signature = [[target class] instanceMethodSignatureForSelector:selector];
    if (!signature) return nil;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    if (!invocation) return nil;
    invocation.target = target;
    invocation.selector = selector;
    /**绑定其他参数*/
    if (obj) {
        NSMutableArray <id>*parameters = [NSMutableArray arrayWithCapacity:0];
        [parameters addObject:obj];
        va_list args;
        va_start(args, obj);
        while ((obj = va_arg(args, id))) {
            [parameters addObject:obj];
        }
        va_end(args);
        /*第一个参数：需要给指定方法传递的值, 需要接收一个指针, 也就是传递值的时候需要传递地址*/
        /*第二个参数：需要给指定方法的第几个参数传值*/
        /*注意: 设置参数的索引时不能从0开始, 因为0已经被self占用, 1已经被_cmd占用*/
        NSInteger index = 2;
        [parameters enumerateObjectsUsingBlock:^(id  _Nonnull parameter, NSUInteger idx, BOOL * _Nonnull stop) {
            [invocation setArgument:&parameter atIndex:(index + idx)];
        }];
    }
    return [self initWithInvocation:invocation];
}

- (instancetype)initWithInvocation:(NSInvocation *)invocation {
    if (!invocation) return nil;
    self = [self init];
    if (!self) return nil;
    self.invocation = invocation;
    return self;
}

#pragma mark - 任务回调容器
- (NSMutableArray <operation_block_t>*)callbackArray {
    if (!_callbackArray) {
        NSMutableArray <operation_block_t>*callbackArray = [NSMutableArray arrayWithCapacity:0];
        _callbackArray = callbackArray;
    }
    return _callbackArray;
}

#pragma mark - 添加任务回调
- (void)addExecutionCallback:(operation_block_t)callback {
    if (!callback) return;
    [self.callbackArray addObject:[callback copy]];
}

- (void)setExecutionCallback:(operation_block_t)callback {
    [_callbackArray removeAllObjects];
    [self addExecutionCallback:callback];
}

#pragma mark - 异步执行
- (void)async {
    /**如果还未准备好, 依赖的Operation还未结束, 不执行*/
    if (!self.isReady || self.isExecuting) return;
    
    /**分线程KVO*/
    [self willChangeValueForKey:@"isConcurrent"];
    _concurrent = YES;
    [self didChangeValueForKey:@"isConcurrent"];
    
    /**直接调用start, 依附于调用线程, 故在这里开启一个分线程处理*/
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self start];
    });
}

#pragma mark - 同步执行
- (void)sync {
    /**如果还未准备好, 依赖的Operation还未结束, 不执行*/
    if (!self.isReady || self.isExecuting) return;
    
    /**当前线程KVO*/
    [self willChangeValueForKey:@"isConcurrent"];
    _concurrent = NO;
    [self didChangeValueForKey:@"isConcurrent"];
    
    /**开始*/
    [self start];
}

#pragma mark - 重写父类
- (void)start {
    /**切记不可调用父类操作*/
    /**如果还未准备好, 依赖的Operation还未结束, 不执行*/
    if (!self.isReady || self.isExecuting) return;
    
    /**注意时时判断是否被取消, 保证触发KVO, 确保依赖关系正常*/
    if (self.isCancelled || (_callbackArray.count <= 0 && !self.invocation)) {
        [self didFinished];
        return;
    }
    
    /**执行操作*/
    [self main];
}

- (void)main {
    /**执行中KVO*/
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    /**执行操作, 注意执行中时刻判断是否被取消*/
    if (!self.isCancelled) {
        if (self.invocation) {
            [self.invocation invoke];
        } else {
            [_callbackArray enumerateObjectsUsingBlock:^(operation_block_t  _Nonnull callback, NSUInteger idx, BOOL * _Nonnull stop) {
                if (self.cancelled) {
                    *stop = YES;
                    return;
                }
                if (callback) {
                    callback();
                }
            }];
        }
    }

    /**完成*/
    [self didFinished];
}

/**是否分线程*/
- (BOOL)isConcurrent {
    return _concurrent;
}

/**是否正在执行*/
- (BOOL)isExecuting {
    return _executing;
}

/**是否结束执行*/
- (BOOL)isFinished {
    return _finished;
}

#pragma mark - 取消/结束执行
- (void)didFinished {
    
    /**不触发KVO, 标记分线程执行结束*/
    _concurrent = NO;
    
    /**执行结束KVO*/
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    /**结束KVO*/
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
    
    /**回调*/
    if (self.finish_notify_callback) {
        dispatch_queue_t queue = self.finish_notify_queue ? : dispatch_get_main_queue();
        dispatch_async(queue, ^{
            self.finish_notify_callback();
        });
    }
}

#pragma mark - 防GCD样式
MNOperation * dispatch_operation_create (operation_block_t callback) {
    return [MNOperation operationWithCallback:callback];
}

void dispatch_operation_add_execution (MNOperation *operation, operation_block_t callback) {
    if (!operation) return;
    [operation addExecutionCallback:callback];
}

void dispatch_operation_set_execution (MNOperation *operation, operation_block_t callback) {
    if (!operation) return;
    [operation setExecutionCallback:callback];
}

void dispatch_operation_sync (MNOperation *operation) {
    if (!operation) return;
    [operation sync];
}

void dispatch_operation_async (MNOperation *operation) {
    if (!operation) return;
    [operation async];
}

void dispatch_operation_notify (MNOperation *operation, dispatch_queue_t queue, operation_block_t callback) {
    if (!operation) return;
    operation.finish_notify_queue = queue;
    operation.finish_notify_callback = callback;
}

#pragma mark - dealloc
- (void)dealloc {
    _finish_notify_queue = nil;
    _finish_notify_callback = nil;
    [_callbackArray removeAllObjects];
}

@end
