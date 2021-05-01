//
//  WXRedpacket.h
//  WeChat
//
//  Created by Vincent on 2019/5/27.
//  Copyright © 2019 Vincent. All rights reserved.
//  红包数据模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXRedpacket : NSObject <NSSecureCoding, NSCopying>
/**
 是否被开启
 */
@property (nonatomic, getter=isOpen) BOOL open;
/**
 是否是自己发送的
 */
@property (nonatomic, getter=isMine) BOOL mine;
/**
 红包标识
 */
@property (nonatomic, copy) NSString *identifier;
/**
 发送者
 */
@property (nonatomic, copy) NSString *from_uid;
/**
 接収者
 */
@property (nonatomic, copy) NSString *to_uid;
/**
 金额
 */
@property (nonatomic, copy) NSString *money;
/**
 附加文字
 */
@property (nonatomic, copy) NSString *text;
/**
 微信红包/微信转账
 */
@property (nonatomic, copy) NSString *type;
/**
 发送时间
 */
@property (nonatomic, copy) NSString *create_time;
/**
 领取时间
 */
@property (nonatomic, copy) NSString *draw_time;

#pragma mark - Getter
@property (nonatomic, readonly, strong) WXUser *toUser;
@property (nonatomic, readonly, strong) WXUser *fromUser;

@end

NS_ASSUME_NONNULL_END
