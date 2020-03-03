//
//  NSString+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2017/11/14.
//  Copyright © 2017年 小斯. All rights reserved.
//  自符串处理

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MNReplaceBlankString(string) \
if ([NSString isBlankString:string]) {\
    string = @"";\
}\

#define MNReplaceBlankStringWithString(string, replace) \
if ([NSString isBlankString:string]) {\
    string = replace;\
}\

#define NSStringEmpty(string) \
[NSString replacingBlankCharacter:string withCharacter:@""] \

#define NSStringWithFormat(format, ...) \
[NSString stringWithFormat:format,##__VA_ARGS__]


@interface NSString (MNBlanking)

/**
 *判断字符串是否为空指针(或空字符串)
 *@param string 需要判断的字符串
 *@return 是否为空或空字符串
 */
+ (BOOL)isBlankString:(NSString *)string;
BOOL NSStringBlanking(NSString *string);

/**
 修复空字符串指针
 @param string 字符串指针
 */
+ (void)replacingBlankString:(NSString **)string;
void NSStringReplaceBlankString (NSString **string);

/**
 *修复空字符串指针指向指定字符串
 *@param string 需要修复的字符串指针
 *@param replaceString 指定字符串
 */
+ (void)replacingBlankString:(NSString **)string withString:(NSString *)replaceString;
void NSStringReplaceBlankStringWithString (NSString **string, NSString *replaceString);

/**
 返回不为空的字符串<不修改原值>
 @param character 字符串
 @return 不为空字符串
 */
+ (NSString *)replacingBlankCharacter:(NSString *)character;

/**
 返回不为空的字符串<不修改原值>
 @param aCharacter 字符串
 @param bCharacter 默认值字符串
 @return 不为空字符串
 */
+ (NSString *)replacingBlankCharacter:(NSString *)aCharacter withCharacter:(NSString *)bCharacter;

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
- (NSString *)stringByInsertString:(NSString *)aString atString:(NSString *)bString;

/**
 删除字符
 @param range 位置
 @return 新字符串
 */
- (NSString *)stringByDeleteCharactersInRange:(NSRange)range;

@end


@interface NSString (MNSize)

/**
 * 获取字符串Size(单行)
 *@param string 字符串
 *@param fontSize   字体大小
 *@return          字符串size
 */
+ (CGSize)getStringSize:(NSString *)string fontSize:(CGFloat)fontSize;
- (CGSize)sizeWithFontSize:(CGFloat)fontSize;
CGSize NSStringSizeWithFontSize (NSString *string, CGFloat fontSize);

/**
 获取字符串Size(单行)
 @param string 字符串
 @param font 字体
 @return 字符串Size
 */
+ (CGSize)getStringSize:(NSString *)string font:(UIFont *)font;
- (CGSize)sizeWithFont:(UIFont *)font;
CGSize NSStringSizeWithFont (NSString *string, UIFont *font);

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

CGSize NSStringBoundingSize (NSString *string, CGSize size, NSDictionary *attributes);

@end


@interface NSString (MNHelper)
/**
 获取自身Range
 */
@property (nonatomic, readonly) NSRange rangeOfAll;
/**
 获取以自身为名称的图片
 */
@property (nonatomic, readonly, strong) UIImage *image;
/**
 获取自身的富文本形式
 */
@property (nonatomic, readonly, strong) NSAttributedString *attributedString;

/**
 获取基本数据类型字符串
 @param number 基本数据类型Number形式
 @return 字符串
 */
NSString * NSStringFromNumber (NSNumber *number);

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
 @return 是否纯数字
 */
- (BOOL)isNumberString;

/**
 生成随机汉字字符串
 @param length 字符串长度
 @return 随机字符串
 */
+ (NSString *)generateChineseWithLength:(NSUInteger)length;

@end
