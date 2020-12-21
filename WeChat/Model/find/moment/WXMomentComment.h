//
//  WXMomentComment.h
//  MNChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  评论

#import <Foundation/Foundation.h>

@interface WXMomentComment : NSObject <NSCopying>
/**
 标识
 */
@property (nonatomic, copy) NSString *identifier;
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
 时间<详情界面数据需要>
 */
@property (nonatomic, copy) NSString *date;
/**
 发送人
 */
@property (nonatomic, readonly, strong) WXUser *from_user;
/**
 回复人
 */
@property (nonatomic, readonly, strong) WXUser *to_user;

@end
