//
//  MNQuickTime.h
//  MNKit
//
//  Created by Vincent on 2019/12/14.
//  Copyright © 2019 Vincent. All rights reserved.
//  为LivePhoto解决Mov处理方案

#import <Foundation/Foundation.h>
#if __has_include(<AVFoundation/AVFoundation.h>)

/**
 输出状态
 - MNMovExportStatusUnknown: 未知(默认未操作状态)
 - MNMovExportStatusExporting: 输出中
 - MNMovExportStatusCompleted: 输出完成
 - MNMovExportStatusFailed: 操作失败
 - MNMovExportStatusCancelled: 取消
 */
typedef NS_ENUM(NSInteger, MNMovExportStatus) {
    MNMovExportStatusUnknown = 0,
    MNMovExportStatusExporting = 2,
    MNMovExportStatusCompleted = 3,
    MNMovExportStatusFailed = 4,
    MNMovExportStatusCancelled = 5
};

NS_ASSUME_NONNULL_BEGIN

/**
进度回调
@param progress 进度信息
*/
typedef void(^MNMovExportProgressHandler)(float progress);
/**
 输出回调
 @param status 视频路径
 @param error 错误信息(nullable)
 */
typedef void(^MNMovExportCompletionHandler)(MNMovExportStatus status, NSError *_Nullable error);

@interface MNQuickTime : NSObject
/**视频帧率<15-60>*/
@property (nonatomic) int frameRate;
/**错误信息*/
@property (nonatomic, copy, readonly) NSError *error;
/**视频输出路径*/
@property (nonatomic, copy) NSString *outputPath;
/**标识符与图片匹配合成LivePhoto*/
@property (nonatomic, copy) NSString *identifier;
/**进度*/
@property (nonatomic, readonly) float progress;
/**当前状态*/
@property (nonatomic, readonly) MNMovExportStatus status;

/**
依据视频文件实例化输出者
@param videoAsset 资源文件
@return Mov处理实例
*/
- (instancetype)initWithVideoAsset:(AVURLAsset *)videoAsset;

/**
 依据视频URL实例化
 @param URL 视频URL
 @return Mov处理实例
 */
- (instancetype)initWithVideoURL:(NSURL *)URL;

/**
 依据视频路径实例化
 @param videoPath 视频路径
 @return Mov处理实例
 */

- (instancetype)initWithVideoAtPath:(NSString *)videoPath;

/**
 异步处理视频为mov格式
 @param completionHandler 结束回调
 */
- (void)exportAsynchronouslyWithCompletionHandler:(nullable MNMovExportCompletionHandler)completionHandler;

/**
 异步处理视频为mov格式
 @param progressHandler 进度回调
 @param completionHandler 完成回调
 */
- (void)exportAsynchronouslyWithProgressHandler:(nullable MNMovExportProgressHandler)progressHandler
                              completionHandler:(nullable MNMovExportCompletionHandler)completionHandler;

/**
 取消
 */
- (void)cancel;

@end
NS_ASSUME_NONNULL_END
#endif
