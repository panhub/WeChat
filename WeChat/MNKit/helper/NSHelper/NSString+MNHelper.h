//
//  NSString+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2017/11/14.
//  Copyright © 2017年 小斯. All rights reserved.
//  自符串处理

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MNReplacingEmptyStringWith(string, replace) \
if ([NSString isEmptyString:string]) {\
    string = replace;\
}

#define MNReplacingEmptyString(string)  MNReplacingEmptyStringWith(string, @"")

#define NSStringWithFormat(format, ...) \
[NSString stringWithFormat:format,##__VA_ARGS__]

NS_ASSUME_NONNULL_BEGIN
@interface NSString (MNEmptying)
/**
 *判断字符串是否为空指针(或空字符串)
 *@param string 需要判断的字符串
 *@return 是否为空或空字符串
 */
+ (BOOL)isEmptyString:(NSString *_Nullable)string;
FOUNDATION_EXPORT BOOL NSStringIsEmpty(NSString *_Nullable string);

/**
 修复空字符串指针
 @param string 字符串指针
 */
+ (void)replacingEmptyString:(NSString *_Nullable*_Nullable)string;
FOUNDATION_EXPORT void NSStringReplacingEmpty(NSString *_Nullable*_Nullable string);

/**
 *修复空字符串指针指向指定字符串
 *@param string 需要修复的字符串指针
 *@param replaceString 指定字符串
 */
+ (void)replacingEmptyString:(NSString *_Nullable*_Nullable)string withString:(NSString *)replaceString;
FOUNDATION_EXPORT void NSStringReplacingEmptyWith(NSString *_Nullable*_Nullable string, NSString *replaceString);

/**
 返回不为空的字符串<不修改原值>
 @param string 字符串
 @return 不为空字符串
 */
+ (NSString *)replacingEmptyCharacters:(NSString *_Nullable)string;

/**
 返回不为空的字符串<不修改原值>
 @param aCharacters 字符串
 @param bCharacters 默认值字符串
 @return 不为空字符串
 */
+ (NSString *)replacingEmptyCharacters:(NSString *_Nullable)aCharacters withCharacters:(NSString *)bCharacters;

/**
 在指定位置插入字符串
 @param aString 字符串
 @param loc 位置
 @return 新字符串
 */
- (NSString *)stringByInsertString:(NSString *)aString atIndex:(NSUInteger)loc;

/**
 在指定字符串后插入字符串
 @param aString 插入字符串
 @param bString 字符串之后
 @return 新字符串
 */
- (NSString *)stringByInsertString:(NSString *)aString afterString:(NSString *)bString;

/**
 删除字符
 @param range 位置
 @return 新字符串
 */
- (NSString *)stringByDeleteCharactersInRange:(NSRange)range;

/**
 拼接字符串
 @param string 拼接的字符串
 @return 拼接后的字符串
 */
- (NSString *)stringByAppendString:(NSString *)string;

@end


@interface NSString (MNSize)

/**
 * 获取字符串Size(单行)
 *@param string 字符串
 *@param fontSize   字体大小
 *@return          字符串size
 */
+ (CGSize)stringSize:(NSString *)string fontSize:(CGFloat)fontSize;
- (CGSize)sizeWithFontSize:(CGFloat)fontSize;
FOUNDATION_EXPORT CGSize NSStringSizeWithFontSize (NSString *string, CGFloat fontSize);

/**
 获取字符串Size(单行)
 @param string 字符串
 @param font 字体
 @return 字符串Size
 */
+ (CGSize)stringSize:(NSString *)string font:(UIFont *)font;
- (CGSize)sizeWithFont:(UIFont *)font;
FOUNDATION_EXPORT CGSize NSStringSizeWithFont (NSString *string, UIFont *font);

/**
 * 获取字符大小(多行)
 *@param string 字符串
 *@param size   自动调整长宽最大值
 *@return          字符串size
 */
+ (CGSize)boundingSizeWithString:(NSString *)string
                            size:(CGSize)size
                      attributes:(NSDictionary *)attributes;
- (CGSize)boundingSize:(CGSize)size attributes:(NSDictionary *)attributes;
FOUNDATION_EXPORT CGSize NSStringBoundingSize (NSString *string, CGSize size, NSDictionary *attributes);

@end


@interface NSString (MNHelper)
/**
 获取自身Range
 */
@property (nonatomic, readonly) NSRange rangeOfAll;
/**
 是否是数字字符串
 */
@property (nonatomic, readonly) BOOL isNumberString;
/**
 获取以自身为名称的图片
 */
@property (nonatomic, readonly, strong, nullable) UIImage *image;
/**
 获取自身的富文本形式
 */
@property (nonatomic, readonly, strong) NSAttributedString *attributedString;

/**
 获取基本数据类型字符串
 @param number 基本数据类型Number形式
 @return 字符串
 */
FOUNDATION_EXPORT NSString *NSStringFromNumber (NSNumber *number);

/**
 *获取UUID
 *@return UUID
 */
+ (NSString *)UUIDString;

/**
 语言本地化处理
 @return 本地化字符串
 */
- (NSString *)localizedString;

/**
 语言本地化处理
 @param string string
 @return 本地化
 */
+ (NSString *)localizedString:(NSString *)string;

/**
 是否纯数字字符串
 @param string 指定字符串
 @return 是否纯数字
 */
+ (BOOL)isNumberString:(NSString *)string;

/**
 生成随机汉字字符串
 @param length 字符串长度
 @return 随机字符串
 */
+ (NSString *)chineseWithLength:(NSUInteger)length;

/**
 分割字典
 @param separated 以指定字符分割部分
 @return 分割后字典
 */
- (NSDictionary <NSString *, NSString *>*_Nullable)componentsBySeparatedString:(NSString *)separated;

/**
 分割字典
 @param byString 以指定字符分割键值对
 @param separated 以指定字符分割部分
 @return 分割后字典
 */
- (NSDictionary <NSString *, NSString *>*_Nullable)componentsBy:(NSString *)byString separated:(NSString *)separated;

/**
 验证邮箱
 @param email 邮箱
 @return 是否符合邮箱格式
 */
+ (BOOL)evaluateEmail:(NSString *)email;

@end
NS_ASSUME_NONNULL_END
