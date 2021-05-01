//
//  WXFileModel.h
//  WeChat
//
//  Created by Vincent on 2019/6/8.
//  Copyright © 2019 Vincent. All rights reserved.
//  本地文件缓存标记

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WXFileType) {
    WXFileTypeUnknown = 0,
    WXFileTypeAudio,
    WXFileTypeVideo,
    WXFileTypeImage,
    WXFileTypeJSON,
    WXFileTypeObject
};

NS_ASSUME_NONNULL_BEGIN

@interface WXFileModel : NSObject <NSSecureCoding>
/**
 文件类型
 */
@property (nonatomic, assign) WXFileType type;
/**
 标识
 */
@property (nonatomic, copy) NSString *identifier;
/**
 本地文件路径
 */
@property (nonatomic, readonly) NSString *filePath;
/**
 会话标识<文件夹名>
*/
@property (nonatomic, copy) NSString *session;
/**
 获取本地文件<视频类型存放视频快照>
 */
@property (nonatomic, strong, readonly) id content;

/**
 图片封装
 @param image 图片
 @param session 会话标识<作为文件夹名>
 @return 图片文件
 */
+ (instancetype)fileWithImage:(UIImage *)image session:(NSString *)session;

/**
 字典封装
 @param dictionary 图片
 @param session 会话标识<作为文件夹名>
 @return 字典文件
 */
+ (instancetype)fileWithDictionary:(NSDictionary *)dictionary session:(NSString *)session;

/**
 对象封装
 @param obj 对象
 @param session 会话标识<作为文件夹名>
 @return 对象文件
 */
+ (instancetype)fileWithObject:(NSObject *)obj session:(NSString *)session;

/**
 音频封装
 @param audioPath 音频路径
 @param session 会话标识<作为文件夹名>
 @return 音频文件
 */
+ (instancetype)fileWithAudio:(NSString *)audioPath session:(NSString *)session;

/**
 视频封装
 @param videoPath 视频路径
 @param session 会话标识<作为文件夹名>
 @return 视频文件
 */
+ (instancetype)fileWithVideo:(NSString *)videoPath session:(NSString *)session;

/**
 替换文件内容
 @param obj 替换的新内容
 @return 是否替换成功
 */
- (BOOL)replaceContentWithObject:(NSObject *)obj;

/**
 删除文件
 */
- (void)removeContentsAtFile;

@end

NS_ASSUME_NONNULL_END
