//
//  MNURLRequest.h
//  MNKit
//
//  Created by Vincent on 2018/11/18.
//  Copyright © 2018年 小斯. All rights reserved.
//  请求体<抽象类, 请使用其子类>

#import <Foundation/Foundation.h>
#import "MNHTTPProtocol.h"
#import "MNURLResponse.h"

/**
 数据解析类型
 - MNURLRequestSerializationTypeUnknown: 未知
 - MNURLRequestSerializationTypeJSON: 以JSON格式解析
 - MNURLRequestSerializationTypeJSON: 以NSString格式解析
 - MNURLRequestSerializationTypeXML: 以XML格式解析
 - MNURLRequestSerializationTypePlist: 以Plist格式解析
 */
typedef NS_ENUM(NSInteger, MNURLRequestSerializationType) {
    MNURLRequestSerializationTypeUnknown = 0,
    MNURLRequestSerializationTypeJSON,
    MNURLRequestSerializationTypeString,
    MNURLRequestSerializationTypeXML,
    MNURLRequestSerializationTypePlist
};

typedef void(^ _Nullable MNURLRequestStartCallback)(void);
typedef void(^ _Nullable MNURLRequestFinishCallback)(MNURLResponse *_Nonnull response);
typedef void(^_Nullable MNURLRequestProgressCallback)(NSProgress *_Nullable progress);

#ifndef MNURLPath
#define MNURLPath(path)    @(((void)(NO && ((void)path, NO)), strchr(# path, '.') + 1))
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MNURLRequest : NSObject<MNHTTPProtocol>

/**请求地址*/
@property (nonatomic, copy) NSString *url;
/**提交的数据体 只接受 NSString, NSData, NSDictionary<NSString/NSNumber>*/
@property (nonatomic, copy, nullable) id body;
/**请求地址参数 只接受 NSString, NSDictory<NSString/NSNumber>*/
@property (nonatomic, copy, nullable) id query;
/**请求超时时间*/
@property (nonatomic) NSTimeInterval timeoutInterval;
/**字符串编码格式*/
@property (nonatomic) NSStringEncoding stringWritingEncoding;
/**是否允许使用蜂窝网络 默认YES*/
@property (nonatomic, getter=isAllowsCellularAccess) BOOL allowsCellularAccess;
/**是否允许取消回调 默认NO*/
@property (nonatomic, getter=isAllowsCancelCallback) BOOL allowsCancelCallback;
/***是否允许开启网络活动视图, 默认YES*/
@property (nonatomic, getter=isAllowsNetworkActivity) BOOL allowsNetworkActivity;
/**服务端验证密码 key:username value:password*/
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *authHeader;
/**请求体HTTPHeaderField*/
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *headerFields;

/**接受的响应码*/
@property (nonatomic, copy) NSIndexSet *acceptableStatus;
/**String类型解析格式*/
@property (nonatomic) NSStringEncoding stringReadingEncoding;
/**JSON格式编码选项*/
@property (nonatomic) NSJSONReadingOptions JSONReadingOptions;
/**数据解析方式*/
@property (nonatomic) MNURLRequestSerializationType serializationType;

/**是否正在请求*/
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
/**是否请求成功*/
@property (nonatomic, readonly, getter=isSucceed) BOOL succeed;
/**是否第一次请求*/
@property (nonatomic, readonly, getter=isFirstLoading) BOOL firstLoading;
/**请求产生的Task*/
@property (nonatomic, strong, readonly, nullable) NSURLSessionTask *task;
/**响应实例*/
@property (nonatomic, strong, readonly, nullable) MNURLResponse *response;

/**请求开始回调*/
@property (nonatomic, copy, nullable) MNURLRequestStartCallback startCallback;
/**请求结束回调*/
@property (nonatomic, copy, nullable) MNURLRequestFinishCallback finishCallback;
/**请求进度回调*/
@property (nonatomic, copy, nullable) MNURLRequestProgressCallback progressCallback;

/**
 依据请求地址初始化
 @param url 请求地址
 @return 请求实例
 */
- (instancetype)initWithUrl:(NSString *)url;

/**
 初始化参数
 */
- (void)initialized;

/**
 清空回调
 */
- (void)cleanCallback;

/**
 重新开始
 */
- (BOOL)resume;

/**
 不可恢复的取消任务
 */
- (void)cancel;

/**
 添加参数<请求前有效 query=value>
 @param value 参数值
 @param query 参数key
 */
- (void)setValue:(nullable NSString *)value forQuery:(NSString *)query;

/**
 添加请求体<请求前有效 body=value>
 @param value 参数值
 @param body 参数key
 */
- (void)setValue:(nullable NSString *)value forBody:(NSString *)body;

/**
 添加请求头信息<请求前有效 field=value>
 @param value 参数值
 @param field 参数key
 */
- (void)setValue:(nullable NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 设置服务端验证信息
 @param username 用户名
 @param password 密码
 */
- (void)setAuthorizedUsername:(nullable NSString *)username password:(nullable NSString *)password;

@end

NS_ASSUME_NONNULL_END
