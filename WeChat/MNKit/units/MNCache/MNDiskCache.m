//
//  MNDiskCache.m
//  MNKit
//
//  Created by Vincent on 2018/10/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNDiskCache.h"
#import "MNKVStorage.h"
#import <objc/runtime.h>
#import <time.h>

static NSString * const MNDiskCacheExtendedDataKey = @"mn.disk.cache.extended.data.key";

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

static const int kDiskCacheErrorKey = -1;
static NSMapTable <NSString *, MNDiskCache *>*_diskCacheGlobalInstances;
static dispatch_semaphore_t _diskCacheGlobalInstancesLock;

static int64_t MNDiskSpaceFree(void) {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return kDiskCacheErrorKey;
    int64_t space =  [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = kDiskCacheErrorKey;
    return space;
}

static void MNDiskCacheInitGlobal (void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _diskCacheGlobalInstancesLock = dispatch_semaphore_create(1);
        _diskCacheGlobalInstances = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
    });
}

static MNDiskCache * MNDiskCacheGetGlobal(NSString *path) {
    if (path.length <= 0) return nil;
    MNDiskCacheInitGlobal();
    dispatch_semaphore_wait(_diskCacheGlobalInstancesLock, DISPATCH_TIME_FOREVER);
    MNDiskCache *cache = [_diskCacheGlobalInstances objectForKey:path];
    dispatch_semaphore_signal(_diskCacheGlobalInstancesLock);
    return cache;
}

static void MNDiskCacheSetGlobal(MNDiskCache *cache) {
    if (cache.path.length <= 0) return;
    MNDiskCacheInitGlobal();
    dispatch_semaphore_wait(_diskCacheGlobalInstancesLock, DISPATCH_TIME_FOREVER);
    [_diskCacheGlobalInstances setObject:cache forKey:cache.path];
    dispatch_semaphore_signal(_diskCacheGlobalInstancesLock);
}

@implementation MNDiskCache {
    MNKVStorage *_kv;
    dispatch_semaphore_t _lock;
    dispatch_queue_t _queue;
}

#pragma mark - Trim
- (void)_trimRecursively {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_trimTimeInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) __self = _self;
        if (!__self) return;
        [__self _trimInBackground];
        [__self _trimRecursively];
    });
}

- (void)_trimInBackground {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) __self = _self;
        if (!__self) return;
        Lock();
        [__self _trimToCost:__self->_maxCost];
        [__self _trimToCount:__self->_maxCount];
        [__self _trimToTime:__self->_timeOutInterval];
        [__self _trimToFreeDiskSpace:__self->_freeDiskSpace];
        Unlock();
    });
}

- (void)_trimToCost:(NSUInteger)costLimit {
    if (costLimit >= INT_MAX) return;
    [_kv removeItemsToFitSize:(int)costLimit];
}

- (void)_trimToCount:(NSUInteger)countLimit {
    if (countLimit >= INT_MAX) return;
    [_kv removeItemsToFitCount:(int)countLimit];
}

- (void)_trimToTime:(NSTimeInterval)timeInterval {
    if (timeInterval <= 0) {
        [_kv removeAllItems];
        return;
    }
    long timestamp = time(NULL);
    if (timestamp <= timeInterval) return;
    long interval = timestamp - timeInterval;
    if (interval >= INT_MAX) return;
    [_kv removeItemsEarlierThanTime:(int)interval];
}

- (void)_trimToFreeDiskSpace:(NSUInteger)targetFreeDiskSpace {
    if (targetFreeDiskSpace == 0) return;
    int64_t totalBytes = [_kv getItemsSize];
    if (totalBytes <= 0) return;
    int64_t diskFreeBytes = MNDiskSpaceFree();
    if (diskFreeBytes < 0) return;
    int64_t needTrimBytes = targetFreeDiskSpace - diskFreeBytes;
    if (needTrimBytes <= 0) return;
    int64_t costLimit = totalBytes - needTrimBytes;
    if (costLimit < 0) costLimit = 0;
    [self _trimToCost:(int)costLimit];
}

- (NSString *)_filenameForKey:(NSString *)key {
    NSString *filename;
    if (_diskCacheFileNameBlock) filename = _diskCacheFileNameBlock(key);
    if (!filename) filename = key.md5String32;
    return filename;
}

- (void)didEnterBackgroundNotification {
    Lock();
    _kv = nil;
    Unlock();
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];
}

#pragma mark - Initializer
- (instancetype)init {
    @throw [NSException exceptionWithName:@"MNDiskCache实例化方式错误"
                                   reason:@"请使用指定的实例化方式"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    @throw [NSException exceptionWithName:@"MNDiskCache实例化方式错误"
                                   reason:@"请使用指定的实例化方式"
                                 userInfo:nil];
    return nil;
}
+ (nullable instancetype)diskCacheWithPath:(NSString *)path {
    return [[MNDiskCache alloc] initWithPath:path];
}
- (nullable instancetype)initWithPath:(NSString *)path {
    return [self initWithPath:path inlineThreshold:20*1000];
}
- (nullable instancetype)initWithPath:(NSString *)path inlineThreshold:(NSUInteger)inlineThreshold {
    if (path.length <= 0) return nil;
    self = [super init];
    if (!self) return nil;
    /**先从缓存中取*/
    MNDiskCache *globalCache = MNDiskCacheGetGlobal(path);
    if (globalCache) return globalCache;
    /**判断缓存方式*/
    MNKVStorageType type;
    if (inlineThreshold == 0) {
        type = MNKVStorageTypeFile;
    } else if (inlineThreshold == NSUIntegerMax) {
        type = MNKVStorageTypeSQLite;
    } else {
        type = MNKVStorageTypeMixed;
    }
    /**实例化存储器*/
    MNKVStorage *kv = [[MNKVStorage alloc] initWithPath:path type:type];
    if (!kv) return nil;
    /**设置默认值*/
    _kv = kv;
    _path = path;
    _lock = dispatch_semaphore_create(1);
    /**并行线程*/
    _queue = dispatch_queue_create("com.mn.cache.disk", DISPATCH_QUEUE_CONCURRENT);
    _inlineThreshold = inlineThreshold;
    _maxCost = NSUIntegerMax;
    _maxCount = NSUIntegerMax;
    _timeOutInterval = DBL_MAX;
    _freeDiskSpace = 0;
    /**1分钟整理缓存*/
    _trimTimeInterval = 60;
    /**开启整理缓存*/
    [self _trimRecursively];
    /**把自身实例缓存*/
    MNDiskCacheSetGlobal(self);
    /**开启监听*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification)
                                                 name:UIApplicationWillTerminateNotification object:nil];
    return self;
}

- (BOOL)containsObjectForKey:(NSString *)key {
    if (!key) return NO;
    Lock();
    BOOL contains = [_kv itemExistsForKey:key];
    Unlock();
    return contains;
}

- (void)containsObjectForKey:(NSString *)key completion:(void(^)(NSString *, BOOL))completion {
    if (!completion) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) __self = _self;
        BOOL contains = [__self containsObjectForKey:key];
        if (completion) completion(key, contains);
    });
}

- (nullable id)objectForKey:(NSString *)key {
    if (!key) return nil;
    Lock();
    MNKVStorageItem *item = [_kv getItemForKey:key];
    Unlock();
    if (!item.value) return nil;
    
    id object;
    if (_diskCacheUnarchiveBlock) {
        object = _diskCacheUnarchiveBlock(item.value);
    } else {
        @try {
            object = [NSKeyedUnarchiver unarchiveObjectWithData:item.value];
        }
        @catch (NSException *exception) {
            // nothing to do...
        }
    }
    if (object && item.extendedData) {
        [MNDiskCache setExtendedData:item.extendedData toObject:object];
    }
    return object;
}

- (void)objectForKey:(NSString *)key completion:(void(^)(NSString *, id _Nullable))completion {
    if (!completion) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) __self = _self;
        id<NSCoding> object = [__self objectForKey:key];
        if (completion) completion(key, object);
    });
}

- (BOOL)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key {
    if (!key) return NO;
    if (!object) return [self removeObjectForKey:key];
    NSData *extendedData = [MNDiskCache getExtendedDataFromObject:object];
    NSData *value;
    if (_diskCacheArchiveBlock) {
        value = _diskCacheArchiveBlock(object);
    } else {
        @try {
            value = [NSKeyedArchiver archivedDataWithRootObject:object];
        }
        @catch (NSException *exception) {
            // nothing to do...
        }
    }
    if (!value) return NO;
    NSString *filename;
    if (_kv.type != MNKVStorageTypeSQLite && value.length > _inlineThreshold) {
        filename = [self _filenameForKey:key];
    }
    Lock();
    BOOL succeed = [_kv saveItemWithKey:key value:value filename:filename extendedData:extendedData];
    Unlock();
    return succeed;
}

- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key completion:(nullable void(^)(BOOL))completion {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) __self = _self;
        BOOL succeed = [__self setObject:object forKey:key];
        if (completion) completion(succeed);
    });
}

- (BOOL)removeObjectForKey:(NSString *)key {
    if (!key) return NO;
    Lock();
    BOOL succeed = [_kv removeItemForKey:key];
    Unlock();
    return succeed;
}

- (void)removeObjectForKey:(NSString *)key completion:(nullable void(^)(NSString * _Nullable, BOOL))completion {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) __self = _self;
        BOOL succeed = [__self removeObjectForKey:key];
        if (completion) completion(key, succeed);
    });
}

- (BOOL)removeAllObjects {
    Lock();
    BOOL succeed = [_kv removeAllItems];
    Unlock();
    return succeed;
}

- (void)removeAllObjectsWithCompletion:(nullable void(^)(BOOL))completion {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) __self = _self;
        BOOL succeed = [__self removeAllObjects];
        if (completion) completion(succeed);
    });
}

- (void)removeAllObjectsWithProgress:(nullable void(^)(int removedCount, int totalCount))progress
                          completion:(nullable void(^)(BOOL))completion {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) __self = _self;
        if (!__self) {
            if (completion) completion(NO);
            return;
        }
        Lock();
        [_kv removeAllItemsWithProgress:progress completion:completion];
        Unlock();
    });
}

- (NSInteger)totalCount {
    Lock();
    int count = [_kv getItemsCount];
    Unlock();
    return count;
}

- (void)totalCountWithCompletion:(void(^)(NSInteger))completion {
    if (!completion) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) __self = _self;
        NSInteger totalCount = [__self totalCount];
        if (completion) completion(totalCount);
    });
}

- (NSInteger)totalCost {
    Lock();
    int count = [_kv getItemsSize];
    Unlock();
    return count;
}

- (void)totalCostWithCompletion:(void(^)(NSInteger))completion {
    if (!completion) return;
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) __self = _self;
        NSInteger totalCost = [__self totalCost];
        if (completion) completion(totalCost);
    });
}

- (void)trimToCount:(NSUInteger)count {
    Lock();
    [self _trimToCount:count];
    Unlock();
}

- (void)trimToCount:(NSUInteger)count completion:(void(^)(void))completion {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) __self = _self;
        [__self trimToCount:count];
        if (completion) completion();
    });
}

- (void)trimToCost:(NSUInteger)cost {
    Lock();
    [self _trimToCost:cost];
    Unlock();
}

- (void)trimToCost:(NSUInteger)cost completion:(void(^)(void))completion {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) __self = _self;
        [__self trimToCost:cost];
        if (completion) completion();
    });
}

- (void)trimToTime:(NSTimeInterval)timeInterval {
    Lock();
    [self _trimToTime:timeInterval];
    Unlock();
}

- (void)trimToTime:(NSTimeInterval)timeInterval completion:(void(^)(void))completion {
    __weak typeof(self) _self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self) __self = _self;
        [__self trimToTime:timeInterval];
        if (completion) completion();
    });
}

+ (NSData *)getExtendedDataFromObject:(id)object {
    if (!object) return nil;
    return (NSData *)objc_getAssociatedObject(object, &MNDiskCacheExtendedDataKey);
}

+ (void)setExtendedData:(NSData *)extendedData toObject:(id)object {
    if (!object) return;
    objc_setAssociatedObject(object, &MNDiskCacheExtendedDataKey, extendedData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
