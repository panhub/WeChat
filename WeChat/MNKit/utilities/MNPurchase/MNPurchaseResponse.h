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
    MNPurchaseResponseCodeRepeated = 2,
    MNPurchaseResponseCodeCannotPayment = 3,
    MNPurchaseResponseCodeRestored = 4,
    MNPurchaseResponseCodeNetworkError = 5,
    MNPurchaseResponseCodeProductError = 6,
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

@property (nonatomic, readonly) NSString *message;

@property (nonatomic, readonly) MNPurchaseResponseCode code;

- (instancetype)initWithResponseCode:(MNPurchaseResponseCode)code;

+ (instancetype)responseWithCode:(MNPurchaseResponseCode)code;

@end

