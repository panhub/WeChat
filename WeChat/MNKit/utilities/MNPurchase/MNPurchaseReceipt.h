//
//  MNPurchaseReceipt.h
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  内购凭据

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNPurchaseReceipt : NSObject <NSSecureCoding>

/**凭据数据*/
@property (nonatomic, copy, readonly) NSString *receipt;

/**订单标识<依据自定>*/
@property (nonatomic, copy, nullable) NSString *identifier;

/**是否是订阅*/
@property (nonatomic, getter=isSubscribe) BOOL subscribe;

/**
 依据内购数据流实例化
 @param receiptData 内购凭据数据流
 @return 内购凭据对象
*/
+ (nullable instancetype)receiptWithData:(NSData *)receiptData;

/**
 获取本地内购凭据
 @return 本地内购凭据
*/
+ (nullable instancetype)localReceipt;

/**
 删除本地内购凭据
 @return 是否删除成功
*/
+ (BOOL)removeLocalReceipt;

/**
 将内购凭据归档至本地
 @return 是否保存成功
*/
- (BOOL)saveReceiptToLocal;

@end

NS_ASSUME_NONNULL_END
