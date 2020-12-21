//
//  MNThread.m
//  MNKit
//
//  Created by Vincent on 2018/12/4.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNThread.h"

static NSString *MNThreadCreateName (void) {
    NSString *name = @"com.mn.thread";
    name = [name stringByAppendingString:[NSString stringWithFormat:@".%lld",(long long)([[NSDate date] timeIntervalSince1970]*1000)]];
    return name;
}

@interface MNThreadTask ()
@property (nonatomic, copy) MNThreadTaskHandler taskCallback;
@end

@implementation MNThreadTask

- (void)addTaskCallback:(MNThreadTaskHandler)taskCallback {
    self.taskCallback = taskCallback;
}

@end

@interface MNThread ()
/**线程, 开启即存活, 不需要强引用, 强引用也没用*/
@property (nonatomic, weak) NSThread *thread;
/**是否保持RunLoop运行*/
@property (nonatomic, getter=isKeepRun) BOOL keepRun;
@end

@implementation MNThread
- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    _keepRun = YES;
    _runLoopMode = NSDefaultRunLoopMode;
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    thread.name = MNThreadCreateName();
    [thread start];
    self.thread = thread;
    return self;
}

- (void)run {
    @autoreleasepool {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop addPort:[NSMachPort port] forMode:UITrackingRunLoopMode];
        while (self.isKeepRun) {
            /**这种运行模式, 当执行非timer源事件后就会退出, 如果想要线程常驻, 开启runloop即可*/
            [runLoop runMode:self.runLoopMode beforeDate:[NSDate distantFuture]];
        }
        //想要线程常驻, 其后的代码不应该运行, 运行到了说明线程就要销毁了
        NSLog(@"-----线程销毁了-----");
    }
}

- (BOOL)performTasks:(NSArray <MNThreadTask *>*)tasks {
    if (!_thread) return NO;
    if (tasks.count <= 0 || (![tasks firstObject].taskCallback && ![tasks firstObject].invocation)) return NO;
    [self performSelector:@selector(performThreadTasks:)
                 onThread:self.thread
               withObject:tasks
            waitUntilDone:NO
                    modes:@[self.runLoopMode]];
    return YES;
}

- (void)performThreadTasks:(NSArray <MNThreadTask *>*)tasks {
    [tasks enumerateObjectsUsingBlock:^(MNThreadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.taskCallback) {
            obj.taskCallback();
        }
        if (obj.invocation) {
            [obj.invocation invoke];
        }
    }];
}

- (BOOL)performTasks:(NSArray <MNThreadTask *>*)tasks inMode:(NSRunLoopMode)mode {
    if ([@[NSDefaultRunLoopMode, UITrackingRunLoopMode] containsObject:mode]) self.runLoopMode = mode;
    return [self performTasks:tasks];
}

- (BOOL)isEqualThread:(MNThread *)thread {
    if (!thread) return NO;
    return [self.thread.name isEqualToString:thread.thread.name];
}

- (void)exit {
    if (!_thread) return;
    [self performSelector:@selector(therdExit)
                 onThread:self.thread
               withObject:nil
            waitUntilDone:NO
                    modes:@[self.runLoopMode]];
}

- (void)therdExit {
    /**触发runLoop结束, 不再开启, runLoop结束, 线程结束销毁*/
    self.keepRun = NO;
    /**鉴于开启方式, 这种方法可以手动退出runloop*/
    /*
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopStop(runLoop);
    CFRelease(runLoop);
     */
    /**以防万一, 再加退出*/
    [NSThread exit];
}

- (void)setRunLoopMode:(NSRunLoopMode)runLoopMode {
    if (!_thread || [runLoopMode isEqualToString:_runLoopMode]) return;
    [self performSelector:@selector(changeThreadRunLoopMode:)
                 onThread:self.thread
               withObject:runLoopMode
            waitUntilDone:NO
                    modes:@[self.runLoopMode]];
}

- (void)changeThreadRunLoopMode:(NSRunLoopMode)runLoopMode {
    _runLoopMode = runLoopMode;
}

- (void)dealloc {
    [self exit];
}

@end
