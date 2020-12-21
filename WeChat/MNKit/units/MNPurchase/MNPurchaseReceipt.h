//
//  MNPurchaseReceipt.h
//  MNKit
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  内购收据 线程不安全

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNPurchaseReceipt : NSObject <NSSecureCoding, NSCopying>

/**产品价格*/
@property (nonatomic) double price;

/**收据标识符 内部自行生成 切勿私自修改*/
@property (nonatomic, copy) NSString *identifier;

/**是否是本地收据*/
@property (nonatomic, getter=isLocal) BOOL local;

/**是否是恢复购买*/
@property (nonatomic, getter=isRestore) BOOL restore;

/**关联信息*/
@property (nonatomic, copy, nullable) id userInfo;

/**收据内容*/
@property (nonatomic, copy, readonly) NSString *content;

/**产品标识*/
@property (nonatomic, copy) NSString *productIdentifier;

/**交易标识*/
@property (nonatomic, copy) NSString *transactionIdentifier;

/**交易时间ms*/
@property (nonatomic, copy) NSString *transactionDate;

/**原始交易时间ms*/
@property (nonatomic, copy) NSString *originalTransactionDate;

/**原始交易标识*/
@property (nonatomic, copy, nullable) NSString *originalTransactionIdentifier;

/**支付时预设信息 利于苹果后台对收据的验证*/
@property (nonatomic, copy, nullable) NSString *applicationUsername;

/**本地收据数量*/
@property (nonatomic, readonly, class) NSInteger localCount;

/**记录提交验证的次数*/
@property (nonatomic) int checkoutCount;

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
 获取指定标识符的购买收据
 @param identifier 指定标识符
 @return 购买收据
 */
+ (nullable MNPurchaseReceipt *)receiptForIdentifier:(NSString *)identifier;

/**
 获取指定事务的购买收据
 @param transactionIdentifier 事务id
 @return 购买收据
 */
+ (nullable MNPurchaseReceipt *)receiptForTransaction:(NSString *)transactionIdentifier;

/**
 删除本地内购收据
*/
+ (void)removeAllReceipts;

/**
 更新本地收据
 @return 是否成功更新
*/
+ (BOOL)updateReceipts;

/**
 强制更新本地收据
 @param receipts 收据内容<null则删除>
 @return 是否更新成功
 */
+ (BOOL)updateReceipts:(NSArray <MNPurchaseReceipt *>*_Nullable)receipts;

/**
 缓存收据至本地
 @return 是否缓存成功
 */
- (BOOL)insertToLocal;

/**
 缓存收据至本地
 @param receipt 收据
 @return 是否缓存成功
 */
+ (BOOL)insertReceipt:(MNPurchaseReceipt *)receipt;

/**
 删除收据
 @return 是否成功删除
*/
- (BOOL)removeFromLocal;

/**
 从本地删除收据
 @param receipt 收据
 @return 是否成功删除
 */
+ (BOOL)removeReceipt:(MNPurchaseReceipt *)receipt;

/**
 判断是否存在内购收据
 @return 是否存在
*/
+ (BOOL)containsReceipt:(MNPurchaseReceipt *)receipt;

/**
 判断收据是否是同
 @return 判断结果
*/
- (BOOL)isEqualToReceipt:(MNPurchaseReceipt *)receipt;

/**
 遍历本地收据
 @param block 遍历结果回调
 */
+ (void)enumerateReceiptsUsingBlock:(void (NS_NOESCAPE ^)(MNPurchaseReceipt *_Nonnull obj, NSUInteger idx, BOOL *stop))block;

@end

NS_ASSUME_NONNULL_END
