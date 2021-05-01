//
//  NSString+MNMD5.m
//  MNKit
//
//  Created by Vincent on 2018/11/8.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSString+MNCoding.h"
#import "NSData+MNHelper.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (MNCoding)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma mark - MD5
- (NSString *)md5String {
    return [self md5String32];
}

- (NSString *)MD5String {
    return [self MD5String32];
}

- (NSString *)md5String16 {
    NSString *md5String = [self md5String32];
    NSString *string;
    for (int i = 0; i < 24; i++) {
        string = [md5String substringWithRange:NSMakeRange(8, 16)];
    }
    return string;
}

- (NSString *)MD5String16 {
    NSString *md5String = [self MD5String32];
    NSString *string;
    for (int i = 0; i < 24; i++) {
        string = [md5String substringWithRange:NSMakeRange(8, 16)];
    }
    return string;
}

- (NSString *)md5String32 {
    const char*input = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    return digest;
}

- (NSString *)MD5String32 {
    const char*input = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02X", result[i]];
    }
    return digest;
}

#pragma mark - UTF8
+ (NSString *)URLEncodedString:(NSString *)string {
    if (string.length <= 0) return @"";
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]%",
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

- (NSString *)URLEncodedString {
    if ([self respondsToSelector:NSSelectorFromString(@"stringByAddingPercentEncodingWithAllowedCharacters:")]) {
        return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    } else if ([self respondsToSelector:NSSelectorFromString(@"stringByAddingPercentEscapesUsingEncoding:")]) {
        return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return [NSString URLEncodedString:self];
}

inline NSString * NSStringURLEncoded (NSString *string) {
    return [string URLEncodedString];
}

+ (NSString *)URLDecodedString:(NSString *)string {
    if (string.length <= 0) return @"";
    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                 (__bridge CFStringRef)string,
                                                                                                 CFSTR(""),
                                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

- (NSString *)URLDecodedString {
    if ([self respondsToSelector:NSSelectorFromString(@"stringByRemovingPercentEncoding")]) {
        return [self stringByRemovingPercentEncoding];
    } else if ([self respondsToSelector:NSSelectorFromString(@"stringByReplacingPercentEscapesUsingEncoding:")]) {
        return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return [NSString URLDecodedString:self];
}

NSString * NSStringURLDecoded (NSString *string) {
    return [string URLDecodedString];
}

- (NSData *)UTF8EncodedData {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Base64
- (NSData *)base64DecodedData {
    return [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (NSString *)base64EncodedString {
    return self.UTF8EncodedData.base64EncodedString;
}

- (NSString *)base64DecodedString {
    return self.base64DecodedData.UTF8EncodedString;
}

- (UIImage *)base64DecodedImage {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (data.length <= 0) return nil;
    return [UIImage imageWithData:data];
}

#pragma mark - AES
- (NSString *)AES256Encrypt:(NSString *)key {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    //对数据进行加密
    NSData *result = [data AES256Encrypt:key];
    //转换为2进制字符串
    if (result && result.length > 0) {
        Byte *datas = (Byte*)[result bytes];
        NSMutableString *output = [NSMutableString stringWithCapacity:result.length * 2];
        for (int i = 0; i < result.length; i++) {
            [output appendFormat:@"%02x", datas[i]];
        }
        return output;
    }
    return nil;
}

- (NSString *)AES256Decrypt:(NSString *)key {
    //转换为2进制Data
    NSMutableData *data = [NSMutableData dataWithCapacity:self.length / 2];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [self length] / 2; i++) {
        byte_chars[0] = [self characterAtIndex:i*2];
        byte_chars[1] = [self characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    //对数据进行解密
    NSData* result = [data AES256Decrypt:key];
    if (result && result.length > 0) {
        return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSString *)AES128Encrypt:(NSString *)key {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    //对数据进行加密
    NSData *result = [data AES128Encrypt:key];
    if (result) return [NSString hexStringFromData:result];
    return nil;
}

- (NSString *)AES128Decrypt:(NSString *)key {
    // 转换数据流格式
    NSData *data = [NSData dataWithHexString:self];
    //对数据进行解密
    NSData *result = [data AES128Decrypt:key];
    if (result) return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    return nil;
}

+ (NSString *)hexStringFromData:(NSData *)data {
    Byte *bytes = (Byte *)[data bytes];
    // 下面是Byte 转换为16进制。
    NSString *hexStr = @"";
    for (int i=0; i<data.length; i++) {
        //16进制数
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];
        newHexStr = [newHexStr uppercaseString];
        if ([newHexStr length] == 1) {
            newHexStr = [NSString stringWithFormat:@"0%@",newHexStr];
        }
        hexStr = [hexStr stringByAppendingString:newHexStr];
    }
    return hexStr;
}
#pragma clang diagnostic pop
@end
