//
//  MNPurchaseManager.h
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  内购管理者 

#import <Foundation/Foundation.h>
#import "MNPurchaseRequest.h"
#import "MNPurchaseReceipt.h"
@class MNURLDataRequest, MNPurchaseManager;

NS_ASSUME_NONNULL_BEGIN

@protocol MNPurchaseDelegate <NSObject>
@optional
- (void)purchaseManagerShouldCheckReceipt:(MNPurchaseReceipt *)receipt resultHandler:(void(^)(MNPurchaseResponseCode))resultHandler;
@end

@interface MNPurchaseManager : NSObject

/**此时是否支持内购*/
@property (nonatomic, readonly) BOOL canPayment;

/**验证请求失败次数*/
@property (nonatomic) int checkTryCount;

/**凭据验证 最大失败次数*/
@property (nonatomic) int receiptMaxFailCount;

/**后台生成共享秘钥, 订阅所需*/
@property (nonatomic, copy, nullable) NSString *secretKey;

/**事件代理*/
@property (nonatomic, weak, nullable) id<MNPurchaseDelegate> delegate;

/**使用服务端验证凭证*/
@property (nonatomic, getter=isUseServerCheckReceipt) BOOL useServerCheckReceipt;

/**使用弹窗提示错误信息*/
@property (nonatomic, copy, nullable) NSDictionary <NSString *, NSString *>*receiptHeader;

/**使用弹窗提示错误信息<几个重要错误>*/
@property (nonatomic, getter=isAllowsAlertIfNeeded) BOOL allowsAlertIfNeeded;

/**便于传值*/
@property (nonatomic, strong, nullable) id userInfo;

/**
 内购管理者实例化入口
 @return 内购管理者
*/
+ (MNPurchaseManager *)defaultManager;

/**
 开启内购事务监听
*/
- (void)becomeTransactionObserver;

/**
 结束未完成的内购事务<谨慎调用>
*/
- (void)finishUncompleteTransactions;

/**
 开始内购请求
 @param productId 指定产品ID
 @param completionHandler 结束回调
*/
- (void)startPurchaseProduct:(NSString *)productId completionHandler:(MNPurchaseRequestHandler)completionHandler;

/**
 开始订阅产品
 @param productId 指定产品ID
 @param completionHandler 结束回调
*/
- (void)startSubscribeProduct:(NSString *)productId completionHandler:(MNPurchaseRequestHandler)completionHandler;

/**
 恢复购买
 @param completionHandler 结束回调
*/
- (void)startRestorePurchaseWithCompletionHandler:(MNPurchaseRequestHandler)completionHandler;

/**
 设置收据验证回调<优先级高于代理>
 @param receiptCheckHandler 服务端验证凭据回调
*/
- (void)setPurchaseReceiptCheckHandler:(void(^_Nullable)(MNPurchaseReceipt *, void(^)(MNPurchaseResponseCode)))receiptCheckHandler;

@end

NS_ASSUME_NONNULL_END
