//
//  MNPurchaseRequest.h
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  内购产品请求

#import <Foundation/Foundation.h>
#import "MNPurchaseResponse.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^_Nullable MNPurchaseRequestHandler)(MNPurchaseResponse *response);

@interface MNPurchaseRequest : NSObject

/**请求产品信息失败后的尝试次数*/
@property (nonatomic) NSInteger requestOutCount;

/**请求结束回调*/
@property (nonatomic, copy, nullable) MNPurchaseRequestHandler completionHandler;

/**产品标识*/
@property (nonatomic, copy, nullable) NSString *productIdentifier;

/**
 依据产品标识构造
 @param identifier 产品标识
 @return 产品请求
*/
- (instancetype)initWithProductIdentifier:(NSString *)identifier;

@end


@interface MNPurchaseRequest (MNPurchasing)

/**产品请求次数记录*/
@property (nonatomic) NSInteger requestCount;

/**是否是恢复购买*/
@property (nonatomic, getter=isRestore) BOOL restore;

/**是否是订阅*/
@property (nonatomic, getter=isSubscribe) BOOL subscribe;

@end

NS_ASSUME_NONNULL_END
