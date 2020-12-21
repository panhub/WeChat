//
//  MNKVStorage.h
//  MNKit
//
//  Created by Vincent on 2018/10/30.
//  Copyright © 2018年 小斯. All rights reserved.
//  磁盘缓存存储器

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNKVStorageItem : NSObject
/**键*/
@property (nonatomic, strong) NSString *key;                
/**值*/
@property (nonatomic, strong) NSData *value;
/**文件名 nil able*/
@property (nullable, nonatomic, strong) NSString *filename;
/**文件大小 bytes*/
@property (nonatomic) int size;
/**修改时间*/
@property (nonatomic) int modTime;
/**存取时间*/
@property (nonatomic) int accessTime;
/**--*/
@property (nullable, nonatomic, strong) NSData *extendedData;
@end

/**
 存储方式
 - MNKVStorageTypeFile: 文件存储
 - MNKVStorageTypeSQLite: 数据库存储
 - MNKVStorageTypeMixed: 混合存储
 */
typedef NS_ENUM(NSUInteger, MNKVStorageType) {
    MNKVStorageTypeFile = 0,
    MNKVStorageTypeSQLite,
    MNKVStorageTypeMixed
};

@interface MNKVStorage : NSObject
#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================

/**
 存储器路径
 */
@property (nonatomic, readonly) NSString *path;
/**
 存储方式
 */
@property (nonatomic, readonly) MNKVStorageType type;

#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;

/**
 特定的存储器实例化方法
 @param path 路径
 @param type 存储方式
 @return 存储器实例
 */
- (nullable instancetype)initWithPath:(NSString *)path
                                 type:(MNKVStorageType)type NS_DESIGNATED_INITIALIZER;

///=============================================================================
/// @name Save Items
///=============================================================================

/**
 存储item
 @param item 模型
 @return 是否存储成功
 */
- (BOOL)saveItem:(MNKVStorageItem *)item;

/**
 根据键值存储
 @param key 键
 @param value 值
 @return 是否存储成功
 */
- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value;

/**
 根据键值存储
 @param key 键
 @param value 值
 @param filename 文件名
 @param extendedData 二进制data
 @return 是否存储成功
 */
- (BOOL)saveItemWithKey:(NSString *)key
                  value:(NSData *)value
               filename:(nullable NSString *)filename
           extendedData:(nullable NSData *)extendedData;

#pragma mark - Remove Items
///=============================================================================
/// @name Remove Items
///=============================================================================

/**
 删除指定键的值
 @param key 键
 @return 是否删除成功
 */
- (BOOL)removeItemForKey:(NSString *)key;

/**
 删除一组数据
 @param keys 键组
 @return 是否删除成功
 */
- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys;

/**
 删除体积大于指定的数据
 @param size 指定体积
 @return 是否删除成功
 */
- (BOOL)removeItemsLargerThanSize:(int)size;

/**
 删除时间大于指定的数据
 @param time 指定时间
 @return 是否删除成功
 */
- (BOOL)removeItemsEarlierThanTime:(int)time;

/**
 删除数据到指定体积
 @param maxSize 指定体积
 @return 是否删除成功
 */
- (BOOL)removeItemsToFitSize:(int)maxSize;

/**
 删除数据数量到指定数量
 @param maxCount 指定数量
 @return 是否删除成功
 */
- (BOOL)removeItemsToFitCount:(int)maxCount;

/**
 删除所有数据
 @return 是否删除成功
 */
- (BOOL)removeAllItems;

/**
 删除所有数据
 @param progress 进度
 @param completion 是否删除成功回调
 */
- (void)removeAllItemsWithProgress:(nullable void(^)(int removedCount, int totalCount))progress
                             completion:(nullable void(^)(BOOL succeed))completion;


#pragma mark - Get Items
///=============================================================================
/// @name Get Items
///=============================================================================

/**
 获取指定键对应的数据模型
 @param key 键
 @return 对应的数据模型
 */
- (nullable MNKVStorageItem *)getItemForKey:(NSString *)key;

/**
 获取指定键对应的数据模型
 @param key 键
 @return 对应的数据模型
 */
- (nullable MNKVStorageItem *)getItemInfoForKey:(NSString *)key;

/**
 获取指定键的二进制数据
 @param key 键
 @return 二进制数据
 */
- (nullable NSData *)getItemValueForKey:(NSString *)key;

/**
 获取一组指定键的数据模型
 @param keys 一组键
 @return 一组对应数据模型
 */
- (nullable NSArray<MNKVStorageItem *> *)getItemForKeys:(NSArray<NSString *> *)keys;

/**
 获取一组指定键的数据模型
 @param keys 一组键
 @return 一组对应数据模型
 */
- (nullable NSArray<MNKVStorageItem *> *)getItemInfoForKeys:(NSArray<NSString *> *)keys;

/**
 获取一组指定键的数据字典
 @param keys 一组键
 @return 一组对应数据字典
 */
- (nullable NSDictionary<NSString *, NSData *> *)getItemValueForKeys:(NSArray<NSString *> *)keys;

#pragma mark - Get Storage Status
///=============================================================================
/// @name Get Storage Status
///=============================================================================

/**
 判断是否存在对应键数据
 @param key 键
 @return 是否存在对应数据
 */
- (BOOL)itemExistsForKey:(NSString *)key;

/**
 获取数据总数量
 @return 数据总数量
 */
- (int)getItemsCount;

/**
 获取数据总体积
 @return 数据总体积
 */
- (int)getItemsSize;

@end

NS_ASSUME_NONNULL_END
