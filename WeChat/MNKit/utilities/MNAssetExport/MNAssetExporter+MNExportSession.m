//
//  MNAssetExporter+MNExportSession.m
//  MNKit
//
//  Created by Vincent on 2020/1/2.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNAssetExporter+MNExportSession.h"

@implementation MNAssetExporter (MNExportSession)

+ (void)exportVideoTrackAsynchronouslyWithFilePath:(NSString *)filePath
                                        outputPath:(NSString *)outputPath
                                   progressHandler:(MNAssetExportProgressHandler)progressHandler
                                 completionHandler:(MNAssetExportCompletionHandler)completionHandler
{
    MNAssetExporter *exporter = MNAssetExporter.new;
    exporter.filePath = filePath;
    exporter.outputPath = outputPath;
    exporter.exportAudioTrack = NO;
    [exporter exportAsynchronouslyWithProgressHandler:progressHandler completionHandler:completionHandler];
}

+ (void)exportAudioTrackAsynchronouslyWithFilePath:(NSString *)filePath
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
                        completionHandler:(MNAssetExportSessionCompletionHandler)completionHandler
{
    MNAssetExportSession *exporter = MNAssetExportSession.new;
    exporter.filePath = filePath;
    exporter.outputPath = outputPath;
    exporter.presetName = presetName;
    exporter.outputFileType = AVFileTypeMPEG4;
    [exporter exportAsynchronouslyWithCompletionHandler:completionHandler];
}

+ (void)exportVideoTrackAsynchronouslyWithFilePath:(NSString *)filePath
                                        outputPath:(NSString *)outputPath
                                        presetName:(NSString *)presetName
                                 completionHandler:(MNAssetExportSessionCompletionHandler)completionHandler
{
    MNAssetExportSession *exporter = MNAssetExportSession.new;
    exporter.filePath = filePath;
    exporter.outputPath = outputPath;
    exporter.presetName = presetName;
    exporter.exportAudioTrack = NO;
    exporter.outputFileType = AVFileTypeMPEG4;
    [exporter exportAsynchronouslyWithCompletionHandler:completionHandler];
}

+ (void)exportAudioTrackAsynchronouslyWithFilePath:(NSString *)filePath
                                        outputPath:(NSString *)outputPath
                                 completionHandler:(MNAssetExportSessionCompletionHandler)completionHandler
{
    MNAssetExportSession *exporter = MNAssetExportSession.new;
    exporter.filePath = filePath;
    exporter.outputPath = outputPath;
    exporter.exportVideoTrack = NO;
    exporter.presetName = AVAssetExportPresetAppleM4A;
    exporter.outputFileType = AVFileTypeAppleM4A;
    [exporter exportAsynchronouslyWithCompletionHandler:completionHandler];
}

@end
