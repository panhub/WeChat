//
//  MNPurchaseReceipt.m
//  MNKit
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPurchaseReceipt.h"

#define kMNPurchaseReceipts    @"key.mn.purchase.receipts"
#define kMNPurchaseReceiptLocal    @"local"
#define kMNPurchaseReceiptPrice     @"price"
#define kMNPurchaseReceiptUserInfo    @"userInfo"
#define kMNPurchaseReceiptContent    @"content"
#define kMNPurchaseReceiptIdentifier    @"identifier"
#define kMNPurchaseReceiptProductIdentifier    @"productIdentifier"
#define kMNPurchaseReceiptTransactionDate      @"transactionDate"
#define kMNPurchaseReceiptApplicationUsername      @"applicationUsername"
#define kMNPurchaseReceiptOriginalTransactionDate      @"originalTransactionDate"
#define kMNPurchaseReceiptTransactionIdentifier    @"transactionIdentifier"
#define kMNPurchaseReceiptOriginalTransactionIdentifier    @"originalTransactionIdentifier"
#define MNPurchaseReceiptArchivePath  [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:NSStringFromClass(MNPurchaseReceipt.class)]

#define MN_PURCHASE_RECEIPT     [MNPurchaseReceipt receipts]

@interface MNPurchaseReceipt ()
@property (nonatomic, copy) NSString *content;
@property (nonatomic, readonly, class) NSMutableArray <MNPurchaseReceipt *>*receipts;
@end

@implementation MNPurchaseReceipt
- (instancetype)init {
    if (self = [super init]) {
        NSMutableString *identifier = @"com.mn.purchase".mutableCopy;
        [identifier appendString:@"."];
        [identifier appendString:[[NSNumber numberWithLongLong:(long long)(NSDate.date.timeIntervalSince1970*1000)] stringValue]];
        [identifier appendString:@"."];
        [identifier appendFormat:@"%@", @(__COUNTER__).stringValue];
        _identifier = identifier.copy;
    }
    return self;
}

+ (instancetype)receiptWithData:(NSData *)receiptData {
    NSString *content = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    if (content.length <= 0) return nil;
    MNPurchaseReceipt *receipt = MNPurchaseReceipt.new;
    receipt.content = content;
    return receipt;
}

+ (instancetype)receiptWithDictionary:(NSDictionary *)json {
    NSString *content = [json objectForKey:kMNPurchaseReceiptContent];
    if (!content || content.length <= 0) return nil;
    MNPurchaseReceipt *receipt = MNPurchaseReceipt.new;
    receipt.content = content;
    receipt.userInfo = [json objectForKey:kMNPurchaseReceiptUserInfo];
    receipt.price = [[json objectForKey:kMNPurchaseReceiptPrice] doubleValue];
    receipt.identifier = [json objectForKey:kMNPurchaseReceiptIdentifier];
    receipt.transactionDate = [json objectForKey:kMNPurchaseReceiptTransactionDate];
    receipt.productIdentifier = [json objectForKey:kMNPurchaseReceiptProductIdentifier];
    receipt.transactionIdentifier = [json objectForKey:kMNPurchaseReceiptTransactionIdentifier];
    receipt.applicationUsername = [json objectForKey:kMNPurchaseReceiptApplicationUsername];
    receipt.originalTransactionDate = [json objectForKey:kMNPurchaseReceiptOriginalTransactionDate];
    receipt.originalTransactionIdentifier = [json objectForKey:kMNPurchaseReceiptOriginalTransactionIdentifier];
    return receipt;
}

+ (MNPurchaseReceipt *)receiptForIdentifier:(NSString *)identifier {
    if (!identifier || identifier.length <= 0) return nil;
    MNPurchaseReceipt *receipt;
    for (MNPurchaseReceipt *obj in MN_PURCHASE_RECEIPT.copy) {
        if ([obj.identifier isEqualToString:identifier]) {
            receipt = obj;
            break;
        }
    }
    return receipt;
}

+ (MNPurchaseReceipt *)receiptForTransaction:(NSString *)transactionIdentifier {
    if (!transactionIdentifier || transactionIdentifier.length <= 0) return nil;
    MNPurchaseReceipt *receipt;
    for (MNPurchaseReceipt *obj in MN_PURCHASE_RECEIPT.copy) {
        if ([obj.transactionIdentifier isEqualToString:transactionIdentifier]) {
            receipt = obj;
            break;
        }
    }
    return receipt;
}

- (BOOL)insertToLocal {
    return [MNPurchaseReceipt insertReceipt:self];
}

+ (BOOL)insertReceipt:(MNPurchaseReceipt *)receipt {
    if (!receipt || receipt.content.length <= 0) return NO;
    if ([MNPurchaseReceipt containsReceipt:receipt]) return YES;
    [MN_PURCHASE_RECEIPT addObject:receipt];
    if ([MNPurchaseReceipt updateReceipts]) return YES;
    [MN_PURCHASE_RECEIPT removeObject:receipt];
    return NO;
}

- (BOOL)removeFromLocal {
    return [MNPurchaseReceipt removeReceipt:self];
}

+ (BOOL)removeReceipt:(MNPurchaseReceipt *)localReceipt {
    if (!localReceipt || localReceipt.content.length <= 0) return NO;
    MNPurchaseReceipt *receipt = [MNPurchaseReceipt receiptForIdentifier:localReceipt.identifier];
    if (!receipt) return YES;
    [MN_PURCHASE_RECEIPT removeObject:receipt];
    if ([MNPurchaseReceipt updateReceipts]) return YES;
    [MN_PURCHASE_RECEIPT addObject:receipt];
    return NO;
}

- (BOOL)isEqualToReceipt:(MNPurchaseReceipt *)receipt {
    if (!receipt) return NO;
    return ([self.identifier isEqualToString:receipt.identifier]);
}

+ (BOOL)containsReceipt:(MNPurchaseReceipt *)receipt {
    if (!receipt) return NO;
    BOOL exists = NO;
    for (MNPurchaseReceipt *obj in MN_PURCHASE_RECEIPT.copy) {
        if ([obj isEqualToReceipt:receipt]) {
            exists = YES;
            break;
        }
    }
    return exists;
}

+ (void)removeAllReceipts {
    [MN_PURCHASE_RECEIPT removeAllObjects];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kMNPurchaseReceipts];
    if (![NSUserDefaults.standardUserDefaults synchronize]) [NSUserDefaults.standardUserDefaults synchronize];
}

+ (BOOL)updateReceipts {
    if (MN_PURCHASE_RECEIPT.count <= 0) {
        [self removeAllReceipts];
        return YES;
    }
    NSMutableArray <NSDictionary *>*receipts = @[].mutableCopy;
    for (MNPurchaseReceipt *receipt in MN_PURCHASE_RECEIPT.copy) {
        [receipts addObject:[receipt jsonValue]];
    }
    NSError *error;
    NSData *receiptData = [NSJSONSerialization dataWithJSONObject:receipts.copy options:kNilOptions error:&error];
    if (receiptData.length <= 0 || error) {
        NSLog(@"⚠️⚠️⚠️⚠️⚠️ 更新收据失败 ⚠️⚠️⚠️⚠️⚠️\n%@", error);
        return NO;
    }
    [NSUserDefaults.standardUserDefaults setObject:receiptData forKey:kMNPurchaseReceipts];
    if (![NSUserDefaults.standardUserDefaults synchronize]) [NSUserDefaults.standardUserDefaults synchronize];
    return YES;
}

+ (BOOL)updateReceipts:(NSArray <MNPurchaseReceipt *>*)receipts {
    NSArray <MNPurchaseReceipt *>*localReceipts = MN_PURCHASE_RECEIPT.copy;
    [MN_PURCHASE_RECEIPT removeAllObjects];
    if (receipts && receipts.count) [MN_PURCHASE_RECEIPT addObjectsFromArray:receipts];
    if ([self updateReceipts]) return YES;
    [MN_PURCHASE_RECEIPT removeAllObjects];
    [MN_PURCHASE_RECEIPT addObjectsFromArray:localReceipts];
    NSLog(@"⚠️⚠️⚠️⚠️⚠️ 更新收据失败 ⚠️⚠️⚠️⚠️⚠️");
    return NO;
}

+ (void)enumerateReceiptsUsingBlock:(void (NS_NOESCAPE ^)(MNPurchaseReceipt *_Nonnull obj, NSUInteger idx, BOOL *stop))block {
    [MN_PURCHASE_RECEIPT.copy enumerateObjectsUsingBlock:block];
}

#pragma mark - Getter
- (NSString *)identifier {
    return _identifier.length ? _identifier : @"com.mn.purchase.receipt.identifier";
}

- (NSString *)productIdentifier {
    return _productIdentifier.length ? _productIdentifier : @"com.mn.purchase.receipt.product.identifier";
}

- (NSString *)transactionIdentifier {
    return _transactionIdentifier.length ? _transactionIdentifier : @"com.mn.purchase.receipt.transaction.identifier";
}

- (NSDictionary *)jsonValue {
    NSMutableDictionary *dic = @{}.mutableCopy;
    if (self.content) [dic setObject:self.content forKey:kMNPurchaseReceiptContent];
    if (self.identifier) [dic setObject:self.identifier forKey:kMNPurchaseReceiptIdentifier];
    if (self.userInfo) [dic setObject:self.userInfo forKey:kMNPurchaseReceiptUserInfo];
    [dic setObject:[[NSNumber numberWithDouble:self.price] stringValue] forKey:kMNPurchaseReceiptPrice];
    if (self.productIdentifier) [dic setObject:self.productIdentifier forKey:kMNPurchaseReceiptProductIdentifier];
    if (self.transactionIdentifier) [dic setObject:self.transactionIdentifier forKey:kMNPurchaseReceiptTransactionIdentifier];
    if (self.applicationUsername) [dic setObject:self.applicationUsername forKey:kMNPurchaseReceiptApplicationUsername];
    if (self.originalTransactionIdentifier) [dic setObject:self.originalTransactionIdentifier forKey:kMNPurchaseReceiptOriginalTransactionIdentifier];
    [dic setObject:self.transactionDate forKey:kMNPurchaseReceiptTransactionDate];
    [dic setObject:self.originalTransactionDate forKey:kMNPurchaseReceiptOriginalTransactionDate];
    return dic.copy;
}

+ (NSMutableArray <MNPurchaseReceipt *>*)receipts {
    static NSMutableArray <MNPurchaseReceipt *>*purchase_receipts;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        purchase_receipts = @[].mutableCopy;
        NSData *receiptData = [NSUserDefaults.standardUserDefaults dataForKey:kMNPurchaseReceipts];
        if (receiptData.length) {
            NSArray <NSDictionary *>*receipts = [NSJSONSerialization JSONObjectWithData:receiptData options:kNilOptions error:nil];
            [receipts enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MNPurchaseReceipt *receipt = [MNPurchaseReceipt receiptWithDictionary:obj];
                if (receipt) [purchase_receipts addObject:receipt];
            }];
        }
    });
    return purchase_receipts;
}

+ (NSInteger)localCount {
    return MAX(0, MN_PURCHASE_RECEIPT.count);
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeDouble:self.price forKey:kMNPurchaseReceiptPrice];
    [coder encodeObject:self.content forKey:kMNPurchaseReceiptContent];
    [coder encodeObject:self.userInfo forKey:kMNPurchaseReceiptUserInfo];
    [coder encodeObject:self.identifier forKey:kMNPurchaseReceiptIdentifier];
    [coder encodeObject:self.transactionDate forKey:kMNPurchaseReceiptTransactionDate];
    [coder encodeObject:self.productIdentifier forKey:kMNPurchaseReceiptProductIdentifier];
    [coder encodeObject:self.transactionIdentifier forKey:kMNPurchaseReceiptTransactionIdentifier];
    [coder encodeObject:self.applicationUsername forKey:kMNPurchaseReceiptApplicationUsername];
    [coder encodeObject:self.originalTransactionDate forKey:kMNPurchaseReceiptOriginalTransactionDate];
    [coder encodeObject:self.originalTransactionIdentifier forKey:kMNPurchaseReceiptOriginalTransactionIdentifier];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.price = [coder decodeDoubleForKey:kMNPurchaseReceiptPrice];
        self.content = [coder decodeObjectForKey:kMNPurchaseReceiptContent];
        self.userInfo = [coder decodeObjectForKey:kMNPurchaseReceiptUserInfo];
        self.identifier = [coder decodeObjectForKey:kMNPurchaseReceiptIdentifier];
        self.transactionDate = [coder decodeObjectForKey:kMNPurchaseReceiptTransactionDate];
        self.productIdentifier = [coder decodeObjectForKey:kMNPurchaseReceiptProductIdentifier];
        self.transactionIdentifier = [coder decodeObjectForKey:kMNPurchaseReceiptTransactionIdentifier];
        self.applicationUsername = [coder decodeObjectForKey:kMNPurchaseReceiptApplicationUsername];
        self.originalTransactionDate = [coder decodeObjectForKey:kMNPurchaseReceiptOriginalTransactionDate];
        self.originalTransactionIdentifier = [coder decodeObjectForKey:kMNPurchaseReceiptOriginalTransactionIdentifier];
    }
    return self;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    MNPurchaseReceipt *receipt = [MNPurchaseReceipt allocWithZone:zone];
    receipt.local = _local;
    receipt.price = _price;
    receipt.restore = _restore;
    receipt.content = _content;
    receipt.userInfo = _userInfo;
    receipt.identifier = _identifier;
    receipt.checkoutCount = _checkoutCount;
    receipt.transactionDate = _transactionDate;
    receipt.productIdentifier = _productIdentifier;
    receipt.transactionIdentifier = _transactionIdentifier;
    receipt.applicationUsername = _applicationUsername;
    receipt.originalTransactionDate = _originalTransactionDate;
    receipt.originalTransactionIdentifier = _originalTransactionIdentifier;
    return receipt;
}

@end
