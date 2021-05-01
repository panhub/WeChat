//
//  MNPurchaseCheckout.h
//  MNKit
//
//  Created by Vicent on 2020/9/26.
//

#import <Foundation/Foundation.h>
#import "MNPurchaseResponse.h"
@class MNPurchaseReceipt;

NS_ASSUME_NONNULL_BEGIN

@interface MNPurchaseCheckout : NSObject

/**
 向验Itunes证内购收据
 @param receipt 收据
 @param secretKey 订阅秘钥
 @param resultHandler 回调结果
 */
+ (void)checkoutReceiptToItunes:(MNPurchaseReceipt *)receipt secretKey:(NSString *_Nullable)secretKey resultHandler:(void(^)(MNPurchaseResponseCode))resultHandler;

@end

NS_ASSUME_NONNULL_END
