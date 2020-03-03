//
//  MNAudioRecorder.m
//  MNKit
//
//  Created by Vincent on 2018/7/16.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "MNFileManager.h"
#import "MNAuthenticator.h"

static BOOL audio_recorder_set_session_category (void) {
    NSError *error;
    if (![[[AVAudioSession sharedInstance] category] isEqualToString:AVAudioSessionCategoryRecord]) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
    }
    if (error == nil) [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    return error == nil;
}

static NSDictionary <NSString *, NSNumber *>* audio_recorder_settings (void) {
    static NSDictionary *recorder_settings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recorder_settings = @{AVFormatIDKey:@(kAudioFormatLinearPCM),
                              AVSampleRateKey:@(16000),
                              AVNumberOfChannelsKey:@(1),
                              AVLinearPCMBitDepthKey:@(16),
                              AVLinearPCMIsFloatKey:@(NO),
                              AVEncoderAudioQualityKey:@(AVAudioQualityHigh)};
    });
    return recorder_settings;
}

static AVAudioRecorder * create_audio_recorder (NSString *filePath) {
    NSError *error;
    NSURL *URL = [NSURL fileURLWithPath:filePath];
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc]initWithURL:URL
                                                           settings:audio_recorder_settings()
                                                              error:&error];
    if (!error && recorder) {
        //音量控制
        recorder.meteringEnabled = YES;
        //预备状态
        [recorder prepareToRecord];
    }
    return recorder;
}

@interface MNAudioRecorder ()<AVAudioRecorderDelegate>
@property(nonatomic) NSTimeInterval duration;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) AVAudioSession *session;
@property(nonatomic, strong) AVAudioRecorder *recorder;
@property(nonatomic, getter=isAllowsMicrophoneInput) BOOL allowsMicrophoneInput;
@end

@implementation MNAudioRecorder
+ (instancetype)defaultRecorder {
    return [[MNAudioRecorder alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    self.meteringEnabled = YES;
    [MNAuthenticator requestMicrophoneAuthorizationStatusWithHandler:^(BOOL allowed) {
        self.allowsMicrophoneInput = allowed;
    }];
    return self;
}

#pragma mark - 开始
- (void)record {
    if (self.isRecording) return;
    if (self.allowsMicrophoneInput && audio_recorder_set_session_category() && [_recorder record]) {
        [self openTimer];
        if ([_delegate respondsToSelector:@selector(audioRecorderDidStartRecording:)]) {
            [_delegate audioRecorderDidStartRecording:self];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(audioRecorderRecordingFailed:)]) {
            [_delegate audioRecorderRecordingFailed:self];
        }
    }
}

#pragma mark - 停止
- (void)stop {
    if (!self.isRecording) return;
    [_recorder stop];
}

#pragma mark - 删除
- (BOOL)deleteRecording {
    if (self.isRecording || !_recorder) return NO;
    return [_recorder deleteRecording];
}

#pragma mark - 更新音频测量值
- (void)updateMeters {
    if (_meteringEnabled && _recorder) {
        [_recorder updateMeters];
    }
}

#pragma mark - 获取音频测量值
- (float)peakPowerForChannel:(NSUInteger)channelNumber {
    if (!self.isMeteringEnabled || !self.isRecording) return -160.f;
    [_recorder updateMeters];
    return [_recorder peakPowerForChannel:channelNumber];
}

#pragma mark - 获取音频测量平均值
- (float)averagePowerForChannel:(NSUInteger)channelNumber {
    if (!_meteringEnabled || !self.isRecording) return 0.f;
    [_recorder updateMeters];
    return [_recorder averagePowerForChannel:channelNumber];
}

#pragma mark - 定时器
- (void)openTimer {
    if (_timer) return;
    _duration = 0;
    if (_timeMonitorInterval <= 0.f) return;
    NSTimer *timer = [NSTimer timerWithTimeInterval:self.timeMonitorInterval
                                             target:self
                                           selector:@selector(timeRepeatEvent)
                                           userInfo:nil
                                            repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [timer fire];
    self.timer = timer;
}

- (void)timeRepeatEvent {
    _duration += self.timeMonitorInterval;
    if ([_delegate respondsToSelector:@selector(audioRecorder:didRecordDuration:)]) {
        [_delegate audioRecorder:self didRecordDuration:_duration];
    }
}

- (void)closeTimer {
    if (!_timer) return;
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - Setter
- (void)setFilePath:(NSString *)filePath {
    if (self.isRecording) return;
    if (![MNFileManager createFileAtPath:filePath error:nil]) return;
    _filePath = nil;
    _recorder = nil;
    AVAudioRecorder *recorder = create_audio_recorder(filePath);
    if (recorder) {
        _filePath = filePath.copy;
        recorder.delegate = self;
        recorder.meteringEnabled = self.isMeteringEnabled;
        _recorder = recorder;
    }
}

#pragma mark - Getter
- (BOOL)isRecording {
    return (_recorder && _recorder.isRecording);
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [self closeTimer];
    if (flag) {
        if ([_delegate respondsToSelector:@selector(audioRecorderDidFinishRecording:duration:)]) {
            [_delegate audioRecorderDidFinishRecording:self duration:_duration];
        }
    } else {
        [recorder deleteRecording];
        if ([_delegate respondsToSelector:@selector(audioRecorderRecordingFailed:)]) {
            [_delegate audioRecorderRecordingFailed:self];
        }
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {
    [self closeTimer];
    [recorder deleteRecording];
    if ([_delegate respondsToSelector:@selector(audioRecorderRecordingFailed:)]) {
        [_delegate audioRecorderRecordingFailed:self];
    }
}

#pragma mark - dealloc
- (void)dealloc {
    _delegate = nil;
    _recorder.delegate = nil;
    [_recorder stop];
    _recorder = nil;
}

@end
