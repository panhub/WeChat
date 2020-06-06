//
//  MNPurchaseReceipt.h
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  内购收据

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNPurchaseReceipt : NSObject <NSSecureCoding, NSCopying>

/**收据内容*/
@property (nonatomic, copy, readonly) NSString *content;

/**产品标识*/
@property (nonatomic, copy, nullable) NSString *productIdentifier;

/**交易标识*/
@property (nonatomic, copy, nullable) NSString *transactionIdentifier;

/**收据关联信息*/
@property (nonatomic, copy, nullable) id<NSCopying> userInfo;

/**失败次数*/
@property (nonatomic) int failCount;

/**是否是订阅*/
@property (nonatomic, getter=isSubscribe) BOOL subscribe;

/**是否是恢复购买*/
@property (nonatomic, getter=isRestore) BOOL restore;

/**判断是否是本地凭据*/
@property (nonatomic, readonly) BOOL isLocalReceipt;

/**本地凭证*/
@property (nonatomic, readonly, class) NSArray <MNPurchaseReceipt *>*localReceipts;

/**
 依据收据数据流实例化
 @param receiptData 收据数据流
 @return 内购收据对象
*/
+ (nullable instancetype)receiptWithData:(NSData *)receiptData;

/**
 依据收据字典实例化
 @param json 收据数据字典
 @return 内购收据对象
*/
+ (nullable instancetype)receiptWithDictionary:(NSDictionary *)json;

/**
 删除本地内购收据
 @return 是否删除成功
*/
+ (BOOL)removeLocalReceipts;

/**
 更新本地凭据
 @return 是否成功更新
*/
+ (BOOL)updateLocalReceipts;

/**
 强制更新本地凭据
 @param receipts 凭据内容<null 则删除本地凭据>
 @return 是否更新成功
 */
+ (BOOL)updateLocalReceiptCompulsory:(NSArray <MNPurchaseReceipt *>*_Nullable)receipts;

/**
 保存内购收据
 @return 是否保存成功
*/
- (BOOL)saveReceiptToLocal;

/**
 删除凭证
 @return 是否成功删除
*/
- (BOOL)removeFromLocal;

/**
 判断是否存在内购凭证
 @return 是否存在
*/
+ (BOOL)containsReceipt:(MNPurchaseReceipt *)receipt;

/**
 判断两个凭据是否是同一凭据
 @return 是否相同
*/
- (BOOL)isEqualToReceipt:(MNPurchaseReceipt *)receipt;

@end


@interface MNPurchaseReceipt (MNPurchaseSubmiting)

/**尝试验证的次数*/
@property (nonatomic) int submitCount;

@end

NS_ASSUME_NONNULL_END
