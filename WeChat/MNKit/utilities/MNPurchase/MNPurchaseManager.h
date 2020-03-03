//
//  MNPurchaseManager.h
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  内购管理者 

#import <Foundation/Foundation.h>
@class MNPurchaseRequest;

@interface MNPurchaseManager : NSObject

/// 实例化入口
+ (MNPurchaseManager *)defaultManager;

- (void)startRequest:(MNPurchaseRequest *)request;

@end

