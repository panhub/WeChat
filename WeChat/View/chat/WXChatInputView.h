//
//  WXChatInputView.h
//  WeChat
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

- (void)inputViewShouldSendFavorite:(WXChatInputView *)inputView;

- (void)inputViewShouldSendRedpacket:(WXChatInputView *)inputView;

- (void)inputViewShouldSendTransfer:(WXChatInputView *)inputView;

- (void)inputViewShouldSendCard:(WXChatInputView *)inputView;

- (void)inputViewShouldSendVoice:(WXChatInputView *)inputView;

- (void)inputViewDidCancelVoice:(WXChatInputView *)inputView;

- (void)inputViewDidSendVoice:(NSString *)voicePath;

- (void)inputViewShouldSendSpeech:(WXChatInputView *)inputView;

- (void)inputViewDidChangeFrame:(WXChatInputView *)inputView animated:(BOOL)animated;

- (void)inputViewShouldInsertEmojiToFavorites:(WXChatInputView *)inputView;

- (void)inputViewShouldAddEmojiPackets:(WXChatInputView *)inputView;

@end

@interface WXChatInputView : UIView

/**麦克风是否可用*/
@property (nonatomic) BOOL microphoneEnabled;

/**交互代理*/
@property (nonatomic, weak) id<WXChatInputDelegate> delegate;

@end
