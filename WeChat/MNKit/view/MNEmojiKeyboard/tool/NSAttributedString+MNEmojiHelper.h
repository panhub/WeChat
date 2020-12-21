//
//  NSMutableAttributedString+MNEmojiHelper.h
//  MNKit
//
//  Created by Vincent on 2019/2/7.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNEmojiBackedString.h"
@class MNEmojiAttachment;

#define MNEmojiNormalFont   [UIFont systemFontOfSize:16.f]

@interface NSAttributedString (MNEmojiHelper)

/**
 表情富文本转文字内容
 @return 文字内容
 */
- (NSString *)emoji_plainText;

/**
 表情富文本转文字内容
 @param range 范围
 @return 文字内容
 */
- (NSString *)emoji_plainTextForRange:(NSRange)range;

/**
 获取自身Range
 @return 自身Range
 */
- (NSRange)rangeOfAll;

/**
 制作表情富文本
 @param string 文本内容
 @param font 字体大小
 @return 表情富文本
 */
+ (NSAttributedString *)emojiAttributedStringWithString:(NSString *)string font:(UIFont *)font;

/**
 制作Label富文本
 @param string 文字内容
 @param font Label字体
 @param backgroundColor Label背景颜色
 @param textColor Label文字颜色
 @return 富文本
 */
+ (NSAttributedString *)labelAttributedStringWithString:(NSString *)string font:(UIFont *)font backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor;

/**
 制作Label富文本
 @param string 文字内容
 @param font Label字体
 @param handler Label处理回调
 @return 富文本
 */
+ (NSAttributedString *)labelAttributedStringWithString:(NSString *)string font:(UIFont *)font handler:(void(^)(UILabel *label))handler;

@end


@interface NSMutableAttributedString (MNEmojiHelper)

/**
 设置表情文字富文本
 @param backedString 表情文字描述模型
 @param range 区间
 */
- (void)setBackedString:(MNEmojiBackedString *)backedString range:(NSRange)range;

/**
 替换表情
 @param font 字体大小
 */
- (void)matchingEmojiWithFont:(UIFont *)font;

@end
