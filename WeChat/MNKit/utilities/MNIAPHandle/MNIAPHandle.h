//
//  MNIAPHandle.h
//  MNKit
//
//  Created by Vincent on 2019/3/1.
//  Copyright © 2019年 小斯. All rights reserved.
//  内购交易辅助工具
//  http://www.jianshu.com/p/b199a4672608
//  https://www.cnblogs.com/TheYouth/p/6847014.html?utm_source=itdadao&utm_medium=referral

#import <Foundation/Foundation.h>

/**
 支付状态码
 - MNIAPStatusCodeFailed: 失败 <具体情况查看源码>
 - MNIAPStatusCodeSucceed: 成功
 - MNIAPStatusCodeCancelled: 取消交易
 - MNIAPStatusCodeCannotPayment: 内购权限不足
 - MNIAPStatusCodeRestored: 已购买过商品
 - MNIAPStatusCodeNetworkError: 网络错误
 - MNIAPStatusCodeJSONError: 无法验证JSON信息
 - MNIAPStatusCodeDataError: receipt-data 数据格式错误或丢失
 - MNIAPStatusCodeReceiptError: 无法认证收据
 - MNIAPStatusCodeSecretKeyError: 秘钥不匹配
 - MNIAPStatusCodeServerError: 服务器不可用
 - MNIAPStatusCodeSubscribeError: 收据有效, 但订阅期已过
 - MNIAPStatusCodeSandboxError: 收据来自沙盒环境, 但发送到生产环境验证
 - MNIAPStatusCodeProduceError: 收据来自生产环境, 但发送到了沙盒环境验证
 - MNIAPStatusCodeAuthorizationError: 此收据无法获得授权
 - MNIAPStatusCodeInternalError: 内部数据访问错误 <21100 - 21199>
 */
typedef NS_ENUM(NSInteger, MNIAPStatusCode) {
    MNIAPStatusCodeFailed = 0,
    MNIAPStatusCodeSucceed = 1,
    MNIAPStatusCodeCancelled = 2,
    MNIAPStatusCodeCannotPayment = 3,
    MNIAPStatusCodeRestored = 4,
    MNIAPStatusCodeNetworkError = 5,
    MNIAPStatusCodeJSONError = 21000,
    MNIAPStatusCodeDataError = 21002,
    MNIAPStatusCodeReceiptError = 21003,
    MNIAPStatusCodeSecretKeyError = 21004,
    MNIAPStatusCodeServerError = 21005,
    MNIAPStatusCodeSubscribeError = 21006,
    MNIAPStatusCodeSandboxError = 21007,
    MNIAPStatusCodeProduceError = 21008,
    MNIAPStatusCodeAuthorizationError = 21010,
    MNIAPStatusCodeInternalError = 21100
};

@class MNIAPResult;
typedef void(^MNIAPFinishCallback)(NSError *error);
typedef BOOL(^MNIAPRequestCallback)(MNIAPResult *result);

FOUNDATION_EXTERN NSString * const MNIAPProductIdKey;
FOUNDATION_EXTERN NSString * const MNIAPReceiptDataKey;


@interface MNIAPResult : NSObject <NSCopying>

@property (nonatomic, strong, readonly) NSDictionary *receipt;

@property (nonatomic, copy, readonly) NSString *productId;

@end


@interface MNIAPHandle : NSObject

/**
 购买商品
 @param productId 商品id <与后台id对应>
 @param handler 是否需要验证交易凭证
 @param completion 交易结束回调
 */
+ (void)handRequestProduct:(NSString *)productId
                    handler:(MNIAPRequestCallback)handler
                 completion:(MNIAPFinishCallback)completion;

@end
