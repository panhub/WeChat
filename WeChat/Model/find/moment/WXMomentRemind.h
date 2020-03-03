//
//  WXMomentRemind.h
//  MNChat
//
//  Created by Vincent on 2019/7/22.
//  Copyright © 2019 AiZhe. All rights reserved.
//  朋友圈提醒数据

#import <Foundation/Foundation.h>
@class WXMoment, WXMomentComment;

@interface WXMomentRemind : NSObject
/**
 标识符
 */
@property (nonatomic, readwrite, copy) NSString *identifier;
/**
 发送人
 */
@property (nonatomic, readwrite, copy) NSString *from_uid;
/**
 回复人
 */
@property (nonatomic, readwrite, copy) NSString *to_uid;
/**
 内容
 */
@property (nonatomic, readwrite, copy) NSString *content;
/**
 绑定的朋友圈标识符
 */
@property (nonatomic, readwrite, copy) NSString *moment;
/**
 时间<详情界面数据需要>
 */
@property (nonatomic, readwrite, copy) NSString *date;

/**
 点赞消息提醒实例化
 @param uid 点赞人uid
 @param moment 朋友圈
 @return 点赞 消息提醒模型
 */
+ (instancetype)remindWithUid:(NSString *)uid withMoment:(WXMoment *)moment;

/**
 评论/回复 消息提醒实例化
 @param comment 评论/回复 数据模型
 @param moment 朋友圈
 @return 评论/回复 消息提醒模型
 */
+ (instancetype)remindWithComment:(WXMomentComment *)comment withMoment:(WXMoment *)moment;

@end
