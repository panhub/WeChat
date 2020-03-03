//
//  NSString+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2017/11/14.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "NSString+MNHelper.h"

@implementation NSString (MNBlanking)
#pragma mark - 是否为空字符串
+ (BOOL)isBlankString:(NSString *)string {
    /** !string 等价于 (string == nil || string == NULL)*/
    if (!string ||
        [string length] <= 0 ||
        [string isKindOfClass:[NSNull class]] ||
        [string isEqual:[NSNull null]] ||
        [string isEqualToString:@""] ||
        [string isEqualToString:@"(null)"] ||
        [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

BOOL NSStringBlanking(NSString *string) {
    return [NSString isBlankString:string];
}

#pragma mark - 修改空字符串
+ (void)replacingBlankString:(NSString **)string {
    [self replacingBlankString:string withString:@""];
}

void NSStringReplaceBlankString (NSString **string) {
    [NSString replacingBlankString:string];
}

#pragma mark - 设置默认字符串
+ (void)replacingBlankString:(NSString **)string withString:(NSString *)replaceString {
    if ([self isBlankString:*string]) {
        *string = replaceString;
    }
}

void NSStringReplaceBlankStringWithString (NSString **string, NSString *replaceString) {
    [NSString replacingBlankString:string withString:replaceString];
}

#pragma mark - 返回不为空的字符串
+ (NSString *)replacingBlankCharacter:(NSString *)character {
    return [self replacingBlankCharacter:character withCharacter:@""];
}

+ (NSString *)replacingBlankCharacter:(NSString *)aCharacter withCharacter:(NSString *)bCharacter {
    return [self isBlankString:aCharacter] ? bCharacter : aCharacter;
}

#pragma mark - 编辑字符串
- (NSString *)stringByInsertString:(NSString *)aString atIndex:(NSUInteger)loc {
    if (aString.length <= 0) return self;
    if (self.length < loc) return [self stringByAppendingString:aString];
    NSMutableString *string = self.mutableCopy;
    [string insertString:aString atIndex:loc];
    return string.copy;
}

- (NSString *)stringByInsertString:(NSString *)aString atString:(NSString *)bString {
    if (aString.length <= 0 || bString.length <= 0) return self;
    NSRange range = [self rangeOfString:bString];
    if (range.location == NSNotFound) return self;
    return [self stringByInsertString:aString atIndex:(range.location + range.length)];
}

- (NSString *)stringByDeleteCharactersInRange:(NSRange)range {
    if (range.location == NSNotFound || self.length < range.location) return self;
    NSMutableString *string = self.mutableCopy;
    [string deleteCharactersInRange:range];
    return string.copy;
}

@end


@implementation NSString (MNSize)
#pragma mark - 获取字符串的size
+ (CGSize)getStringSize:(NSString *)string fontSize:(CGFloat)fontSize {
    if (fontSize <= .0f || [self isBlankString:string]) return CGSizeZero;
    return [string sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}];
}

- (CGSize)sizeWithFontSize:(CGFloat)fontSize {
    return [NSString getStringSize:self fontSize:fontSize];
}

CGSize NSStringSizeWithFontSize (NSString *string, CGFloat fontSize) {
    return [NSString getStringSize:string fontSize:fontSize];
}

+ (CGSize)getStringSize:(NSString *)string font:(UIFont *)font {
    if (!font || [self isBlankString:string]) return CGSizeZero;
    return [string sizeWithAttributes:@{NSFontAttributeName: font}];
}

- (CGSize)sizeWithFont:(UIFont *)font {
    return [NSString getStringSize:self font:font];
}

CGSize NSStringSizeWithFont (NSString *string, UIFont *font) {
    return [NSString getStringSize:string font:font];
}

#pragma mark - 获取字符串边界大小
+ (CGSize)boundingSizeWithString:(NSString *)string
                            size:(CGSize)size
                      attributes:(NSDictionary *)attributes {
    if (CGSizeEqualToSize(size, CGSizeZero) || NSStringBlanking(string)) return CGSizeZero;
    if (!attributes) attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.f]};
    return [string boundingRectWithSize:size
                                options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                             attributes:attributes
                                context:nil].size;
}

- (CGSize)boundingSize:(CGSize)size attributes:(NSDictionary *)attributes {
    return [NSString boundingSizeWithString:self size:size attributes:attributes];
}

CGSize NSStringBoundingSize (NSString *string, CGSize size, NSDictionary *attributes) {
    return [NSString boundingSizeWithString:string size:size attributes:attributes];
}

@end


@implementation NSString (MNHelper)

#pragma mark - 自身长度
- (NSRange)rangeOfAll {
    return NSMakeRange(0, self.length);
}

#pragma mark - 图片
- (UIImage *)image {
    return [UIImage imageNamed:self];
}

#pragma mark - 富文本
- (NSAttributedString *)attributedString {
    return [[NSAttributedString alloc] initWithString:self.copy];
}

#pragma mark - 获取Number类型字符串
NSString * NSStringFromNumber (NSNumber *number) {
    if (!number) return @"";
    return [NSString stringWithFormat:@"%@",number];
}

#pragma mark - UUID
+ (NSString *)UUIDString {
    /*
     理论上某一时空下是唯一的;
     比如在当前这一秒,全世界产生的UUID都是不一样的;
     当然同一台设备产生的UUID也是不一样的!
     */
    //[[NSUUID UUID] UUIDString]
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef stringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uuidString = (__bridge_transfer NSString *) stringRef;
    return uuidString;
}

#pragma mark - 语言本地化处理
- (NSString *)localizedString {
    return NSLocalizedString(self, @"_localized_");
}

+ (NSString *)localizedString:(NSString *)string {
    return NSLocalizedString(string, @"_localized_");
}

#pragma mark - 是否纯数字字符串
- (BOOL)isNumberString {
    NSCharacterSet *characters = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [self rangeOfCharacterFromSet:characters].location == NSNotFound;
}

#pragma mark - 生成随机汉字
+ (NSString *)generateChineseWithLength:(NSUInteger)length {
    if (length <= 0) return @"";
    NSMutableString *result =@"".mutableCopy;
    for (int idx = 0; idx < length; idx++) {
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSInteger H = 0xA1 + arc4random()%(0xFE - 0xA1 + 1);
        NSInteger L = 0xB0 + arc4random()%(0xF7 - 0xB0 + 1);
        NSInteger count = (H << 8) + L;
        NSData *data = [NSData dataWithBytes:&count length:2];
        NSString *string = [[NSString alloc] initWithData:data encoding:encoding];
        [result appendString:string];
    }
    return result.copy;
}

@end
