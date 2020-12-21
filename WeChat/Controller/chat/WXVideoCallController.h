//
//  WXVideoCallController.h
//  JLChat
//
//  Created by Vincent on 2020/2/7.
//  Copyright © 2020 AiZhe. All rights reserved.
//  视频聊天

#import "MNExtendViewController.h"
@class WXUser;

/**
 外界标记拨打/接收
 - WXVideoCallSend 拨打
 - WXVideoCallReceive 接受
 */
typedef NS_ENUM(NSInteger, WXVideoCallStyle) {
    WXVideoCallSend = 0,
    WXVideoCallReceive
};

/**
外界获取是否接通
- WXVideoCallStateWaiting 等待中
- WXVideoCallStateAnswer 已接通
- WXVideoCallStateRefuse 拒绝
- WXVideoCallStateDecline 挂断
*/
typedef NS_ENUM(NSInteger, WXVideoCallState) {
    WXVideoCallStateWaiting = 0,
    WXVideoCallStateAnswer,
    WXVideoCallStateRefuse,
    WXVideoCallStateDecline
};

@interface WXVideoCallController : MNExtendViewController

/**是拨打还是接受样式*/
@property (nonatomic) WXVideoCallStyle style;

/**是否成功通话*/
@property (nonatomic, readonly) WXVideoCallState state;

/**通话时长<成功通话后有效>*/
@property (nonatomic, readonly) int callDuration;

/**对方账户*/
@property (nonatomic) WXUser *user;

/**退出时回调*/
@property (nonatomic, copy) void (^didEndCallHandler)(WXVideoCallController *vc);

/**
 编辑构造入口
 @param user 对方账户
 @param style 对话类型
 @return 语音聊天控制器
 */
- (instancetype)initWithUser:(WXUser *)user style:(WXVideoCallStyle)style;

/**
 获取描述信息
 @return 描述信息
 */
- (NSString *)desc;

@end
