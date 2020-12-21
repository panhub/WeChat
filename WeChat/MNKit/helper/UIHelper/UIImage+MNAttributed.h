//
//  UIImage+MNAttributed.h
//  MNFoundation
//
//  Created by Vicent on 2020/10/11.
//  拼接富文本

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MNAttributed)

/**
 获取图片的富文本形式
 @param imageFont 指定大小
 @return 图片富文本
*/
- (NSAttributedString *)attachmentWithFont:(UIFont *)imageFont;

/**
 获取图片的富文本形式
 @param string 拼接字符串
 @param textFont 指定文字大小
 @param textColor 指定文字颜色
 @param resizing 调整图片大小
 @return 图片富文本
*/
- (NSAttributedString *)appendString:(NSString *_Nullable)string font:(UIFont *)textFont color:(UIColor *_Nullable)textColor resizing:(CGFloat)resizing;

/**
 获取图片的富文本形式
 @param string 插入字符串
 @param textFont 指定文字大小
 @param textColor 指定文字颜色
 @param resizing 调整图片大小
 @return 图片富文本
*/
- (NSAttributedString *)insertString:(NSString *_Nullable)string font:(UIFont *)textFont color:(UIColor *_Nullable)textColor resizing:(CGFloat)resizing;

@end

NS_ASSUME_NONNULL_END
