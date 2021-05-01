//
//  WXChatVoiceRecordView.h
//  WeChat
//
//  Created by Vincent on 2019/6/8.
//  Copyright © 2019 Vincent. All rights reserved.
//  录音视图

#import <UIKit/UIKit.h>

/**
 录音状态
 - WXChatVoiceRecordNormal: 正常状态
 - WXChatVoiceRecordCancel: 松开取消
 - WXChatVoiceRecordTimeout: 即将超时
 - WXChatVoiceRecordStop: 已超时主动停止
 */
typedef NS_ENUM(NSInteger, WXChatVoiceRecordState) {
    WXChatVoiceRecordNormal = 0,
    WXChatVoiceRecordCancel,
    WXChatVoiceRecordTimeout,
    WXChatVoiceRecordStop
};

@protocol WXChatVoiceRecordViewDelegate <NSObject>

- (void)voiceRecordTimeoutNeedStop:(int)duration;

@end

@interface WXChatVoiceRecordView : UIView

@property (nonatomic) float power;

@property (nonatomic) NSTimeInterval duration;

@property (nonatomic) NSTimeInterval maxRecordDuration;

@property (nonatomic) WXChatVoiceRecordState state;

@property (nonatomic) id<WXChatVoiceRecordViewDelegate> delegate;

- (void)show;

- (void)dismiss;

@end
