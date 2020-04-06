//
//  MNPurchaseReceipt.m
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPurchaseReceipt.h"
#import "MNKeyChain.h"

#define kMNPurchaseReceipts    @"com.mn.purchase.receipts.key"
#define kMNPurchaseReceiptContent    @"receipt"
#define kMNPurchaseReceiptIdentifier    @"identifier"
#define kMNPurchaseReceiptSubscribe    @"subscribe"
#define kMNPurchaseReceiptRestore    @"restore"
#define kMNPurchaseReceiptFailCount    @"failCount"
#define kMNPurchaseReceiptHeader    @"header"
#define MNPurchaseReceiptArchivePath  [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:NSStringFromClass(MNPurchaseReceipt.class)]

@interface MNPurchaseReceipt ()
@property (nonatomic, copy) NSString *content;
@property (nonatomic, readonly, class) NSMutableArray <MNPurchaseReceipt *>*receipts;
@end

@implementation MNPurchaseReceipt
+ (instancetype)receiptWithData:(NSData *)receiptData {
    NSString *receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    if (receipt.length <= 0) return nil;
    MNPurchaseReceipt *r = MNPurchaseReceipt.new;
    r.content = receipt;
    return r;
}

+ (instancetype)receiptWithDictionary:(NSDictionary *)json {
    if ([json objectForKey:kMNPurchaseReceiptContent] == nil) return nil;
    MNPurchaseReceipt *r = MNPurchaseReceipt.new;
    r.content = [json objectForKey:kMNPurchaseReceiptContent];
    r.identifier = [json objectForKey:kMNPurchaseReceiptIdentifier];
    r.header = [json objectForKey:kMNPurchaseReceiptHeader];
    r.failCount = [[json objectForKey:kMNPurchaseReceiptFailCount] intValue];
    r.subscribe = [[json objectForKey:kMNPurchaseReceiptSubscribe] boolValue];
    r.restore = [[json objectForKey:kMNPurchaseReceiptRestore] boolValue];
    return r;
}

+ (NSMutableArray <MNPurchaseReceipt *>*)receipts {
    static NSMutableArray <MNPurchaseReceipt *>*receiptCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        receiptCache = @[].mutableCopy;
        NSData *receiptData = [MNKeyChain dataForKey:kMNPurchaseReceipts];
        if (receiptData.length) {
            NSArray *receipts = [NSJSONSerialization JSONObjectWithData:receiptData options:kNilOptions error:nil];
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
    [self.receipts removeAllObjects];
    return [MNKeyChain removeItemForKey:kMNPurchaseReceipts];
}

+ (BOOL)updateLocalReceipts {
    if (self.receipts.count <= 0) return [self removeLocalReceipts];
    NSMutableArray <NSDictionary *>*receipts = @[].mutableCopy;
    [self.receipts enumerateObjectsUsingBlock:^(MNPurchaseReceipt * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [receipts addObject:[obj jsonValue]];
    }];
    NSData *receiptData = [NSJSONSerialization dataWithJSONObject:receipts options:kNilOptions error:nil];
    if (receiptData.length <= 0) return NO;
    return [MNKeyChain setData:receiptData forKey:kMNPurchaseReceipts];
}

#pragma mark - Getter
- (NSString *)identifier {
    if (_identifier.length) return _identifier;
    return @"com.mn.purchase.receipt.identifier";
}

- (BOOL)isEqualToReceipt:(MNPurchaseReceipt *)receipt {
    if (!receipt) return NO;
    return ([self.identifier isEqualToString:receipt.identifier] && [self.content isEqualToString:receipt.content]);
}

- (NSDictionary *)jsonValue {
    NSMutableDictionary *dic = @{}.mutableCopy;
    [dic setObject:self.content forKey:kMNPurchaseReceiptContent];
    [dic setObject:@(self.failCount).stringValue forKey:kMNPurchaseReceiptFailCount];
    [dic setObject:@(self.isRestore).stringValue forKey:kMNPurchaseReceiptRestore];
    [dic setObject:@(self.isSubscribe).stringValue forKey:kMNPurchaseReceiptSubscribe];
    [dic setObject:self.identifier forKey:kMNPurchaseReceiptIdentifier];
    if (self.header) [dic setObject:self.header forKey:kMNPurchaseReceiptHeader];
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
    [coder encodeObject:self.identifier forKey:kMNPurchaseReceiptIdentifier];
    [coder encodeObject:self.header forKey:kMNPurchaseReceiptHeader];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.content = [coder decodeObjectForKey:kMNPurchaseReceipts];
        self.restore = [coder decodeBoolForKey:kMNPurchaseReceiptRestore];
        self.failCount = [coder decodeIntForKey:kMNPurchaseReceiptFailCount];
        self.subscribe = [coder decodeBoolForKey:kMNPurchaseReceiptSubscribe];
        self.identifier = [coder decodeObjectForKey:kMNPurchaseReceiptIdentifier];
        self.header = [coder decodeObjectForKey:kMNPurchaseReceiptHeader];
    }
    return self;
}

@end


@implementation MNPurchaseReceipt (MNPurchaseVerify)

- (int)tryCount {
    NSNumber *n = objc_getAssociatedObject(self, @"com.mn.purchase.receipt.try.count");
    if (n) return n.intValue;
    return 0;
}

- (void)setTryCount:(int)tryCount {
    objc_setAssociatedObject(self, @"com.mn.purchase.receipt.try.count", @(tryCount), OBJC_ASSOCIATION_COPY);
}

@end
