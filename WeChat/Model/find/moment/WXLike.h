//
//  WXLike.h
//  WeChat
//
//  Created by Vicent on 2021/4/24.
//  Copyright © 2021 Vincent. All rights reserved.
//  点赞模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXLike : NSObject
/**
 发送人uid
 */
@property (nonatomic, copy) NSString *uid;
/**
 标识
 */
@property (nonatomic, copy) NSString *identifier;
/**
 标记朋友圈
 */
@property (nonatomic, copy) NSString *moment;
/**
 记录时间<详情界面数据需要>
 */
@property (nonatomic, copy) NSString *timestamp;
/**
 回复人
 */
@property (nonatomic, readonly) WXUser *user;


/**
 依据用户标识实例化点赞模型
 @param uid 用户标识
 @return 点赞模型
 */
- (instancetype)initWithUid:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
