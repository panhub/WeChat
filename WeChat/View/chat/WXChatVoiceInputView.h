//
//  WXChatVoiceInputView.h
//  WeChat
//
//  Created by Vincent on 2019/6/7.
//  Copyright © 2019 Vincent. All rights reserved.
//  语音聊天视图

#import <UIKit/UIKit.h>
@class WXChatVoiceInputView, WXFileModel;

@protocol WXChatVoiceInputViewDelegate <NSObject>
@required;
- (void)voiceInputViewDidEndRecording:(NSString *)voicePath;
- (void)voiceInputViewDidBeginRecording:(WXChatVoiceInputView *)inputView;
- (void)voiceInputViewDidCancelRecording:(WXChatVoiceInputView *)inputView;
@optional;
- (void)voiceInputViewDidFailedRecording:(WXChatVoiceInputView *)inputView;
@end

@interface WXChatVoiceInputView : UIView

@property (nonatomic, weak) id<WXChatVoiceInputViewDelegate> delegate;

@end
