//
//  WXNotify.h
//  WeChat
//
//  Created by Vincent on 2019/7/22.
//  Copyright © 2019 AiZhe. All rights reserved.
//  朋友圈消息通知

#import <Foundation/Foundation.h>
@class WXComment, WXLike;

@interface WXNotify : NSObject
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
@property (nonatomic, readwrite, copy) NSString *timestamp;

/**
 评论/回复 消息提醒实例化
 @param comment 评论/回复 数据模型
 @return 评论/回复 消息提醒模型
 */
- (instancetype)initWithComment:(WXComment *)comment;

/**
 点赞消息提醒实例化
 @param like 点赞数据
 @return 点赞 消息提醒模型
 */
- (instancetype)initWithLike:(WXLike *)like;

@end
