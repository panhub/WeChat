//
//  MNAudioRecorder.m
//  MNKit
//
//  Created by Vincent on 2018/7/16.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

@interface MNAudioRecorder ()<AVAudioRecorderDelegate>
@property(nonatomic) NSInteger capacity;
@property(nonatomic) NSTimeInterval timeInterval;
@property(nonatomic) NSTimeInterval powerInterval;
@property(nonatomic, copy) NSError *error;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSTimer *powerTimer;
@property(nonatomic, strong) AVAudioRecorder *recorder;
@property(nonatomic, strong) NSMutableArray <NSNumber *>*powers;
@property(nonatomic, copy) AVAudioSessionCategory audioSessionCategory;
@property(nonatomic, getter=isPausing) BOOL pausing;
@end

@implementation MNAudioRecorder
- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    self.sampleRate = 44100;
    self.meteringEnabled = YES;
    self.bitDepth = MNRecordBitDepth16;
    self.channel = MNRecordChannelStereo;
    self.quality = MNRecordQualityMedium;
    self.powers = @[].mutableCopy;
    self.audioSessionCategory = AVAudioSession.sharedInstance.category;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    return self;
}

#pragma mark - 即将开始
- (BOOL)prepareToRecord {
    if (!_filePath || !self.recorder) return NO;
    self.error = nil;
    return [self.recorder prepareToRecord];
}

#pragma mark - 开始
- (BOOL)record {
    if (!_recorder) return NO;
    if (self.isRecording) return YES;
    if (![self makeRecordSessionActive]) return NO;
    if ([self.recorder record]) {
        self.error = nil;
        self.pausing = NO;
        [self openTimer];
        if ([_delegate respondsToSelector:@selector(audioRecorderDidStartRecording:)]) {
            [_delegate audioRecorderDidStartRecording:self];
        }
        return YES;
    }
    return NO;
}

#pragma mark - 停止
- (void)stop {
    if (_recorder) {
        [_recorder stop];
        self.pausing = NO;
    }
}

#pragma mark - 暂停
- (void)pause {
    if (self.isRecording) {
        [self closeTimer];
        [_recorder pause];
        self.pausing = YES;
        if ([_delegate respondsToSelector:@selector(audioRecorderDidPauseRecording:)]) {
            [_delegate audioRecorderDidPauseRecording:self];
        }
    }
}

#pragma mark - 删除
- (BOOL)deleteRecording {
    if (self.isRecording) return NO;
    return [_recorder deleteRecording];
}

#pragma mark - 更新音频测量值
- (BOOL)updateMeters {
    if (_recorder && _recorder.isMeteringEnabled) {
        [_recorder updateMeters];
        return YES;
    }
    return NO;
}

#pragma mark - 获取音频测量值
- (float)peakPowerForChannel:(NSUInteger)channelNumber {
    if ([self updateMeters]) return [_recorder peakPowerForChannel:channelNumber];
    return 0.f;
}

#pragma mark - 获取音频测量平均值
- (float)averagePowerForChannel:(NSUInteger)channelNumber {
    if ([self updateMeters]) return [_recorder averagePowerForChannel:channelNumber];
    return 0.f;
}

- (void)addPeriodicTimeObserverForInterval:(NSTimeInterval)interval {
    self.timeInterval = interval;
}

- (void)addPeriodicPowerObserverForInterval:(NSTimeInterval)interval capacity:(NSInteger)capacity {
    self.capacity = capacity;
    self.powerInterval = interval;
    if (!_powerTimer && interval > 0.f && self.powers.count < capacity) {
        for (int i = 0; i < capacity - self.powers.count; i++) {
            [self.powers addObject:@(-160.f)];
        }
    }
}

#pragma mark - 定时器
- (void)openTimer {
    if (self.timeInterval > 0.f && !_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:self.timeInterval target:self selector:@selector(time) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [timer fire];
        _timer = timer;
    }
    if (self.capacity > 0 && self.powerInterval > 0.f && !_powerTimer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:self.powerInterval target:self selector:@selector(power) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [timer fire];
        _powerTimer = timer;
    }
}

- (void)power {
    float power = [self peakPowerForChannel:0];
    [self.powers addObject:[NSNumber numberWithFloat:power]];
    if (self.powers.count > self.capacity) [self.powers removeObjectsInRange:NSMakeRange(0, self.powers.count - self.capacity)];
    if (self.powers.count >= self.capacity) {
        NSArray <NSNumber *>*powers = self.powers.copy;
        if ([_delegate respondsToSelector:@selector(audioRecorder:periodicPower:)]) {
            [_delegate audioRecorder:self periodicPower:powers];
        }
    }
}

- (void)time {
    if ([_delegate respondsToSelector:@selector(audioRecorderPeriodicRecording:)]) {
        [_delegate audioRecorderPeriodicRecording:self];
    }
}

- (void)closeTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if (_powerTimer) {
        [_powerTimer invalidate];
        _powerTimer = nil;
    }
}

#pragma mark - 设置会话
- (BOOL)makeRecordSessionActive {
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!error) [[AVAudioSession sharedInstance] setActive:YES error:&error];
    return !error;
}

- (BOOL)renewAudioSessionActive {
    if (!self.audioSessionCategory) return NO;
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:self.audioSessionCategory error:&error];
    if (!error) [[AVAudioSession sharedInstance] setActive:YES error:&error];
    return !error;
}

- (void)didEnterBackgroundNotification:(NSNotification *)notify {
    if (self.isRecording) [self pause];
}

#pragma mark - Getter
- (NSTimeInterval)duration {
    if (_recorder) return _recorder.currentTime;
    return 0.f;
}

- (BOOL)isRecording {
    return (_recorder && _recorder.isRecording);
}

- (AVAudioRecorder *)recorder {
    if (!_recorder) {
        NSMutableDictionary *setings = @{}.mutableCopy;
        // pcm格式
        [setings setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
        // 声道
        [setings setObject:@(self.channel) forKey:AVNumberOfChannelsKey];
        // 采样率
        [setings setObject:@(self.sampleRate) forKey:AVSampleRateKey];
        // 质量
        [setings setObject:@(self.quality) forKey:AVEncoderAudioQualityKey];
        // 每个采样点位数 分为8、16、24、32
        if (self.bitDepth > MNRecordBitDepthNon) [setings setObject:@(self.bitDepth) forKey:AVLinearPCMBitDepthKey];
        NSError *error;
        AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.filePath] settings:setings error:&error];
        if (!error && recorder) {
            recorder.delegate = self;
            recorder.meteringEnabled = self.isMeteringEnabled;
        }
        _error = error;
        _recorder = recorder;
    }
    return _recorder;
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    self.pausing = NO;
    [self closeTimer];
    [self renewAudioSessionActive];
    if (!flag && !self.error) self.error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"录音失败"}];
    if ([_delegate respondsToSelector:@selector(audioRecorderDidFinishRecording:successfully:)]) {
        [_delegate audioRecorderDidFinishRecording:self successfully:flag];
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {
    self.pausing = NO;
    self.error = error;
    [self closeTimer];
    [self renewAudioSessionActive];
    if ([_delegate respondsToSelector:@selector(audioRecorderDidFailRecording:)]) {
        [_delegate audioRecorderDidFailRecording:self];
    }
}

#pragma mark - dealloc
- (void)dealloc {
    [self closeTimer];
    _delegate = nil;
    _recorder.delegate = nil;
    [_recorder stop];
    [_recorder deleteRecording];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
