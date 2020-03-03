//
//  MNPurchaseRequest.h
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  内购产品请求

#import <Foundation/Foundation.h>
#import "MNPurchaseReceipt.h"
#import "MNPurchaseResponse.h"

typedef BOOL(^MNPurchaseReceiptHandler)(MNPurchaseReceipt *receipt);
typedef void(^MNPurchaseRequestHandler)(MNPurchaseResponse *response);

@interface MNPurchaseRequest : NSObject

/// 请求产品信息失败后的尝试次数
@property (nonatomic) NSInteger requestOutCount;
/// 请求次数
@property (nonatomic) NSInteger requestCount;

@property (nonatomic, readonly) NSString *productIdentifier;

- (instancetype)initWithProductIdentifier:(NSString *)identifier;

- (void)startRequestPaymentWithReceiptHandler:(MNPurchaseReceiptHandler)receiptHandler completionHandler:(MNPurchaseRequestHandler)completionHandler;

- (void)completeRequestWithReceiptData:(NSData *)receiptData;

- (void)finishRequestWithResponseCode:(MNPurchaseResponseCode)responseCode;

@end
