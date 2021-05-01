//
//  MNKVStorage.m
//  MNKit
//
//  Created by Vincent on 2018/10/30.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNKVStorage.h"
#import <UIKit/UIKit.h>
#import <time.h>
#import <sqlite3.h>

static const NSUInteger kMaxErrorRetryCount = 5; //允许最大错误次数
static const NSTimeInterval kMinRetryTimeInterval = 2.f; //重试时间间隔
static const int kPathLengthMax = PATH_MAX - 64; //路径最大长度
static const int kDBGetErrorKey = -1; //获取数据库数据失败的返回值
static NSString *const kDBTableName = @"t_manifest"; //表格名
static NSString *const kDBFileName = @"mn_disk_cache.sqlite";
static NSString *const kDBShmFileName = @"mn_disk_cache.sqlite-shm";
static NSString *const kDBWalFileName = @"mn_disk_cache.sqlite-wal";
static NSString *const kDataDirectoryName = @"data"; //data文件名
static NSString *const kTrashDirectoryName = @"trash"; //垃圾文件名

@implementation MNKVStorageItem
@end



@implementation MNKVStorage {
    /**垃圾处理线程*/
    dispatch_queue_t _trashQueue;
    /**磁盘缓存路径*/
    NSString *_path;
    /**db相关路径*/
    NSString *_dbPath;
    NSString *_dataPath;
    NSString *_trashPath;
    /**数据库*/
    sqlite3 *_db;
    /**句柄缓存*/
    CFMutableDictionaryRef _dbStmtCache;
    /**数据库上一次打开失败时间*/
    NSTimeInterval _dbLastOpenErrorTime;
    /**数据库打开失败次数*/
    NSUInteger _dbOpenErrorCount;
}

#pragma mark - 数据库操作
- (BOOL)_dbOpen {
    if (_db) return YES;
    /**打开数据库*/
    int result = sqlite3_open(_dbPath.UTF8String, &_db);
    if (result == SQLITE_OK) {
        /**初始化句柄容器*/
        CFDictionaryKeyCallBacks keyCallbacks = kCFCopyStringDictionaryKeyCallBacks;
        CFDictionaryValueCallBacks valueCallbacks = {0};
        _dbStmtCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallbacks, &valueCallbacks);
        /**清空错误时间记录*/
        _dbLastOpenErrorTime = 0;
        /**清空错误次数*/
        _dbOpenErrorCount = 0;
        return YES;
    }
    /**确保下次判断为NO*/
    _db = NULL;
    /**清空句柄*/
    if (_dbStmtCache) CFRelease(_dbStmtCache);
    _dbStmtCache = NULL;
    /**记录此次打开失败时间*/
    _dbLastOpenErrorTime = CACurrentMediaTime();
    /**记录打开失败次数*/
    _dbOpenErrorCount++;
    return NO;
}

- (BOOL)_dbClose {
    if (!_db) return YES;
    /**清空句柄*/
    if (_dbStmtCache) CFRelease(_dbStmtCache);
    _dbStmtCache = NULL;
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
            NSLog(@"%s line:%d sqlite close failed (%d).", __FUNCTION__, __LINE__, result);
        }
    } while (!retry);
    _db = NULL;
    return YES;
}
//确保数据库处于正常状态<防止关闭>
- (BOOL)_dbCheck {
    if (_db) return YES;
    if (_dbOpenErrorCount < kMaxErrorRetryCount &&
        CACurrentMediaTime() - _dbLastOpenErrorTime > kMinRetryTimeInterval) {
        return [self _dbOpen] && [self _dbInitialized];
    }
    return NO;
}

/**创建表格*/
- (BOOL)_dbInitialized {
    NSString *sql = [NSString stringWithFormat:@"pragma journal_mode = wal; pragma synchronous = normal; create table if not exists %@ (key text, filename text, size integer, inline_data blob, modification_time integer, last_access_time integer, extended_data blob, primary key(key)); create index if not exists last_access_time_idx on %@(last_access_time);",kDBTableName,kDBTableName];
    return [self _dbExecute:sql];
}

/**执行数据库语句, 返回执行结果*/
- (BOOL)_dbExecute:(NSString *)sql {
    if (sql.length <= 0) return NO;
    if (![self _dbCheck]) return NO;
    char *error = NULL;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
    if (error) {
        NSLog(@"%s line:%d sqlite exec error (%d): %s", __FUNCTION__, __LINE__, result, error);
        sqlite3_free(error);
    }
    return result == SQLITE_OK;
}

- (void)_dbCheckpoint {
    if (![self _dbCheck]) return;
    //手动执行 checkpoint,检查wal文件 (可查询 SQLite wal 模式了解)
    sqlite3_wal_checkpoint(_db, NULL);
}

/**获取句柄, 先从缓存中取, 有则返回, 没有就创建, 缓存, 返回*/
- (sqlite3_stmt *)_dbPrepareStmt:(NSString *)sql {
    if (![self _dbCheck] || !_dbStmtCache || sql.length <= 0) return NULL;
    sqlite3_stmt *stmt = (sqlite3_stmt *)CFDictionaryGetValue(_dbStmtCache, (__bridge const void*)(sql));
    if (stmt) {
        /**以防缓存上次数据信息,重置句柄*/
        sqlite3_reset(stmt);
    } else {
        /**检查SQL语句的合法性, 获取句柄*/
        /**对于C字符串, 可以传递-1代替字符串的长度*/
        /**
         int sqlite3_exec(
            sqlite3*,  // 一个打开的数据库实例
            const char *sql, // 需要执行的SQL语句
            int (*callback)(void*,int,char**,char**),  // SQL语句执行完毕后的回调
            void *,  // 回调函数的第1个参数
            char **errmsg // 错误信息
         );
         */
        int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            /**获取句柄成功, 放入缓存*/
            CFDictionarySetValue(_dbStmtCache, (__bridge const void*)(sql), stmt);
        } else {
            NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            return NULL;
        }
    }
    return stmt;
}

/**插入数据*/
- (BOOL)_dbInsertItemWithKey:(NSString *)key value:(NSData *)value  filename:(NSString *)filename extendedData:(NSData *)extendedData {
    NSString *sql = [NSString stringWithFormat:@"insert or replace into %@ (key, filename, size, inline_data, modification_time, last_access_time, extended_data) values (?1, ?2, ?3, ?4, ?5, ?6, ?7);",kDBTableName];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return NO;
    /**依据句柄设置数据*/
    /**
     第1个参数是sqlite3_stmt *类型
     第2个参数指占位符的位置, 第一个占位符的位置是1，不是0
     第3个参数指占位符要绑定的值
     第4个参数指在第3个参数中所传递数据的长度, 对于C字符串, 可以传递-1代替字符串的长度
     第5个参数是一个可选的函数回调, 一般用于在语句执行后完成内存清理工作
     */
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    sqlite3_bind_text(stmt, 2, filename.UTF8String, -1, NULL);
    sqlite3_bind_int(stmt, 3, (int)value.length);
    if (filename.length <= 0) {
        sqlite3_bind_blob(stmt, 4, value.bytes, (int)(value.length), 0);
    } else {
        sqlite3_bind_blob(stmt, 4, NULL, 0, 0);
    }
    int timestamp = (int)time(NULL);
    sqlite3_bind_int(stmt, 5, timestamp);
    sqlite3_bind_int(stmt, 6, timestamp);
    sqlite3_bind_blob(stmt, 7, extendedData.bytes, (int)(extendedData.length), 0);
    /**sqlite3_step(sqlite3_stmt*) 执行SQL语句, 返回SQLITE_DONE代表成功*/
    int result = sqlite3_step(stmt);
    if (result == SQLITE_DONE) return YES;
    NSLog(@"%s line:%d sqlite insert error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
    return NO;
}

/**更新一条数据存取时间*/
- (BOOL)_dbUpdateAccessTimeWithKey:(NSString *)key {
    NSString *sql = [NSString stringWithFormat:@"update %@ set last_access_time = ?1 where key = ?2;",kDBTableName];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return NO;
    int timestamp = (int)time(NULL);
    sqlite3_bind_int(stmt, 1, timestamp);
    sqlite3_bind_text(stmt, 2, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result == SQLITE_DONE) return YES;
    NSLog(@"%s line:%d sqlite update error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
    return NO;
}

/**更新一组数据存取时间*/
- (BOOL)_dbUpdateAccessTimeWithKeys:(NSArray <NSString *>*)keys {
    if (![self _dbCheck]) return NO;
    int timestamp = (int)time(NULL);
    NSString *sql = [NSString stringWithFormat:@"update %@ set last_access_time = %d where key in (%@);", kDBTableName, timestamp, [self _dbJoinedKeys:keys]];
    
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    [self _dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    result = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (result != SQLITE_DONE) {
        NSLog(@"%s line:%d sqlite update error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

/**删除一条数据*/
- (BOOL)_dbDeleteItemWithKey:(NSString *)key {
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where key = ?1;",kDBTableName];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return NO;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result == SQLITE_DONE) return YES;
    NSLog(@"%s line:%d db delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
    return NO;
}

/**删除指定key的一组数据*/
- (BOOL)_dbDeleteItemWithKeys:(NSArray <NSString *>*)keys {
    if (![self _dbCheck]) return NO;
    /**补充sql语句*/
    NSString *sql =  [NSString stringWithFormat:@"delete from %@ where key in (%@);",kDBTableName,[self _dbJoinedKeys:keys]];
    /**因为删除的key数量不固定, 故句柄不定, 所以不做缓存, 不取缓存*/
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    /**绑定key*/
    [self _dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    result = sqlite3_step(stmt);
    /**用完使其结束,释放*/
    sqlite3_finalize(stmt);
    if (result == SQLITE_ERROR) {
        NSLog(@"%s line:%d sqlite delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return NO;
    }
    return YES;
}

/**删除size大于指定量的一组数据*/
- (BOOL)_dbDeleteItemsWithSizeLargerThan:(int)size {
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where size > ?1;",kDBTableName];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return NO;
    sqlite3_bind_int(stmt, 1, size);
    int result = sqlite3_step(stmt);
    if (result == SQLITE_DONE) return YES;
    NSLog(@"%s line:%d sqlite delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
    return NO;
}

/**删除时间大于指定的一组数据*/
- (BOOL)_dbDeleteItemsWithTimeEarlierThan:(int)time {
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where last_access_time < ?1;",kDBTableName];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return NO;
    sqlite3_bind_int(stmt, 1, time);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_DONE) return YES;
    NSLog(@"%s line:%d sqlite delete error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
    return NO;
}

/**补充sql语句*/
- (NSString *)_dbJoinedKeys:(NSArray <NSString *>*)keys {
    NSMutableString *string = [NSMutableString new];
    for (NSUInteger i = 0,max = keys.count; i < max; i++) {
        [string appendString:@"?"];
        if (i + 1 != max) {
            [string appendString:@","];
        }
    }
    return [string copy];
}

/**句柄绑定参数*/
- (void)_dbBindJoinedKeys:(NSArray <NSString *>*)keys stmt:(sqlite3_stmt *)stmt fromIndex:(int)index {
    for (int i = 0, max = (int)keys.count; i < max; i++) {
        NSString *key = keys[i];
        sqlite3_bind_text(stmt, index + i, key.UTF8String, -1, NULL);
    }
}

/**获取指定参数的存储模型*/
- (MNKVStorageItem *)_dbGetItemWithKey:(NSString *)key excludeInlineData:(BOOL)excludeInlineData {
    NSString *sql = excludeInlineData ? [NSString stringWithFormat:@"select key, filename, size, modification_time, last_access_time, extended_data from %@ where key = ?1;",kDBTableName] : [NSString stringWithFormat:@"select key, filename, size, inline_data, modification_time, last_access_time, extended_data from %@ where key = ?1;",kDBTableName];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    MNKVStorageItem *item;
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        item = [self _dbGetItemFromStmt:stmt excludeInlineData:excludeInlineData];
    } else {
        if (result != SQLITE_DONE) {
            NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        }
    }
    return item;
}

/**获取存储模型*/
- (MNKVStorageItem *)_dbGetItemFromStmt:(sqlite3_stmt *)stmt excludeInlineData:(BOOL)excludeInlineData {
    /**取数据*/
    //(key text, filename text, size integer, inline_data blob, modification_time integer, last_access_time integer, extended_data blob, primary key(key))
    int i = 0;
    char *key = (char *)sqlite3_column_text(stmt, i++);
    char *filename = (char *)sqlite3_column_text(stmt, i++);
    int size = sqlite3_column_int(stmt, i++);
    const void *inline_data = excludeInlineData ? NULL : sqlite3_column_blob(stmt, i);
    int inline_data_bytes = excludeInlineData ? 0 : sqlite3_column_bytes(stmt, i++);
    int modification_time = sqlite3_column_int(stmt, i++);
    int last_access_time = sqlite3_column_int(stmt, i++);
    const void *extended_data = sqlite3_column_blob(stmt, i);
    int extended_data_bytes = sqlite3_column_bytes(stmt, i++);
    /**构建模型*/
    MNKVStorageItem *item = [MNKVStorageItem new];
    if (key) item.key = [NSString stringWithUTF8String:key];
    if (filename && *filename != 0) item.filename = [NSString stringWithUTF8String:filename];
    item.size = size;
    if (inline_data_bytes > 0 && inline_data) item.value = [NSData dataWithBytes:inline_data length:inline_data_bytes];
    item.modTime = modification_time;
    item.accessTime = last_access_time;
    if (extended_data_bytes > 0 && extended_data) item.extendedData = [NSData dataWithBytes:extended_data length:extended_data_bytes];
    return item;
}

/**取出指定一组key的存储模型*/
- (NSMutableArray <MNKVStorageItem *>*)_dbGetItemsWithKeys:(NSArray <NSString *>*)keys excludeInlineData:(BOOL)excludeInlineData {
    if (![self _dbCheck]) return nil;
    NSString *sql = excludeInlineData ? [NSString stringWithFormat:@"select key, filename, size, modification_time, last_access_time, extended_data from %@ where key in (%@);",kDBTableName,[self _dbJoinedKeys:keys]] : [NSString stringWithFormat:@"select key, filename, size, inline_data, modification_time, last_access_time, extended_data from %@ where key in (%@);",kDBTableName, [self _dbJoinedKeys:keys]];
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return nil;
    }
    [self _dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    NSMutableArray <MNKVStorageItem *>*items = [NSMutableArray new];
    do {
        result = sqlite3_step(stmt);
        if (result == SQLITE_OK) {
            MNKVStorageItem *item = [self _dbGetItemFromStmt:stmt excludeInlineData:excludeInlineData];
            if (item) [items addObject:item];
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            [items removeAllObjects];
            items = nil;
            break;
        }
    } while (1);
    sqlite3_finalize(stmt);
    return items;
}

/**获取指定key的数据*/
- (NSData *)_dbGetValueWithKey:(NSString *)key {
    NSString *sql = [NSString stringWithFormat:@"select inline_data from %@ where key = ?1;",kDBTableName];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        const void *inline_data = sqlite3_column_blob(stmt, 0);
        int inline_data_bytes = sqlite3_column_bytes(stmt, 0);
        if (!inline_data || inline_data_bytes <= 0) return nil;
        return [NSData dataWithBytes:inline_data length:inline_data_bytes];
    } else if (result != SQLITE_DONE) {
        NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
    }
    return nil;
}

/**获取指定key的Filename*/
- (NSString *)_dbGetFilenameWithKey:(NSString *)key {
    NSString *sql = [NSString stringWithFormat:@"select filename from %@ where key = ?1;",kDBTableName];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        char *filename = (char *)sqlite3_column_text(stmt, 0);
        if (filename && *filename != 0) {
            return [NSString stringWithUTF8String:filename];
        }
    } else if (result != SQLITE_DONE) {
        NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
    }
    return nil;
}

/**取出指定一组key的文件名*/
- (NSMutableArray <NSString *>*)_dbGetFilenamesWithKeys:(NSArray <NSString *>*)keys {
    if (![self _dbCheck]) return nil;
    NSString *sql = [NSString stringWithFormat:@"select filename from %@ where key in (%@);",kDBTableName, [self _dbJoinedKeys:keys]];
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"%s line:%d sqlite stmt prepare error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return nil;
    }
    [self _dbBindJoinedKeys:keys stmt:stmt fromIndex:1];
    NSMutableArray <NSString *>*filenames = [NSMutableArray new];
    do {
        result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *filename = (char *)sqlite3_column_text(stmt, 0);
            if (filename && *filename != 0) {
                NSString *name = [NSString stringWithUTF8String:filename];
                if (name) [filenames addObject:name];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            [filenames removeAllObjects];
            filenames = nil;
            break;
        }
    } while (1);
    sqlite3_finalize(stmt);
    return filenames;
}

/**获取文件大于指定体积的一组文件*/
- (NSMutableArray <NSString *>*)_dbGetFilenamesWithSizeLargerThan:(int)size {
    NSString *sql = [NSString stringWithFormat:@"select filename from %@ where size > ?1 and filename is not null;",kDBTableName];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_int(stmt, 1, size);
    
    NSMutableArray <NSString *>*filenames = [NSMutableArray new];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *filename = (char *)sqlite3_column_text(stmt, 0);
            if (filename && *filename != 0) {
                NSString *name = [NSString stringWithUTF8String:filename];
                if (name) [filenames addObject:name];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            [filenames removeAllObjects];
            filenames = nil;
            break;
        }
    } while (1);
    return filenames;
}

/**获取时间大于指定时间的一组文件*/
- (NSMutableArray <NSString *>*)_dbGetFilenamesWithTimeEarlierThan:(int)time {
    NSString *sql = [NSString stringWithFormat:@"select filename from %@ where last_access_time < ?1 and filename is not null;",kDBTableName];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_int(stmt, 1, time);
    NSMutableArray <NSString *>*filenames = [NSMutableArray new];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *filename = (char *)sqlite3_column_text(stmt, 0);
            if (filename && *filename != 0) {
                NSString *name = [NSString stringWithUTF8String:filename];
                if (name) [filenames addObject:name];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            [filenames removeAllObjects];
            filenames = nil;
            break;
        }
    } while (1);
    return filenames;
}

- (NSMutableArray <MNKVStorageItem *>*)_dbGetItemSizeInfoOrderByTimeAscWithLimit:(int)count {
    NSString *sql = [NSString stringWithFormat:@"select key, filename, size from %@ order by last_access_time asc limit ?1;",kDBTableName];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return nil;
    sqlite3_bind_int(stmt, 1, count);
    NSMutableArray <MNKVStorageItem *>*items = [NSMutableArray arrayWithCapacity:count];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *key = (char *)sqlite3_column_text(stmt, 0);
            char *filename = (char *)sqlite3_column_text(stmt, 1);
            int size = sqlite3_column_int(stmt, 2);
            NSString *keyStr = key ? [NSString stringWithUTF8String:key] : nil;
            if (keyStr) {
                MNKVStorageItem *item = [MNKVStorageItem new];
                item.key = keyStr;
                item.filename = filename ? [NSString stringWithUTF8String:filename] : nil;
                item.size = size;
                [items addObject:item];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
            [items removeAllObjects];
            items = nil;
            break;
        }
    } while (1);
    return items;
}

/**获取指定key的数量*/
- (int)_dbGetItemCountWithKey:(NSString *)key {
    NSString *sql = [NSString stringWithFormat:@"select count(key) from %@ where key = ?1;",kDBTableName];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return kDBGetErrorKey;
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return kDBGetErrorKey;
    }
    return sqlite3_column_int(stmt, 0);
}

/**获取总体积*/
- (int)_dbGetTotalItemSize {
    NSString *sql = [NSString stringWithFormat:@"select sum(size) from %@;",kDBTableName];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return kDBGetErrorKey;
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return kDBGetErrorKey;
    }
    return sqlite3_column_int(stmt, 0);
}

/**获取总数量*/
- (int)_dbGetTotalItemCount {
    NSString *sql = [NSString stringWithFormat:@"select count(*) from %@;",kDBTableName];
    sqlite3_stmt *stmt = [self _dbPrepareStmt:sql];
    if (!stmt) return kDBGetErrorKey;
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        NSLog(@"%s line:%d sqlite query error (%d): %s", __FUNCTION__, __LINE__, result, sqlite3_errmsg(_db));
        return kDBGetErrorKey;
    }
    return sqlite3_column_int(stmt, 0);
}

#pragma mark - File
/**写入文件*/
- (BOOL)_fileWriteWithName:(NSString *)filename data:(NSData *)data {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [data writeToFile:path atomically:NO];
}

/**读取文件*/
- (NSData *)_fileReadWithName:(NSString *)filename {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

/**删除文件*/
- (BOOL)_fileDeleteWithName:(NSString *)filename {
    NSString *path = [_dataPath stringByAppendingPathComponent:filename];
    return [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

/**移动文件到垃圾文件夹*/
- (BOOL)_fileMoveAllToTrash {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuid = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *tmpPath = [_trashPath stringByAppendingPathComponent:(__bridge NSString *)(uuid)];
    BOOL succeed = [[NSFileManager defaultManager] moveItemAtPath:_dataPath toPath:tmpPath error:nil];
    if (succeed) {
        succeed = [[NSFileManager defaultManager] createDirectoryAtPath:_dataPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    CFRelease(uuid);
    return succeed;
}

/**清空垃圾文件夹*/
- (void)_fileEmptyTrashInBackground {
    NSString *trashPath = _trashPath;
    dispatch_queue_t queue = _trashQueue;
    dispatch_async(queue, ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        NSArray *directoryContents = [manager contentsOfDirectoryAtPath:trashPath error:NULL];
        [directoryContents enumerateObjectsUsingBlock:^(NSString * _Nonnull path, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *fullPath = [trashPath stringByAppendingPathComponent:path];
            [manager removeItemAtPath:fullPath error:NULL];
        }];
    });
}

#pragma mark - 私有方法
/**确保数据库关闭的状态下, 清空数据库相关文件和删除数据文件*/
- (void)_reset {
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBFileName] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBShmFileName] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[_path stringByAppendingPathComponent:kDBWalFileName] error:nil];
    [self _fileMoveAllToTrash];
    [self _fileEmptyTrashInBackground];
}

#pragma mark - 公共的
- (instancetype)init {
    @throw [NSException exceptionWithName:@"MNKVStorage实例化方式错误"
                                   reason:@"请使用指定的实例化方式"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    @throw [NSException exceptionWithName:@"MNKVStorage实例化方式错误"
                                   reason:@"请使用指定的实例化方式"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithPath:(NSString *)path type:(MNKVStorageType)type {
    if (path.length <= 0 || path.length > kPathLengthMax) {
        NSLog(@"MNKVStorage init error: invalid path length: [%@].", path);
        return nil;
    }
    if (type > MNKVStorageTypeMixed) {
        NSLog(@"MNKVStorage init error: invalid type: %lu.", (unsigned long)type);
        return nil;
    }
    if (self = [super init]) {
        /**记录类型*/
        _type = type;
        /**记录路径*/
        _path = [path copy];
        _dbPath = [_path stringByAppendingPathComponent:kDBFileName];
        _dataPath = [_path stringByAppendingPathComponent:kDataDirectoryName];
        _trashPath = [_path stringByAppendingPathComponent:kTrashDirectoryName];
        /**垃圾处理线程,串行任务*/
        _trashQueue = dispatch_queue_create("com.mn.cache.disk.trash", DISPATCH_QUEUE_SERIAL);
        /**创建文件夹*/
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error] ||
            ![[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingPathComponent:kDataDirectoryName]
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error] ||
            ![[NSFileManager defaultManager] createDirectoryAtPath:[path stringByAppendingPathComponent:kTrashDirectoryName]
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
                NSLog(@"MNKVStorage init error:%@", error);
                return nil;
            }
        if (![self _dbOpen] || ![self _dbInitialized]) {
            /**数据库打开失败或建表失败*/
            [self _dbClose];
            [self _reset];
            /**再次尝试打开数据库并建表*/
            if (![self _dbOpen] || ![self _dbInitialized]) {
                [self _dbClose];
                [self _reset];
                NSLog(@"MNKVStorage init error: fail to open sqlite db.");
                return nil;
            }
        }
        /**清空垃圾文件<可能是上次运行时留下的文件>*/
        [self _fileEmptyTrashInBackground];
    }
    return self;
}

- (void)dealloc {
    /**程序多存活*/
    UIBackgroundTaskIdentifier taskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    [self _dbClose];
    if (taskID != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:taskID];
    }
}

/**存储item*/
- (BOOL)saveItem:(MNKVStorageItem *)item {
    return [self _dbInsertItemWithKey:item.key
                                value:item.value
                             filename:item.filename
                         extendedData:item.extendedData];
}

- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value {
    return [self _dbInsertItemWithKey:key
                                value:value
                             filename:nil
                         extendedData:nil];
}

- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value filename:(NSString *)filename extendedData:(NSData *)extendedData {
    if (key.length <= 0 || value.length <= 0) return NO;
    if (_type == MNKVStorageTypeFile && filename.length <= 0) return NO;
    if (filename.length > 0) {
        if (![self _fileWriteWithName:filename data:value]) return NO;
        if (![self _dbInsertItemWithKey:key value:value filename:filename extendedData:extendedData]) {
            [self _fileDeleteWithName:filename];
            return NO;
        }
        return YES;
    }
    if (_type != MNKVStorageTypeSQLite) {
        NSString *filename = [self _dbGetFilenameWithKey:key];
        if (filename) {
            [self _fileDeleteWithName:filename];
        }
    }
    return [self _dbInsertItemWithKey:key
                                value:value
                             filename:nil
                         extendedData:extendedData];
}

- (BOOL)removeItemForKey:(NSString *)key {
    if (key.length <= 0) return NO;
    switch (_type) {
        case MNKVStorageTypeSQLite: {
            return [self _dbDeleteItemWithKey:key];
        } break;
        case MNKVStorageTypeFile:
        case MNKVStorageTypeMixed: {
            NSString *filename = [self _dbGetFilenameWithKey:key];
            if (filename) {
                [self _fileDeleteWithName:filename];
            }
            return [self _dbDeleteItemWithKey:key];
        } break;
        default:return NO;
    }
}

- (BOOL)removeItemForKeys:(NSArray <NSString *>*)keys {
    if (keys.count <= 0) return NO;
    switch (_type) {
        case MNKVStorageTypeSQLite: {
            return [self _dbDeleteItemWithKeys:keys];
        } break;
        case MNKVStorageTypeFile:
        case MNKVStorageTypeMixed: {
            NSArray <NSString *>*filenames = [self _dbGetFilenamesWithKeys:keys];
            [filenames enumerateObjectsUsingBlock:^(NSString * _Nonnull filename, NSUInteger idx, BOOL * _Nonnull stop) {
                [self _fileDeleteWithName:filename];
            }];
            return [self _dbDeleteItemWithKeys:keys];
        } break;
        default: return NO;
    }
}

- (BOOL)removeItemsLargerThanSize:(int)size {
    if (size == INT_MAX) return YES;
    if (size <= 0) return [self removeAllItems];
    switch (_type) {
        case MNKVStorageTypeSQLite: {
            if ([self _dbDeleteItemsWithSizeLargerThan:size]) {
                [self _dbCheckpoint];
                return YES;
            }
        } break;
        case MNKVStorageTypeFile:
        case MNKVStorageTypeMixed: {
            NSArray *filenames = [self _dbGetFilenamesWithSizeLargerThan:size];
            [filenames enumerateObjectsUsingBlock:^(NSString * _Nonnull filename, NSUInteger idx, BOOL * _Nonnull stop) {
                [self _fileDeleteWithName:filename];
            }];
            if ([self _dbDeleteItemsWithSizeLargerThan:size]) {
                [self _dbCheckpoint];
                return YES;
            }
        } break;
    }
    return NO;
}

- (BOOL)removeItemsEarlierThanTime:(int)time {
    if (time <= 0) return YES;
    if (time == INT_MAX) return [self removeAllItems];
    switch (_type) {
        case MNKVStorageTypeSQLite: {
            if ([self _dbDeleteItemsWithTimeEarlierThan:time]) {
                [self _dbCheckpoint];
                return YES;
            }
        } break;
        case MNKVStorageTypeFile:
        case MNKVStorageTypeMixed: {
            NSArray *filenames = [self _dbGetFilenamesWithTimeEarlierThan:time];
            [filenames enumerateObjectsUsingBlock:^(NSString * _Nonnull filename, NSUInteger idx, BOOL * _Nonnull stop) {
                [self _fileDeleteWithName:filename];
            }];
            if ([self _dbDeleteItemsWithTimeEarlierThan:time]) {
                [self _dbCheckpoint];
                return YES;
            }
        } break;
    }
    return NO;
}

- (BOOL)removeItemsToFitSize:(int)maxSize {
    if (maxSize == INT_MAX) return YES;
    if (maxSize <= 0) return [self removeAllItems];
    
    int total = [self _dbGetTotalItemSize];
    if (total == kDBGetErrorKey) return NO;
    if (total <= maxSize) return YES;
    
    NSArray *items;
    BOOL succeed = NO;
    do {
        items = [self _dbGetItemSizeInfoOrderByTimeAscWithLimit:16];
        for (MNKVStorageItem *item in items) {
            if (total > maxSize) {
                if (item.filename) {
                    [self _fileDeleteWithName:item.filename];
                }
                succeed = [self _dbDeleteItemWithKey:item.key];
                total -= item.size;
            } else {
                break;
            }
            if (!succeed) break;
        }
    } while (total > maxSize && items.count > 0 && succeed);
    if (succeed) [self _dbCheckpoint];
    return succeed;
}

- (BOOL)removeItemsToFitCount:(int)maxCount {
    if (maxCount == INT_MAX) return YES;
    if (maxCount <= 0) return [self removeAllItems];
    
    int total = [self _dbGetTotalItemCount];
    if (total == kDBGetErrorKey) return NO;
    if (total <= maxCount) return YES;
    
    NSArray *items;
    BOOL succeed = NO;
    do {
        items = [self _dbGetItemSizeInfoOrderByTimeAscWithLimit:16];
        for (MNKVStorageItem *item in items) {
            if (total > maxCount) {
                if (item.filename) {
                    [self _fileDeleteWithName:item.filename];
                }
                succeed = [self _dbDeleteItemWithKey:item.key];
                total--;
            } else {
                break;
            }
            if (!succeed) break;
        }
    } while (total > maxCount && items.count > 0 && succeed);
    if (succeed) [self _dbCheckpoint];
    return succeed;
}

- (BOOL)removeAllItems {
    if (![self _dbClose]) return NO;
    [self _reset];
    if (![self _dbOpen]) return NO;
    if (![self _dbInitialized]) return NO;
    return YES;
}

- (void)removeAllItemsWithProgress:(nullable void(^)(int, int))progress
                        completion:(nullable void(^)(BOOL))completion {
    int total = [self _dbGetTotalItemCount];
    if (total <= 0) {
        if (completion) completion(YES);
    } else {
        int _total = total;
        NSArray *items;
        BOOL succeed = NO;
        do {
            items = [self _dbGetItemSizeInfoOrderByTimeAscWithLimit:32];
            for (MNKVStorageItem *item in items) {
                if (_total > 0) {
                    if (item.filename) {
                        [self _fileDeleteWithName:item.filename];
                    }
                    succeed = [self _dbDeleteItemWithKey:item.key];
                    _total--;
                } else {
                    break;
                }
                if (!succeed) break;
            }
            if (progress) progress(total-_total, total);
        } while (_total > 0 && items.count > 0 && succeed);
        if (succeed) [self _dbCheckpoint];
        if (completion) completion(succeed);
    }
}

- (MNKVStorageItem *)getItemForKey:(NSString *)key {
    if (key.length <= 0) return nil;
    MNKVStorageItem *item = [self _dbGetItemWithKey:key excludeInlineData:NO];
    if (item) {
        [self _dbUpdateAccessTimeWithKey:key];
        if (item.filename) {
            item.value = [self _fileReadWithName:item.filename];
            if (!item.value) {
                [self _dbDeleteItemWithKey:key];
                item = nil;
            }
        }
    }
    return item;
}

- (MNKVStorageItem *)getItemInfoForKey:(NSString *)key {
    if (key.length <= 0) return nil;
    return [self _dbGetItemWithKey:key excludeInlineData:YES];
}

- (NSData *)getItemValueForKey:(NSString *)key {
    if (key.length <= 0) return nil;
    NSData *value;
    switch (_type) {
        case MNKVStorageTypeFile: {
            NSString *filename = [self _dbGetFilenameWithKey:key];
            if (filename) {
                value = [self _fileReadWithName:filename];
                if (!value) {
                    [self _dbDeleteItemWithKey:key];
                    [self _fileDeleteWithName:filename];
                    value = nil;
                }
            }
        } break;
        case MNKVStorageTypeSQLite: {
            value = [self _dbGetValueWithKey:key];
        } break;
        case MNKVStorageTypeMixed: {
            NSString *filename = [self _dbGetFilenameWithKey:key];
            if (filename) {
                value = [self _fileReadWithName:filename];
                if (!value) {
                    [self _dbDeleteItemWithKey:key];
                    [self _fileDeleteWithName:filename]; 
                    value = nil;
                }
            } else {
                value = [self _dbGetValueWithKey:key];
            }
        } break;
    }
    if (value) {
        /**更新操作时间*/
        [self _dbUpdateAccessTimeWithKey:key];
    }
    return value;
}

- (NSArray <MNKVStorageItem *>*)getItemForKeys:(NSArray <NSString *>*)keys {
    if (keys.count == 0) return nil;
    NSMutableArray <MNKVStorageItem *>*items = [self _dbGetItemsWithKeys:keys excludeInlineData:NO];
    if (_type != MNKVStorageTypeSQLite) {
        for (NSInteger i = 0, max = items.count; i < max; i++) {
            MNKVStorageItem *item = items[i];
            if (item.filename) {
                item.value = [self _fileReadWithName:item.filename];
                if (!item.value) {
                    if (item.key) [self _dbDeleteItemWithKey:item.key];
                    [items removeObjectAtIndex:i];
                    i--;
                    max--;
                }
            }
        }
    }
    if (items.count > 0) {
        [self _dbUpdateAccessTimeWithKeys:keys];
    }
    return items.count ? items : nil;
}

- (NSArray <MNKVStorageItem *>*)getItemInfoForKeys:(NSArray <NSString *>*)keys {
    if (keys.count <= 0) return nil;
    return [self _dbGetItemsWithKeys:keys excludeInlineData:YES];
}

- (NSDictionary *)getItemValueForKeys:(NSArray *)keys {
    NSArray *items = [self getItemForKeys:keys];
    if (!items) return nil;
    NSMutableDictionary *kv = [NSMutableDictionary new];
    for (MNKVStorageItem *item in items) {
        if (item.key && item.value) {
            [kv setObject:item.value forKey:item.key];
        }
    }
    return kv.count ? kv : nil;
}

- (BOOL)itemExistsForKey:(NSString *)key {
    if (key.length <= 0) return NO;
    return [self _dbGetItemCountWithKey:key] > 0;
}

- (int)getItemsCount {
    return [self _dbGetTotalItemCount];
}

- (int)getItemsSize {
    return [self _dbGetTotalItemSize];
}

@end
