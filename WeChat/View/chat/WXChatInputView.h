//
//  WXChatInputView.h
//  MNChat
//
//  Created by Vincent on 2019/3/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  微信聊天编辑框

#import <UIKit/UIKit.h>
@class WXChatInputView, WXFileModel;

UIKIT_EXTERN const CGFloat WXChatToolBarNormalHeight;

@protocol WXChatInputDelegate <NSObject>
@optional
- (void)inputViewShouldSendText:(NSString *)text;

- (void)inputViewShouldSendEmotion:(UIImage *)image;

- (void)inputViewShouldSendAsset:(WXChatInputView *)inputView;

- (void)inputViewShouldSendCapture:(WXChatInputView *)inputView;

- (void)inputViewShouldSendCall:(WXChatInputView *)inputView;

- (void)inputViewShouldSendLocation:(WXChatInputView *)inputView;

- (void)inputViewShouldSendWebpage:(WXChatInputView *)inputView;

- (void)inputViewShouldSendRedpacket:(WXChatInputView *)inputView;

- (void)inputViewShouldSendTransfer:(WXChatInputView *)inputView;

- (void)inputViewShouldSendCard:(WXChatInputView *)inputView;

- (void)inputViewShouldSendVoice:(WXChatInputView *)inputView;

- (void)inputViewDidCancelVoice:(WXChatInputView *)inputView;

- (void)inputViewDidSendVoice:(NSString *)voicePath;

- (void)inputViewDidChangeFrame:(WXChatInputView *)inputView animated:(BOOL)animated;

- (void)inputViewShouldInsertEmojiToFavorites:(WXChatInputView *)inputView;

- (void)inputViewShouldAddEmojiPackets:(WXChatInputView *)inputView;

@end

@interface WXChatInputView : UIView

/**交互代理*/
@property (nonatomic, weak) id<WXChatInputDelegate> delegate;

/**
 向收藏夹插入图片
 @param emojiImage 表情图片
 @return 是否插入成功
 */
- (BOOL)insertEmojiToFavorites:(UIImage *)emojiImage;

@end
