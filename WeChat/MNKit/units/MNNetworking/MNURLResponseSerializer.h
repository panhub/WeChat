//
//  MNURLResponseSerializer.h
//  MNKit
//
//  Created by Vincent on 2018/11/7.
//  Copyright © 2018年 小斯. All rights reserved.
//  数据序列化器

#import <Foundation/Foundation.h>

/**
 数据解析类型
 - MNURLSerializationTypeUnknown 未知类型
 - MNURLSerializationTypeJSON JSON格式
 - MNURLSerializationTypeString String格式
 - MNURLSerializationTypeXML XML格式
 - MNURLSerializationTypePlist Plist格式
 */
typedef NS_ENUM(NSInteger, MNURLSerializationType) {
    MNURLSerializationTypeUnknown = 0,
    MNURLSerializationTypeJSON,
    MNURLSerializationTypeString,
    MNURLSerializationTypeXML,
    MNURLSerializationTypePlist
};

/**解析错误Domain*/
FOUNDATION_EXTERN NSString * const _Nonnull MNURLResponseSerializationErrorDomain;
/**请求失败信息key*/
FOUNDATION_EXTERN NSString * const _Nonnull MNURLResponseFailingErrorKey;
/**数据解析错误信息key*/
FOUNDATION_EXTERN NSString * const _Nonnull MNURLResponseSerializationErrorKey;

/**可接受的响应码*/
FOUNDATION_EXPORT NSIndexSet *_Nonnull MNURLResponseAcceptableStatus (void);

NS_ASSUME_NONNULL_BEGIN

@interface MNURLResponseSerializer : NSObject<NSCopying>

/**String类型解析格式*/
@property (nonatomic) NSStringEncoding stringEncoding;

/**接受的响应码*/
@property (nonatomic, copy) NSIndexSet *acceptableStatus;

/**JSON格式编码选项*/
@property (nonatomic) NSJSONReadingOptions JSONOptions;

/**解析数据类型*/
@property (nonatomic) MNURLSerializationType serializationType;

/**
 响应序列器实例化(提供默认配置)
 @return 解析实例
 */
+ (instancetype)serializer;

/**
 数据解析

 @param response 请求响应者
 @param data 数据体
 @param error 错误指针
 @return 根据序列化类型解析后的数据
 */
- (id)objectWithResponse:(NSURLResponse *_Nullable)response
                           data:(NSData *_Nullable)data
                          error:(NSError *__autoreleasing _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
