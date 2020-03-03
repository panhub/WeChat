//
//  NSString+MNMD5.h
//  MNKit
//
//  Created by Vincent on 2018/11/8.
//  Copyright © 2018年 小斯. All rights reserved.
//  MD5加密

#import <Foundation/Foundation.h>

@interface NSString (MNCoding)
#pragma mark - MD5
/**
 乱序后的md5小写加密
 @return md5加密字符串
 */
- (NSString *)md5String;

/**
 乱序后的md5大写加密
 @return md5加密字符串
 */
- (NSString *)MD5String;

/**
 16位小写加密
 @return 16位小写MD5加密字符串
 */
- (NSString *)md5String16;

/**
 16位大写加密
 @return 16位大写MD5加密字符串
 */
- (NSString *)MD5String16;

/**
 32位小写加密
 @return 32位小写MD5加密字符串
 */
- (NSString *)md5String32;

/**
 32位大写加密
 @return 32位大写MD5加密字符串
 */
- (NSString *)MD5String32;

#pragma mark - UTF8
/**
 *字符串编码
 *@param string 需要编码的字符串
 *@return 编码后的字符串
 */
+ (NSString *)URLEncodedString:(NSString *)string;
- (NSString *)URLEncodedString;
NSString * NSStringURLEncoded (NSString *string);


/**
 *字符串解码
 *@param string 需要解码的字符串
 *@return 解码后的字符串
 */
+ (NSString *)URLDecodedString:(NSString *)string;
- (NSString *)URLDecodedString;
NSString * NSStringURLDecoded (NSString *string);

/**
 字符串编码
 @return 二进制数据流
 */
- (NSData *)UTF8EncodedData;

#pragma mark - Base64

/**
 Base64编码的Data
 @return Base64编码的Data
 */
- (NSData *)base64DecodedData;

/**
 Base64编码
 @return Base64编码后字符串
 */
- (NSString *)base64EncodedString;

/**
 Base64解码
 @return Base64解码字符串
 */
- (NSString *)base64DecodedString;

/**
 Base64编码的字符串解码
 @return UIImage
 */
- (UIImage *)base64DecodedImage;

@end

