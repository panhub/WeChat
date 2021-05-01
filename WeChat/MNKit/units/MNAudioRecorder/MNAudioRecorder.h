//
//  MNRecorder.h
//  MNKit
//
//  Created by Vincent on 2018/7/16.
//  Copyright © 2018年 小斯. All rights reserved.
//  录音

#import <Foundation/Foundation.h>
#if __has_include(<AVFoundation/AVFoundation.h>)
@class MNAudioRecorder;

NS_ASSUME_NONNULL_BEGIN

@protocol MNAudioRecorderDelegate <NSObject>
@optional
- (void)audioRecorderDidStartRecording:(MNAudioRecorder *)recorder;
- (void)audioRecorderDidPauseRecording:(MNAudioRecorder *)recorder;
- (void)audioRecorderDidFinishRecording:(MNAudioRecorder *)recorder;
- (void)audioRecorderDidFailRecording:(MNAudioRecorder *)recorder;
- (void)audioRecorderPeriodicRecording:(MNAudioRecorder *)recorder;
- (void)audioRecorder:(MNAudioRecorder *)recorder periodicPower:(NSArray <NSNumber *>*)powers;
@end


typedef NS_ENUM(int, MNRecordChannel) {
    MNRecordChannelSingle = 1,
    MNRecordChannelDouble
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
/**声道*/
@property(nonatomic) MNRecordChannel channel;
/**质量*/
@property(nonatomic) MNRecordQuality quality;
/**采样率*/
@property(nonatomic) int sampleRate;
/**采样位深 default 'MNRecordBitDepthNon' 不指定*/
@property(nonatomic) MNRecordBitDepth bitDepth;
/**是否浮点采样*/
@property(nonatomic, getter=isFloatKey) BOOL floatKey;
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
#endif
