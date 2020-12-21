//
//  MNRecorder.h
//  MNKit
//
//  Created by Vincent on 2018/7/16.
//  Copyright © 2018年 小斯. All rights reserved.
//  录音

#import <Foundation/Foundation.h>
@class MNAudioRecorder;

@protocol MNAudioRecorderDelegate <NSObject>
@optional
- (void)audioRecorderDidStartRecording:(MNAudioRecorder *)recorder;
- (void)audioRecorderDidFinishRecording:(MNAudioRecorder *)recorder duration:(int)duration;
- (void)audioRecorderRecordingFailed:(MNAudioRecorder *)recorder;
- (void)audioRecorder:(MNAudioRecorder *)recorder didRecordDuration:(int)duration;
@end

@interface MNAudioRecorder : NSObject
/**是否正在录音*/
@property(nonatomic, readonly, getter=isRecording) BOOL recording;
/**事件回调*/
@property(nonatomic, weak, readwrite) id<MNAudioRecorderDelegate> delegate;
/**时长*/
@property(nonatomic, readonly) int duration;
/**录音地址*/
@property(nonatomic, copy) NSString *filePath;
/**分贝可测性*/
@property(nonatomic, getter=isMeteringEnabled) BOOL meteringEnabled;

/**
 快捷初始化
 */
+ (instancetype)defaultRecorder;

/**
 开始录音
 */
- (void)record;

/**
 停止录音
 */
- (void)stop;

/**
 暂停录音
 */
- (void)pause;

/**
 删除录音
 */
- (BOOL)deleteRecording;

/**
 重置
 */
- (void)reset;

/**
 更新音频测量值
 */
- (void)updateMeters;

/**
 获取指定声道音频测量值
 @param channelNumber 指定声道
 @return 测量值
 */
- (float)peakPowerForChannel:(NSUInteger)channelNumber;

/**
 获取指定声道平均音频测量值
 @param channelNumber 指定声道
 @return 平均测量值
 */
- (float)averagePowerForChannel:(NSUInteger)channelNumber;

@end
