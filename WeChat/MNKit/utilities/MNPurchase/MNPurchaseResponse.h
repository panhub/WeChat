//
//  MNPurchaseResponse.h
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MNPurchaseResponseCode) {
    MNPurchaseResponseCodeFailed = 0,
    MNPurchaseResponseCodeSucceed = 1,
    MNPurchaseResponseCodeCancelled = 2,
    MNPurchaseResponseCodeExistReceipt = 3,
    MNPurchaseResponseCodeCannotPayment = 4,
    MNPurchaseResponseCodeRestored = 5,
    MNPurchaseResponseCodeRestoreUnknown = 6,
    MNPurchaseResponseCodeVerifyError = 7,
    MNPurchaseResponseCodeRequestError = 8,
    MNPurchaseResponseCodeJSONError = 21000,
    MNPurchaseResponseCodeDataError = 21002,
    MNPurchaseResponseCodeReceiptError = 21003,
    MNPurchaseResponseCodeSecretKeyError = 21004,
    MNPurchaseResponseCodeServerError = 21005,
    MNPurchaseResponseCodeSubscribeError = 21006,
    MNPurchaseResponseCodeSandboxError = 21007,
    MNPurchaseResponseCodeProduceError = 21008,
    MNPurchaseResponseCodeAuthorizationError = 21010,
    MNPurchaseResponseCodeInternalError = 21100
};

@interface MNPurchaseResponse : NSObject

/**错误信息*/
@property (nonatomic, readonly) NSString *message;

/**错误码*/
@property (nonatomic, readonly) MNPurchaseResponseCode code;

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

