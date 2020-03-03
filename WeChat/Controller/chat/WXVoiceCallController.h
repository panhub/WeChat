//
//  WXVoiceCallController.h
//  JLChat
//
//  Created by Vincent on 2020/2/6.
//  Copyright © 2020 AiZhe. All rights reserved.
//  语音聊天

#import "MNExtendViewController.h"
@class WXUser;

/**
 外界标记拨打/接收
 - WXVoiceCallSend 拨打
 - WXVoiceCallReceive 接受
 */
typedef NS_ENUM(NSInteger, WXVoiceCallStyle) {
    WXVoiceCallSend = 0,
    WXVoiceCallReceive
};

/**
外界获取是否接通
- WXVoiceCallStateWaiting 等待中
- WXVoiceCallStateAnswer 已接通
- WXVoiceCallStateRefuse 拒绝
- WXVoiceCallStateDecline 挂断
*/
typedef NS_ENUM(NSInteger, WXVoiceCallState) {
    WXVoiceCallStateWaiting = 0,
    WXVoiceCallStateAnswer,
    WXVoiceCallStateRefuse,
    WXVoiceCallStateDecline
};

@interface WXVoiceCallController : MNExtendViewController

/**是拨打还是接受样式*/
@property (nonatomic) WXVoiceCallStyle style;

/**是否成功通话*/
@property (nonatomic, readonly) WXVoiceCallState state;

/**通话时长<成功通话后有效>*/
@property (nonatomic, readonly) int callDuration;

/**对方账户*/
@property (nonatomic) WXUser *user;

/**结束回调*/
@property (nonatomic, copy) void(^didEndCallHandler) (WXVoiceCallController *vc);

/**
 编辑构造入口
 @param user 对方账户
 @param style 对话类型
 @return 语音聊天控制器
 */
- (instancetype)initWithUser:(WXUser *)user style:(WXVoiceCallStyle)style;

/**
 获取描述信息
 @return 描述信息
 */
- (NSString *)desc;

@end

