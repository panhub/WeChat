//
//  MNDatabase.h
//  MNKit
//
//  Created by Vincent on 2019/2/20.
//  Copyright © 2019年 小斯. All rights reserved.
//  数据库<线程安全>
//  https://www.jianshu.com/p/51aec65a06df
//  https://www.cnblogs.com/wendingding/p/3868926.html
//  https://www.cnblogs.com/wendingding/p/3871792.html

#import <Foundation/Foundation.h>
#import "NSObject+MNSQLField.h"
#import "NSDictionary+MNSQLStatement.h"

NS_ASSUME_NONNULL_BEGIN

/**定义表字段类型*/
typedef NSString * MNSQLFieldType;
/**字符串类型*/
FOUNDATION_EXTERN MNSQLFieldType const MNSQLFieldText;
/**数据流类型*/
FOUNDATION_EXTERN MNSQLFieldType const MNSQLFieldBlob;
/**实数类型*/
FOUNDATION_EXTERN MNSQLFieldType const MNSQLFieldReal;
/**整型*/
FOUNDATION_EXTERN MNSQLFieldType const MNSQLFieldInteger;

/**数据库表主键*/
FOUNDATION_EXTERN NSString *const MNSQLTablePrimaryKey;

/**数据库路径名*/
FOUNDATION_EXTERN NSString *const MNDatabasePathName;
/**数据库路径后缀*/
FOUNDATION_EXTERN NSString *const MNDatabasePathExtension;
/**设置数据库路径<实例化前设置>*/
FOUNDATION_EXPORT void MNDatabaseSetPath(NSString *);
/**数据库默认路径*/
FOUNDATION_EXPORT NSString *MNDatabaseDefaultPath(void);

#ifndef sql_pair
#define sql_pair(pair)  [NSString stringWithFormat:@"'%@'", pair]
#endif

#ifndef sql_field
#define sql_field(field)    @(((void)(NO && ((void)field, NO)), strchr(# field, '.') + 1))
#endif

@interface MNSQLField : NSObject
/**字段索引*/
@property (nonatomic) int idx;
/**字段名*/
@property (nonatomic, copy) NSString *field;
/**字段类型*/
@property (nonatomic, copy) NSString *type;

@end

@interface MNDatabase : NSObject

/**数据库本地路径*/
@property (nonatomic, readonly) NSString *path;

/**
 推荐实例化入口
 @return 数据库管理者
 */
+ (instancetype)database;

#pragma mark - 打开/关闭数据库
/**
 打开数据库
 @return 是否打开成功
 */
- (BOOL)open;

/**
 关闭数据库
 */
- (void)close;

/**
 判断是否存在表
 @param name 表名
 @return 是否存在
 */
- (BOOL)existsTable:(NSString *)name;

/**
 获取表字段信息
 @param name 字段模型
 @return 表字段信息
 */
- (nullable NSArray <MNSQLField *>*)selectTableInfo:(NSString *)name;

#pragma mark - 创建表
/**
 依据字典创建表
 @param name 表名
 @param fields {字段:类型}
 @return 是否创建成功
 */
- (BOOL)createTable:(NSString *)name fields:(NSDictionary <NSString *, NSString *>*)fields;

/**
 依据字典创建表<异步操作>
 @param name 表名
 @param fields {字段:类型}
 @param completion 完成回调
 */
+ (void)createTable:(NSString *)name fields:(NSDictionary <NSString *, NSString *>*)fields completion:(nullable void(^)(BOOL succeed))completion;

/**
 依据类属性列表创建表
 @param name 表名
 @param cls 类
 @return 是否创建成功
 */
- (BOOL)createTable:(NSString *)name class:(Class)cls;

/**
 依据类属性列表创建表<异步操作>
 @param name 表名
 @param cls 类
 @param completion 完成回调
 */
+ (void)createTable:(NSString *)name class:(Class)cls completion:(nullable void(^)(BOOL succeed))completion;

/**
 依据不定参数创建表
 @param name 表名
 @param field 字段, 类型
 @return 是否创建成功
 */
- (BOOL)createTable:(NSString *)name fieldsAndTypes:(NSString *)field,...NS_REQUIRES_NIL_TERMINATION;

/**
 依据不定参数创建表<异步操作>
 @param name 表名
 @param completion 完成回调
 @param field 字段, 类型
 */
+ (void)createTable:(NSString *)name completion:(nullable void(^)(BOOL succeed))completion fieldsAndTypes:(NSString *)field,...NS_REQUIRES_NIL_TERMINATION;

#pragma mark - 删除表
/**
 删除表
 @param name 表名
 @return 是否删除成功
 */
- (BOOL)deleteTable:(NSString *)name;

/**
 删除表<异步操作>
 @param name 表名
 @param completion 完成回调
 */
+ (void)deleteTable:(NSString *)name completion:(nullable void(^)(BOOL succeed))completion;

#pragma mark - 插入数据
/**
 使用字典插入表数据
 @param name 表名
 @param fields {字段:数据} <NSString, NSData, NSNumber>
 @return 是否插入成功
 */
- (BOOL)insertToTable:(NSString *)name fields:(NSDictionary <NSString *, id>*)fields;

/**
 使用字典插入表数据<异步操作>
 @param name 表名
 @param fields {字段:数据} <NSString, NSData, NSNumber>
 @param completion 结束回调
 */
+ (void)insertToTable:(NSString *)name fields:(NSDictionary <NSString *, id>*)fields completion:(nullable void(^)(BOOL succeed))completion;

/**
 使用模型插入表数据
 @param name 表名
 @param model 数据模型
 @return 是否插入成功
 */
- (BOOL)insertToTable:(NSString *)name model:(id)model;

/**
 使用模型插入表数据<异步操作>
 @param name 表名
 @param model 模型
 @param completion 结束回调
 */
+ (void)insertToTable:(NSString *)name model:(id)model completion:(nullable void(^)(BOOL succeed))completion;

/**
 使用不定参数插入数据
 @param name 表名
 @param field 字段名<NSString>, 数据 <NSString, NSData, NSNumber>
 @return 是否插入成功
 */
- (BOOL)insertToTable:(NSString *)name fieldsAndValues:(id)field,...NS_REQUIRES_NIL_TERMINATION;

/**
 使用不定参数插入数据<异步操作>
 @param name 表名
 @param completion 完成回调
 @param field 字段名<NSString>, 数据<NSString, NSData, NSNumber>
 */
+ (void)insertToTable:(NSString *)name completion:(nullable void(^)(BOOL succeed))completion fieldsAndValues:(id)field,...NS_REQUIRES_NIL_TERMINATION;

#pragma mark - 更新数据
/**
 使用字典更新数据
 @param name 表名
 @param where 更新条件<不设置则更新所有数据>
 @param fields {字段:数据}
 @return 是否更新成功
 */
- (BOOL)updateTable:(NSString *)name where:(nullable NSString *)where fields:(NSDictionary <NSString *, id>*)fields;

/**
 使用字典更新数据<异步操作>
 @param name 表名
 @param where 更新条件
 @param fields {字段:数据}
 @param completion 完成回调
 */
+ (void)updateTable:(NSString *)name where:(nullable NSString *)where fields:(NSDictionary <NSString *, id>*)fields completion:(nullable void(^)(BOOL succeed))completion;

/**
 使用模型更新数据
 @param name 表名
 @param where 条件
 @param model 模型
 @return 是否更新成功
 */
- (BOOL)updateTable:(NSString *)name where:(nullable NSString *)where model:(id)model;

/**
 使用模型更新数据<异步操作>
 @param name 表名
 @param where 条件
 @param model 模型
 @param completion 完成回调
 */
+ (void)updateTable:(NSString *)name where:(nullable NSString *)where model:(id)model completion:(nullable void(^)(BOOL succeed))completion;

/**
 使用不定参数更新数据
 @param name 表名
 @param where 条件
 @param field 字段名<NSString>, 数据<NSString, NSData, NSNumber>
 @return 是否更新成功
 */
- (BOOL)updateTable:(NSString *)name where:(nullable NSString *)where fieldsAndValues:(id)field,...NS_REQUIRES_NIL_TERMINATION;

/**
 使用不定参数更新数据<异步操作>
 @param name 表名
 @param where 条件
 @param completion 完成回调
 @param field 字段名<NSString>, 数据<NSString, NSData, NSNumber>
 */
+ (void)updateTable:(NSString *)name where:(nullable NSString *)where completion:(nullable void(^)(BOOL succeed))completion fieldsAndValues:(id)field,...NS_REQUIRES_NIL_TERMINATION;

#pragma mark - 删除数据
/**
 删除表中数据
 @param name 表名
 @param where 条件<不限制条件则删除所有数据, 此方法保持索引>
 关于删除所有数据有两种方式, 详查:
 https://blog.csdn.net/strggle_bin/article/details/78318305
 字段 = 某个值
 字段 is 某个值    <相当于 = >
 字段 != 某个值
 字段 is not 某个值  <相当于 !=>
 字段 > 某个值
 字段1 = 某个值 and 字段2 > 某个值  <and相当于C语言中的 &&>
 字段1 = 某个值 or 字段2 = 某个值    <or 相当于C语言中的 || >
 @return 是否删除成功
 */
- (BOOL)deleteRowFromTable:(NSString *)name where:(nullable NSString *)where;

/**
 删除表中数据<异步操作>
 @param name 表名
 @param where 条件
 @param completion 结束回调
 */
+ (void)deleteRowFromTable:(NSString *)name where:(nullable NSString *)where completion:(nullable void(^)(BOOL succeed))completion;

#pragma mark - 查询数据
/**
 查询数据库内所有表
 @return 表名数组
 */
- (NSArray <NSString *>*)selectTables;

/**
 查询数据库内所有表<分线程>
 @param block 查询结果
 */
+ (void)selectTablesUsingBlock:(void(^)(NSArray <NSString *>*tables))block;

/**
 查询表内符合条件的数据数<条件为空则查询总数>
 @param name 表名
 @param where 条件
 @return 总数
 */
- (NSUInteger)selectCountFromTable:(NSString *)name where:(nullable NSString *)where;

/**
 查询表内符合条件的数据数<条件为空则查询总数, 分线程>
 @param name 表名
 @param where 条件
 @param completion 结束回调
 */
+ (void)selectCountFromTable:(NSString *)name where:(nullable NSString *)where completion:(void(^)(NSUInteger count))completion;

/**
 获取表内数据某列和
 @param name 表名
 @param column 列字段
 @return 和
 */
- (CGFloat)selectSumFromTable:(NSString *)name column:(NSString *)column;

/**
 获取表内数据某列和<异步操作>
 @param name 表名
 @param column 列字段
 @param completion 查询回调
 */
+ (void)selectSumFromTable:(NSString *)name column:(NSString *)column completion:(void(^)(CGFloat sum))completion;

/**
 利用sql语句查询数据库
 @param name 表名
 @param sql 语句<便于排序查询, 必须是全部字段内容>
 @return 查询结果
 */
- (nullable NSArray <NSDictionary <NSString *, id>*>*)selectRowsFromTable:(NSString *)name sql:(NSString *)sql;

/**
 利用sql语句查询数据库<分线程>
 @param name 表名
 @param sql 语句<便于排序查询, 必须是全部字段内容>
 @param completion 查询结果回调
 */
+ (void)selectRowsFromTable:(NSString *)name sql:(NSString *)sql completion:(void(^)(NSArray <NSDictionary <NSString *, id>*>* rows))completion;

/**
 利用sql语句查询数据库
 @param name 表名
 @param sql 语句<便于排序查询, 必须是全部字段内容>
 @param cls 模型类
 @return 模型数组
 */
- (nullable NSArray <id>*)selectRowsModelFromTable:(NSString *)name sql:(NSString *)sql class:(Class)cls;

/**
 利用sql语句查询数据库<分线程>
 @param name 表名
 @param sql 语句<便于排序查询, 必须是全部字段内容>
 @param cls 模型类
 @param completion 查询结果回调
 */
+ (void)selectRowsModelFromTable:(NSString *)name sql:(NSString *)sql class:(Class)cls completion:(void(^)(NSArray <id>* rows))completion;

/**
 获取表内符合条件的数据
 @param name 表名
 @param fields 指定查询字段<空则查询所有字段>
 @param where 条件<空则查询所有项>
 @param limit 范围{跳过的条数, 返回的条数}<length = 0则不限制条数>
 @return 数据列表
 */
- (nullable NSArray <NSDictionary <NSString *, id>*>*)selectRowsFromTable:(NSString *)name fields:(nullable NSArray <NSString *>*)fields where:(nullable NSString *)where limit:(NSRange)limit;

/**
 获取表内符合条件的数据<异步操作>
 @param name 表名
 @param fields 指定查询字段<空则查询所有字段>
 @param where 条件<空则查询所有项>
 @param limit 范围{跳过的条数, 返回的条数}<length = 0则不限制条数>
 @param completion 查询结果回调
 */
+ (void)selectRowsFromTable:(NSString *)name fields:(nullable NSArray <NSString *>*)fields where:(nullable NSString *)where limit:(NSRange)limit completion:(void(^)(NSArray <NSDictionary <NSString *, id>*>* rows))completion;

/**
 获取表内符合条件的数据模型
 @param name 表名
 @param where 条件<空则查询所有项>
 @param limit 范围{跳过的条数, 返回的条数}<length = 0则不限制条数>
 @param cls 模型类
 @return 结果回调
 */
- (nullable NSArray <id>*)selectRowsModelFromTable:(NSString *)name where:(nullable NSString *)where limit:(NSRange)limit class:(Class)cls;

/**
 获取表内符合条件的数据模型<异步操作>
 @param name 表名
 @param where 条件<空则查询所有项>
 @param limit 范围{跳过的条数, 返回的条数}<length = 0则不限制条数>
 @param cls 模型类
 @param completion 查询结果回调
 */
+ (void)selectRowsModelFromTable:(NSString *)name where:(nullable NSString *)where limit:(NSRange)limit class:(Class)cls completion:(void(^)(NSArray <id>* rows))completion;

/**
 获取表内数据模型
 @param name 表名
 @param cls 模型类
 @return 数据项模型数组
 */
- (NSArray <id>*)selectRowsModelFromTable:(NSString *)name class:(Class)cls;

/**
 获取表内数据模型<异步操作>
 @param name 表名
 @param cls 模型类
 @param completion 查询结果回调
 */
+ (void)selectRowsModelFromTable:(NSString *)name class:(Class)cls completion:(void(^)(NSArray <id>*rows))completion;

#pragma mark - 更新数据库字段
/**
 表中是否存在某字段
 @param fieldName 字段名称
 @param tableName 表名称
 @return 是否存在
*/
- (BOOL)existsField:(NSString *)fieldName inTable:(NSString *)tableName;

/**
 表中是否存在某字段<使用分线程>
 @param tableName 字段名称
 @param completion 检查结果回调
*/
+ (void)existsField:(NSString *)fieldName inTable:(NSString *)tableName completion:(void(^_Nullable)(BOOL))completion;

/**
 更新表字段
 @param cls 类名
 @return 是否更新成功
*/
- (BOOL)updateTableFields:(NSString *)tableName cls:(Class)cls;

/**
 更新表字段<使用分线程>
 @param cls 类名
 @param completion 更新结果回调
*/
+ (void)updateTableFields:(NSString *)tableName cls:(Class)cls completion:(void(^_Nullable)(BOOL))completion;

/**
 更新表字段
 @param model 模型
 @return 是否更新成功
*/
- (BOOL)updateTableFields:(NSString *)tableName model:(id)model;

/**
 更新表字段<使用分线程>
 @param model 类名
 @param completion 更新结果回调
*/
+ (void)updateTableFields:(NSString *)tableName model:(id)model completion:(void(^_Nullable)(BOOL))completion;

#pragma mark - 修改数据库
/**
 改变数据库路径
 @param path 新的数据库路径
 @return 是否改变成功
 */
- (BOOL)setDatabaseReadyPath:(NSString *)path;

/**
 分线程改变数据库路径
 @param path 新的数据库路径
 @param completion 回调结果
 */
+ (void)setDatabaseReadyPath:(NSString *)path completion:(nullable void(^)(BOOL succeed))completion;

/**
 恢复数据库原本路径
 @return 是否恢复成功
 */
- (BOOL)restoreDatabase;

/**
 分线程恢复数据库原本路径
 @param block 回调结果
 */
+ (void)restoreDatabaseUsingBlock:(nullable void(^)(BOOL))block;

/**
 保存此时数据库路径为使用路径
 @return 是否操作成功
 */
- (BOOL)retainDatabase;

/**
 分线程保存此时数据库路径为使用路径
 @param block 回调结果
 */
+ (void)retainDatabaseUsingBlock:(nullable void(^)(BOOL))block;

#pragma mark - 查询类符合数据库规则的字段
/**
 获取类符合数据库类型的字段
 @param cls 类
 @return {字段:类型}
 */
- (NSDictionary <NSString *, NSString *>*)fieldsOfClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
