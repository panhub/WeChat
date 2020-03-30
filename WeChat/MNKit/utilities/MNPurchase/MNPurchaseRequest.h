//
//  MNPurchaseRequest.h
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  内购产品请求

#import <Foundation/Foundation.h>
#import "MNPurchaseResponse.h"

typedef void(^MNPurchaseRequestHandler)(MNPurchaseResponse *response);

@interface MNPurchaseRequest : NSObject

/// 请求产品信息失败后的尝试次数
@property (nonatomic) NSInteger requestOutCount;

/// 请求结束回调
@property (nonatomic, copy) MNPurchaseRequestHandler completionHandler;

/// 产品标识
@property (nonatomic, copy) NSString *productIdentifier;

- (instancetype)initWithProductIdentifier:(NSString *)identifier;

- (void)startRequestWithCompletionHandler:(MNPurchaseRequestHandler)completionHandler;

@end
