//
//  MNPurchaseManager.h
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  内购管理者 

#import <Foundation/Foundation.h>
#import "MNPurchaseRequest.h"

@interface MNPurchaseManager : NSObject

/**此时是否支持内购*/
@property (nonatomic, readonly) BOOL canPayment;

/**后台生成共享秘钥, 订阅所需*/
@property (nonatomic, copy) NSString *sharedKey;

/**使用弹窗提示错误信息<几个重要错误>*/
@property (nonatomic) BOOL useAlertHintIfNeeded;

/**
 内购管理者实例化入口
 @return 内购管理者
*/
+ (MNPurchaseManager *)defaultManager;

/**
 开始内购请求
 @param request 指定内购请求体
*/
- (void)startRequest:(MNPurchaseRequest *)request;

/**
 开始内购请求
 @param productId 指定产品ID
 @param completionHandler 结束回调
*/
- (void)startPurchaseProduct:(NSString *)productId completionHandler:(MNPurchaseRequestHandler)completionHandler;

@end

