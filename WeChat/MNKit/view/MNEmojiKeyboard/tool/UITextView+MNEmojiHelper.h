//
//  UITextView+MNEmojiHelper.h
//  MNKit
//
//  Created by Vincent on 2019/2/12.
//  Copyright © 2019年 小斯. All rights reserved.
//  表情辅助

#import <UIKit/UIKit.h>

@interface UITextView (MNEmojiHelper)

/**
 插入表情
 @param emoji 表情模型
 @return 是否插入成功
 */
- (BOOL)inputEmoji:(MNEmoji *)emoji;

/**
 解析表情富文本为纯文字内容
 @return 文字内容
 */
- (NSString *)emoji_plainText;

/**
 更新表情富文本
 */
- (void)updateEmojiAttributeIfNeeded;

/**
 复制
 @param sender sender
 */
- (void)hand_copy:(id)sender;

/**
 粘贴
 @param sender sender
 */
- (void)hand_paste:(id)sender;

/**
 剪切
 @param sender sender
 */
- (void)hand_cut:(id)sender;

@end
