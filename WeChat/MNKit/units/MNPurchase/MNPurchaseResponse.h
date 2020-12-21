//
//  MNPurchaseResponse.h
//  MNKit
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  内购结果响应者

#import <Foundation/Foundation.h>
@class MNPurchaseReceipt, MNPurchaseRequest;

/**
 内购错误码
 错误信息请参考message
 */
typedef NS_ENUM(NSInteger, MNPurchaseResponseCode) {
    MNPurchaseResponseCodeUnknown = -1,
    MNPurchaseResponseCodeFailed = 0,
    MNPurchaseResponseCodeSucceed = 1,
    MNPurchaseResponseCodeCancelled = 2,
    MNPurchaseResponseCodeNotSupport = 3,
    MNPurchaseResponseCodeRestoreNotAllowed = 4,
    MNPurchaseResponseCodeRestoreNone = 5,
    MNPurchaseResponseCodeRequestFailed = 6,
    MNPurchaseResponseCodeBusying = 7,
    MNPurchaseResponseCodePermissionDenied = 8,
    MNPurchaseResponseCodeNetworkError = 9,
    MNPurchaseResponseCodePaymentInvalid = 10,
    MNPurchaseResponseCodeCheckoutNone = 11,
    MNPurchaseResponseCodeReceiptInvalid = 107,
    MNPurchaseResponseCodeJSONError = 21000,
    MNPurchaseResponseCodeDataError = 21002,
    MNPurchaseResponseCodeReceiptError = 21003,
    MNPurchaseResponseCodeSecretKeyError = 21004,
    MNPurchaseResponseCodeServerError = 21005,
    MNPurchaseResponseCodeSubscribeError = 21006,
    MNPurchaseResponseCodeSandboxError = 21007,
    MNPurchaseResponseCodeProductionError = 21008,
    MNPurchaseResponseCodeAuthorizationError = 21010,
    MNPurchaseResponseCodeInternalError = 21100
};

NS_ASSUME_NONNULL_BEGIN

@interface MNPurchaseResponse : NSObject

/**错误信息*/
@property (nonatomic, readonly) NSString *message;

/**错误码*/
@property (nonatomic, readonly) MNPurchaseResponseCode code;

/**内购请求*/
@property (nonatomic, readonly, nullable) MNPurchaseRequest *request;

/**内购收据集合<本地订单校验或恢复购买可能存在多个收据>*/
@property (nonatomic, readonly, nullable) NSArray <MNPurchaseReceipt *>*receipts;

/**
 依据响应码初始化
 @param code 响应码
 @return 内购结果
*/
- (instancetype)initWithResponseCode:(MNPurchaseResponseCode)code;

/**
 依据响应码初始化
 @param code 响应码
 @return 内购结果
*/
+ (instancetype)responseWithCode:(MNPurchaseResponseCode)code;

@end

NS_ASSUME_NONNULL_END
