//
//  WXVideoCallController.h
//  JLChat
//
//  Created by Vincent on 2020/2/7.
//  Copyright © 2020 AiZhe. All rights reserved.
//  视频聊天

#import "MNExtendViewController.h"
#import "WXVoipButton.h"
@class WXUser;

@interface WXVideoCallController : MNExtendViewController

/**是拨打还是接受样式*/
@property (nonatomic) WXVoipStyle style;

/**是否成功通话*/
@property (nonatomic, readonly) WXVoipState state;

/**通话时长<成功通话后有效>*/
@property (nonatomic, readonly) int duration;

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
- (instancetype)initWithUser:(WXUser *)user style:(WXVoipStyle)style;

@end
