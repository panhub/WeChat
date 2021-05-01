//
//  MNURLDatabase.h
//  MNKit
//
//  Created by Vincent on 2018/11/22.
//  Copyright © 2018年 小斯. All rights reserved.
//  网络数据缓存

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * _Nonnull const MNURLDatabaseName;
FOUNDATION_EXTERN NSString *_Nonnull const MNURLDatabaseTableName;

NS_ASSUME_NONNULL_BEGIN

@interface MNURLDatabase : NSObject

/**
 实例化入口
 @return 数据缓存实例
 */
+ (instancetype)database;

#pragma mark - 存储缓存
/**
 存储缓存
 @param cache 缓存
 @param url 请求地址
 @return 是否存储成功
 */
- (BOOL)setCache:(id<NSCoding>)cache forUrl:(NSString *)url;

/**
 存储缓存<分线程>
 @param cache 缓存
 @param url 请求地址
 @param completion 是否存储成功
 */
- (void)setCache:(id<NSCoding>)cache forUrl:(NSString *)url completion:(nullable void(^)(BOOL succeed))completion;

#pragma mark - 获取缓存
/**
 获取指定网络缓存
 @param url 请求地址
 @return 缓存
 */
- (nullable id)cacheForUrl:(NSString *)url;

/**
 获取指定网络缓存<分线程>
 @param url 请求地址
 @param completion 缓存
 */
- (void)cacheForUrl:(NSString *)url completion:(void(^)(id cache))completion;

/**
 获取不超过指定时间的网络缓存
 @param url 请求地址
 @param timeoutInterval 超时天数(<=0 则不验证超时)
 @return 缓存
 */
- (nullable id)cacheForUrl:(NSString *)url timeoutInterval:(NSTimeInterval)timeoutInterval;

/**
 获取不超过指定时间的网络缓存<分线程>
 @param url 请求地址
 @param timeoutInterval 超时天数
 @param completion 缓存
 */
- (void)cacheForUrl:(NSString *)url timeoutInterval:(NSTimeInterval)timeoutInterval completion:(void(^)(id cache))completion;

#pragma mark - 判断是否有缓存
/**
 是否有某条网络缓存
 @param url 请求地址
 @return 是否有缓存
 */
- (BOOL)containsCacheForUrl:(NSString *)url;

/**
 是否有某条网络缓存<分线程>
 @param url 请求地址
 @param completion 是否有缓存
 */
- (void)containsCacheForUrl:(NSString *)url completion:(void(^)(BOOL succeed))completion;

#pragma mark - 删除缓存
/**
 删除网络缓存
 @param url 请求地址
 @return 是否删除成功
 */
- (BOOL)removeCacheForUrl:(NSString *)url;

/**
 删除网络缓存<分线程>
 @param url 请求地址
 @param completion 是否删除成功
 */
- (void)removeCacheForUrl:(NSString *)url completion:(nullable void(^)(BOOL succeed))completion;

/**
 删除所有缓存记录
 @return 是否删除成功
 */
- (BOOL)removeAllCaches;

/**
 删除所有缓存<分线程操作>
 @param block 操作结束回调
 */
- (void)removeAllCachesUsingBlock:(nullable void(^)(BOOL succeed))block;

@end

NS_ASSUME_NONNULL_END
