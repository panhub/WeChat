//
//  MNAudioConvert.h
//  MNKit
//
//  Created by Vincent on 2018/7/20.
//  Copyright © 2018年 小斯. All rights reserved.
//  音频转码

#import <Foundation/Foundation.h>

typedef void(^MNAudioConvertCallback)(NSString *filePath);

@interface MNAudioConvert : NSObject

#pragma mark - WavToMp3

/**
 同步转码MP3<录转同步, 内部使用分线程>
 @param wavPath 录音文件地址
 @param savePath mp3地址
 @param completion 结束回调
 */
+ (void)convertWavToMp3Sync:(NSString *)wavPath
                   savePath:(NSString *)savePath
                 completion:(MNAudioConvertCallback)completion;

void dispatch_convert_mp3_sync (NSString *wavPath, NSString *savePath, MNAudioConvertCallback callback);

/**
 录制完成后转码<内部使用分线程>
 @param wavPath 录音文件地址
 @param savePath mp3地址
 @param completion 结束回调
 */
+ (void)convertWavToMp3:(NSString *)wavPath
               savePath:(NSString *)savePath
             completion:(MNAudioConvertCallback)completion;

void dispatch_convert_mp3 (NSString *wavPath, NSString *savePath, MNAudioConvertCallback callback);


#pragma mark - WavToAmr
/**
 同步Wav转Amr
 @param wavPath wav文件路径
 @param savePath Amr保存路径
 @return 是否转换成功
 */
+ (BOOL)convertWavToAmr:(NSString *)wavPath savePath:(NSString *)savePath;

/**
 异步Wav转Amr
 @param wavPath wav文件路径
 @param savePath Amr保存路径
 @param completion 结束回调
 */
+ (void)convertWavToAmr:(NSString *)wavPath
               savePath:(NSString *)savePath
             completion:(MNAudioConvertCallback)completion;


#pragma mark - AmrToWav
/**
 同步AmrToWav
 @param amrPath amr文件路径
 @param savePath wav保存路径
 @return 是否转换成功
 */
+ (BOOL)convertAmrToWav:(NSString *)amrPath savePath:(NSString *)savePath;

/**
 异步AmrToWav
 @param amrPath amr文件路径
 @param savePath wav保存路径
 @param completion 结束回调
 */
+ (void)convertAmrToWav:(NSString *)amrPath
               savePath:(NSString *)savePath
             completion:(MNAudioConvertCallback)completion;

@end
