//
//  NSObject+MNObserving.h
//  SQB_ScreenShot
//
//  Created by Vincent on 2019/1/15.
//  Copyright © 2019年 AiZhe. All rights reserved.
//  KVO处理

#import <Foundation/Foundation.h>

@interface NSObject (MNObserving)

/**
 判断自身是否观察了指定对象的属性变化
 @param obj 指定对象
 @param keyPath 指定属性
 @return 判断结果
 */
- (BOOL)observedObj:(NSObject *)obj forKeyPath:(NSString *)keyPath;

/**
 安全的监听
 @param observer 观察者
 @param keyPath 属性变化
 @param options 监听可选项
 @param context 上下文
 */
- (void)safelyAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;

/**
 安全的删除观察者
 @param observer 观察者
 @param keyPath 属性
 */
- (void)safelyRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end

