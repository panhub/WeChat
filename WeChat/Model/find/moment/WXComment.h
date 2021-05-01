//
//  WXComment.h
//  WeChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  评论

#import <Foundation/Foundation.h>

@interface WXComment : NSObject <NSCopying>
/**
 标识
 */
@property (nonatomic, copy) NSString *identifier;
/**
 标记朋友圈
 */
@property (nonatomic, copy) NSString *moment;
/**
 发送人uid
 */
@property (nonatomic, copy) NSString *from_uid;
/**
 回复人uid
 */
@property (nonatomic, copy) NSString *to_uid;
/**
 内容
 */
@property (nonatomic, copy) NSString *content;
/**
 记录时间<详情界面数据需要>
 */
@property (nonatomic, copy) NSString *timestamp;
/**
 发送人
 */
@property (nonatomic, readonly) WXUser *fromUser;
/**
 回复人
 */
@property (nonatomic, readonly) WXUser *toUser;

@end
