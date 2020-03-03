//
//  NSData+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/8/4.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MNHelper)

/**
 工程文件转NSData
 @param name 文件名
 @param type 文件类型
 @return NSData
 */
+ (NSData *)dataWithResource:(NSString *)name ofType:(NSString *)type;

+ (NSData *)dataWithResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)directory;

/**
 归档
 @param obj 需要归档的对象
 @return 归档数据
 */
+ (NSData *)archivedDataWithRootObject:(id)obj;

/**
 解档/反序列化
 @return 解档后数据
 */
- (id)unarchivedObject;

/**
 解档/反序列化
 @param cls 解档类
 @return 接档后对象
 */
- (id)unarchivedObjectOfClass:(Class)cls;

/**
 UTF8编码的字符串
 @return UTF8编码的字符串
 */
- (NSString *)UTF8EncodedString;

/**
 Base64编码的字符串
 @return Base64编码的字符串
 */
- (NSString *)base64EncodedString;

@end
