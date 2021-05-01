//
//  WXMoment.h
//  WeChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈数据模型

#import <Foundation/Foundation.h>
#import "WXWebpage.h"
#import "WXProfile.h"
#import "WXLike.h"
#import "WXComment.h"

/**
 朋友圈类型
 - WXMomentTypeWord: 纯文字
 - WXMomentTypeWeb: 网页
 - WXMomentTypePicture: 图片
 - WXMomentTypeVideo: 视频
 */
typedef NS_ENUM(NSInteger, WXMomentType) {
    WXMomentTypeWord = 0,
    WXMomentTypeWeb,
    WXMomentTypePicture,
    WXMomentTypeVideo
};

NS_ASSUME_NONNULL_BEGIN

@interface WXMoment : NSObject <NSCopying>
/**
 朋友圈标识
 */
@property (nonatomic, copy) NSString *identifier;
/**
 朋友圈类型
 */
@property (nonatomic, assign) WXMomentType type;
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
 网页数据流
 */
@property (nonatomic, copy) NSData *web;

#pragma mark - 数据快速获取入口, 不计入数据库
/**
 是否是新朋友圈模型 <相册-我的朋友圈使用>
 */
@property (nonatomic, readonly) BOOL isNewMoment;
/**
 分享模型
 */
@property (nonatomic, readonly) WXWebpage *webpage;
/**
 配图数组
 */
@property (nonatomic, strong) NSMutableArray <WXProfile *>*profiles;
/**
 点赞数组
 */
@property (nonatomic, readonly) NSMutableArray <WXLike *>*likes;
/**
 评论数组
 */
@property (nonatomic, readonly) NSMutableArray <WXComment *>*comments;

/**销毁缓存*/
- (void)cleanMemory;

/**
 比较两个朋友圈数据模型是否相同
 @param moment 朋友圈数据模型
 @return 比较结果
 */
- (BOOL)isEqualToMoment:(WXMoment *)moment;

@end

NS_ASSUME_NONNULL_END
