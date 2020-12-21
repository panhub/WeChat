//
//  WXSession.h
//  MNChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//  微信消息会话模型

#import <Foundation/Foundation.h>
@class WXUser;
@class WXMessage;

typedef NS_ENUM(NSInteger, WXSessionType) {
    WXSessionTypeSingle = 0,
    WXSessionTypeGroup = 1,
    WXSessionTypeChatRoom
};

@interface WXSession : NSObject
#pragma mark - Fields
/**
 用户uid
 */
@property (nonatomic, copy) NSString *uid;
/**
 最新一条消息id
 */
@property (nonatomic, copy) NSString *latest;
/**
 最新一条消息时间
 */
@property (nonatomic, copy) NSString *timestamp;
/**
 最新一条消息描述<文字消息内容, [图片], [语音], [位置]>
 */
@property (nonatomic, copy) NSString *desc;
/**
 会话标识
 */
@property (nonatomic, copy) NSString *identifier;
/**
 聊天记录表名
 */
@property (nonatomic, copy) NSString *list;
/**
 未读消息数量
 */
@property (nonatomic) NSInteger unread_count;
/**
 会话类型
 */
@property (nonatomic) WXSessionType type;
/**
 聊天免打扰
 */
@property (nonatomic) BOOL remind;
/**
 是否置顶
 */
@property (nonatomic) BOOL front;

#pragma mark - Getter
@property (nonatomic, strong, readonly) WXUser *user;
@property (nonatomic, strong, readonly) WXMessage *message;

/**
 获取与指定用户的会话
 @param user 指定用户
 @return 会话实例
 */
+ (instancetype)sessionForUser:(WXUser *)user;

@end
