//
//  NSFileManager+MNShareGroup.h
//  MNKit
//
//  Created by Vicent on 2020/11/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (MNShareGroup)
/**
 共享沙盒目录
 @param suitename 组标识
 @return 共享沙盒目录
 */
+ (NSString *_Nullable)directoryWithGroup:(NSString *)suitename;
/**
 共享沙盒Library目录
 @param suitename 组标识
 @return 共享沙盒Library目录
 */
+ (NSString *_Nullable)libraryWithGroup:(NSString *)suitename;
/**
 共享沙盒Caches目录
 @param suitename 组标识
 @return 共享沙盒Caches目录
 */
+ (NSString *_Nullable)cacheWithGroup:(NSString *)suitename;
/**
 共享沙盒写入文件
 @param value 待写入的数据
 @param filename 文件名
 @param suitename 组标识
 @return 是否成功写入
 */
+ (BOOL)writeObject:(id)value fileName:(NSString *)filename withGroup:(NSString *)suitename;
/**
 获取沙盒数据流
 @param filename 文件名
 @param suitename 组标识
 @return 数据流
 */
+ (NSData *_Nullable)dataWithFileName:(NSString *)filename withGroup:(NSString *)suitename;
/**
 获取沙盒字符串
 @param filename 文件名
 @param suitename 组标识
 @return 字符串
 */
+ (NSString *_Nullable)stringWithFileName:(NSString *)filename withGroup:(NSString *)suitename;
/**
 获取沙盒字符串
 @param filename 文件名
 @param suitename 组标识
 @param encoding 编码格式
 @return 字符串
 */
+ (NSString *_Nullable)stringWithFileName:(NSString *)filename withGroup:(NSString *)suitename encoding:(NSStringEncoding)encoding;

//+ (BOOL)createDirectoryAtPath:(NSString *)path withGroup:(NSString *)suitename error:(NSError **_Nullable)error;

@end

NS_ASSUME_NONNULL_END
