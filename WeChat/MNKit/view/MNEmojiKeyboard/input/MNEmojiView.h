//
//  MNEmojiView.h
//  MNKit
//
//  Created by Vincent on 2019/1/31.
//  Copyright © 2019年 小斯. All rights reserved.
//  表情视图

#import "MNScrollView.h"
@class MNEmoji, MNEmojiView, MNEmojiPacket, MNEmojiKeyboardConfiguration;

@protocol MNEmojiViewDelegate <NSObject>
/**删除按钮点击事件*/
- (void)emojiViewDeleteButtonTouchUpInside:(MNEmojiView *)emojiView;
/**Return键点击事件*/
- (void)emojiViewReturnButtonTouchUpInside:(MNEmojiView *)emojiView;
/**表情按钮点击事件*/
- (void)emojiViewEmojiButtonTouchUpInside:(MNEmoji *)emoji;
/**已滑动到指定索引*/
- (void)emojiViewDidScrollToPageOfIndex:(NSUInteger)pageIndex;
/**表情长按, 触发预览*/
- (void)emojiViewShouldPreviewEmoji:(MNEmoji *)emoji atRect:(CGRect)frame;
@end

@interface MNEmojiView : MNScrollView
/**
 表情包索引
 */
@property (nonatomic) NSUInteger index;
/**
 表情包
 */
@property (nonatomic, strong) MNEmojiPacket *packet;
/**
 表情点击事件回调代理
 */
@property (nonatomic, weak) id<MNEmojiViewDelegate> emojiDelegate;
/**
 表情键盘配置
*/
@property (nonatomic, strong) MNEmojiKeyboardConfiguration *configuration;

@end

