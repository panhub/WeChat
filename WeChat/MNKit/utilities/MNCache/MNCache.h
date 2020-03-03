//
//  MNCache.h
//  MNKit
//
//  Created by Vincent on 2018/10/29.
//  Copyright © 2018年 小斯. All rights reserved.
//  YYCache
//  Copy版 只为研究YYCache设计思路

#import <Foundation/Foundation.h>
#import "MNMemoryCache.h"
#import "MNDiskCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNCache : NSObject
#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/**缓存名, 由实例化时指定*/
@property (nonatomic, readonly, copy) NSString *name;
/**磁盘缓存*/
@property (nonatomic, readonly, strong) MNDiskCache *diskCache;
/**内存缓存*/
@property (nonatomic, readonly, strong) MNMemoryCache *memoryCache;
#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;

/**
 获取随机名称缓存实例
 @return 缓存实例
 */
+ (nullable instancetype)cache;

/**
 获取缓存实例
 @param name 名称
 @return 缓存实例
 */
+ (nullable instancetype)cacheWithName:(NSString *)name;

/**
 获取缓存实例
 @param name 名称
 @return 缓存实例
 */
- (nullable instancetype)initWithName:(NSString *)name NS_DESIGNATED_INITIALIZER;

#pragma mark - Access Methods
///=============================================================================
/// @name Access Methods
///=============================================================================
/**
 判断是否存在对应键数据
 @param key 键
 @return 是否存在对应数据
 */
- (BOOL)containsObjectForKey:(NSString *)key;

/**
 异步判断是否存在对应键数据
 @param key 键
 @param completion 结果回调
 */
- (void)containsObjectForKey:(NSString *)key
                  completion:(void(^)(NSString *key, BOOL contains))completion;

/**
 获取指定key对应的数据
 @param key 键
 @return key对应的数据
 */
- (nullable id)objectForKey:(NSString *)key;

/**
 异步获取指定key对应的数据
 @param key 键
 @param completion 查询结果回调
 */
- (void)objectForKey:(NSString *)key
                    completion:(void(^)(NSString *key, id _Nullable object))completion;

/**
 存入数据
 @param object 数据
 @param key 键
 @return 是否存入成功
 */
- (BOOL)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key;

/**
 异步存入数据
 @param object 数据
 @param key 键值
 @param completion 结束回调
 */
- (void)setObject:(nullable id<NSCoding>)object
           forKey:(NSString *)key
       completion:(nullable void(^)(BOOL succeed))completion;

/**
 删除指定键对应的缓存
 @param key 键
 @return 是否成功删除
 */
- (BOOL)removeObjectForKey:(NSString *)key;

/**
 删除指定键对应的缓存
 @param key 键
 @param completion 结束回调
 */
- (void)removeObjectForKey:(NSString *)key completion:(nullable void(^)(NSString * _Nullable key, BOOL succeed))completion;

/**
 删除所有缓存
 */
- (BOOL)removeAllObjects;

/**
 删除所有缓存
 @param completion 结束回调
 */
- (void)removeAllObjectsWithCompletion:(nullable void(^)(BOOL succeed))completion;

/**
 删除所有缓存
 @param progress 进度
 @param completion 结束回调
 */
- (void)removeAllObjectsWithProgress:(nullable void(^)(int removedCount, int totalCount))progress
                                 completion:(nullable void(^)(BOOL succeed))completion;

@end

NS_ASSUME_NONNULL_END

