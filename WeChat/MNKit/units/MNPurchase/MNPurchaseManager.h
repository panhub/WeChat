//
//  MNPurchaseManager.h
//  MNKit
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  内购管理 验证成功关闭交易会话
//  若存在本地收据则拒绝开启新交易

#import <Foundation/Foundation.h>
#if __has_include(<StoreKit/StoreKit.h>)
#import "MNPurchaseReceipt.h"
#import "MNPurchaseRequest.h"
#import "MNPurchaseResponse.h"
#import "MNPurchaseCheckout.h"
@class MNURLDataRequest, MNPurchaseManager;

/**内购状态回调*/
typedef void(^_Nullable MNPurchaseStatusHandler)(MNPurchaseRequest *_Nonnull);
/**内购结束回调*/
typedef void(^_Nullable MNPurchaseCompletionHandler)(MNPurchaseResponse *_Nonnull);
/**购买事务通知 无论成功与是失败 object MNPurchaseResponse*/
FOUNDATION_EXTERN NSNotificationName const _Nonnull MNPurchaseFinishNotificationName;

NS_ASSUME_NONNULL_BEGIN

@protocol MNPurchaseDelegate <NSObject>
@required
/**
 接收到收据需要自行向服务端验证
 @param receipt 收据<新购产品已缓存至本地>
 @param resultHandler 将验证结果返回<不返回则下次仍校验本地收据且不结束交易>
 */
- (void)purchaseManagerNeedCheckoutReceipt:(MNPurchaseReceipt *)receipt
                             resultHandler:(void(^)(MNPurchaseResponseCode))resultHandler;
@optional
/**
 本地收据校验结束<无论成功失败>
 @param response 校验结果
 */
- (void)purchaseManagerDidFinishPurchasing:(MNPurchaseResponse *)response;
@end

@interface MNPurchaseManager : NSObject

/**请求产品信息最大次数*/
@property (nonatomic) int maxRequestCount;

/**校验订单最大次数*/
@property (nonatomic) int maxCheckoutCount;

/**此时是否支持内购*/
@property (nonatomic, readonly) BOOL canPayment;

/**后台生成订阅所需秘钥*/
@property (nonatomic, copy, nullable) NSString *secretKey;

/**利于苹果后台对收据的验证*/
@property (nonatomic, copy, nullable) NSString *applicationUsername;

/**事件代理*/
@property (nonatomic, weak, nullable) id<MNPurchaseDelegate> delegate;

/**使用服务端验证收据*/
@property (nonatomic, getter=isCheckoutToItunes) BOOL checkoutToItunes;

/**便于传值*/
@property (nonatomic, strong, nullable) id userInfo;

/**
 内购管理者实例化入口
 @return 内购管理者
 */
+ (MNPurchaseManager *)defaultManager;

/**
 开启内购事务监听<仅调用一次>
*/
- (void)becomeTransactionObserver;

/**
 结束未完成的内购事务<线程安全 谨慎调用>
*/
- (void)finishUncompleteTransactions;

/**
 开始内购请求<收据会缓存本地 校验成功后删除 失败则下次重新校验 且不结束交易>
 @param productId 指定产品ID
 @param statusHandler 状态回调<多次回调>
 @param completionHandler 结束回调
*/
- (void)startPurchasing:(NSString *)productId
           startHandler:(MNPurchaseStatusHandler)statusHandler
      completionHandler:(MNPurchaseCompletionHandler)completionHandler;

/**
 恢复购买<恢复购买收据不缓存 下次重新恢复即可>
 @param statusHandler 状态回调<多次回调>
 @param completionHandler 结束回调
*/
- (void)startRestore:(MNPurchaseStatusHandler)statusHandler
           completionHandler:(MNPurchaseCompletionHandler)completionHandler;

/**
 验证本地订单
 @param statusHandler 状态回调<多次回调>
 @param completionHandler 结束回调
 */
- (void)startCheckout:(MNPurchaseStatusHandler)statusHandler completionHandler:(MNPurchaseCompletionHandler)completionHandler;

/**
 寻找当前内购请求
 @param statusHandler 状态回调<多次回调>
 @param completionHandler 结束回调
 */
- (void)resumePurchasing:(MNPurchaseStatusHandler)statusHandler
     completionHandler:(MNPurchaseCompletionHandler)completionHandler;

/**
 从本地删除收据<线程安全 谨慎调用>
 @param receipt 收据
 @return 是否成功删除
 */
- (BOOL)removeReceipt:(MNPurchaseReceipt *)receipt;

/**
 删除本地收据<线程安全 谨慎调用>
 */
- (void)removeAllReceipts;

@end

NS_ASSUME_NONNULL_END
#endif
