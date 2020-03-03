//
//  NSObject+MNCoding.h
//  MNKit
//
//  Created by Vincent on 2018/10/9.
//  Copyright © 2018年 小斯. All rights reserved.
//  便捷方法

#import <Foundation/Foundation.h>

@interface NSObject (MNHelper)

/**
 预留值
 */
@property (nonatomic, strong) id user_info;

/**
 由二进制数据流转换为数组/字典
 */
@property (nonatomic, readonly, strong) id JsonValue;

/**
 字典/数组/字符串 数据流转化
 */
@property (nonatomic, readonly, strong) NSData *JsonData;

/**
 字典/数组/数据流/ 转换为Json格式字符串
 */
@property (nonatomic, readonly, copy) NSString *JsonString;

/**
 属性列表
 */
@property (nonatomic, readonly, strong) NSArray <NSString *>*properties;

/**
 判断是否为空对象
 @param obj 需要判断的对象
 @return 是否为空对象
 */
+ (BOOL)isEmpty:(id)obj;

/**
 替换空对象
 @param aObj 目标对象
 @param bObj 替换对象
 */
+ (void)replacingEmptyObject:(id*)aObj withObject:(id)bObj;

/**
 序列化对象
 @return 二进制数据
 */
- (NSData *)archivedData;

/**
 反序列化
 @param data 序列化后的二进制数据
 @return OC对象
 */
+ (id)unarchiveFromData:(NSData *)data;

/**
 归档到指定文件路径
 @param filePath 文件路径
 @return 是否归档成功
 */
- (BOOL)archiveToFile:(NSString *)filePath;

/**
 从指定文件路径反序列化
 @param filePath 文件路径
 @return OC对象
 */
+ (id)unarchiveFromFile:(NSString *)filePath;

@end
