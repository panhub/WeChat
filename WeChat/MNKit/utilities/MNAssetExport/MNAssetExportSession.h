//
//  MNAssetExportSession.h
//  MNFoundation
//
//  Created by Vincent on 2019/12/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  系统资源输出封装

#import <Foundation/Foundation.h>
#if __has_include(<AVFoundation/AVFoundation.h>)

/**
进度回调
@param progress 进度信息
*/
typedef void(^MNAssetExportSessionProgressHandler)(float progress);

/**
 输出回调
 @param status 输出状态
 @param error 错误信息(nullable)
 */
typedef void(^MNAssetExportSessionCompletionHandler)(AVAssetExportSessionStatus status, NSError *error);

@interface MNAssetExportSession : NSObject
/**资源对象, 内部依据初始化自行转化*/
@property (nonatomic, strong, readonly) AVAsset *asset;
/**视频路径*/
@property (nonatomic, copy) NSString *filePath;
/**质量 AVAssetExportPresetHighestQuality */
@property (nonatomic, copy) NSString *presetName;
/**文件封装格式*/
@property (nonatomic, copy) AVFileType outputFileType;
/**裁剪片段*/
@property (nonatomic) CMTimeRange timeRange;
/**裁剪区域, 不赋值则不裁剪*/
@property (nonatomic) CGRect outputRect;
/**输出分辨率 outputRect有效时有效*/
@property (nonatomic) CGSize renderSize;
/**输出路径*/
@property (nonatomic, copy) NSString *outputPath;
/**是否针对网络使用进行优化*/
@property (nonatomic) BOOL shouldOptimizeForNetworkUse;
/**输出视频内容*/
@property (nonatomic, getter=isExportVideoTrack) BOOL exportVideoTrack;
/**输出音频内容*/
@property (nonatomic, getter=isExportAudioTrack) BOOL exportAudioTrack;
/**输出状态*/
@property (nonatomic, readonly) AVAssetExportSessionStatus status;
/**进度信息*/
@property (nonatomic, readonly) float progress;
/**错误信息*/
@property (nonatomic, readonly) NSError *error;

/**
依据资源文件实例化输出者
@param asset 资源文件
@return 视/音输出者
*/
- (instancetype)initWithAsset:(AVURLAsset *)asset;

/**
 依据视/音频路径实例化输出者
 @param filePath 视/音频路径
 @return 视/音输出者
 */
- (instancetype)initWithAssetAtPath:(NSString *)filePath NS_DESIGNATED_INITIALIZER;

/**
 依据视/音频本地URL实例化输出者
 @param fileURL 视/音频本地URL
 @return 视/音输出者
 */
- (instancetype)initWithAssetOfURL:(NSURL *)fileURL;

/**
 异步输出操作
 @param completionHandler 结束回调
 */
- (void)exportAsynchronouslyWithCompletionHandler:(MNAssetExportSessionCompletionHandler)completionHandler;

/**
 异步输出
 @param progressHandler 进度回调
 @param completionHandler 完成回调
 */
- (void)exportAsynchronouslyWithProgressHandler:(MNAssetExportSessionProgressHandler)progressHandler
                              completionHandler:(MNAssetExportSessionCompletionHandler)completionHandler;

/**
 获取时间片段
 @param range (开始, 时长)
 @return 时间片段
 */
- (CMTimeRange)timeRangeWithSeconds:(NSRange)range;

/**
 获取时间片段
 @param fromProgress 开始进度
 @param toProgress 结束进度
 @return 时间片段
 */
- (CMTimeRange)timeRangeFromProgress:(float)fromProgress toProgress:(float)toProgress;

/**
 获取时间片段
 @param fromSeconds 开始时长
 @param toSeconds 结束时长
 @return 时间片段
 */
- (CMTimeRange)timeRangeFromSeconds:(NSTimeInterval)fromSeconds toSeconds:(NSTimeInterval)toSeconds;

@end
#endif
