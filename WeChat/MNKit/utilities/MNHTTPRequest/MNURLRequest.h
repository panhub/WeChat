//
//  MNURLRequest.h
//  MNKit
//
//  Created by Vincent on 2018/11/18.
//  Copyright © 2018年 小斯. All rights reserved.
//  请求体<抽象类, 请使用其子类>

#import <Foundation/Foundation.h>
#import "MNURLResponse.h"

/**
 数据解析类型
 - MNURLRequestSerializationUnknown: 未知
 - MNURLRequestSerializationJSON: 以JSON格式解析
 - MNURLRequestSerializationXML: 以XML格式解析
 - MNURLRequestSerializationPlist: 以Plist格式解析
 */
typedef NS_ENUM(NSInteger, MNURLRequestSerializationType) {
    MNURLRequestSerializationUnknown = 0,
    MNURLRequestSerializationJSON,
    MNURLRequestSerializationXML,
    MNURLRequestSerializationPlist
};


typedef void(^MNURLRequestStartCallback)(void);
typedef void(^MNURLRequestFinishCallback)(MNURLResponse *response);
typedef void(^MNURLRequestProgressCallback)(NSProgress *progress);

typedef void(^MNURLRequestDidLoadFinishCallback)(id responseObject, NSError *error);
typedef void(^MNURLRequestConfirmResponseCallback)(MNURLResponse *response);
typedef void(^MNURLRequestDidSucceedCallback)(id responseObject);

@interface MNURLRequest : NSObject<MNURLRequestProtocol>

/**请求地址*/
@property (nonatomic, copy) NSString *url;
/**请求超时时间*/
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
/**是否允许使用蜂窝网络*/
@property (nonatomic, assign) BOOL allowsCellularAccess;
/***是否允许开启网络活动视图*/
@property (nonatomic, assign) BOOL allowsNetworkActivity;
/**请求产生的Task*/
@property (nonatomic, strong, readonly) NSURLSessionTask *task;
/**task状态*/
@property (nonatomic, readonly) NSURLSessionTaskState state;
/**响应实例*/
@property (nonatomic, strong, readonly) MNURLResponse *response;
/**请求体HTTPHeaderField*/
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *headerField;
/**服务端验证密码 key:username value:password*/
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *authorizationHeaderField;
/**GET拼接请求/POST提交数据<最好直接拼接好网址, 便于缓存数据>*/
@property (nonatomic, strong) NSDictionary *parameter;
/**是否正在请求*/
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
/**是否第一次请求*/
@property (nonatomic, readonly, getter=isFirstLoading) BOOL firstLoading;
/**是否请求成功*/
@property (nonatomic, readonly, getter=isSucceed) BOOL succeed;
/**数据解析方式*/
@property (nonatomic , assign) MNURLRequestSerializationType serializationType;

/**请求开始回调*/
@property (nonatomic, copy) MNURLRequestStartCallback startCallback;
/**请求结束回调*/
@property (nonatomic, copy) MNURLRequestFinishCallback finishCallback;
/**请求进度回调*/
@property (nonatomic, copy) MNURLRequestProgressCallback progressCallback;

/**请求结束回调<didLoadFinishWithResponseObject >*/
@property (nonatomic, copy) MNURLRequestDidLoadFinishCallback didLoadFinishCallback;
/**准备保存响应者回调<didLoadFinishWithResponse>*/
@property (nonatomic, copy) MNURLRequestConfirmResponseCallback confirmResponseCallback;
/**已请求到数据回调<didLoadSucceedWithResponseObject>*/
@property (nonatomic, copy) MNURLRequestDidSucceedCallback didLoadSucceedCallback;

- (instancetype)initWithUrl:(NSString *)url;

- (void)initialized;

- (void)cleanCallback;

/**
 暂停
 */
- (void)suspend;

/**
 重新开始
 */
- (void)resume;

/**
 不可恢复的取消任务
 */
- (void)cancel;

@end

