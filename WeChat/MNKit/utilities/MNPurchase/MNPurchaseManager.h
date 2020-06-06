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
#import "MNPurchaseResponse.h"
@class MNURLDataRequest, MNPurchaseManager;

FOUNDATION_EXTERN NSNotificationName const _Nonnull MNPurchaseFinishNotificationName;
FOUNDATION_EXTERN NSNotificationName const _Nonnull MNPurchaseSubmitLocalNotificationName;

NS_ASSUME_NONNULL_BEGIN

@protocol MNPurchaseDelegate <NSObject>
@optional
/**
 接收到购买凭据需要自行向服务端验证
 @param receipt 凭据<已缓存至本地>
 @param resultHandler 将验证结果返回<若不返回, 下次还会检查验证>
 */
- (void)purchaseManagerNeedSubmitReceipt:(MNPurchaseReceipt *)receipt
                           resultHandler:(void(^)(MNPurchaseResponseCode))resultHandler;
/**
 检查到本地有校验失败的凭据<生命周期内只回调一次>
 @param receipts 凭据
 */
- (void)purchaseManagerStartSubmitLocalReceipts:(NSArray <MNPurchaseReceipt *>*)receipts;
/**
 本地凭据校验结束<无论成功失败>
 @param receipt 购买凭据
 @param response 校验结果
 */
- (void)purchaseManagerDidFinishSubmitReceipt:(MNPurchaseReceipt *)receipt response:(MNPurchaseResponse *)response;
@end

@interface MNPurchaseManager : NSObject

/**此时是否支持内购*/
@property (nonatomic, readonly) BOOL canPayment;

/**尝试再次验证次数*/
@property (nonatomic) int receiptMaxSubmitCount;

/**凭据验证 最大失败次数*/
@property (nonatomic) int receiptMaxFailCount;

/**后台生成共享秘钥, 订阅所需*/
@property (nonatomic, copy, nullable) NSString *secretKey;

/**事件代理*/
@property (nonatomic, weak, nullable) id<MNPurchaseDelegate> delegate;

/**使用服务端验证凭证*/
@property (nonatomic, getter=isUseItunesSubmitReceipt) BOOL useItunesSubmitReceipt;

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
 删除本地凭据<谨慎调用>
 @return 是否清理成功
 */
- (BOOL)removeAllLocalReceipts;

/**
 强制更新本地凭据
 @param receipts 凭据内容<null 则删除本地凭据>
 @return 是否更新成功
 */
- (BOOL)updateLocalReceiptCompulsory:(NSArray <MNPurchaseReceipt *>*_Nullable)receipts;

/**
 开始内购请求
 @param productId 指定产品ID
 @param startHandler 开始回调
 @param completionHandler 结束回调
*/
- (void)startPurchaseProduct:(NSString *)productId
                startHandler:(MNPurchaseStartHandler)startHandler
           completionHandler:(MNPurchaseFinishHandler)completionHandler;

/**
 开始订阅产品
 @param productId 指定产品ID
 @param startHandler 开始回调
 @param completionHandler 结束回调
*/
- (void)startSubscribeProduct:(NSString *)productId
                 startHandler:(MNPurchaseStartHandler)startHandler
            completionHandler:(MNPurchaseFinishHandler)completionHandler;

/**
 恢复购买
 @param startHandler 开始回调
 @param completionHandler 结束回调
*/
- (void)startRestorePurchase:(MNPurchaseStartHandler)startHandler
           completionHandler:(MNPurchaseFinishHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
