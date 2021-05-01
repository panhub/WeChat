//
//  MNEmojiKeyboard.h
//  MNKit
//
//  Created by Vincent on 2019/1/31.
//  Copyright © 2019年 小斯. All rights reserved.
//  表情键盘

#import <UIKit/UIKit.h>
#import "MNEmojiManager.h"
#import "MNEmojiBackedString.h"
#import "NSAttributedString+MNEmojiHelper.h"
#import "MNEmojiTextView.h"
#import "MNEmojiTextField.h"
#import "UITextView+MNEmojiHelper.h"
#import "UITextField+MNEmojiHelper.h"
#import "MNEmojiKeyboardConfiguration.h"
@class MNEmojiKeyboard;

@protocol MNEmojiKeyboardDelegate <NSObject>
@optional
/**表情键盘删除键触发*/
- (void)emojiKeyboardDeleteButtonTouchUpInside:(MNEmojiKeyboard *)emojiKeyboard;
/**表情键盘Return键触发*/
- (void)emojiKeyboardReturnButtonTouchUpInside:(MNEmojiKeyboard *)emojiKeyboard;
/**表情键盘收藏夹添加按钮触发*/
- (void)emojiKeyboardFavoritesButtonTouchUpInside:(MNEmojiKeyboard *)emojiKeyboard;
/**表情键盘表情包添加按钮触发*/
- (void)emojiKeyboardPacketButtonTouchUpInside:(MNEmojiKeyboard *)emojiKeyboard;
/**表情键盘按钮触发*/
- (void)emojiKeyboard:(MNEmojiKeyboard *)emojiKeyboard emojiButtonTouchUpInside:(MNEmoji *)emoji;
@end

@interface MNEmojiKeyboard : UIView
/**
 交互事件代理
 */
@property (nonatomic, weak) id<MNEmojiKeyboardDelegate> delegate;
/**
 配置信息
*/
@property (nonatomic, strong, readonly) MNEmojiKeyboardConfiguration *configuration;
/**
 快速实例入口
*/
@property (nonatomic, class, readonly) MNEmojiKeyboard *keyboard;

/**
 表情键盘构造入口
 @param height 指定高度
 @return 表情键盘
 */
- (instancetype)initWithKeyboardHeight:(CGFloat)height;

@end

