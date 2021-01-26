//
//  NSData+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/8/4.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSData+MNHelper.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (MNHelper)

#pragma mark - NSData Path
+ (NSData *)dataWithResource:(NSString *)name ofType:(NSString *)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    if (!path) return nil;
    return [NSData dataWithContentsOfFile:path];
}

+ (NSData *)dataWithResource:(NSString *)name ofType:(NSString *)type inDirectory:(NSString *)directory {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type inDirectory:directory];
    if (!path) return nil;
    return [NSData dataWithContentsOfFile:path];
}

#pragma mark - 归档
+ (NSData *)archivedDataWithRootObject:(id)obj {
    if (obj && [obj conformsToProtocol:@protocol(NSCoding)] && [obj respondsToSelector:@selector(encodeWithCoder:)]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 120000
        if (@available(iOS 12.0, *)) {
            return [NSKeyedArchiver archivedDataWithRootObject:obj requiringSecureCoding:YES error:nil];
        }
#endif
        return [NSKeyedArchiver archivedDataWithRootObject:obj];
    }
    return nil;
}

#pragma mark - 解档
- (id)unarchivedObject {
    if (self.length <= 0) return nil;
    return [NSKeyedUnarchiver unarchiveObjectWithData:self];
}

- (id)unarchivedObjectOfClass:(Class)cls {
    if (self.length > 0 && cls && [cls conformsToProtocol:@protocol(NSCoding)] && class_respondsToSelector(cls, @selector(initWithCoder:))) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 120000
        if (@available(iOS 12.0, *)) {
            return [NSKeyedUnarchiver unarchivedObjectOfClass:cls fromData:self error:nil];
        }
#endif
        return [NSKeyedUnarchiver unarchiveObjectWithData:self];
    }
    return nil;
}

- (NSString *)UTF8EncodedString {
    if (self.length <= 0) return nil;
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

- (NSString *)base64EncodedString {
    if (self.length <= 0) return nil;
    return [self base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

#pragma mark - AES
- (NSData *)AES256Encrypt:(NSString *)key {
    if (key.length <= 0) return nil;
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                                kCCOptionPKCS7Padding | kCCOptionECBMode,
                                                keyPtr,
                                                kCCBlockSizeAES128,
                                                NULL,
                                                [self bytes],
                                                dataLength,
                                                buffer,
                                                bufferSize,
                                                &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

- (NSData *)AES256Decrypt:(NSString *)key {
    if (key.length <= 0) return nil;
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                                kCCOptionPKCS7Padding | kCCOptionECBMode,
                                                keyPtr, kCCBlockSizeAES128,
                                                NULL,
                                                [self bytes],
                                                dataLength,
                                                buffer,
                                                bufferSize,
                                                &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

- (NSData *)AES128Encrypt:(NSString *)key {
    if (key.length <= 0) return nil;
    char keyPtr[kCCKeySizeAES128+1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

- (NSData *)AES128Decrypt:(NSString *)key {
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
    }
    free(buffer);
    return nil;
}

+ (NSData*)dataWithHexString:(NSString*)hexString {
    if (hexString == nil) return nil;
    const char* ch = [[hexString lowercaseString] cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* data = [NSMutableData data];
    while (*ch) {
        if (*ch == ' ') continue;
        char byte = 0;
        if ('0' <= *ch && *ch <= '9') {
            byte = *ch - '0';
        } else if ('a' <= *ch && *ch <= 'f') {
            byte = *ch - 'a' + 10;
        } else if ('A' <= *ch && *ch <= 'F') {
            byte = *ch - 'A' + 10;
        }
        ch++;
        byte = byte << 4;
        if (*ch) {
            if ('0' <= *ch && *ch <= '9') {
                byte += *ch - '0';
            } else if ('a' <= *ch && *ch <= 'f') {
                byte += *ch - 'a' + 10;
            } else if('A' <= *ch && *ch <= 'F'){
                byte += *ch - 'A' + 10;
            }
            ch++;
        }
        [data appendBytes:&byte length:1];
    }
    return data.copy;
}

#pragma mark - XOR异或加解密
- (NSData *)XOREncrypt:(NSString *)key {
    if (!key || key.length <= 0) return self;
    // 获取key的长度
    NSInteger length = key.length;
    // 将OC字符串转换为C字符串
    const char *keys = [key cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cKey[length];
    memcpy(cKey, keys, length);
    // 获取字节指针
    const Byte *point = self.bytes;
    // 数据初始化，空间未分配 配合使用 appendBytes
    NSMutableData *encryptData = [[NSMutableData alloc] initWithCapacity:length];
    for (int i = 0; i < self.length; i++) {
        int m = i % length; // 算出当前位置字节，要和密钥的异或运算的密钥字节
        char c = cKey[m]; // 取出密码位
        Byte b = (Byte)((point[i])^c); // 异或运算
        [encryptData appendBytes:&b length:1]; // 追加字节
    }
    return encryptData.copy;
}

- (NSData *)XOREncrypt:(NSString *)key length:(NSUInteger)encryptLength {
    NSUInteger length = self.length;
    if (length <= 0 || encryptLength <= 0 || key.length <= 0) return self;
    NSMutableData *mutableData = self.mutableCopy;
    if (length > encryptLength) {
        NSData *subData = [[mutableData subdataWithRange:NSMakeRange(0, encryptLength)] XOREncrypt:key];
        [mutableData replaceBytesInRange:NSMakeRange(0, encryptLength) withBytes:subData.bytes length:encryptLength];
    } else {
        NSData *subData = [self XOREncrypt:key];
        [mutableData replaceBytesInRange:NSMakeRange(0, length) withBytes:subData.bytes length:subData.length];
    }
    return mutableData.copy;
}

@end
