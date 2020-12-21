//
//  MNCache.m
//  MNKit
//
//  Created by Vincent on 2018/10/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNCache.h"

@interface MNCache ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) MNDiskCache *diskCache;
@property (nonatomic, strong) MNMemoryCache *memoryCache;
@end
@implementation MNCache
#pragma mark - 实例化
- (instancetype)init {
    @throw [NSException exceptionWithName:@"MNCache实例化方式错误"
                                   reason:@"请使用指定的实例化方式"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    @throw [NSException exceptionWithName:@"MNCache实例化方式错误"
                                   reason:@"请使用指定的实例化方式"
                                 userInfo:nil];
    return nil;
}
+ (nullable instancetype)cache {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef stringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *name = [NSString stringWithFormat:@"%@-%@-%@",(__bridge NSString *)(stringRef),@(arc4random()%10000), @(__COUNTER__)];
    CFRelease(stringRef);
    return [self cacheWithName:name.MD5String];
}
+ (nullable instancetype)cacheWithName:(NSString *)name {
    return [[MNCache alloc] initWithName:name];
}
- (nullable instancetype)initWithName:(NSString *)name {
    if (name.length <= 0) return nil;
    if (self = [super init]) {
        MNMemoryCache *memoryCache = [MNMemoryCache memoryCacheWithName:name];
        if (!memoryCache) return nil;
        _memoryCache = memoryCache;
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        path = [path stringByAppendingPathComponent:name];
        MNDiskCache *diskCache = [MNDiskCache diskCacheWithPath:path];
        if (!diskCache) return nil;
        diskCache.name = name;
        _diskCache = diskCache;
        
        _name = name;
    }
    return self;
}

- (BOOL)containsObjectForKey:(NSString *)key {
    return ([_memoryCache containsObjectForKey:key] || [_diskCache containsObjectForKey:key]);
}

- (void)containsObjectForKey:(NSString *)key completion:(void(^)(NSString *, BOOL))completion {
    if (!completion) return;
    if ([_memoryCache containsObjectForKey:key]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (completion) completion(key, YES);
        });
    } else {
        [_diskCache containsObjectForKey:key completion:completion];
    }
}

- (nullable id)objectForKey:(NSString *)key {
    id<NSCoding> object = [_memoryCache objectForKey:key];
    if (!object) {
        object = [_diskCache objectForKey:key];
        if (object) {
            [_memoryCache setObject:object forKey:key];
        }
    }
    return object;
}

- (void)objectForKey:(NSString *)key completion:(void(^)(NSString *, id _Nullable))completion {
    if (!completion) return;
    id<NSCoding> object = [_memoryCache objectForKey:key];
    if (object) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (completion) completion(key, object);
        });
    } else {
        [_diskCache containsObjectForKey:key completion:^(NSString * _Nonnull key, BOOL contains) {
            /**异步回调, 重新判断内存是否有此key缓存*/
            if (object && ![_memoryCache containsObjectForKey:key]) {
                [_memoryCache setObject:object forKey:key];
            }
            if (completion) completion(key, object);
        }];
    }
}

- (BOOL)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key {
    [_memoryCache setObject:object forKey:key];
    return [_diskCache setObject:object forKey:key];
}

- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key completion:(nullable void(^)(BOOL succeed))completion {
    [_memoryCache setObject:object forKey:key];
    [_diskCache setObject:object forKey:key completion:completion];
}

- (BOOL)removeObjectForKey:(NSString *)key {
    [_memoryCache removeObjectForKey:key];
    return [_diskCache removeObjectForKey:key];
}

- (void)removeObjectForKey:(NSString *)key completion:(nullable void(^)(NSString * _Nullable, BOOL))completion {
    [_memoryCache removeObjectForKey:key];
    [_diskCache removeObjectForKey:key completion:completion];
}

- (BOOL)removeAllObjects {
    [_memoryCache removeAllObjects];
    return [_diskCache removeAllObjects];
}

- (void)removeAllObjectsWithCompletion:(nullable void(^)(BOOL))completion {
    [_memoryCache removeAllObjects];
    [_diskCache removeAllObjectsWithCompletion:completion];
}

- (void)removeAllObjectsWithProgress:(nullable void(^)(int removedCount, int totalCount))progress
                          completion:(nullable void(^)(BOOL))completion {
    [_memoryCache removeAllObjects];
    [_diskCache removeAllObjectsWithProgress:progress completion:completion];
}

@end
