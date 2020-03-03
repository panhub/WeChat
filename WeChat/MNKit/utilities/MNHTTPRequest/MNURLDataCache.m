//
//  MNURLDataCache.m
//  MNKit
//
//  Created by Vincent on 2018/11/22.
//  Copyright © 2018年 小斯. All rights reserved.
//  

#import "MNURLDataCache.h"
#import <sqlite3.h>
#import <time.h>

@interface __MNURLCache : NSObject
@property (nonatomic) int time;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSData *value;
@end

@implementation __MNURLCache

@end

@interface MNURLDataCache ()

@end

static MNURLDataCache *_dataCache;

NSString *const MNURLDataCacheDBName = @"mn_url_cache.sqlite";
NSString *const MNURLDataCacheTableName = @"t_cache";

#define Lock()      dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)
#define Unlock()   dispatch_semaphore_signal(_semaphore)

@implementation MNURLDataCache
{
    sqlite3 *_db;
    NSString *_dbPath;
    dispatch_queue_t _queue;
    dispatch_semaphore_t _semaphore;
    CFMutableDictionaryRef _dbStmtCache;
    CFMutableDictionaryRef _memoryCache;
}

+ (MNURLDataCache *)dataCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_dataCache) {
            _dataCache = [[MNURLDataCache alloc] init];
        }
    });
    return _dataCache;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dataCache = [super allocWithZone:zone];
    });
    return _dataCache;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dataCache = [super init];
        if (_dataCache) {
            _dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:MNURLDataCacheDBName];
            _semaphore = dispatch_semaphore_create(1);
            _queue = dispatch_queue_create("com.mn.url.data.cache.queue", DISPATCH_QUEUE_CONCURRENT);
            CFDictionaryKeyCallBacks keyCallbacks = kCFCopyStringDictionaryKeyCallBacks;
            CFDictionaryValueCallBacks valueCallbacks = {0};
            _dbStmtCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallbacks, &valueCallbacks);
            _memoryCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            NSLog(@"url.cache.db.path===%@", _dbPath);
        }
    });
    return _dataCache;
}

#pragma mark - 存储缓存
- (BOOL)setCache:(id<NSCoding>)cache forUrl:(NSString *)url {
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (!cache || url.length <= 0) return NO;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cache];
    if (data.length <= 0) return NO;
    __MNURLCache *item = [__MNURLCache new];
    item.key = url;
    item.value = data;
    item.time = (int)time(NULL);
    Lock();
    CFDictionarySetValue(_memoryCache, (__bridge const void*)(url), (__bridge const void*)(item));
    BOOL succeed = [self dbSetCache:item];
    Unlock();
    return succeed;
}

- (void)setCache:(id<NSCoding>)cache forUrl:(NSString *)url completion:(void(^)(BOOL))completion
{
    dispatch_async(_queue, ^{
        BOOL succeed = [self setCache:cache forUrl:url];
        if (completion) {
            completion(succeed);
        }
    });
}

#pragma mark - 读取缓存
- (__MNURLCache *)dbCacheForUrl:(NSString *)url {
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (url.length <= 0 ) return nil;
    Lock();
    __MNURLCache *item = CFDictionaryGetValue(_memoryCache, (__bridge const void*)(url));
    if (!item) {
        item = [self dbCacheForKey:url];
        if (item) {
            CFDictionarySetValue(_memoryCache, (__bridge const void*)(url), (__bridge const void*)(item));
        }
    }
    Unlock();
    return item;
}

- (id)cacheForUrl:(NSString *)url {
    return [self cacheForUrl:url timeoutInterval:0.f];
}

- (void)cacheForUrl:(NSString *)url completion:(void(^)(id))completion {
    if (!completion) return;
    dispatch_async(_queue, ^{
        id<NSCoding> cache = [self cacheForUrl:url];
        if (completion) {
            completion(cache);
        }
    });
}

- (id)cacheForUrl:(NSString *)url timeoutInterval:(NSTimeInterval)timeoutInterval {
    __MNURLCache *item = [self dbCacheForUrl:url];
    if (!item || item.value.length <= 0) return nil;
    if (timeoutInterval > 0.f) {
        int interval = 60*60*24*timeoutInterval;
        int timestamp = (int)time(NULL);
        if (timestamp > (item.time + interval)) {
            [self removeCacheForUrl:url completion:nil];
            return nil;
        }
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:item.value];
}

- (void)cacheForUrl:(NSString *)url timeoutInterval:(NSTimeInterval)timeoutInterval completion:(void(^)(id))completion {
    if (!completion) return;
    dispatch_async(_queue, ^{
        id<NSCoding> cache = [self cacheForUrl:url timeoutInterval:timeoutInterval];
        if (completion) {
            completion(cache);
        }
    });
}

#pragma mark - 是否包含某条缓存
- (BOOL)containsCacheForUrl:(NSString *)url {
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (url.length <= 0) return NO;
    Lock();
    BOOL contains = (CFDictionaryContainsKey(_memoryCache, (__bridge const void*)(url)) || [self dbCacheCountForKey:url] > 0);
    Unlock();
    return contains;
}

- (void)containsCacheForUrl:(NSString *)url completion:(void(^)(BOOL))completion {
    if (!completion) return;
    dispatch_async(_queue, ^{
        BOOL contains = [self containsCacheForUrl:url];
        if (completion) {
            completion(contains);
        }
    });
}

#pragma mark - 删除某条缓存
- (BOOL)removeItemForUrl:(NSString *)url {
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (url.length <= 0 ) return NO;
    Lock();
    CFDictionaryRemoveValue(_memoryCache, (__bridge const void*)(url));
    BOOL succeed = [self dbDeleteCacheForKey:url];
    Unlock();
    return succeed;
}

- (BOOL)removeCacheForUrl:(NSString *)url {
    return [self removeItemForUrl:url];
}

- (void)removeCacheForUrl:(NSString *)url completion:(void(^)(BOOL))completion {
    dispatch_async(_queue, ^{
        BOOL succeed = [self removeItemForUrl:url];
        if (completion) {
            completion(succeed);
        }
    });
}

- (BOOL)removeAllCaches {
    Lock();
    BOOL succeed = [self dbDeleteAllCaches];
    Unlock();
    return succeed;
}

- (void)removeAllCachesUsingBlock:(void(^)(BOOL succeed))block {
    dispatch_async(_queue, ^{
        BOOL succeed = [self removeAllCaches];
        if (block) {
            block(succeed);
        }
    });
}

#pragma mark - 数据库操作
- (BOOL)dbOpen {
    if (_db) return YES;
    int result = sqlite3_open(_dbPath.UTF8String, &_db);
    if (result == SQLITE_OK && [self dbCreateTable]) return YES;
    [self dbClose];
    return NO;
}

- (BOOL)dbClose {
    if (!_db) return YES;
    /**关闭数据库*/
    int  result = 0;
    BOOL retry = YES;
    BOOL stmtFinalized = NO;
    do {
        result = sqlite3_close(_db);
        if (result == SQLITE_OK) {
            /**关闭成功*/
            retry = YES;
        } else if (result == SQLITE_BUSY || result == SQLITE_LOCKED) {
            /**繁忙或锁定*/
            if (!stmtFinalized) {
                stmtFinalized = YES;
                /**销毁句柄*/
                sqlite3_stmt *stmt;
                while ((stmt = sqlite3_next_stmt(_db, nil)) != 0) {
                    sqlite3_finalize(stmt);
                }
                retry = YES;
            }
        } else {
            NSLog(@"sqlite close failed");
        }
    } while (!retry);
    _db = NULL;
    return YES;
}

- (BOOL)dbCreateTable {
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (time integer, url text, data blob, primary key(time));",MNURLDataCacheTableName];
    return [self dbExecute:sql];
}

/**执行数据库语句, 返回执行结果*/
- (BOOL)dbExecute:(NSString *)sql {
    if (sql.length <= 0 || !_db) return NO;
    return sqlite3_exec(_db, sql.UTF8String, NULL, NULL, NULL) == SQLITE_OK;
}

- (BOOL)dbSetCache:(__MNURLCache *)item {
    if (!item) return NO;
    NSString *sql = [NSString stringWithFormat:@"insert or replace into %@ (time, url, data) values (?1, ?2, ?3);",MNURLDataCacheTableName];
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return NO;
    //NSInteger timestamp = (long)[[NSDate date] timeIntervalSince1970];
    int timestamp = (int)time(NULL);
    sqlite3_bind_int(stmt, 1, timestamp);
    sqlite3_bind_text(stmt, 2, item.key.UTF8String, -1, NULL);
    if (item.value.length > 0) {
        sqlite3_bind_blob(stmt, 3, item.value.bytes, (int)item.value.length, 0);
    } else {
        sqlite3_bind_blob(stmt, 3, NULL, 0, 0);
    }
    int result = sqlite3_step(stmt);
    return result == SQLITE_DONE;
}

- (__MNURLCache *)dbCacheForKey:(NSString *)key {
    NSString *sql = [NSString stringWithFormat:@"select time, url, data from %@ where url = ?1;",MNURLDataCacheTableName];
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    __MNURLCache *item;
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        //取值, 注意建表顺序, 取值时从0开始
        int time = sqlite3_column_int(stmt, 0);
        char *url = (char *)sqlite3_column_text(stmt, 1);
        const void *data = sqlite3_column_blob(stmt, 2);
        int data_bytes = sqlite3_column_bytes(stmt, 2);
        item = [__MNURLCache new];
        item.time = time;
        item.key = [[NSString alloc] initWithUTF8String:url];
        item.value = [NSData dataWithBytes:data length:data_bytes];
    }
    return item;
}

- (int)dbCacheCountForKey:(NSString *)key {
    NSString *sql = [NSString stringWithFormat:@"select count(url) from %@ where url = ?1;",MNURLDataCacheTableName];
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return 0;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) return 0;
    return sqlite3_column_int(stmt, 0);
}

- (BOOL)dbDeleteCacheForKey:(NSString *)key {
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where url = ?1;",MNURLDataCacheTableName];
    sqlite3_stmt *stmt = [self dbPrepareStmt:sql];
    if (!stmt) return NO;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result == SQLITE_DONE) return YES;
    return NO;
}

- (BOOL)dbDeleteAllCaches {
    if (![self dbOpen]) return NO;
    NSString *sql = [NSString stringWithFormat:@"delete from %@;", MNURLDataCacheTableName];
    return sqlite3_exec(_db, sql.UTF8String, NULL, NULL, NULL) == SQLITE_OK;
}

- (sqlite3_stmt *)dbPrepareStmt:(NSString *)sql {
    if (sql.length <= 0 || ![self dbOpen] || !_dbStmtCache) return NULL;
    sqlite3_stmt *stmt = (sqlite3_stmt *)CFDictionaryGetValue(_dbStmtCache, (__bridge const void*)(sql));
    if (stmt) {
        sqlite3_reset(stmt);
    } else {
        int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            CFDictionarySetValue(_dbStmtCache, (__bridge const void*)(sql), stmt);
        } else {
            NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            sqlite3_finalize(stmt);
            stmt = NULL;
        }
    }
    return stmt;
}

#pragma mark - dealloc
- (void)dealloc {
    CFDictionaryRemoveAllValues(_dbStmtCache);
    CFDictionaryRemoveAllValues(_memoryCache);
    CFRelease(_dbStmtCache);
    CFRelease(_memoryCache);
    [self dbClose];
}

@end
