//
//  WXMoment.h
//  MNChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈数据模型

#import <Foundation/Foundation.h>
#import "WXMomentWebpage.h"
#import "WXMomentPicture.h"
#import "WXMomentComment.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMoment : NSObject <NSCopying>
/**
 朋友圈标识
 */
@property (nonatomic, copy) NSString *identifier;
/**
 发布者uid
 */
@property (nonatomic, copy) NSString *uid;
/**
 发布者
 */
@property (nonatomic, readonly, strong) WXUser *user;
/**
 是否自己朋友圈 <删除功能的依据>
 */
@property (nonatomic, readonly, getter=isMine) BOOL mine;
/**
 部分人可见 <自己的朋友圈有效>
 */
@property (nonatomic, getter=isPrivacy) BOOL privacy;
/**
 正文
 */
@property (nonatomic, copy) NSString *content;
/**
 创建日期<时间戳>
 */
@property (nonatomic, copy) NSString *timestamp;
/**
 来源 <如:今日头条、QQ音乐...>
 */
@property (nonatomic, copy) NSString *source;
/**
 位置
 */
@property (nonatomic, copy) NSString *location;
/**
 网页分享
 */
@property (nonatomic, copy) NSString *web;
/**
 配图标识
 */
@property (nonatomic, copy) NSString *img;
/**
 点赞标识
 */
@property (nonatomic, copy) NSString *like;
/**
 评论标识
 */
@property (nonatomic, copy) NSString *comment;
/**
 分享模型
 */
@property (nonatomic, readonly, strong) WXMomentWebpage *webpage;
/**
 配图数组
 */
@property (nonatomic, readonly, strong) NSMutableArray <WXMomentPicture *>*pictures;
/**
 点赞数组
 */
@property (nonatomic, readonly, strong) NSMutableArray <NSString *>*likes;
/**
 评论数组
 */
@property (nonatomic, readonly, strong) NSMutableArray <WXMomentComment *>*comments;

@end

NS_ASSUME_NONNULL_END
