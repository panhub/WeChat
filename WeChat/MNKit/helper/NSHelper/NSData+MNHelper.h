//
//  NSData+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/8/4.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSData (MNHelper)
/**
 工程文件转NSData
 @param name 文件名
 @param type 文件类型
 @return NSData
 */
+ (NSData *_Nullable)dataWithResource:(NSString *)name ofType:(NSString *_Nullable)type;

/**
 工程文件转NSData
 @param name 文件名
 @param type 文件类型
 @param directory 所在文件夹
 @return NSData
 */
+ (NSData *_Nullable)dataWithResource:(NSString *)name ofType:(NSString *_Nullable)type inDirectory:(NSString *_Nullable)directory;

/**
 归档
 @param obj 需要归档的对象
 @return 归档数据
 */
+ (NSData *_Nullable)archivedDataWithRootObject:(id)obj;

/**
 解档/反序列化
 @return 解档后数据
 */
- (id _Nullable)unarchivedObject;

/**
 解档/反序列化
 @param cls 解档类
 @return 接档后对象
 */
- (id _Nullable)unarchivedObjectOfClass:(Class)cls;

/**
 UTF8编码的字符串
 @return UTF8编码的字符串
 */
- (NSString *_Nullable)UTF8EncodedString;

/**
 Base64编码的字符串
 @return Base64编码的字符串
 */
- (NSString *_Nullable)base64EncodedString;

#pragma mark - AES
/**
 AES加密
 @param key 密码
 @return 加密后数据
 */
- (NSData *_Nullable)AES256Encrypt:(NSString *)key;

/**
 AES加密
 @param key 密码
 @return 解密后数据
 */
- (NSData *_Nullable)AES256Decrypt:(NSString *)key;

/**
 AES128加密
 @param key 密码
 @return 加密后数据
 */
- (NSData *_Nullable)AES128Encrypt:(NSString *)key;

/**
 AES128解密
 @param key 密码
 @return 解密后数据
 */
- (NSData *_Nullable)AES128Decrypt:(NSString *)key;

#pragma mark - 16进制字符串转换NSData
/**
 16进制字符串转换NSData
 @param hexString 16进制字符串
 @return 转换后数据流
 */
+ (NSData *_Nullable)dataWithHexString:(NSString*)hexString;

@end
NS_ASSUME_NONNULL_END
