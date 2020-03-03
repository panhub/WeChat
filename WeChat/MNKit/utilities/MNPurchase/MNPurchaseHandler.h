//
//  MNPurchaseHandler.h
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  内购操作回掉

#import <Foundation/Foundation.h>
#import "MNPurchaseManager.h"

@interface MNPurchaseHandler : NSObject

@property (nonatomic) NSUInteger requestCount;

@property (nonatomic, copy) MNPurchaseReceiptHandler receiptHandler;

@property (nonatomic, copy) MNPurchaseRequestHandler finishHandler;

@end
