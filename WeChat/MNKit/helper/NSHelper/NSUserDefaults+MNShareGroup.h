//
//  NSUserDefaults+MNShareGroup.h
//  MNKit
//
//  Created by Vicent on 2020/11/19.
//  公共沙箱存取方案

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSUserDefaults (MNShareGroup)
/**
 向公共沙盒存储
 @param value 值
 @param defaultName 键
 @param suitename 沙盒标识
 @return 是否成功存取
 */
+ (BOOL)setObject:(id _Nullable)value forKey:(NSString *)defaultName withGroup:(NSString *)suitename;
/**
 向公共沙盒存储
 @param value 值
 @param defaultName 键
 @param suitename 沙盒标识
 @return 是否成功存取
 */
+ (BOOL)setBool:(BOOL)value forKey:(NSString *)defaultName withGroup:(NSString *)suitename;
/**
 向公共沙盒存储
 @param value 值
 @param defaultName 键
 @param suitename 沙盒标识
 @return 是否成功存取
 */
+ (BOOL)setInteger:(NSInteger)value forKey:(NSString *)defaultName withGroup:(NSString *)suitename;
/**
 向公共沙盒存储
 @param value 值
 @param defaultName 键
 @param suitename 沙盒标识
 @return 是否成功存取
 */
+ (BOOL)setDouble:(double)value forKey:(NSString *)defaultName withGroup:(NSString *)suitename;
/**
 向公共沙盒读取
 @param defaultName 键
 @param suitename 沙盒标识
 @return 键关联的值
 */
+ (id _Nullable)objectForKey:(NSString *)defaultName withGroup:(NSString *)suitename;
/**
 向公共沙盒读取
 @param defaultName 键
 @param suitename 沙盒标识
 @return 键关联的值
 */
+ (BOOL)boolForKey:(NSString *)defaultName withGroup:(NSString *)suitename;
/**
 向公共沙盒读取
 @param defaultName 键
 @param suitename 沙盒标识
 @return 键关联的值
 */
+ (NSInteger)integerForKey:(NSString *)defaultName withGroup:(NSString *)suitename;
/**
 向公共沙盒读取
 @param defaultName 键
 @param suitename 沙盒标识
 @return 键关联的值
 */
+ (double)doubleForKey:(NSString *)defaultName withGroup:(NSString *)suitename;
/**
 删除公共沙盒键值
 @param defaultName 键
 @param suitename 沙盒标识
 */
+ (void)removeObjectForKey:(NSString *)defaultName withGroup:(NSString *)suitename;

@end

NS_ASSUME_NONNULL_END
