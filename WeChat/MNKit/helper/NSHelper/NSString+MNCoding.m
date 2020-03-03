//
//  NSString+MNMD5.m
//  MNKit
//
//  Created by Vincent on 2018/11/8.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSString+MNCoding.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MNCoding)
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

@end
