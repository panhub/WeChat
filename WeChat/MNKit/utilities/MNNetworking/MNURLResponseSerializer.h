//
//  MNURLResponseSerializer.h
//  MNKit
//
//  Created by Vincent on 2018/11/7.
//  Copyright © 2018年 小斯. All rights reserved.
//  数据序列化器

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MNURLResponseSerializationType) {
    MNURLResponseSerializationUnknown = 0,
    MNURLResponseSerializationJSON,
    MNURLResponseSerializationXML,
    MNURLResponseSerializationPlist
};

UIKIT_EXTERN NSString * const MNURLResponseSerializationErrorDomain;
UIKIT_EXTERN NSString * const MNNetworkingOperationFailingURLResponseErrorKey;
UIKIT_EXTERN NSString * const MNNetworkingOperationFailingURLResponseDataErrorKey;


@interface MNURLResponseSerializer : NSObject

@property (nonatomic, assign, readwrite) MNURLResponseSerializationType type;
@property (nonatomic, copy, readonly) NSIndexSet *acceptableStatusCodes;

+ (instancetype)serializer;

/**
 数据解析

 @param response 请求响应者
 @param type 序列化方式
 @param data 数据体
 @param error 错误指针
 @return 根据序列化类型解析后的数据
 */
- (id)responseObjectForResponse:(NSURLResponse *)response
                           type:(MNURLResponseSerializationType)type
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error;

@end
