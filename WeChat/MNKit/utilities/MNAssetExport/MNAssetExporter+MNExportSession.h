//
//  MNAssetExporter+MNExportSession.h
//  MNKit
//
//  Created by Vincent on 2020/1/2.
//  Copyright © 2020 Vincent. All rights reserved.
//  提供简写方案

#import "MNAssetExporter.h"
#import "MNAssetExportSession.h"

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
                                   progressHandler:(MNAssetExportProgressHandler)progressHandler
                                 completionHandler:(MNAssetExportCompletionHandler)completionHandler;

/**
从视频中提取音频
@param filePath 视频路径
@param outputPath 输出路径
@param progressHandler 进度回调
@param completionHandler 结束回调
*/
+ (void)exportAudioTrackAsynchronouslyWithAssetPath:(NSString *)filePath
                                        outputPath:(NSString *)outputPath
                                   progressHandler:(MNAssetExportProgressHandler)progressHandler
                                 completionHandler:(MNAssetExportCompletionHandler)completionHandler;

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
                               presetName:(NSString *)presetName
                          progressHandler:(MNAssetExportSessionProgressHandler)progressHandler
                        completionHandler:(MNAssetExportSessionCompletionHandler)completionHandler;

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
                                        presetName:(NSString *)presetName
                                    progressHandler:(MNAssetExportSessionProgressHandler)progressHandler
                                 completionHandler:(MNAssetExportSessionCompletionHandler)completionHandler;

/**
从视频中提取音频
@param filePath 视频路径
@param outputPath 输出路径
@param progressHandler 进度回调
@param completionHandler 结束回调
*/
+ (void)exportAudioTrackAsynchronouslyWithAssetPath:(NSString *)filePath
                                        outputPath:(NSString *)outputPath
                                    progressHandler:(MNAssetExportSessionProgressHandler)progressHandler
                                 completionHandler:(MNAssetExportSessionCompletionHandler)completionHandler;

@end
