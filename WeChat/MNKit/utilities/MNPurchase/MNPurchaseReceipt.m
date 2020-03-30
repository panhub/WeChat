//
//  MNPurchaseReceipt.m
//  MNChat
//
//  Created by Vincent on 2019/10/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNPurchaseReceipt.h"
#import "MNKeyChain.h"

#define kMNPurchaseReceipt    @"com.mn.purchase.receipt.key"
#define kMNPurchaseReceiptString    @"receipt"
#define kMNPurchaseReceiptIdentifier    @"identifier"
#define kMNPurchaseReceiptSubscribe    @"subscribe"
#define kMNPurchaseReceiptRestore    @"restore"
#define MNPurchaseReceiptArchivePath  [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:NSStringFromClass(MNPurchaseReceipt.class)]

@interface MNPurchaseReceipt ()
@property (nonatomic, copy) NSString *receipt;
@end

@implementation MNPurchaseReceipt
+ (nullable instancetype)receiptWithData:(NSData *)receiptData {
    NSString *receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    if (receipt.length <= 0) return nil;
    MNPurchaseReceipt *r = MNPurchaseReceipt.new;
    r.receipt = receipt;
    return r;
}

+ (instancetype)localReceipt {
    NSData *receiptData = [MNKeyChain dataForKey:kMNPurchaseReceipt];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:receiptData options:kNilOptions error:nil];
    if (dic.allKeys.count <= 0) return nil;
    //NSDictionary *dic = [NSUserDefaults.standardUserDefaults objectForKey:kMNPurchaseReceipt];
    NSString *receipt = [dic objectForKey:kMNPurchaseReceiptString];
    if (!receipt || receipt.length <= 0) return nil;
    BOOL restore = [[dic objectForKey:kMNPurchaseReceiptRestore] boolValue];
    BOOL subscribe = [[dic objectForKey:kMNPurchaseReceiptSubscribe] boolValue];
    NSString *identifier = [dic objectForKey:kMNPurchaseReceiptIdentifier];
    if (identifier.length <= 0) identifier = @"com.mn.purchase.receipt.identifier";
    MNPurchaseReceipt *r = MNPurchaseReceipt.new;
    r.identifier = identifier;
    r.receipt = receipt;
    r.restore = restore;
    r.subscribe = subscribe;
    return r;
    /*
    NSData *receiptData = [[NSData alloc] initWithContentsOfFile:MNPurchaseReceiptArchivePath];
    if (receiptData.length <= 0) return nil;
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 11.0, *)) {
        return [NSKeyedUnarchiver unarchivedObjectOfClass:self.class fromData:receiptData error:nil];
    } else {
        return [NSKeyedUnarchiver unarchiveObjectWithData:receiptData];
    }
    #else
    return [NSKeyedUnarchiver unarchiveObjectWithData:receiptData];
    #endif
    */
}

+ (BOOL)removeLocalReceipt {
    return [MNKeyChain removeItemForKey:kMNPurchaseReceipt];
    /*
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kMNPurchaseReceipt];
    return YES;
    */
    /*
    if ([NSFileManager.defaultManager fileExistsAtPath:MNPurchaseReceiptArchivePath] == NO) return YES;
    return [NSFileManager.defaultManager removeItemAtPath:MNPurchaseReceiptArchivePath error:nil];
    */
}

- (BOOL)saveReceiptToLocal {
    if (self.receipt.length <= 0) return NO;
    NSMutableDictionary *dic = @{}.mutableCopy;
    [dic setObject:self.receipt forKey:kMNPurchaseReceiptString];
    [dic setObject:@(self.isRestore) forKey:kMNPurchaseReceiptRestore];
    [dic setObject:@(self.isSubscribe) forKey:kMNPurchaseReceiptSubscribe];
    if (self.identifier.length) [dic setObject:self.identifier forKey:kMNPurchaseReceiptIdentifier];
    NSData *receiptData = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    if (receiptData.length <= 0) return NO;
    return [MNKeyChain setData:receiptData forKey:kMNPurchaseReceipt];
    /*
    [NSUserDefaults.standardUserDefaults setObject:dic.copy forKey:kMNPurchaseReceipt];
    [NSUserDefaults.standardUserDefaults synchronize];
    return YES;
    */
    /*
    NSData *receiptData = NSData.data;
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 11.0, *)) {
        receiptData = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:YES error:nil];
    } else {
        receiptData = [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    #else
    receiptData = [NSKeyedArchiver archivedDataWithRootObject:self];
    #endif
    return [receiptData writeToFile:MNPurchaseReceiptArchivePath atomically:YES];
    */
}

+ (BOOL)hasLocalReceipt {
    return self.localReceipt != nil;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.receipt forKey:kMNPurchaseReceipt];
    [coder encodeBool:self.subscribe forKey:kMNPurchaseReceiptSubscribe];
    [coder encodeObject:self.identifier forKey:kMNPurchaseReceiptIdentifier];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.receipt = [coder decodeObjectForKey:kMNPurchaseReceipt];
        self.subscribe = [coder decodeBoolForKey:kMNPurchaseReceiptSubscribe];
        self.identifier = [coder decodeObjectForKey:kMNPurchaseReceiptIdentifier];
    }
    return self;
}

@end
