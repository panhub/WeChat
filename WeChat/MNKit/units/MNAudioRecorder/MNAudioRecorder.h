//
//  MNRecorder.h
//  MNKit
//
//  Created by Vincent on 2018/7/16.
//  Copyright © 2018年 小斯. All rights reserved.
//  录音 .wav

#import <Foundation/Foundation.h>
@class MNAudioRecorder;

NS_ASSUME_NONNULL_BEGIN

@protocol MNAudioRecorderDelegate <NSObject>
@optional
- (void)audioRecorderDidStartRecording:(MNAudioRecorder *)recorder;
- (void)audioRecorderDidPauseRecording:(MNAudioRecorder *)recorder;
- (void)audioRecorderDidFinishRecording:(MNAudioRecorder *)recorder successfully:(BOOL)flag;
- (void)audioRecorderDidFailRecording:(MNAudioRecorder *)recorder;
- (void)audioRecorderPeriodicRecording:(MNAudioRecorder *)recorder;
- (void)audioRecorder:(MNAudioRecorder *)recorder periodicPower:(NSArray <NSNumber *>*)powers;
@end


typedef NS_ENUM(int, MNRecordChannel) {
    MNRecordChannelMono = 1,
    MNRecordChannelStereo
};

typedef NS_ENUM(int, MNRecordQuality) {
    MNRecordQualityMin    = 0,
    MNRecordQualityLow    = 0x20,
    MNRecordQualityMedium = 0x40,
    MNRecordQualityHigh   = 0x60,
    MNRecordQualityMax    = 0x7F
};

typedef NS_ENUM(int, MNRecordBitDepth) {
    MNRecordBitDepthNon = 0,
    MNRecordBitDepth8 = 8,
    MNRecordBitDepth16 = 16,
    MNRecordBitDepth24 = 24,
    MNRecordBitDepth32 = 32
};

@interface MNAudioRecorder : NSObject
/**是否暂停中*/
@property(nonatomic, readonly) BOOL isPausing;
/**是否录音中*/
@property(nonatomic, readonly) BOOL isRecording;
/**事件回调*/
@property(nonatomic, weak, nullable) id<MNAudioRecorderDelegate> delegate;
/**时长*/
@property(nonatomic, readonly) NSTimeInterval duration;
/**声道 默认'MNRecordChannelStereo'*/
@property(nonatomic) MNRecordChannel channel;
/**质量 默认'MNRecordQualityMedium'*/
@property(nonatomic) MNRecordQuality quality;
/**采样率 默认44100*/
@property(nonatomic) int sampleRate;
/**比特深度 (8、16、24、32) 默认 MNRecordBitDepth16
 * 基本上PCM流的质量由两个属性表示: 采样率和比特深度
 * 如果以WAV格式记录PCM使用AVLinearPCMBitDepthKey设置深度即可 使用编码器则以AVEncoderBitRateKey设置比特率
 * 采样率*比特深度*声道数 = 比特率
 */
@property(nonatomic) MNRecordBitDepth bitDepth;
/**录音地址*/
@property(nonatomic, copy) NSString *filePath;
/**错误信息*/
@property(nonatomic, copy, readonly, nullable) NSError *error;
/**分贝可测性*/
@property(nonatomic, getter=isMeteringEnabled) BOOL meteringEnabled;

/**
 即将录音, 创建本地录音文件
 */
- (BOOL)prepareToRecord;

/**
 开始录音
 */
- (BOOL)record;

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
 更新音频测量值
 */
- (BOOL)updateMeters;

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

/**
 定时监听时间
 @param interval 时间间隔
 */
- (void)addPeriodicTimeObserverForInterval:(NSTimeInterval)interval;

/**
 定时监听分贝值
 @param interval 时间间隔
 @param capacity 多少数量的检测值
 */
- (void)addPeriodicPowerObserverForInterval:(NSTimeInterval)interval capacity:(NSInteger)capacity;

@end

NS_ASSUME_NONNULL_END
