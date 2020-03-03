//
//  UIFont+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/12/12.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIFontSystemFontName  @"SFUIText"

@interface UIFont (MNHelper)

/**
 获取字体
 @param fontName 字体名
 @param fontSize 字号
 @return 字体(nullable)
 */
UIFont * UIFontWithNameSize (NSString *fontName, CGFloat fontSize);

/**
 注册字体
 @param path 字体文件路径
 @return 是否注册成功
 */
+ (BOOL)registFontWithPath:(NSString *)path;
BOOL UIFontRegistAtPath (NSString *path);

/**
 解决版本限制问题
 8_2之前使用系统字体
 @param fontSize 字号 UIFontWeight
 @param weights 字体
 @return 系统字体
 */
+ (UIFont *)systemFontOfSizes:(CGFloat)fontSize weights:(CGFloat)weights;

/**
 比较字体大小,名称是否相同
 @param font 与之比较的字体
 @return 比较结果
 */
- (BOOL)isEqualFont:(UIFont *)font;

/**
 系统默认字体
 @param fontSize 字号
 @return 默认字体
 */
UIFont * UIFontSystem (CGFloat fontSize);

/**
 系统默认字体<中粗体>
 @param fontSize 字号
 @return 默认中粗字体
 */
UIFont * UIFontSystemMedium (CGFloat fontSize);

/**
 平方细体
 @param fontSize 字号
 @return 平方细体
 */
UIFont * UIFontLight (CGFloat fontSize);

/**
 平方常规体
 @param fontSize 字号
 @return 平方常规体
 */
UIFont * UIFontRegular (CGFloat fontSize);

/**
 平方中黑体
 @param fontSize 字号
 @return 平方中黑体
 */
UIFont * UIFontMedium (CGFloat fontSize);

/**
 平方中粗体
 @param fontSize 字号
 @return 平方中粗体
 */
UIFont * UIFontSemibold (CGFloat fontSize);

@end

