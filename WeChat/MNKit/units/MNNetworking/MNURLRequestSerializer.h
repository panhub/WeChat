//
//  MNURLRequestSerializer.h
//  MNKit
//
//  Created by Vincent on 2018/11/6.
//  Copyright © 2018年 小斯. All rights reserved.
//  请求序列化器

#import <Foundation/Foundation.h>

/**定义请求方法名*/
typedef NSString *const MNURLRequestMethodName NS_TYPED_EXTENSIBLE_ENUM;
FOUNDATION_EXPORT MNURLRequestMethodName _Nonnull MNURLRequestMethodGET;
FOUNDATION_EXPORT MNURLRequestMethodName _Nonnull MNURLRequestMethodPOST;
FOUNDATION_EXPORT MNURLRequestMethodName _Nonnull MNURLRequestMethodHEAD;
FOUNDATION_EXPORT MNURLRequestMethodName _Nonnull MNURLRequestMethodDELETE;

/**定义请求边界名*/
FOUNDATION_EXPORT NSString * _Nonnull const MNURLRequestUploadBoundaryName;

/**定义请求参数解析回调*/
typedef NSString * _Nullable (^_Nullable MNQueryStringSerializationCallback)(id _Nullable query, NSError * _Nullable __autoreleasing *_Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface MNURLRequestSerializer : NSObject <NSCopying>
/**是否允许蜂窝网络访问*/
@property (nonatomic) BOOL allowsCellularAccess;
/**超时时间*/
@property (nonatomic) NSTimeInterval timeoutInterval;
/**字符串编码格式*/
@property (nonatomic) NSStringEncoding stringEncoding;
/**提交的数据体, 只接收 NSString, NSData, NSDictionary, NSArray*/
@property (nonatomic, copy, nullable) id body;
/**请求地址拼接(NSString, NSDictory<NSString/NSNumber, NSString/NSNumber>)*/
@property (nonatomic, copy, nullable) id query;
/**上传数据时的边界<nil则取默认值 MNURLRequestUploadBoundaryName>*/
@property (nonatomic, copy, null_resettable) NSString *boundary;
/**服务端认证信息*/
@property (nonatomic, copy, nullable) NSDictionary *authHeader;
/**缓存策略*/
@property (nonatomic) NSURLRequestCachePolicy cachePolicy;
/**请求体参数*/
@property (nonatomic, copy, nullable) NSDictionary <NSString *, NSString *>*headerFields;
/**序列化回调*/
@property (nonatomic, copy, nullable) MNQueryStringSerializationCallback queryStringSerializationCallback;

/**请求参数序列化*/
FOUNDATION_EXPORT NSString * _Nullable MNQueryStringExtract (id, NSString *);

/**
 请求序列化器实例化(提供默认配置)
 @return 请求序列化器
 */
+ (instancetype)serializer;

/**
 数据请求序列化入口
 @param url 请求地址
 @param method 请求方式
 @param error 错误信息
 @return 可变请求体
 */
- (NSURLRequest *_Nullable)requestWithUrl:(NSString *)url
                                            method:(MNURLRequestMethodName)method
                                        error:(NSError *__autoreleasing *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
