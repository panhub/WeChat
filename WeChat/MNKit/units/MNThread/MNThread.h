//
//  MNThread.h
//  MNKit
//
//  Created by Vincent on 2018/12/4.
//  Copyright © 2018年 小斯. All rights reserved.
//  线程管理

#import <Foundation/Foundation.h>

typedef void(^MNThreadTaskHandler)(void);

@interface MNThreadTask : NSObject

@property (nonatomic, strong) NSInvocation *invocation;

- (void)addTaskCallback:(MNThreadTaskHandler)taskCallback;

@end

@interface MNThread : NSObject

@property (nonatomic, copy) NSRunLoopMode runLoopMode;

- (BOOL)performTasks:(NSArray <MNThreadTask *>*)tasks;

- (BOOL)performTasks:(NSArray <MNThreadTask *>*)tasks inMode:(NSRunLoopMode)mode;

- (BOOL)isEqualThread:(MNThread *)thread;

- (void)exit;

@end

