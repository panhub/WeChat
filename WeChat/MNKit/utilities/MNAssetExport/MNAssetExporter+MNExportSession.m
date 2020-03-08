//
//  MNAssetExporter+MNExportSession.m
//  MNKit
//
//  Created by Vincent on 2020/1/2.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNAssetExporter+MNExportSession.h"

@implementation MNAssetExporter (MNExportSession)

+ (void)exportVideoTrackAsynchronouslyWithAssetPath:(NSString *)filePath
                                        outputPath:(NSString *)outputPath
                                   progressHandler:(MNAssetExportProgressHandler)progressHandler
                                 completionHandler:(MNAssetExportCompletionHandler)completionHandler
{
    MNAssetExporter *exporter = MNAssetExporter.new;
    exporter.filePath = filePath;
    exporter.outputPath = outputPath;
    exporter.exportAudioTrack = NO;
    exporter.presetName = MNAssetExportPresetHighestQuality;
    [exporter exportAsynchronouslyWithProgressHandler:progressHandler completionHandler:completionHandler];
}

+ (void)exportAudioTrackAsynchronouslyWithAssetPath:(NSString *)filePath
                                        outputPath:(NSString *)outputPath
                                   progressHandler:(MNAssetExportProgressHandler)progressHandler
                                 completionHandler:(MNAssetExportCompletionHandler)completionHandler
{
    MNAssetExporter *exporter = MNAssetExporter.new;
    exporter.filePath = filePath;
    exporter.outputPath = outputPath;
    exporter.exportVideoTrack = NO;
    [exporter exportAsynchronouslyWithProgressHandler:progressHandler completionHandler:completionHandler];
}

@end

@implementation MNAssetExportSession (MNExportSession)

+ (void)exportAsynchronouslyOfVideoAtPath:(NSString *)filePath
                               outputPath:(NSString *)outputPath
                               presetName:(NSString *)presetName
                          progressHandler:(MNAssetExportSessionProgressHandler)progressHandler
                        completionHandler:(MNAssetExportSessionCompletionHandler)completionHandler
{
    MNAssetExportSession *exporter = MNAssetExportSession.new;
    exporter.filePath = filePath;
    exporter.outputPath = outputPath;
    exporter.presetName = presetName;
    exporter.outputFileType = AVFileTypeMPEG4;
    [exporter exportAsynchronouslyWithProgressHandler:progressHandler completionHandler:completionHandler];
}

+ (void)exportVideoTrackAsynchronouslyWithAssetPath:(NSString *)filePath
                                        outputPath:(NSString *)outputPath
                                        presetName:(NSString *)presetName
                                    progressHandler:(MNAssetExportSessionProgressHandler)progressHandler
                                 completionHandler:(MNAssetExportSessionCompletionHandler)completionHandler
{
    MNAssetExportSession *exporter = MNAssetExportSession.new;
    exporter.filePath = filePath;
    exporter.outputPath = outputPath;
    exporter.presetName = presetName;
    exporter.exportAudioTrack = NO;
    exporter.outputFileType = AVFileTypeMPEG4;
    [exporter exportAsynchronouslyWithProgressHandler:progressHandler completionHandler:completionHandler];
}

+ (void)exportAudioTrackAsynchronouslyWithAssetPath:(NSString *)filePath
                                        outputPath:(NSString *)outputPath
                                    progressHandler:(MNAssetExportSessionProgressHandler)progressHandler
                                 completionHandler:(MNAssetExportSessionCompletionHandler)completionHandler
{
    MNAssetExportSession *exporter = MNAssetExportSession.new;
    exporter.filePath = filePath;
    exporter.outputPath = outputPath;
    exporter.exportVideoTrack = NO;
    exporter.presetName = AVAssetExportPresetAppleM4A;
    exporter.outputFileType = AVFileTypeAppleM4A;
    [exporter exportAsynchronouslyWithProgressHandler:progressHandler completionHandler:completionHandler];
}

@end
