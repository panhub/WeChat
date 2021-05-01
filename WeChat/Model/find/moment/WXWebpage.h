//
//  WXWebpage.h
//  WeChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈分享模型 

#import <Foundation/Foundation.h>
@class WXSession, WXFavorite;

NS_ASSUME_NONNULL_BEGIN

@interface WXWebpage : NSObject<NSCopying, NSSecureCoding>
/**
 标识
 */
@property (nonatomic, copy) NSString *identifier;
/**
 时间
 */
@property (nonatomic, copy) NSString *timestamp;
/**
 链接
 */
@property (nonatomic, copy) NSString *url;
/**
 标题
 */
@property (nonatomic, copy) NSString *title;
/**
 简述
 */
@property (nonatomic, copy, nullable) NSString *subtitle;
/**
 图片
 */
@property (nonatomic, readonly) UIImage *image;

/**
 实例化朋友圈网页分享模型
 @param image 图片
 @return 朋友圈网页
 */
+ (WXWebpage *_Nullable)webpageWithImage:(UIImage *)image;

/**
 实例化聊天消息网页模型
 @param favorite 网页收藏
 @return 消息网页模型
 */
+ (WXWebpage *_Nullable)webpageWithWebFavorite:(WXFavorite *)favorite session:(WXSession *_Nullable)session;

/**
 实例化朋友圈网页分享模型
 @param imageData 图片数据流
 @return 朋友圈网页
 */
+ (WXWebpage *_Nullable)webpageWithImageData:(NSData *)imageData;

/**
 插件数据实例化入口
 @param dic 数据集合
 @return 朋友圈网页
 */
+ (WXWebpage *_Nullable)shareWithDictionary:(NSDictionary *)dic;

/**
 删除文件
 */
- (void)removeContentsAtFile;

@end
NS_ASSUME_NONNULL_END
