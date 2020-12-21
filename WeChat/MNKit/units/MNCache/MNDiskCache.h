//
//  MNDiskCache.h
//  MNKit
//
//  Created by Vincent on 2018/10/29.
//  Copyright © 2018年 小斯. All rights reserved.
//  磁盘缓存模块

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNDiskCache : NSObject
#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/**缓存名*/
@property (nullable, copy) NSString *name;
/**缓存存储路径*/
@property (readonly) NSString *path;
/**缓存数量上限 默认为NSUIntegerMax*/
@property NSUInteger maxCount;
/**缓存消耗上限 默认为NSUIntegerMax*/
@property NSUInteger maxCost;
/**缓存时间上限 默认为DBL_MAX*/
@property NSTimeInterval timeOutInterval;
/**整理缓存的时间间隔, 默认为10s*/
@property NSTimeInterval trimTimeInterval;
/**预留空间*/
@property NSUInteger freeDiskSpace;
/**存储方式分界限 默认20K*/
@property (readonly) NSUInteger inlineThreshold;
/**获取指定key对应的文件名*/
@property (nullable, copy) NSString *(^diskCacheFileNameBlock)(NSString *key);
/**获取二进制数据流对应的oc对象*/
@property (nullable, copy) id (^diskCacheUnarchiveBlock)(NSData *data);
/**获取指定oc对象对应的二进制数据流*/
@property (nullable, copy) NSData *(^diskCacheArchiveBlock)(id object);

#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;

/**
 获取磁盘缓存实例
 @param path 缓存路径
 @return 磁盘缓存实例
 */
+ (nullable instancetype)diskCacheWithPath:(NSString *)path;

/**
 获取磁盘缓存实例
 @param path 缓存路径
 @return 磁盘缓存实例
 */
- (nullable instancetype)initWithPath:(NSString *)path;

/**
 获取磁盘缓存实例

 @param path 缓存路径
 @param inlineThreshold 缓存方式分界限
 @return 磁盘缓存实例
 */
- (nullable instancetype)initWithPath:(NSString *)path inlineThreshold:(NSUInteger)inlineThreshold NS_DESIGNATED_INITIALIZER;

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
 判断是否存在对应键数据
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
 获取指定key对应的数据
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
 存入数据
 @param object 数据
 @param key 键
 @param completion 回调
 */
- (void)setObject:(nullable id<NSCoding>)object
           forKey:(NSString *)key
       completion:(nullable void(^)(BOOL succeed))completion;

/**
 删除数据
 @param key 键值
 @return 是否成功删除
 */
- (BOOL)removeObjectForKey:(NSString *)key;

/**
 删除数据
 @param key 键值
 @param completion 是否成功删除回调
 */
- (void)removeObjectForKey:(NSString *)key
                completion:(nullable void(^)(NSString * _Nullable key, BOOL succeed))completion;

/**
 删除所有数据
 @return 是否删除成功
 */
- (BOOL)removeAllObjects;

/**
 删除所有数据
 @param completion 是否删除成功回调
 */
- (void)removeAllObjectsWithCompletion:(nullable void(^)(BOOL succeed))completion;

/**
 删除所有数据
 @param progress 进度
 @param completion 结果回调
 */
- (void)removeAllObjectsWithProgress:(nullable void(^)(int removedCount, int totalCount))progress
                               completion:(nullable void(^)(BOOL succeed))completion;

/**
 获取缓存总数量
 @return 缓存总数量
 */
- (NSInteger)totalCount;

/**
 获取缓存总数量
 @param completion 总数量回调
 */
- (void)totalCountWithCompletion:(void(^)(NSInteger totalCount))completion;

/**
 获取缓存总开销
 @return 总开销
 */
- (NSInteger)totalCost;

/**
 获取缓存总开销
 @param completion 总开销回调
 */
- (void)totalCostWithCompletion:(void(^)(NSInteger totalCost))completion;


#pragma mark - Trim
///=============================================================================
/// @name Trim
///=============================================================================

/**
 整理缓存到指定数量
 @param count 指定数量
 */
- (void)trimToCount:(NSUInteger)count;

/**
 整理缓存到指定数量
 @param count 指定数量
 @param completion 结束回调
 */
- (void)trimToCount:(NSUInteger)count completion:(void(^)(void))completion;

/**
 整理缓存到指定开销总量
 @param cost 指定开销
 */
- (void)trimToCost:(NSUInteger)cost;

/**
 整理缓存到指定开销
 @param cost 指定开销
 @param completion 结束回调
 */
- (void)trimToCost:(NSUInteger)cost completion:(void(^)(void))completion;

/**
 整理缓存到指定时间
 @param timeInterval 指定时间
 */
- (void)trimToTime:(NSTimeInterval)timeInterval;

/**
 整理缓存到指定时间
 @param timeInterval 指定时间
 @param completion 结束回调
 */
- (void)trimToTime:(NSTimeInterval)timeInterval completion:(void(^)(void))completion;


#pragma mark - Extended Data
///=============================================================================
/// @name Extended Data
///=============================================================================

/**
 获取二进制数据流
 @param object oc对象
 @return 二进制数据流
 */
+ (nullable NSData *)getExtendedDataFromObject:(id)object;

/**
 设置oc对象二进制数据流
 @param extendedData 二进制数据流
 @param object oc对象
 */
+ (void)setExtendedData:(nullable NSData *)extendedData toObject:(id)object;

@end

NS_ASSUME_NONNULL_END
