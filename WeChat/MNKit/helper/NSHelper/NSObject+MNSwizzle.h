//
//  NSObject+MNSwizzle.h
//  MNKit
//
//  Created by Vincent on 2018/9/28.
//  Copyright © 2018年 小斯. All rights reserved.
//  交换方法使用

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MNSwizzle)

/**
 替换系统实例方法
 @param systemSelector 系统方法
 @param swizzledSelector 替换方法
 @return 是否替换成功
 */
+ (BOOL)swizzleInstanceMethod:(SEL)systemSelector withSelector:(SEL)swizzledSelector;

BOOL MNSwizzleInstanceMethod(Class cls, SEL systemSelector, SEL swizzledSelector);

/**
 替换系统类方法
 @param systemSelector 系统方法
 @param swizzledSelector 替换方法
 @return 是否替换成功
 */
+ (BOOL)swizzleClassMethod:(SEL)systemSelector withSelector:(SEL)swizzledSelector;

BOOL MNSwizzleClassMethod(Class cls, SEL systemSelector, SEL swizzledSelector);

@end

NS_ASSUME_NONNULL_END
