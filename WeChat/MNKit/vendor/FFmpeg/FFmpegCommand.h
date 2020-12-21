//
//  FFmpegCommand.h
//  ZiMuKing
//
//  Created by Vincent on 2019/12/5.
//  Copyright © 2019 Vincent. All rights reserved.
//  FFmpeg 命令行工具 4.2

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFmpegCommand : NSObject
/**
 执行FFmpeg命令
 @param command 命令
 @return 执行结果
 */
+ (BOOL)execute:(NSString *)command;
/**
 执行FFmpeg命令<分线程>
 @param command 命令
 @param completion 执行结果
 */
+ (void)execute:(NSString *)command completion:(void(^)(BOOL result))completion;


/**
 从视频中提取音频轨道
 @param videoPath 视频路径
 @param outputPath 输出路径
 @return 执行结果
 */
+ (BOOL)exportAudioTrack:(NSString *)videoPath outputPath:(NSString *)outputPath;
/**
 从视频中提取音频轨道<分线程>
 @param videoPath 视频路径
 @param outputPath 输出路径
 @param completion 执行结果
 */
+ (void)exportAudioTrack:(NSString *)videoPath outputPath:(NSString *)outputPath completion:(void(^)(BOOL succeed))completion;

/**
 从视频中提取视频轨道
 @param videoPath 视频路径
 @param outputPath 输出路径
 @return 执行结果
 */
+ (BOOL)exportVideoTrack:(NSString *)videoPath outputPath:(NSString *)outputPath;
/**
 从视频中提取视频轨道<分线程>
 @param videoPath 视频路径
 @param outputPath 输出路径
 @param completion 执行结果
 */
+ (void)exportVideoTrack:(NSString *)videoPath outputPath:(NSString *)outputPath completion:(void(^)(BOOL succeed))completion;

/**
 从视频中输出GIF
 @param videoPath 视频路径
 @param range 位置(s), 长度(s)
 @param outputPath 输出路径
 @return 执行结果
 */
+ (BOOL)exportGif:(NSString *)videoPath inRange:(NSRange)range outputPath:(NSString *)outputPath;
/**
 从视频中输出GIF<分线程>
 @param videoPath 视频路径
 @param range 位置(s), 长度(s)
 @param outputPath 输出路径
 @param completion 执行结果
 */
+ (void)exportGif:(NSString *)videoPath inRange:(NSRange)range outputPath:(NSString *)outputPath completion:(void(^)(BOOL succeed))completion;

/**
 将m4a转换为wav
 @param m4aPath m4a路径
 @param wavPath wav路径
 @return 执行结果
 */
+ (BOOL)convertM4a:(NSString *)m4aPath toWav:(NSString *)wavPath;
/**
 将m4a转换为wav<分线程>
 @param m4aPath m4a路径
 @param wavPath 输出路径
 @param completion 执行结果
 */
+ (void)convertM4a:(NSString *)m4aPath toWav:(NSString *)wavPath completion:(void(^)(BOOL succeed))completion;

/**
 将mp3转换为wav
 @param mp3Path mp3路径
 @param wavPath 输出路径
 @return 执行结果
 */
+ (BOOL)convertMp3:(NSString *)mp3Path toWav:(NSString *)wavPath;
/**
 将mp3转换为wav<分线程>
 @param mp3Path mp3路径
 @param wavPath 输出路径
 @param completion 执行结果
 */
+ (void)convertMp3:(NSString *)mp3Path toWav:(NSString *)wavPath completion:(void(^)(BOOL succeed))completion;

/**
 裁剪视频
 @param videoPath 视频路径
 @param range 开始位置-裁剪长度s
 @param outputPath 输出路径
 @return 执行结果
 */
+ (BOOL)cutVideo:(NSString *)videoPath withRange:(NSRange)range outputPath:(NSString *)outputPath;
/**
 裁剪视频<分线程>
 @param videoPath 视频路径
 @param range 开始位置(s)-裁剪长度(s)
 @param outputPath 输出路径
 @param completion 执行结果
 */
+ (void)cutVideo:(NSString *)videoPath withRange:(NSRange)range outputPath:(NSString *)outputPath completion:(void(^)(BOOL succeed))completion;

/**
 裁剪视频
 @param videoPath 视频路径
 @param begin 开始位置(s)
 @param duration 裁剪长度(s)
 @param outputPath 输出路径
 @return 执行结果
 */
+ (BOOL)cutVideo:(NSString *)videoPath beginTime:(CGFloat)begin duration:(CGFloat)duration outputPath:(NSString *)outputPath;
/**
 裁剪视频<分线程>
 @param videoPath 视频路径
 @param begin 开始位置(s)
 @param duration 裁剪长度(s)
 @param outputPath 输出路径
 @param completion 执行结果
 */
+ (void)cutVideo:(NSString *)videoPath beginTime:(CGFloat)begin duration:(CGFloat)duration outputPath:(NSString *)outputPath completion:(void(^)(BOOL succeed))completion;

/**
 视频画面裁剪
 @param videoPath 视频路径
 @param frame 尺寸大小
 @param outputPath 输出路径
 @return 执行结果
 */
+ (BOOL)cropVideo:(NSString *)videoPath withFrame:(CGRect)frame outputPath:(NSString *)outputPath;
/**
 视频画面裁剪<分线程>
 @param videoPath 视频路径
 @param frame 尺寸大小
 @param outputPath 输出路径
 @param completion 执行结果
 */
+ (void)cropVideo:(NSString *)videoPath withFrame:(CGRect)frame outputPath:(NSString *)outputPath completion:(void(^)(BOOL succeed))completion;

/**
 获取视频缩略图
 @param videoPath 视频路径
 @param time 时间(s)
 @param size 缩略图大小
 @param outputPath 输出路径
 @return 执行结果
 */
+ (BOOL)exportThumbnail:(NSString *)videoPath atTime:(CGFloat)time size:(CGSize)size outputPath:(NSString *)outputPath;
/**
 获取视频缩略图<分线程>
 @param videoPath 视频路径
 @param time 时间(s)
 @param size 缩略图大小
 @param outputPath 输出路径
 @param completion 执行结果
 */
+ (void)exportThumbnail:(NSString *)videoPath atTime:(CGFloat)time size:(CGSize)size outputPath:(NSString *)outputPath completion:(void(^)(BOOL succeed))completion;

/**
 视频水印模糊
 @param videoPath 视频路径
 @param rect 水印位置
 @param outputPath 输出路径
 @return 执行结果
 */
+ (BOOL)exportWithoutWatermark:(NSString *)videoPath rect:(CGRect)rect outputPath:(NSString *)outputPath;
/**
 视频水印模糊分线程>
 @param videoPath 视频路径
 @param rect 水印位置
 @param outputPath 输出路径
 @param completion 执行结果
 */
+ (void)exportWithoutWatermark:(NSString *)videoPath rect:(CGRect)rect outputPath:(NSString *)outputPath completion:(void(^)(BOOL succeed))completion;

@end

NS_ASSUME_NONNULL_END
