//
//  MNThread.h
//  MNKit
//
//  Created by Vincent on 2018/12/4.
//  Copyright © 2018年 小斯. All rights reserved.
//  线程管理

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MNRunLoopMode) {
    MNDefaultRunLoopMode = 1,
    MNTrackingRunLoopMode
};

typedef void(^MNThreadTaskCallback)(void);

@interface MNThreadTask : NSObject

@property (nonatomic, strong) NSInvocation *invocation;

- (void)addTaskCallback:(MNThreadTaskCallback)taskCallback;

@end

@interface MNThread : NSObject

@property (nonatomic, copy, readonly) NSRunLoopMode runLoopMode;
@property (nonatomic, assign) MNRunLoopMode mode;

- (BOOL)performTasks:(NSArray <MNThreadTask *>*)tasks;

- (BOOL)performTasks:(NSArray <MNThreadTask *>*)tasks inMode:(MNRunLoopMode)mode;

- (BOOL)isEqualThread:(MNThread *)thread;

- (void)exit;

@end

