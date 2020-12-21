//
//  MNMemoryCache.h
//  MNKit
//
//  Created by Vincent on 2018/10/29.
//  Copyright © 2018年 小斯. All rights reserved.
//  内存缓存模块

#import <Foundation/Foundation.h>
@class MNMemoryCache;

NS_ASSUME_NONNULL_BEGIN

@interface MNMemoryCache : NSObject
#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/**缓存实例name*/
@property (nullable, copy) NSString *name;
/**缓存数量*/
@property (readonly) NSUInteger totalCount;
/**缓存消耗*/
@property (readonly) NSUInteger totalCost;

#pragma mark - Limit
///=============================================================================
/// @name Limit
///=============================================================================
/**缓存数量上限 默认为NSUIntegerMax*/
@property NSUInteger maxCount;
/**缓存消耗上限 默认为NSUIntegerMax*/
@property NSUInteger maxCost;
/**缓存时间上限 默认为DBL_MAX*/
@property NSTimeInterval timeOutInterval;
/**清理超出上限之外缓存的操作时间间隔, 默认为10s*/
@property NSTimeInterval trimTimeInterval;
/**收到内存警告时是否清理所有缓存, 默认为YES*/
@property BOOL clearCacheWhenMemoryWarning;
/**进入后台时是否清理所有缓存, 默认为YES*/
@property BOOL clearCacheWhenEnterBackground;
/**收到内存警告的回调*/
@property (nullable, copy) void(^didReceiveMemoryWarningCallback)(MNMemoryCache *cache);
/**收到后台的回调*/
@property (nullable, copy) void(^didEnterBackgroundCallback)(MNMemoryCache *cache);
/**释放操作是否在后台进行, 默认为NO*/
@property BOOL releaseOnMainThread;
/**释放操作是否异步执行，默认为YES*/
@property BOOL releaseUseAsynchronously;

#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;

/**
 获取内存缓存实例
 @return 内存缓存实例
 */
+ (instancetype)memoryCache;

/**
 获取内存缓存实例
 @param name 名称
 @return 内存缓存实例
 */
+ (instancetype)memoryCacheWithName:(nullable NSString *)name;

/**
 获取内存缓存实例
 @param name 名称
 @return 内存缓存实例
 */
- (instancetype)initWithName:(nullable NSString *)name NS_DESIGNATED_INITIALIZER;

#pragma mark - Access Methods
///=============================================================================
/// @name Access Methods
///=============================================================================
/**
 是否包含某个缓存
 @param key 键
 @return 查询结果
 */
- (BOOL)containsObjectForKey:(id)key;

/**
 获取缓存对象
 @param key 键
 @return 缓存
 */
- (nullable id)objectForKey:(id)key;

/**
 写入缓存
 @param object 缓存对象
 @param key 键
 */
- (void)setObject:(nullable id)object forKey:(id)key;

/**
 写入缓存
 @param object 缓存对象
 @param key 键
 @param cost 消耗
 */
- (void)setObject:(nullable id)object forKey:(id)key withCost:(NSUInteger)cost;

/**
 移除缓存
 @param key 键
 */
- (void)removeObjectForKey:(id)key;

/**
 清空所有缓存
 */
- (void)removeAllObjects;

#pragma mark - Trim
///=============================================================================
/// @name Trim
///=============================================================================

/**
 清理缓存到指定数量
 @param count 数量
 */
- (void)trimToCount:(NSUInteger)count;

/**
 清理缓存到指定消耗
 @param cost 消耗
 */
- (void)trimToCost:(NSUInteger)cost;

/**
 清理缓存到指定时间
 @param timeInterval 时间
 */
- (void)trimToTime:(NSTimeInterval)timeInterval;

@end

NS_ASSUME_NONNULL_END
