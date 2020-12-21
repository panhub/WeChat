//
//  MNDatabase.m
//  MNKit
//
//  Created by Vincent on 2019/2/20.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNDatabase.h"
#import <objc/runtime.h>
#import <sqlite3.h>

MNSQLFieldType const MNSQLFieldText = @"TEXT";
MNSQLFieldType const MNSQLFieldBlob = @"BLOB";
MNSQLFieldType const MNSQLFieldReal = @"REAL";
MNSQLFieldType const MNSQLFieldInteger = @"INTEGER";

NSString *const MNSQLTablePrimaryKey = @"id";

NSString *const MNDatabasePathName = @"database";
NSString *const MNDatabasePathExtension = @"sqlite";

static MNDatabase *_database;
static NSString *_MNDatabaseSqlitePath;

void MNDatabaseSetPath(NSString *directoryPath) {
    _MNDatabaseSqlitePath = directoryPath;
}

static NSString *MNDatabaseGetPath(void) {
    if (_MNDatabaseSqlitePath.length) return _MNDatabaseSqlitePath;
    return MNDatabaseDefaultPath();
}

NSString *MNDatabaseDefaultPath(void) {
    NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"MNKit"];
    NSString *errorPath = [[folderPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[MNDatabasePathName stringByAppendingPathExtension:MNDatabasePathExtension]];
    if ([NSFileManager.defaultManager fileExistsAtPath:errorPath]) return errorPath;
    if (![NSFileManager.defaultManager fileExistsAtPath:folderPath]) {
        NSError *error;
        if (![NSFileManager.defaultManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil]) {
            folderPath = [folderPath stringByDeletingLastPathComponent];
            NSLog(@"%@", error);
        }
    }
    return [folderPath stringByAppendingPathComponent:[MNDatabasePathName stringByAppendingPathExtension:MNDatabasePathExtension]];
}

static dispatch_queue_t dispatch_database_concurrent_queue (void) {
    static dispatch_queue_t database_concurrent_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        database_concurrent_queue = dispatch_queue_create("com.mn.database.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return database_concurrent_queue;
}

#define Lock()      dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)
#define Unlock()   dispatch_semaphore_signal(_semaphore)
#define dispatch_database_queue   dispatch_database_concurrent_queue()

@implementation MNSQLField
@end

@implementation MNDatabase
{   // 数据库实例
    sqlite3 *_db;
    // 数据库路径
    NSString *_dbPath;
    // 修改数据库时保存默认路径便于恢复
    NSString *_ready_db_path;
    // 加锁信号量
    dispatch_semaphore_t _semaphore;
    // 句柄缓存
    CFMutableDictionaryRef _dbStmtCache;
    // 表名缓存
    NSMutableArray <NSString *>*_tableNameCache;
    // 表信息缓存
    NSMutableDictionary <NSString *, NSArray <MNSQLField *>*>*_tableInfoCache;
    // 模型对应表字段缓存
    NSMutableDictionary <NSString *, NSDictionary <NSString *, NSString *>*>*_classFieldCache;
}

+ (instancetype)database {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_database) {
            _database = [[MNDatabase alloc] init];
        }
    });
    return _database;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _database = [super allocWithZone:zone];
    });
    return _database;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _database = [super init];
        if (_database) {
            NSString *sqlitePath = MNDatabaseGetPath();
            if ([sqlitePath.pathExtension isEqualToString:MNDatabasePathExtension] && [NSFileManager.defaultManager createDirectoryAtPath:sqlitePath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil]) {
                _dbPath = sqlitePath;
            }
            _semaphore = dispatch_semaphore_create(1);
            _tableNameCache = [NSMutableArray arrayWithCapacity:0];
            _tableInfoCache = [NSMutableDictionary dictionaryWithCapacity:0];
            _classFieldCache = [NSMutableDictionary dictionaryWithCapacity:0];
            CFDictionaryKeyCallBacks keyCallbacks = kCFCopyStringDictionaryKeyCallBacks;
            CFDictionaryValueCallBacks valueCallbacks = {0};
            _dbStmtCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &keyCallbacks, &valueCallbacks);
            NSArray <NSString *>*tables = [_database selectTables];
            if (tables.count) [_tableNameCache addObjectsFromArray:tables];
            NSLog(@"db.path===%@", _dbPath);
        }
    });
    return _database;
}

#pragma mark - 开启/关闭数据库
- (BOOL)open {
    return [self dbOpen];
}

- (void)close {
    [self dbClose];
}

#pragma mark - Getter
- (NSString *)path {
    return _dbPath.copy;
}

#pragma mark - 创建表
- (BOOL)createTable:(NSString *)name fields:(NSDictionary <NSString *, NSString *>*)fields {
    if (name.length <= 0 || fields.count <= 0) return NO;
    if ([self existsTable:name]) return YES;
    if (![self dbOpen]) return NO;
    NSMutableString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id integer primary key autoincrement", name].mutableCopy;
    [fields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull field, NSString * _Nonnull type, BOOL * _Nonnull stop) {
        [sql appendFormat:@", %@ %@", field, type];
    }];
    [sql appendString:@");"];
    Lock();
    BOOL succeed = [self execute:sql.copy];
    if (succeed) [_tableNameCache addObject:name];
    Unlock();
    return succeed;
}

+ (void)createTable:(NSString *)name fields:(NSDictionary <NSString *, NSString *>*)fields completion:(void(^)(BOOL))completion {
    dispatch_async(dispatch_database_queue, ^{
        BOOL succeed = [[MNDatabase database] createTable:name fields:fields];
        if (completion) {
            completion(succeed);
        }
    });
}

- (BOOL)createTable:(NSString *)name class:(Class)cls {
    return [self createTable:name fields:[self fieldsOfClass:cls]];
}

+ (void)createTable:(NSString *)name class:(Class)cls completion:(void(^)(BOOL))completion {
    dispatch_async(dispatch_database_queue, ^{
        BOOL succeed = [[MNDatabase database] createTable:name class:cls];
        if (completion) {
            completion(succeed);
        }
    });
}

- (BOOL)createTable:(NSString *)name fieldsAndTypes:(NSString *)field,...NS_REQUIRES_NIL_TERMINATION {
    if (name.length <= 0 || field.length <= 0) return NO;
    NSString *key = field;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    va_list args;
    va_start(args, field);
    while ((field = va_arg(args, NSString *))) {
        if (!key) {
            key = field;
        } else {
            [dic setObject:field forKey:key];
            key = nil;
        }
    }
    va_end(args);
    return [self createTable:name fields:dic.copy];
}

+ (void)createTable:(NSString *)name completion:(void(^)(BOOL))completion fieldsAndTypes:(NSString *)field,...NS_REQUIRES_NIL_TERMINATION {
    if (name.length <= 0 || field.length <= 0) {
        dispatch_async(dispatch_database_queue, ^{
            if (completion) {
                completion(NO);
            }
        });
        return;
    }
    NSString *key = field;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    va_list args;
    va_start(args, field);
    while ((field = va_arg(args, NSString *))) {
        if (!key) {
            key = field;
        } else {
            [dic setObject:field forKey:key];
            key = nil;
        }
    }
    va_end(args);
    dispatch_async(dispatch_database_queue, ^{
        BOOL succeed = [[MNDatabase database] createTable:name fields:dic.copy];
        if (completion) {
            completion(succeed);
        }
    });
}

#pragma mark - 删除表
- (BOOL)deleteTable:(NSString *)name {
    if (name.length <= 0) return NO;
    if (![self existsTable:name]) return YES;
    if (![self dbOpen]) return NO;
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@;", name];
    Lock();
    BOOL succeed = [self execute:sql];
    if (succeed) {
        /// 删除表名记录
        NSMutableArray <NSString *>*tableNames = [NSMutableArray arrayWithCapacity:0];
        [_tableNameCache enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:name]) {
                [tableNames addObject:name];
            }
        }];
        [_tableNameCache removeObjectsInArray:tableNames.copy];
    }
    Unlock();
    return succeed;
}

+ (void)deleteTable:(NSString *)name completion:(void(^)(BOOL))completion {
    dispatch_async(dispatch_database_queue, ^{
        BOOL succeed = [[MNDatabase database] deleteTable:name];
        if (completion) {
            completion(succeed);
        }
    });
}

#pragma mark - 插入数据
- (BOOL)insertToTable:(NSString *)name fields:(NSDictionary <NSString *, id>*)fields {
    if (name.length <= 0 || fields.count <= 0 || ![self existsTable:name] || ![self dbOpen]) return NO;
    NSMutableString *sql = [NSString stringWithFormat:@"INSERT INTO %@ ( VALUES (;", name].mutableCopy;
    __block NSInteger start = [sql rangeOfString:name].location + name.length + 2;
    __block NSInteger end = [sql rangeOfString:@"VALUES ("].location + @"VALUES (".length;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:0];
    [fields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull field, id _Nonnull obj, BOOL * _Nonnull stop) {
        [values addObject:obj];
        field = [field stringByAppendingString:@","];
        [sql insertString:field atIndex:start];
        start += field.length;
        end += field.length;
        NSString *place = [NSString stringWithFormat:@"?%@,", @(values.count)];
        [sql insertString:place atIndex:end];
        end += place.length;
    }];
    [sql replaceCharactersInRange:NSMakeRange(start - 1, 1) withString:@")"];
    [sql replaceCharactersInRange:NSMakeRange(end - 1, 1) withString:@")"];
    /// NOTE:确保获取句柄与绑定句柄线程安全<踩坑总结>
    Lock();
    int result = INT_MAX;
    sqlite3_stmt *stmt = [self sqlStmt:sql.copy];
    if (stmt) {
        [self bindSqlStmt:stmt values:values];
        result = sqlite3_step(stmt);
        if (result != SQLITE_DONE) {
            NSLog(@"sqlite insert into table not done (%d): %s", result, sqlite3_errmsg(_db));
        }
    }
    Unlock();
    return result == SQLITE_DONE;
}

+ (void)insertToTable:(NSString *)name fields:(NSDictionary <NSString *, id>*)fields completion:(void(^)(BOOL))completion {
    dispatch_async(dispatch_database_queue, ^{
        BOOL succeed = [[MNDatabase database] insertToTable:name fields:fields];
        if (completion) {
            completion(succeed);
        }
    });
}

- (BOOL)insertToTable:(NSString *)name model:(id)model {
    return [self insertToTable:name fields:[self fieldsAndValuesOfModel:model]];
}

+ (void)insertToTable:(NSString *)name model:(id)model completion:(void(^)(BOOL))completion
{
    dispatch_async(dispatch_database_queue, ^{
        BOOL succeed = [[MNDatabase database] insertToTable:name model:model];
        if (completion) {
            completion(succeed);
        }
    });
}

- (BOOL)insertToTable:(NSString *)name fieldsAndValues:(id)field,...NS_REQUIRES_NIL_TERMINATION {
    if (name.length <= 0 || !field) return NO;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *key = field;
    va_list args;
    va_start(args, field);
    while ((field = va_arg(args, id))) {
        if (!key) {
            key = (NSString *)field;
        } else {
            [dic setObject:field forKey:key];
            key = nil;
        }
    }
    va_end(args);
    return [self insertToTable:name fields:dic.copy];
}

+ (void)insertToTable:(NSString *)name completion:(void(^)(BOOL))completion fieldsAndValues:(id)field,...NS_REQUIRES_NIL_TERMINATION {
    if (name.length <= 0 || !field) {
        dispatch_async(dispatch_database_queue, ^{
            if (completion) {
                completion(NO);
            }
        });
        return;
    }
    NSString *key = field;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    va_list args;
    va_start(args, field);
    while ((field = va_arg(args, id))) {
        if (!key) {
            key = (NSString *)field;
        } else {
            [dic setObject:field forKey:key];
            key = nil;
        }
    }
    va_end(args);
    dispatch_async(dispatch_database_queue, ^{
        BOOL succeed = [[MNDatabase database] insertToTable:name fields:dic.copy];
        if (completion) {
            completion(succeed);
        }
    });
}

#pragma mark - 更新数据
- (BOOL)updateTable:(NSString *)name where:(NSString *)where fields:(NSDictionary <NSString *, id>*)fields {
    if (name.length <= 0 || fields.count <= 0 || ![self existsTable:name] || ![self dbOpen]) return NO;
    NSString *condition = where.length > 0 ? [NSString stringWithFormat:@" WHERE %@", where] : @"";
    NSMutableString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@;", name, condition].mutableCopy;
    __block NSInteger index = [sql rangeOfString:@"SET "].location + @"SET ".length;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:fields.count];
    [fields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull field, id _Nonnull obj, BOOL * _Nonnull stop) {
        [values addObject:obj];
        field = [NSString stringWithFormat:@"%@=?%@, ", field, @(values.count)];
        [sql insertString:field atIndex:index];
        index += field.length;
    }];
    [sql replaceCharactersInRange:NSMakeRange(index - 2, 2) withString:@""];
    Lock();
    int result = INT_MAX;
    sqlite3_stmt *stmt = [self sqlStmt:sql.copy];
    if (stmt) {
        [self bindSqlStmt:stmt values:values.copy];
        result = sqlite3_step(stmt);
    }
    Unlock();
    return result == SQLITE_DONE;
}

+ (void)updateTable:(NSString *)name where:(NSString *)where fields:(NSDictionary <NSString *, id>*)fields completion:(void(^)(BOOL))completion {
    dispatch_async(dispatch_database_queue, ^{
        BOOL succeed = [[MNDatabase database] updateTable:name where:where fields:fields];
        if (completion) {
            completion(succeed);
        }
    });
}

- (BOOL)updateTable:(NSString *)name where:(NSString *)where model:(id)model {
    return [self updateTable:name where:where fields:[self fieldsAndValuesOfModel:model]];
}

+ (void)updateTable:(NSString *)name where:(NSString *)where model:(id)model completion:(void(^)(BOOL))completion {
    dispatch_async(dispatch_database_queue, ^{
        BOOL succeed = [[MNDatabase database] updateTable:name where:where model:model];
        if (completion) {
            completion(succeed);
        }
    });
}

- (BOOL)updateTable:(NSString *)name where:(NSString *)where fieldsAndValues:(id)field,...NS_REQUIRES_NIL_TERMINATION {
    if (name.length <= 0 || !field) return NO;
    NSString *key = (NSString *)field;
    NSMutableDictionary <NSString *, id>*dic = [NSMutableDictionary dictionary];
    va_list args;
    va_start(args, field);
    while ((field = va_arg(args, id))) {
        if (!key) {
            key = (NSString *)field;
        } else {
            [dic setObject:field forKey:key];
            key = nil;
        }
    }
    va_end(args);
    return [self updateTable:name where:where fields:dic.copy];
}

+ (void)updateTable:(NSString *)name where:(NSString *)where completion:(void(^)(BOOL))completion fieldsAndValues:(id)field,...NS_REQUIRES_NIL_TERMINATION {
    if (name.length <= 0 || !field) {
        dispatch_async(dispatch_database_queue, ^{
            if (completion) {
                completion(NO);
            }
        });
        return;
    }
    NSString *key = (NSString *)field;
    NSMutableDictionary <NSString *, id>*dic = [NSMutableDictionary dictionary];
    va_list args;
    va_start(args, field);
    while ((field = va_arg(args, id))) {
        if (!key) {
            key = (NSString *)field;
        } else {
            [dic setObject:field forKey:key];
            key = nil;
        }
    }
    va_end(args);
    dispatch_async(dispatch_database_queue, ^{
        BOOL succeed = [[MNDatabase database] updateTable:name where:where fields:dic.copy];
        if (completion) {
            completion(succeed);
        }
    });
}

#pragma mark - 删除数据
- (BOOL)deleteRowFromTable:(NSString *)name where:(NSString *)where {
    if (name.length <= 0 || ![self existsTable:name] || ![self dbOpen]) return NO;
    NSString *condition = where.length > 0 ? [NSString stringWithFormat:@" WHERE %@", where] : @"";
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@%@;", name, condition];
    Lock();
    BOOL succeed = [self execute:sql];
    Unlock();
    return succeed;
}

+ (void)deleteRowFromTable:(NSString *)name where:(NSString *)where completion:(void(^)(BOOL))completion {
    dispatch_async(dispatch_database_queue, ^{
        BOOL succeed = [[MNDatabase database] deleteRowFromTable:name where:where];
        if (completion) {
            completion(succeed);
        }
    });
}

#pragma mark - 查询数据
- (NSArray <NSString *>*)selectTables {
    if (![self dbOpen]) return nil;
    sqlite3_stmt *stmt;
    NSString *sql = @"select name from sqlite_master where type='table'";
    NSMutableArray <NSString *>*tables = [NSMutableArray arrayWithCapacity:5];
    Lock();
    if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {
        do {
            int result = sqlite3_step(stmt);
            if (result == SQLITE_ROW) {
                const char *value = (const char *)sqlite3_column_text(stmt, 0);
                NSString *string = [NSString stringWithUTF8String:value];
                if (string.length > 0 && ![tables containsObject:string]) {
                    [tables addObject:string];
                }
            } else {
                if (result == SQLITE_ERROR) {
                    NSLog(@"sqlite select table error (%d): %s", result, sqlite3_errmsg(_db));
                }
                break;
            }
        } while (YES);
    }
    sqlite3_finalize(stmt);
    Unlock();
    return tables.copy;
}

+ (void)selectTablesUsingBlock:(void(^)(NSArray <NSString *>*))block {
    if (!block) return;
    dispatch_async(dispatch_database_queue, ^{
        NSArray <NSString *>*tables = [[MNDatabase database] selectTables];
        if (block) {
            block(tables);
        }
    });
}

- (NSUInteger)selectCountFromTable:(NSString *)name where:(NSString *)where {
    if (name.length <= 0 || ![self existsTable:name] || ![self dbOpen]) return 0;
    where = where.length > 0 ? [NSString stringWithFormat:@" WHERE %@", where] : @"";
    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM %@%@;", name, where];
    Lock();
    NSUInteger count = 0;
    sqlite3_stmt *stmt = [self sqlStmt:sql];
    if (stmt && sqlite3_step(stmt) == SQLITE_ROW) {
        count = sqlite3_column_int(stmt, 0);
    }
    Unlock();
    return count;
}

+ (void)selectCountFromTable:(NSString *)name where:(NSString *)where completion:(void(^)(NSUInteger))completion {
    if (!completion) return;
    dispatch_async(dispatch_database_queue, ^{
        NSUInteger count = [[MNDatabase database] selectCountFromTable:name where:where];
        if (completion) {
            completion(count);
        }
    });
}

- (CGFloat)selectSumFromTable:(NSString *)name column:(NSString *)column {
    if (name.length <= 0 || column.length <= 0 || ![self existsTable:name] || ![self dbOpen]) return 0.f;
    NSString *sql = [NSString stringWithFormat:@"SELECT SUM(%@) FROM %@;", column, name];
    Lock();
    CGFloat sum = 0.f;
    sqlite3_stmt *stmt = [self sqlStmt:sql];
    if (stmt && sqlite3_step(stmt) == SQLITE_ROW) {
        sum = sqlite3_column_double(stmt, 0);
    }
    Unlock();
    return sum;
}

+ (void)selectSumFromTable:(NSString *)name column:(NSString *)column completion:(void(^)(CGFloat))completion {
    if (!completion) return;
    dispatch_async(dispatch_database_queue, ^{
        CGFloat sum = [[MNDatabase database] selectSumFromTable:name column:column];
        if (completion) {
            completion(sum);
        }
    });
}

- (nullable NSArray <NSDictionary <NSString *, id>*>*)selectRowsFromTable:(NSString *)name sql:(NSString *)sql {
    if (name.length <= 0 || sql.length <= 0 || ![self existsTable:name] || ![self dbOpen]) return nil;
    NSArray <MNSQLField *>*infos = [self selectTableInfo:name];
    if (infos.count <= 0) return nil;
    Lock();
    sqlite3_stmt *stmt = [self sqlStmt:sql.copy];
    NSMutableArray <NSDictionary <NSString *, id>*>*rows = [NSMutableArray arrayWithCapacity:0];
    if (stmt) {
        NSInteger count = infos.count;
        do {
            int result = sqlite3_step(stmt);
            if (result == SQLITE_ROW) {
                /// 取值
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
                for (int i = 0; i < count; i++) {
                    MNSQLField *info = [self tableInfoInFields:nil infos:infos idx:i];
                    if (!info) continue;
                    NSString *type = info.type;
                    if ([type isEqualToString:MNSQLFieldText]) {
                        const char *value = (const char *)sqlite3_column_text(stmt, i);
                        if (value == NULL) value = @"".UTF8String;
                        NSString *string = [NSString stringWithUTF8String:value];
                        [dic setObject:(string ? : @"") forKey:info.field];
                    } else if ([type isEqualToString:MNSQLFieldBlob]) {
                        const void *bytes = sqlite3_column_blob(stmt, i);
                        int length = sqlite3_column_bytes(stmt, i);
                        NSData *data = (bytes && length > 0) ? [NSData dataWithBytes:bytes length:length] : NSData.data;
                        [dic setObject:data forKey:info.field];
                    } else if ([type isEqualToString:MNSQLFieldReal]) {
                        double num = sqlite3_column_double(stmt, i);
                        [dic setObject:@(num) forKey:info.field];
                    } else if ([type isEqualToString:MNSQLFieldInteger]) {
                        long long intv = sqlite3_column_int64(stmt, i);
                        [dic setObject:@(intv) forKey:info.field];
                    }
                }
                if (dic.count > 0) [rows addObject:dic];
            } else {
                if (result == SQLITE_ERROR) {
                    NSLog(@"select row error (%d): %s", result, sqlite3_errmsg(_db));
                }
                break;
            }
        } while (YES);
    }
    Unlock();
    return rows.copy;
}

+ (void)selectRowsFromTable:(NSString *)name sql:(NSString *)sql completion:(void(^)(NSArray <NSDictionary <NSString *, id>*>* rows))completion {
    if (!completion) return;
    dispatch_async(dispatch_database_queue, ^{
        NSArray <NSDictionary <NSString *, id>*>*rows = [[MNDatabase database] selectRowsFromTable:name sql:sql];
        if (completion) {
            completion(rows);
        }
    });
}

- (nullable NSArray <id>*)selectRowsModelFromTable:(NSString *)name sql:(NSString *)sql class:(Class)cls {
    if (!cls) return nil;
    /// 获取类符合数据库存储标准的字段列表
    NSArray <NSString *>*fields = [self fieldsOfClass:cls].allKeys;
    if (fields.count <= 0) return nil;
    /// 获取数据字典列表
    NSArray <NSDictionary <NSString *, id>*>*rows = [self selectRowsFromTable:name sql:sql];
    if (rows.count <= 0) return nil;
    /// 遍历数据列表寻找每一条数据制作模型
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:rows.count];
    [rows enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL isMeet = NO;
        id model = [cls new];
        /// 遍历数据找出类存在的属性赋值
        [obj enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([fields containsObject:key]) {
                isMeet = YES;
                [model setValue:obj forKey:key];
            }
        }];
        if (isMeet) {
            [array addObject:model];
        }
    }];
    return array.copy;
}

+ (void)selectRowsModelFromTable:(NSString *)name sql:(NSString *)sql class:(Class)cls completion:(void(^)(NSArray <id>* rows))completion {
    if (!completion) return;
    dispatch_async(dispatch_database_queue, ^{
        NSArray <id>* rows = [[MNDatabase database] selectRowsModelFromTable:name sql:sql class:cls];
        if (completion) {
            completion(rows);
        }
    });
}

- (NSArray <NSDictionary <NSString *, id>*>*)selectRowsFromTable:(NSString *)name fields:(NSArray <NSString *>*)fields where:(NSString *)where limit:(NSRange)limit {
    if (name.length <= 0 || ![self existsTable:name] || ![self dbOpen]) return nil;
    NSArray <MNSQLField *>*infos = [self selectTableInfo:name];
    if (infos.count <= 0) return nil;
    NSString *condition = where.length > 0 ? [NSString stringWithFormat:@" WHERE %@", where] : @"";
    NSString *limits = limit.length > 0 ? [NSString stringWithFormat:@" LIMIT ?1, ?2"] : @"";
    NSMutableString *sql = [NSString stringWithFormat:@"SELECT * FROM %@%@%@;", name, condition, limits].mutableCopy;
    if (fields.count > 0) {
        [sql replaceCharactersInRange:[sql rangeOfString:@"* "] withString:@""];
        NSRange range = [sql rangeOfString:@"SELECT "];
        NSInteger index = range.location + range.length;
        for (int idx = 0; idx < fields.count; idx++) {
            NSString *field = fields[idx];
            field = [field stringByAppendingString:@", "];
            [sql insertString:field atIndex:index];
            index += field.length;
        }
        [sql replaceCharactersInRange:NSMakeRange(index - 2, 1) withString:@""];
    }
    Lock();
    sqlite3_stmt *stmt = [self sqlStmt:sql.copy];
    NSMutableArray <NSDictionary <NSString *, id>*>*rows = [NSMutableArray arrayWithCapacity:0];
    if (stmt) {
        if ([sql rangeOfString:@"LIMIT"].location != NSNotFound) {
            sqlite3_bind_int(stmt, 1, (int)limit.location);
            sqlite3_bind_int(stmt, 2, (int)limit.length);
        }
        NSInteger count = fields.count > 0 ? fields.count : infos.count;
        do {
            int result = sqlite3_step(stmt);
            if (result == SQLITE_ROW) {
                /// 取值
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
                for (int i = 0; i < count; i++) {
                    MNSQLField *info = [self tableInfoInFields:fields infos:infos idx:i];
                    if (!info) continue;
                    NSString *type = info.type;
                    if ([type isEqualToString:MNSQLFieldText]) {
                        const char *value = (const char *)sqlite3_column_text(stmt, i);
                        if (value == NULL) value = @"".UTF8String;
                        NSString *string = [NSString stringWithUTF8String:value];
                        [dic setObject:(string ? : @"") forKey:info.field];
                    } else if ([type isEqualToString:MNSQLFieldBlob]) {
                        const void *bytes = sqlite3_column_blob(stmt, i);
                        int length = sqlite3_column_bytes(stmt, i);
                        NSData *data = (bytes && length > 0) ? [NSData dataWithBytes:bytes length:length] : NSData.data;
                        [dic setObject:data forKey:info.field];
                    } else if ([type isEqualToString:MNSQLFieldReal]) {
                        double num = sqlite3_column_double(stmt, i);
                        [dic setObject:@(num) forKey:info.field];
                    } else if ([type isEqualToString:MNSQLFieldInteger]) {
                        long long intv = sqlite3_column_int64(stmt, i);
                        [dic setObject:@(intv) forKey:info.field];
                    }
                }
                if (dic.count > 0) [rows addObject:dic];
            } else {
                if (result == SQLITE_ERROR) {
                    NSLog(@"select row error (%d): %s", result, sqlite3_errmsg(_db));
                }
                break;
            }
        } while (YES);
    }
    Unlock();
    return rows.copy;
}

- (MNSQLField *)tableInfoInFields:(NSArray <NSString *>*)fields infos:(NSArray <MNSQLField *>*)infos idx:(NSInteger)idx {
    if (fields.count <= 0) return infos[idx];
    NSString *field = fields[idx];
    __block MNSQLField *info;
    [infos enumerateObjectsUsingBlock:^(MNSQLField * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.field isEqualToString:field]) {
            info = obj;
            *stop = YES;
        }
    }];
    return info;
}

+ (void)selectRowsFromTable:(NSString *)name fields:(NSArray <NSString *>*)fields where:(NSString *)where limit:(NSRange)limit completion:(void(^)(NSArray <NSDictionary <NSString *, id>*>*))completion {
    if (!completion) return;
    dispatch_async(dispatch_database_queue, ^{
        NSArray <NSDictionary <NSString *, id>*>*rows = [[MNDatabase database] selectRowsFromTable:name fields:fields where:where limit:limit];
        if (completion) {
            completion(rows);
        }
    });
}

- (NSArray <id>*)selectRowsModelFromTable:(NSString *)name where:(NSString *)where limit:(NSRange)limit class:(Class)cls {
    if (!cls) return nil;
    /// 获取类符合数据库存储标准的字段列表
    NSArray <NSString *>*fields = [self fieldsOfClass:cls].allKeys;
    if (fields.count <= 0) return nil;
    /// 获取数据字典列表
    NSArray <NSDictionary <NSString *, id>*>*rows = [self selectRowsFromTable:name fields:nil where:where limit:limit];
    if (rows.count <= 0) return nil;
    /// 遍历数据列表寻找每一条数据制作模型
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:rows.count];
    [rows enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL isMeet = NO;
        id model = [cls new];
        /// 遍历数据找出类存在的属性赋值
        [obj enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([fields containsObject:key]) {
                isMeet = YES;
                [model setValue:obj forKey:key];
            }
        }];
        if (isMeet) {
            [array addObject:model];
        }
    }];
    return array.copy;
}

+ (void)selectRowsModelFromTable:(NSString *)name where:(NSString *)where limit:(NSRange)limit class:(Class)cls completion:(void(^)(NSArray <id>*))completion {
    if (!completion) return;
    dispatch_async(dispatch_database_queue, ^{
        NSArray <id>* rows = [[MNDatabase database] selectRowsModelFromTable:name where:where limit:limit class:cls];
        if (completion) {
            completion(rows);
        }
    });
}

- (NSArray <id>*)selectRowsModelFromTable:(NSString *)name class:(Class)cls {
    return [self selectRowsModelFromTable:name where:nil limit:NSMakeRange(0, 0) class:cls];
}

+ (void)selectRowsModelFromTable:(NSString *)name class:(Class)cls completion:(void(^)(NSArray <id>*))completion {
    [self selectRowsModelFromTable:name where:nil limit:NSMakeRange(0, 0) class:cls completion:completion];
}

#pragma mark - - - - - - - - - - - - - 更新数据库字段 - - - - - - - - - - - - -
- (BOOL)existsField:(NSString *)fieldName inTable:(NSString *)tableName {
    if (fieldName.length <= 0 || tableName.length <= 0) return NO;
    NSArray <MNSQLField *>*fields = [self selectTableInfo:tableName];
    if (!fields || fields.count <= 0) return NO;
    Lock();
    BOOL exists = NO;
    for (MNSQLField *obj in fields) {
        if ([obj.field isEqualToString:fieldName]) {
            exists = YES;
            break;
        }
    }
    Unlock();
    return exists;
}

+ (void)existsField:(NSString *)fieldName inTable:(NSString *)tableName completion:(void(^)(BOOL))completion {
    dispatch_async(dispatch_database_queue, ^{
        BOOL success = [[MNDatabase database] existsField:fieldName inTable:tableName];
        if (completion) {
            completion(success);
        }
    });
}

- (BOOL)updateTableFields:(NSString *)tableName cls:(Class)cls {
    if (tableName.length <= 0 || cls == NULL || ![self existsTable:tableName]) return NO;
    // 类支持的字段 内部已加锁处理
    NSDictionary <NSString *, NSString *>*clsFields = [self fieldsOfClass:cls];
    if (!clsFields || clsFields.count <= 0) return NO;
    // 表现存在字段
    NSArray <MNSQLField *>*fieldModels = [self selectTableInfo:tableName];
    if (!fieldModels || fieldModels.count <= 0) return NO;
    NSMutableArray <NSString *>*existFields = @[].mutableCopy;
    [fieldModels enumerateObjectsUsingBlock:^(MNSQLField * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [existFields addObject:obj.field];
    }];
    // 需要添加的字段
    NSMutableDictionary <NSString *, NSString *>*addFields = @{}.mutableCopy;
    [clsFields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull field, NSString * _Nonnull type, BOOL * _Nonnull stop) {
        if (![field isEqualToString:MNSQLTablePrimaryKey] && ![existFields containsObject:field] && type.length) {
            [addFields setObject:type forKey:field];
        }
    }];
    if (addFields.count <= 0) return YES;
    Lock();
    // 操作数据库字段
    __block BOOL result = YES;
    [addFields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull field, NSString * _Nonnull type, BOOL * _Nonnull stop) {
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE '%@' ADD COLUMN %@ %@;", tableName, field, type];
        if (![self execute:sql.copy]) result = NO;
    }];
    if (result) [_tableInfoCache removeObjectForKey:tableName];
    Unlock();
    return result;
}

+ (void)updateTableFields:(NSString *)tableName cls:(Class)cls completion:(void(^)(BOOL))completion {
    dispatch_async(dispatch_database_queue, ^{
        BOOL success = [[MNDatabase database] updateTableFields:tableName cls:cls];
        if (completion) {
            completion(success);
        }
    });
}

- (BOOL)updateTableFields:(NSString *)tableName model:(id)model {
    if (tableName.length <= 0 || !model || ![self existsTable:tableName]) return NO;
    // 类支持的字段 内部已加锁处理
    NSDictionary <NSString *, NSString *>*clsFields = [self fieldsOfClass:object_getClass(model)];
    if (!clsFields || clsFields.count <= 0) return NO;
    // 表现存在字段
    NSArray <MNSQLField *>*fieldModels = [self selectTableInfo:tableName];
    if (!fieldModels || fieldModels.count <= 0) return NO;
    NSMutableArray <NSString *>*existFields = @{}.mutableCopy;
    [fieldModels enumerateObjectsUsingBlock:^(MNSQLField * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [existFields addObject:obj.field];
    }];
    // 需要添加的字段
    NSMutableDictionary <NSString *, id>*fieldValues = @{}.mutableCopy;
    NSMutableDictionary <NSString *, NSString *>*addFields = @{}.mutableCopy;
    [clsFields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull field, NSString * _Nonnull type, BOOL * _Nonnull stop) {
        if (![field isEqualToString:MNSQLTablePrimaryKey] && ![existFields containsObject:field] && type.length) {
            id value = [model valueForKey:field];
            if (value && ([value isKindOfClass:NSString.class] || [value isKindOfClass:NSNumber.class])) {
                [addFields setObject:type forKey:field];
                [fieldValues setObject:value forKey:field];
            }
        }
    }];
    if (addFields.count <= 0) return YES;
    Lock();
    // 操作数据库字段
    __block BOOL result = YES;
    [addFields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull field, NSString * _Nonnull type, BOOL * _Nonnull stop) {
        id value = [fieldValues objectForKey:field];
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE '%@' ADD COLUMN %@ %@ DEFAULT '%@';", tableName, field, type, value];
        if (![self execute:sql.copy]) result = NO;
    }];
    if (result) [_tableInfoCache removeObjectForKey:tableName];
    Unlock();
    return result;
}

+ (void)updateTableFields:(NSString *)tableName model:(id)model completion:(void(^)(BOOL))completion {
    dispatch_async(dispatch_database_queue, ^{
        BOOL success = [[MNDatabase database] updateTableFields:tableName model:model];
        if (completion) {
            completion(success);
        }
    });
}

#pragma mark - - - - - - - - - - - - - 修改数据库 - - - - - - - - - - - - -
- (BOOL)setDatabaseReadyPath:(NSString *)path {
    // 判断路径是否可用
    if (![NSFileManager.defaultManager fileExistsAtPath:path] || ![path.pathExtension isEqualToString:MNDatabasePathExtension]) return NO;
    // 先关闭数据库
    [self dbClose];
    NSString *copy_db_path = _ready_db_path.copy;
    _ready_db_path = _dbPath.copy;
    _dbPath = path;
    if ([self dbOpen]) {
        CFDictionaryRemoveAllValues(_dbStmtCache);
        [_tableInfoCache removeAllObjects];
        [_tableNameCache removeAllObjects];
        [_tableNameCache addObjectsFromArray:[self selectTables]];
        return YES;
    }
    _dbPath = _ready_db_path.copy;
    _ready_db_path = copy_db_path;
    [self dbOpen];
    return NO;
}

+ (void)setDatabaseReadyPath:(NSString *)path completion:(nullable void(^)(BOOL succeed))completion {
    dispatch_async(dispatch_database_queue, ^{
        BOOL success = [[MNDatabase database] setDatabaseReadyPath:path];
        if (completion) {
            completion(success);
        }
    });
}

- (BOOL)restoreDatabase {
    if (_ready_db_path.length <= 0) return YES;
    if ([self setDatabaseReadyPath:_ready_db_path]) _ready_db_path = nil;
    return _ready_db_path.length <= 0;
}

+ (void)restoreDatabaseUsingBlock:(void(^)(BOOL))block {
    dispatch_async(dispatch_database_queue, ^{
        BOOL success = [[MNDatabase database] restoreDatabase];
        if (block) {
            block(success);
        }
    });
}

- (BOOL)retainDatabase {
    if (_ready_db_path.length <= 0) return YES;
    NSString *dbPath = _ready_db_path;
    NSString *temp_db_path = _dbPath;
    [self dbClose];
    NSString *cachePath = [[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSNumber numberWithLongLong:NSDate.date.timeIntervalSince1970*1000].stringValue] stringByAppendingPathExtension:MNDatabasePathExtension];
    if (![NSFileManager.defaultManager moveItemAtPath:dbPath toPath:cachePath error:nil]) {
        [self dbOpen];
        return NO;
    }
    if (![NSFileManager.defaultManager moveItemAtPath:temp_db_path toPath:dbPath error:nil]) {
        [NSFileManager.defaultManager moveItemAtPath:cachePath toPath:dbPath error:nil];
        [self dbOpen];
        return NO;
    }
    _dbPath = dbPath;
    _ready_db_path = nil;
    [self dbOpen];
    CFDictionaryRemoveAllValues(_dbStmtCache);
    [_tableInfoCache removeAllObjects];
    [_tableNameCache removeAllObjects];
    [_tableNameCache addObjectsFromArray:[self selectTables]];
    [NSFileManager.defaultManager removeItemAtPath:cachePath error:nil];
    return YES;
}

+ (void)retainDatabaseUsingBlock:(nullable void(^)(BOOL))block {
    dispatch_async(dispatch_database_queue, ^{
        BOOL success = [[MNDatabase database] retainDatabase];
        if (block) {
            block(success);
        }
    });
}

#pragma mark - - - - - - - - - - - - - 数据库操作 - - - - - - - - - - - - -
/// 打开/关闭数据库
- (BOOL)dbOpen {
    if (_db) return YES;
    if (_dbPath.length <= 0) return NO;
    Lock();
    int result = sqlite3_open(_dbPath.UTF8String, &_db);
    Unlock();
    if (result != SQLITE_OK) [self dbClose];
    return result == SQLITE_OK;
}

- (void)dbClose {
    if (!_db) return;
    /**关闭数据库*/
    Lock();
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
    Unlock();
}

/// 判断表是否存在
- (BOOL)existsTable:(NSString *)tableName {
    Lock();
    BOOL exists = tableName.length > 0 && [_tableNameCache containsObject:tableName];
    Unlock();
    return exists;
}

/// 获取表中所有字段名类型
- (NSArray <MNSQLField *>*)selectTableInfo:(NSString *)name {
    if (name.length <= 0) return nil;
    Lock();
    NSArray <MNSQLField *>*infos = _tableInfoCache[name];
    if (!infos) {
        sqlite3_stmt *stmt;
        NSMutableArray <MNSQLField *>*array = [NSMutableArray arrayWithCapacity:0];
        NSString *sql = [NSString stringWithFormat:@"pragma table_info ('%@');", name];
        if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {
            int idx = 1;
            do {
                int result = sqlite3_step(stmt);
                if (result == SQLITE_ROW) {
                    const char *field = (const char *)sqlite3_column_text(stmt, 1);
                    const char *type = (const char *)sqlite3_column_text(stmt, 2);
                    MNSQLField *info = [MNSQLField new];
                    info.idx = idx;
                    info.field = [[NSString alloc] initWithUTF8String:field];
                    info.type = [[NSString alloc] initWithUTF8String:type];
                    [array addObject:info];
                } else if (result == SQLITE_DONE) {
                    break;
                } else {
                    /// SQLITE_NOTICE 等
                    [array removeAllObjects];
                    break;
                }
                idx++;
            } while (YES);
        }
        sqlite3_finalize(stmt);
        infos = array.copy;
        if (infos > 0) [_tableInfoCache setObject:infos forKey:name];
    }
    Unlock();
    return infos;
}

#pragma mark - 执行数据库语句
- (BOOL)execute:(NSString *)sql {
    if (sql.length <= 0 || !_db) return NO;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, NULL);
    //return sqlite3_exec(_db, sql.UTF8String, NULL, NULL, NULL) == SQLITE_OK;
    if (result == SQLITE_OK) return YES;
    NSLog(@"execute sql '%@' error (%d): %s", sql, result, sqlite3_errmsg(_db));
    return NO;
}

#pragma mark - 获取句柄
/// 这里没有加锁是因为获取句柄与绑定句柄过程已加锁, 避免双重锁
- (sqlite3_stmt *)sqlStmt:(NSString *)sql {
    if (sql.length <= 0 || !_dbStmtCache || ![self dbOpen]) return NULL;
    sqlite3_stmt *stmt = (sqlite3_stmt *)CFDictionaryGetValue(_dbStmtCache, (__bridge const void*)(sql));
    if (stmt) {
        sqlite3_reset(stmt);
    } else {
        int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            CFDictionarySetValue(_dbStmtCache, (__bridge const void*)sql, stmt);
        } else {
            NSLog(@"sqlite stmt prepare error (%d): %s", result, sqlite3_errmsg(_db));
            sqlite3_finalize(stmt);
            stmt = NULL;
        }
    }
    return stmt;
}

#pragma mark - - - - - - - - - - - - - 辅助方法 - - - - - - - - - - - - -
/// 获取类属性对应的数据库字段与类型{field:type}
- (NSDictionary <NSString *, NSString *>*)fieldsOfClass:(Class)cls {
    Lock();
    NSDictionary <NSString *, NSString *>*fields = [_classFieldCache objectForKey:NSStringFromClass(cls)];
    if (fields.count) {
        Unlock();
        return fields;
    }
    // 检查数据合法可用
    NSMutableDictionary <NSString *, NSString *>*dic = @{}.mutableCopy;
    NSArray <NSString *>*supportTypes = @[MNSQLFieldText, MNSQLFieldBlob, MNSQLFieldReal, MNSQLFieldInteger];
    [[cls sqliteTableFields] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if (key.length && [supportTypes containsObject:obj]) [dic setObject:obj forKey:key];
    }];
    fields = dic.copy;
    if (fields.count) {
        [_classFieldCache setObject:fields forKey:NSStringFromClass(cls)];
        Unlock();
        return fields;
    }
    [dic removeAllObjects];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *field = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if (field.length <= 0) continue;
        NSString *type = [self fieldTypeWithProperty:property];
        if (type.length <= 0 ) continue;
        [dic setObject:type forKey:field];
    }
    free(properties);
    fields = dic.copy;
    if (fields.count > 0) {
        [_classFieldCache setObject:fields forKey:NSStringFromClass(cls)];
        Unlock();
        return fields;
    }
    Unlock();
    return nil;
}

/// 获取属性对应的数据库字段类型
- (NSString *)fieldTypeWithProperty:(objc_property_t)property {
    NSString *attr = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
    NSArray *array = [attr componentsSeparatedByString:@","];
    if (array.count <= 0) return nil;
    /// 考虑到会有模型赋值问题, 只读属性不考虑做数据库字段
    if ([array containsObject:@"R"]) return nil;
    NSString *type = [array firstObject];
    if ([type isEqualToString:@"T@\"NSString\""]) {
        /// NSString
        return MNSQLFieldText;
    }
    if ([type isEqualToString:@"T@\"NSData\""]) {
        /// NSData
        return MNSQLFieldBlob;
    }
    if ([type isEqualToString:@"T@\"NSNumber\""] || [type isEqualToString:@"Td"] || [type isEqualToString:@"Tf"]) {
        /// NSNumber double float CGFloat
        return MNSQLFieldReal;
    }
    if ([type isEqualToString:@"Ti"] || [type isEqualToString:@"TB"] || [type isEqualToString:@"Tq"] || [type isEqualToString:@"TQ"]) {
        /// int BOOL NSInteger NSUInteger
        return MNSQLFieldInteger;
    }
    return nil;
}

/// 获取模型值<不可缓存>
- (NSDictionary <NSString *, id>*)fieldsAndValuesOfModel:(id)model {
    if (!model) return nil;
    NSDictionary <NSString *, NSString *>*fields = [self fieldsOfClass:object_getClass(model)];
    NSMutableDictionary <NSString *, id>*dic = [NSMutableDictionary dictionaryWithCapacity:fields.count];
    [fields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull field, NSString * _Nonnull type, BOOL * _Nonnull stop) {
        id value = [model valueForKey:field];
        if (!value) {
            if ([type isEqualToString:MNSQLFieldText]) {
                value = @"";
            } else if ([type isEqualToString:MNSQLFieldBlob]) {
                value = [NSData data];
            } else if ([type isEqualToString:MNSQLFieldReal]) {
                value = [NSNumber numberWithFloat:0.f];
            } else {
                value = [NSNumber numberWithInteger:0];
            }
        }
        [dic setObject:value forKey:field];
    }];
    return dic.copy;
}

/// 绑定句柄, 一定要确保顺序一致<外界加锁, 内部不再重复加锁>
- (void)bindSqlStmt:(sqlite3_stmt *)stmt values:(NSArray *)values {
    for (int idx = 1; idx <= values.count; idx++) {
        id obj = values[idx-1];
        if ([obj isKindOfClass:NSString.class]) {
            NSString *string = (NSString *)obj;
            sqlite3_bind_text(stmt, idx, string.UTF8String, -1, NULL);
        } else if ([obj isKindOfClass:NSData.class]) {
            NSData *data = (NSData *)obj;
            if (data.length > 0) {
                sqlite3_bind_blob(stmt, idx, data.bytes, (int)(data.length), NULL);
            } else {
                sqlite3_bind_blob(stmt, idx, NULL, 0, NULL);
            }
        } else if ([obj isKindOfClass:NSNumber.class]) {
            long long intv = ((NSNumber *)obj).longLongValue;
            double dou = ((NSNumber *)obj).doubleValue;
            if (ceil(dou) == intv) {
                sqlite3_bind_int64(stmt, idx, intv);
            } else {
                sqlite3_bind_double(stmt, idx, dou);
            }
        }
    }
}

#pragma mark - dealloc
/**本类使用单利设计模式, 原理不会触发dealloc 为了规范*/
- (void)dealloc {
    [self dbClose];
    [_tableInfoCache removeAllObjects];
    [_tableNameCache removeAllObjects];
    CFDictionaryRemoveAllValues(_dbStmtCache);
    CFRelease(_dbStmtCache);
    _dbStmtCache = NULL;
}

@end
