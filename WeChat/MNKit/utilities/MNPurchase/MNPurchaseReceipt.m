//
//  MNPurchaseReceipt.m
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPurchaseReceipt.h"
#if __has_include("MNKeyChain.h")
#import "MNKeyChain.h"
#endif

#define kMNPurchaseReceipts    @"com.mn.purchase.receipts.key"
#define kMNPurchaseReceiptContent    @"receipt"
#define kMNPurchaseReceiptProductIdentifier    @"productIdentifier"
#define kMNPurchaseReceiptTransactionIdentifier    @"transactionIdentifier"
#define kMNPurchaseReceiptSubscribe    @"subscribe"
#define kMNPurchaseReceiptRestore    @"restore"
#define kMNPurchaseReceiptFailCount    @"failCount"
#define kMNPurchaseReceiptUserInfo    @"userInfo"
#define MNPurchaseReceiptArchivePath  [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:NSStringFromClass(MNPurchaseReceipt.class)]

@interface MNPurchaseReceipt ()
@property (nonatomic, copy) NSString *content;
@property (nonatomic, readonly, class) NSMutableArray <MNPurchaseReceipt *>*receipts;
@end

@implementation MNPurchaseReceipt
+ (instancetype)receiptWithData:(NSData *)receiptData {
    NSString *content = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    if (content.length <= 0) return nil;
    MNPurchaseReceipt *receipt = MNPurchaseReceipt.new;
    receipt.content = content;
    return receipt;
}

+ (instancetype)receiptWithDictionary:(NSDictionary *)json {
    if ([json objectForKey:kMNPurchaseReceiptContent] == nil) return nil;
    MNPurchaseReceipt *receipt = MNPurchaseReceipt.new;
    receipt.content = [json objectForKey:kMNPurchaseReceiptContent];
    receipt.productIdentifier = [json objectForKey:kMNPurchaseReceiptProductIdentifier];
    receipt.transactionIdentifier = [json objectForKey:kMNPurchaseReceiptTransactionIdentifier];
    receipt.userInfo = [json objectForKey:kMNPurchaseReceiptUserInfo];
    receipt.failCount = [[json objectForKey:kMNPurchaseReceiptFailCount] intValue];
    receipt.subscribe = [[json objectForKey:kMNPurchaseReceiptSubscribe] boolValue];
    receipt.restore = [[json objectForKey:kMNPurchaseReceiptRestore] boolValue];
    return receipt;
}

+ (NSMutableArray <MNPurchaseReceipt *>*)receipts {
    static NSMutableArray <MNPurchaseReceipt *>*receiptCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        receiptCache = @[].mutableCopy;
        NSData *receiptData;
#if __has_include("MNKeyChain.h")
        receiptData = [MNKeyChain dataForKey:kMNPurchaseReceipts];
#elif USE_ICLOUD_STORAGE
        receiptData = [NSUbiquitousKeyValueStore.defaultStore dataForKey:kMNPurchaseReceipts];
#else
        receiptData = [NSUserDefaults.standardUserDefaults dataForKey:kMNPurchaseReceipts];
#endif
        if (receiptData.length) {
            NSArray <NSDictionary *>*receipts = [NSJSONSerialization JSONObjectWithData:receiptData options:kNilOptions error:nil];
            [receipts enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MNPurchaseReceipt *r = [MNPurchaseReceipt receiptWithDictionary:obj];
                if (r) [receiptCache addObject:r];
            }];
        }
    });
    return receiptCache;
}

+ (NSArray <MNPurchaseReceipt *>*)localReceipts {
    return self.receipts.copy;
}

- (BOOL)saveReceiptToLocal {
    if (self.content.length <= 0) return NO;
    if ([MNPurchaseReceipt containsReceipt:self]) return YES;
    [MNPurchaseReceipt.receipts addObject:self];
    return [MNPurchaseReceipt updateLocalReceipts];
}

- (BOOL)removeFromLocal {
    MNPurchaseReceipt *receipt = [MNPurchaseReceipt receiptForContent:self.content];
    if (!receipt) return YES;
    [MNPurchaseReceipt.receipts removeObject:receipt];
    return [MNPurchaseReceipt updateLocalReceipts];
}

+ (BOOL)removeLocalReceipts {
    // 尝试两次
    [self.receipts removeAllObjects];
#if __has_include("MNKeyChain.h")
    if ([MNKeyChain removeItemForKey:kMNPurchaseReceipts]) return YES;
    return [MNKeyChain removeItemForKey:kMNPurchaseReceipts];
#elif USE_ICLOUD_STORAGE
    [NSUbiquitousKeyValueStore.defaultStore removeObjectForKey:kMNPurchaseReceipts];
#else
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kMNPurchaseReceipts];
#endif
    return YES;
}

+ (BOOL)updateLocalReceipts {
    // 尝试两次
    if (self.receipts.count <= 0) return [self removeLocalReceipts];
    NSMutableArray <NSDictionary *>*receipts = @[].mutableCopy;
    [self.receipts enumerateObjectsUsingBlock:^(MNPurchaseReceipt * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [receipts addObject:[obj jsonValue]];
    }];
    NSData *receiptData = [NSJSONSerialization dataWithJSONObject:receipts options:kNilOptions error:nil];
    if (receiptData.length <= 0) return NO;
#if __has_include("MNKeyChain.h")
    if ([MNKeyChain setData:receiptData forKey:kMNPurchaseReceipts]) return YES;
    return [MNKeyChain setData:receiptData forKey:kMNPurchaseReceipts];
#elif USE_ICLOUD_STORAGE
    [NSUbiquitousKeyValueStore.defaultStore setData:receiptData forKey:kMNPurchaseReceipts];
#else
    [NSUserDefaults.standardUserDefaults setObject:receiptData forKey:kMNPurchaseReceipts];
#endif
    return YES;
}

+ (BOOL)updateLocalReceiptCompulsory:(NSArray <MNPurchaseReceipt *>*)receipts {
    [self.receipts removeAllObjects];
    if (receipts && receipts.count) [self.receipts addObjectsFromArray:receipts];
    return [self updateLocalReceipts];
}

#pragma mark - Getter
- (NSString *)productIdentifier {
    if (_productIdentifier.length) return _productIdentifier;
    return @"com.mn.purchase.receipt.product.identifier";
}

- (NSString *)transactionIdentifier {
    if (_transactionIdentifier.length) return _transactionIdentifier;
    return @"com.mn.purchase.receipt.transaction.identifier";
}

- (BOOL)isEqualToReceipt:(MNPurchaseReceipt *)receipt {
    if (!receipt) return NO;
    return ([self.productIdentifier isEqualToString:receipt.productIdentifier] && [self.content isEqualToString:receipt.content]);
}

- (NSDictionary *)jsonValue {
    NSMutableDictionary *dic = @{}.mutableCopy;
    [dic setObject:self.content forKey:kMNPurchaseReceiptContent];
    [dic setObject:@(self.failCount).stringValue forKey:kMNPurchaseReceiptFailCount];
    [dic setObject:@(self.isRestore).stringValue forKey:kMNPurchaseReceiptRestore];
    [dic setObject:@(self.isSubscribe).stringValue forKey:kMNPurchaseReceiptSubscribe];
    [dic setObject:self.productIdentifier forKey:kMNPurchaseReceiptProductIdentifier];
    [dic setObject:self.transactionIdentifier forKey:kMNPurchaseReceiptTransactionIdentifier];
    if (self.userInfo) [dic setObject:self.userInfo forKey:kMNPurchaseReceiptUserInfo];
    return dic.copy;
}

+ (BOOL)containsReceipt:(MNPurchaseReceipt *)receipt {
    if (!receipt) return NO;
    __block BOOL exists = NO;
    [self.localReceipts enumerateObjectsUsingBlock:^(MNPurchaseReceipt * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToReceipt:receipt]) {
            exists = YES;
            *stop = YES;
        }
    }];
    return exists;
}

+ (MNPurchaseReceipt *)receiptForContent:(NSString *)content {
    if (content.length <= 0) return nil;
    __block MNPurchaseReceipt *receipt;
    [self.localReceipts enumerateObjectsUsingBlock:^(MNPurchaseReceipt * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.content isEqualToString:content]) {
            receipt = obj;
            *stop = YES;
        }
    }];
    return receipt;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.content forKey:kMNPurchaseReceipts];
    [coder encodeBool:self.isSubscribe forKey:kMNPurchaseReceiptSubscribe];
    [coder encodeBool:self.isRestore forKey:kMNPurchaseReceiptRestore];
    [coder encodeInt:self.failCount forKey:kMNPurchaseReceiptFailCount];
    [coder encodeObject:self.productIdentifier forKey:kMNPurchaseReceiptProductIdentifier];
    [coder encodeObject:self.transactionIdentifier forKey:kMNPurchaseReceiptTransactionIdentifier];
    [coder encodeObject:self.userInfo forKey:kMNPurchaseReceiptUserInfo];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.content = [coder decodeObjectForKey:kMNPurchaseReceipts];
        self.restore = [coder decodeBoolForKey:kMNPurchaseReceiptRestore];
        self.failCount = [coder decodeIntForKey:kMNPurchaseReceiptFailCount];
        self.subscribe = [coder decodeBoolForKey:kMNPurchaseReceiptSubscribe];
        self.productIdentifier = [coder decodeObjectForKey:kMNPurchaseReceiptProductIdentifier];
        self.transactionIdentifier = [coder decodeObjectForKey:kMNPurchaseReceiptTransactionIdentifier];
        self.userInfo = [coder decodeObjectForKey:kMNPurchaseReceiptUserInfo];
    }
    return self;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    MNPurchaseReceipt *receipt = MNPurchaseReceipt.new;
    receipt.content = self.content;
    receipt.productIdentifier = self.productIdentifier;
    receipt.transactionIdentifier = self.transactionIdentifier;
    receipt.userInfo = self.userInfo;
    receipt.failCount = self.failCount;
    receipt.subscribe = self.subscribe;
    receipt.restore = self.restore;
    return receipt;
}

@end


@implementation MNPurchaseReceipt (MNPurchaseSubmiting)

- (int)submitCount {
    NSNumber *n = objc_getAssociatedObject(self, @"com.mn.purchase.receipt.submit.count");
    if (n) return n.intValue;
    return 0;
}

- (void)setSubmitCount:(int)submitCount {
    objc_setAssociatedObject(self, @"com.mn.purchase.receipt.submit.count", @(submitCount), OBJC_ASSOCIATION_COPY);
}

@end
