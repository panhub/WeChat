//
//  MNAssetExporter+MNExportSession.h
//  MNKit
//
//  Created by Vincent on 2020/1/2.
//  Copyright © 2020 Vincent. All rights reserved.
//  提供简写方案

#import "MNAssetExporter.h"
#if __has_include(<AVFoundation/AVFoundation.h>)
#import "MNAssetExportSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNAssetExporter (MNExportSession)
/**
 提取视频画面
 @param filePath 视频路径
 @param outputPath 输出路径
 @param progressHandler 进度回调
 @param completionHandler 结束回调
 */
+ (void)exportVideoTrackAsynchronouslyWithAssetPath:(NSString *)filePath
                                        outputPath:(NSString *)outputPath
                                   progressHandler:(_Nullable MNAssetExportProgressHandler)progressHandler
                                 completionHandler:(_Nullable MNAssetExportCompletionHandler)completionHandler;

/**
从视频中提取音频
@param filePath 视频路径
@param outputPath 输出路径
@param progressHandler 进度回调
@param completionHandler 结束回调
*/
+ (void)exportAudioTrackAsynchronouslyWithAssetPath:(NSString *)filePath
                                        outputPath:(NSString *)outputPath
                                   progressHandler:(_Nullable MNAssetExportProgressHandler)progressHandler
                                 completionHandler:(_Nullable MNAssetExportCompletionHandler)completionHandler;

@end


@interface MNAssetExportSession (MNExportSession)
/**
输出视频
@param filePath 视频路径
@param outputPath 输出路径
@param presetName 视频质量
@param progressHandler 进度回调
@param completionHandler 结束回调
*/
+ (void)exportAsynchronouslyOfVideoAtPath:(NSString *)filePath
                               outputPath:(NSString *)outputPath
                               presetName:(NSString *_Nullable)presetName
                          progressHandler:(_Nullable MNAssetExportSessionProgressHandler)progressHandler
                        completionHandler:(_Nullable MNAssetExportSessionCompletionHandler)completionHandler;

/**
 提取视频画面
 @param filePath 视频路径
 @param outputPath 输出路径
 @param presetName 视频质量
 @param progressHandler 进度回调
 @param completionHandler 结束回调
 */
+ (void)exportVideoTrackAsynchronouslyWithAssetPath:(NSString *)filePath
                                        outputPath:(NSString *)outputPath
                                        presetName:(NSString *_Nullable)presetName
                                    progressHandler:(_Nullable MNAssetExportSessionProgressHandler)progressHandler
                                 completionHandler:(_Nullable MNAssetExportSessionCompletionHandler)completionHandler;

/**
从视频中提取音频
@param filePath 视频路径
@param outputPath 输出路径
@param progressHandler 进度回调
@param completionHandler 结束回调
*/
+ (void)exportAudioTrackAsynchronouslyWithAssetPath:(NSString *)filePath
                                        outputPath:(NSString *)outputPath
                                    progressHandler:(_Nullable MNAssetExportSessionProgressHandler)progressHandler
                                 completionHandler:(_Nullable MNAssetExportSessionCompletionHandler)completionHandler;

@end
NS_ASSUME_NONNULL_END
#endif
