//
//  MNEmojiInputView.h
//  MNKit
//
//  Created by Vincent on 2019/2/3.
//  Copyright © 2019年 小斯. All rights reserved.
//  表情管理视图

#import <UIKit/UIKit.h>
#import "MNEmojiView.h"
@class MNEmojiInputView, MNEmojiKeyboardConfiguration;

@protocol MNEmojiInputViewDelegate <NSObject>
/**页面索引改变*/
- (void)emojiInputViewDidScrollToPageOfIndex:(NSUInteger)pageIndex;
/**表情按钮点击*/
- (void)emojiInputViewEmojiButtonTouchUpInside:(MNEmoji *)emoji;
/**展示页面*/
- (void)emojiInputViewDidDisplayEmojiView:(MNEmojiView *)emojiView;
/**Return键点击*/
- (void)emojiReturnButtonTouchUpInside;
/**删除按钮点击*/
- (void)emojiDeleteButtonTouchUpInside;
@end

@protocol MNEmojiInputViewDataSource <NSObject>
/**获取表情包*/
- (NSArray <MNEmojiPacket *>*)emojiPacketsOfInputView;
@end

@interface MNEmojiInputView : UIView
/**
 事件代理
 */
@property (nonatomic, weak) id<MNEmojiInputViewDelegate> delegate;
/**
 数据源代理
 */
@property (nonatomic, weak) id<MNEmojiInputViewDataSource> dataSource;
/**
 表情键盘配置信息
*/
@property (nonatomic, strong) MNEmojiKeyboardConfiguration *configuration;
/**
 选择器重载数据
 */
- (void)reloadData;
/**
 展示指定页
 @param pageIndex 指定页
 */
- (void)displayPageOfIndex:(NSUInteger)pageIndex;
/**
 展示当前页指定索引
 @param pageIndex 指定索引
 */
- (void)displayCurrentPageOfIndex:(NSUInteger)pageIndex;
/**
 重载当前页表情<收藏夹更新时>
 */
- (void)reloadEmojis;

@end
