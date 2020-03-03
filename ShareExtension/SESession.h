//
//  WXSession.h
//  MNChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//  微信消息会话模型

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SESession : NSObject
/**
 用户uid
 */
@property (nonatomic, copy) NSString *uid;
/**
 会话对方备注/昵称
 */
@property (nonatomic, copy) NSString *notename;
/**
 会话标识
 */
@property (nonatomic, copy) NSString *identifier;
/**
 头像
*/
@property (nonatomic, strong) UIImage *avatar;

/**
 沙盒数据转化会话实例
 @param dic 沙盒数据
 @return 会话实例
 */
+ (instancetype)sessionWithSandboox:(NSDictionary *)dic;

@end
