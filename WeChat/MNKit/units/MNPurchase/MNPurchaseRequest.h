//
//  MNPurchaseRequest.h
//  MNKit
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  内购请求体

#import <Foundation/Foundation.h>
@class MNPurchaseRequest, MNPurchaseResponse;

/**
 购买请求状态
 - MNPurchaseStatusNormal 默认状态
 - MNPurchaseStatusGetting 商品信息获取中
 - MNPurchaseStatusPurchasing 购买中
 - MNPurchaseStatusCheckout 校验订单中
 - MNPurchaseStatusCompleted 完成
 */
typedef NS_ENUM(NSInteger, MNPurchaseStatus) {
    MNPurchaseStatusNormal = 0,
    MNPurchaseStatusGetting,
    MNPurchaseStatusPurchasing,
    MNPurchaseStatusCheckout,
    MNPurchaseStatusCompleted
};

NS_ASSUME_NONNULL_BEGIN

@interface MNPurchaseRequest : NSObject

/**产品价格*/
@property (nonatomic) double price;

/**请求标识符 内部自动生成*/
@property (nonatomic, readonly) NSString *identifier;

/**购买请求状态*/
@property (nonatomic) MNPurchaseStatus status;

/**购买请求次数*/
@property (nonatomic) NSInteger requestCount;

/**请求是否合法*/
@property (nonatomic, readonly) BOOL isValid;

/**是否在请求*/
@property (nonatomic, readonly) BOOL isLoading;

/**状态描述*/
@property (nonatomic, readonly) NSString *message;

/**是否是恢复购买*/
@property (nonatomic, readonly, getter=isRestore) BOOL restore;

/**是否是校验本地订单/收据请求*/
@property (nonatomic, readonly, getter=isCheckout) BOOL checkout;

/**产品标识<恢复购买时为空>*/
@property (nonatomic, readonly, nullable) NSString *productIdentifier;


/**
 依据产品标识构造
 @param productIdentifier 产品标识<恢复购买/本地订单校验请求可为nil>
 @return 产品请求
*/
- (instancetype)initWithProductIdentifier:(NSString *_Nullable)productIdentifier;

/**
 成为一个检查本地订单/收据的请求
*/
- (void)makeCheckoutUsable;

/**
 成为一个恢复购买的请求
*/
- (void)makeRestoreUsable;

/**
 回调当前状态
 */
- (void)signal;

/**
 判断内购请求是否相同
 @return 判断结果
*/
- (BOOL)isEqualToRequest:(MNPurchaseRequest *)request;

/**
 请求结束
 @param response 内购响应者
 */
- (void)didFinishWithResponse:(MNPurchaseResponse *)response;

@end

NS_ASSUME_NONNULL_END
