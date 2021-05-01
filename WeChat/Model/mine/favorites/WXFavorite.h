//
//  WXFavorite.h
//  WeChat
//
//  Created by Vincent on 2019/4/29.
//  Copyright © 2019 Vincent. All rights reserved.
//  收藏模型

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class WXWebpage, WXLocation;

/**
 收藏类型
 - WXFavoriteTypeWeb: 网页
 - WXFavoriteTypeText: 文字
 - WXFavoriteTypeImage: 图片
 - WXFavoriteTypeVideo: 视频
 - WXFavoriteTypeLocation: 位置
 */
typedef NS_ENUM(NSInteger, WXFavoriteType) {
    WXFavoriteTypeWeb = 0,
    WXFavoriteTypeText,
    WXFavoriteTypeImage,
    WXFavoriteTypeVideo,
    WXFavoriteTypeLocation
};

NS_ASSUME_NONNULL_BEGIN

@interface WXFavorite : NSObject <NSSecureCoding>
/**类型*/
@property (nonatomic) WXFavoriteType type;
/**标识*/
@property (nonatomic, copy) NSString *identifier;
/**标题 WXFavoriteTypeWeb标题 WXFavoriteTypeText内容*/
@property (nonatomic, copy) NSString *title;
/**副标题 位置信息的详细描述*/
@property (nonatomic, copy) NSString *subtitle;
/**链接, WXFavoriteTypeLocation保存纬度经度*/
@property (nonatomic, copy) NSString *url;
/**来源*/
@property (nonatomic, copy) NSString *source;
/**用户标识 若有用户标识则替代'source'*/
@property (nonatomic, copy) NSString *uid;
/**标签*/
@property (nonatomic, copy) NSString *label;
/**时间戳*/
@property (nonatomic, copy) NSString *timestamp;
/**缩略图*/
@property (nonatomic, readonly) UIImage *image;
/**文件路径*/
@property (nonatomic, readonly) NSString *filePath;

/**
 为插件数据实例化模型
 @param dic 沙盒数据
 @return 收藏模型<网页>
 */
+ (instancetype)shareWithDictionary:(NSDictionary *)dic;

/**
 实例化图片收藏模型
 @param image 图片
 @return 图片收藏模型
 */
+ (WXFavorite *_Nullable)favoriteWithImage:(UIImage *)image;

/**
 实例化图片收藏模型
 @param imagePath 图片路径
 @return 图片收藏模型
 */
+ (WXFavorite *_Nullable)favoriteWithImagePath:(NSString *)imagePath;

/**
 实例化文字收藏模型
 @param text 文字
 @return 文字收藏模型
 */
+ (WXFavorite *_Nullable)favoriteWithText:(NSString *)text;

/**
 实例化视频收藏模型
 @param videoPath 视频路径
 @return 视频收藏模型
 */
+ (WXFavorite *_Nullable)favoriteWithVideoPath:(NSString *)videoPath;

/**
 实例化网页收藏模型
 @param webpage 网页模型
 @return 视频收藏模型
 */
+ (WXFavorite *_Nullable)favoriteWithWebpage:(WXWebpage *)webpage;

/**
 实例化位置收藏模型
 @param location 位置模型
 @return 位置收藏模型
 */
+ (WXFavorite *_Nullable)favoriteWithLocation:(WXLocation *)location;

/**
 删除文件
 */
- (void)removeContentsAtFile;

@end
NS_ASSUME_NONNULL_END
