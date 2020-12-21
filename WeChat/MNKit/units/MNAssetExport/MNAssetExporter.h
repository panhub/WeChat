//
//  MNAssetExporter.h
//  MNKit
//
//  Created by Vincent on 2019/12/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  资源输出方案

#import <Foundation/Foundation.h>
#if __has_include(<AVFoundation/AVFoundation.h>)
@class MNAssetExporter;

NS_ASSUME_NONNULL_BEGIN

/**
 输出状态 <与AVFoundation AVAssetExportSessionStatus 保持一致>
 - MNAssetExportStatusUnknown: 未知(默认未操作状态)
 - MNAssetExportStatusExporting: 输出中
 - MNAssetExportStatusCompleted: 输出完成
 - MNAssetExportStatusFailed: 操作失败
 - MNAssetExportStatusCancelled: 取消
 */
typedef NS_ENUM(NSInteger, MNAssetExportStatus) {
    MNAssetExportStatusUnknown = 0,
    MNAssetExportStatusExporting = 2,
    MNAssetExportStatusCompleted = 3,
    MNAssetExportStatusFailed = 4,
    MNAssetExportStatusCancelled = 5
};

/**
进度回调
@param progress 进度信息
*/
typedef void(^MNAssetExportProgressHandler)(float progress);

/**
 输出回调
 @param status 输出状态
 @param error 错误信息(nullable)
 */
typedef void(^MNAssetExportCompletionHandler)(MNAssetExportStatus status, NSError *_Nullable error);

/**导出质量选择*/
typedef NSString *_Nonnull MNAssetExportPresetName;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPresetLowQuality;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPresetMediumQuality;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPresetHighestQuality;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset360x240;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset240x360;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset640x360;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset360x640;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset640x480;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset480x640;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset800x600;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset600x800;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset960x540;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset540x960;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset1024x576;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset576x1024;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset1024x768;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset768x1024;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset1280x960;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset960x1280;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset1152x864;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset864x1152;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset1280x720;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset720x1280;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset1440x1080;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset1080x1440;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset1920x1080;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset1080x1920;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset3840x2160;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset2160x3840;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset1080x1080;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset1024x1024;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset800x800;
FOUNDATION_EXTERN MNAssetExportPresetName const MNAssetExportPreset600x600;

FOUNDATION_EXTERN BOOL MNAssetExportIsEmptySize (CGSize);

@interface MNAssetExporter : NSObject
/**帧率*/
@property (nonatomic) int frameRate;
/**视频路径*/
@property (nonatomic, copy) NSString *filePath;
/**输出路径*/
@property (nonatomic, copy) NSString *outputPath;
/**裁剪片段*/
@property (nonatomic) CMTimeRange timeRange;
/**裁剪区域*/
@property (nonatomic) CGRect outputRect;
/**输出分辨率*/
@property (nonatomic) CGSize renderSize;
/**资源对象*/
@property (nonatomic, strong, readonly) AVAsset *asset;
/**是否针对网络使用进行优化*/
@property (nonatomic) BOOL shouldOptimizeForNetworkUse;
/**导出质量 default MNAssetExportPresetHighestQuality*/
@property (nonatomic, copy) MNAssetExportPresetName presetName;
/**输出视频内容*/
@property (nonatomic, getter=isExportVideoTrack) BOOL exportVideoTrack;
/**输出音频内容*/
@property (nonatomic, getter=isExportAudioTrack) BOOL exportAudioTrack;
/**错误信息(nullable)*/
@property (nonatomic, strong, readonly, nullable) NSError *error;
/**进度信息*/
@property (nonatomic, readonly) float progress;
/**输出状态*/
@property (nonatomic, readonly) MNAssetExportStatus status;

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
- (instancetype)initWithAssetAtPath:(NSString *)filePath;

/**
 依据视/音频本地URL实例化输出者
 @param fileURL 视/音频本地URL
 @return 视/音输出者
 */
- (instancetype)initWithAssetOfURL:(NSURL *)fileURL;

/**
 异步输出
 @param completionHandler 完成回调
 */
- (void)exportAsynchronouslyWithCompletionHandler:(_Nullable MNAssetExportCompletionHandler)completionHandler;

/**
 异步输出
 @param progressHandler 进度回调
 @param completionHandler 完成回调
 */
- (void)exportAsynchronouslyWithProgressHandler:(_Nullable MNAssetExportProgressHandler)progressHandler
                              completionHandler:(_Nullable MNAssetExportCompletionHandler)completionHandler;

/**
 取消任务
 */
- (void)cancel;

/**
 追加媒体资源
 @param asset 资源
 @return 是否追加成功
 */
- (BOOL)appendAsset:(AVAsset *)asset;

/**
 追加媒体资源
 @param filePath 媒体资源路径
 @return 是否追加成功
 */
- (BOOL)appendAssetWithContentsOfFile:(NSString *)filePath;

/**
 追加媒体素材
 @param filePath 媒体资源路径
 @param mediaType 媒体类型
 @return 是否追加成功
 */
- (BOOL)appendAssetWithContentsOfFile:(NSString *)filePath mediaType:(AVMediaType)mediaType;

/**
 追加媒体素材
 @param assetTrack 媒体素材
 @return 是否追加成功
 */
- (BOOL)appendAssetTrack:(AVAssetTrack *)assetTrack;

@end
NS_ASSUME_NONNULL_END
#endif
