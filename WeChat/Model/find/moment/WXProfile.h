//
//  WXProfile.h
//  WeChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈配图

#import <Foundation/Foundation.h>

/**
 朋友圈配图类型
 - WXProfileTypeImage: 图片
 - WXProfileTypeVideo: 视频
 */
typedef NS_ENUM(NSInteger, WXProfileType) {
    WXProfileTypeImage = 0,
    WXProfileTypeVideo
};

NS_ASSUME_NONNULL_BEGIN

@interface WXProfile : NSObject <NSCopying, NSSecureCoding>
/**
 类型
 */
@property (nonatomic) WXProfileType type;
/**
 标识符
 */
@property (nonatomic, copy) NSString *identifier;
/**
 文件名
 */
@property (nonatomic, copy) NSString *file_name;
/**
 标记时间<相册使用>
 */
@property (nonatomic, copy) NSString *timestamp;
/**
 关联的朋友圈
 */
@property (nonatomic, copy) NSString *moment;
/**
 文件路径
 */
@property (nonatomic, readonly) NSString *filePath;
/**
 图片
 */
@property (nonatomic, readonly) UIImage *image;
/**
 图片或视频路径
 */
@property (nonatomic, readonly) id content;

/**
 实例化朋友圈配图
 @param image 图片实例
 @return 朋友圈配图
 */
+ (WXProfile *_Nullable)pictureWithImage:(UIImage *)image;

/**
 实例化朋友圈配图
 @param videoPath 视频路径
 @return 朋友圈配图
 */
+ (WXProfile *_Nullable)pictureWithVideoPath:(NSString *)videoPath;

/**
 实例化朋友圈配图
 @param profile 视频路径/图片
 @return 朋友圈配图实例
 */
+ (WXProfile *_Nullable)pictureWithProfile:(id)profile;

/**
 删除文件
 */
- (void)removeContentsAtFile;

/**
 比较两个图片数据模型是否相同
 @param profile 图片数据模型
 @return 比较结果
 */
- (BOOL)isEqualToProfile:(WXProfile *)profile;

@end

NS_ASSUME_NONNULL_END
