//
//  MNPurchaseReceipt.h
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  内购收据

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNPurchaseReceipt : NSObject <NSSecureCoding>

/**收据数据*/
@property (nonatomic, copy, readonly) NSString *receipt;

/**收据标识<订单号>*/
@property (nonatomic, copy, nullable) NSString *identifier;

/**是否是订阅*/
@property (nonatomic, getter=isSubscribe) BOOL subscribe;

/**是否是恢复购买*/
@property (nonatomic, getter=isRestore) BOOL restore;

/**是否存在本地收据*/
@property (nonatomic, readonly, class) BOOL hasLocalReceipt;

/**
 依据收据数据流实例化
 @param receiptData 收据数据流
 @return 内购收据对象
*/
+ (nullable instancetype)receiptWithData:(NSData *)receiptData;

/**
 获取本地内购收据
 @return 本地内购收据
*/
+ (nullable instancetype)localReceipt;

/**
 删除本地内购收据
 @return 是否删除成功
*/
+ (BOOL)removeLocalReceipt;

/**
 保存内购收据
 @return 是否保存成功
*/
- (BOOL)saveReceiptToLocal;

@end

NS_ASSUME_NONNULL_END
