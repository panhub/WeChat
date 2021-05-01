//
//  WXChatVoiceInputView.m
//  WeChat
//
//  Created by Vincent on 2019/6/7.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChatVoiceInputView.h"
#import "WXChatVoiceRecordView.h"
#import "WXFileModel.h"

typedef NS_ENUM(NSInteger, WXChatVoiceInputState) {
    WXChatVoiceInputStateNormal = 0,
    WXChatVoiceInputStateRecording,
    WXChatVoiceInputStateCancel
};

#define WXChatVoiceNormalTitle     @"按住 说话"
#define WXChatVoiceHighlightedTitle     @"松开 结束"
#define WXChatVoiceNormalTitleColor     [[UIColor darkTextColor] colorWithAlphaComponent:.65f]
#define WXChatVoiceHighlightedTitleColor     [[UIColor darkTextColor] colorWithAlphaComponent:.9f]
#define WXChatVoiceNormalBackgroundColor     [UIColor whiteColor]
#define WXChatVoiceHighlightedBackgroundColor     UIColorWithSingleRGB(220.f)

@interface WXChatVoiceInputView () <MNAudioRecorderDelegate, WXChatVoiceRecordViewDelegate>
@property (nonatomic) CGPoint previousPoint;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) MNAudioRecorder *recorder;
@property (nonatomic, strong) WXChatVoiceRecordView *recordView;
@property (nonatomic, assign) WXChatVoiceInputState state;
@end

@implementation WXChatVoiceInputView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = WXChatVoiceNormalBackgroundColor;
        
        UILabel *titleLabel = [UILabel labelWithFrame:self.bounds text:WXChatVoiceNormalTitle alignment:NSTextAlignmentCenter textColor:WXChatVoiceNormalTitleColor font:UIFontMedium(18.f)];
        titleLabel.userInteractionEnabled = NO;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        [self addGestureRecognizer:UILongPressGestureRecognizerCreate(self, .1f, @selector(handLongPress:), nil)];
    }
    return self;
}

#pragma mark - 长按
- (void)handLongPress:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.previousPoint = [recognizer locationInView:recognizer.view];
            self.backgroundColor = WXChatVoiceHighlightedBackgroundColor;
            self.titleLabel.textColor = WXChatVoiceHighlightedTitleColor;
            [self.recorder prepareToRecord];
            [self.recorder record];
        } break;
        case UIGestureRecognizerStateCancelled:
        {
            [_recordView dismiss];
            self.state = WXChatVoiceInputStateCancel;
            self.backgroundColor = WXChatVoiceNormalBackgroundColor;
            self.titleLabel.textColor = WXChatVoiceNormalTitleColor;
            [self.recorder stop];
        } break;
        case UIGestureRecognizerStateEnded:
        {
            if (self.recordView.state == WXChatVoiceRecordStop) return;
            self.backgroundColor = WXChatVoiceNormalBackgroundColor;
            self.titleLabel.textColor = WXChatVoiceNormalTitleColor;
            [self.recorder stop];
        } break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [recognizer locationInView:recognizer.view];
            self.previousPoint = point;
            if (point.y < -50.f) {
                /// 上滑
                self.recordView.state = WXChatVoiceRecordCancel;
                self.state = WXChatVoiceInputStateCancel;
            } else {
                /// 下滑
                self.recordView.state = WXChatVoiceRecordNormal;
                self.state = WXChatVoiceInputStateRecording;
            }
        } break;
        default:
        {
            [_recordView dismiss];
            self.state = WXChatVoiceInputStateNormal;
            self.backgroundColor = WXChatVoiceNormalBackgroundColor;
            self.titleLabel.textColor = WXChatVoiceNormalTitleColor;
        } break;
    }
}

#pragma mark - MNAudioRecordDelegate
- (void)audioRecorderDidStartRecording:(MNAudioRecorder *)recorder {
    self.state = WXChatVoiceInputStateRecording;
    [self.recordView show];
    if ([self.delegate respondsToSelector:@selector(voiceInputViewDidBeginRecording:)]) {
        [self.delegate voiceInputViewDidBeginRecording:self];
    }
}

- (void)audioRecorderDidFinishRecording:(MNAudioRecorder *)recorder {
    [_recordView dismiss];
    if (self.state == WXChatVoiceInputStateCancel || floor(recorder.duration) < 1.f) {
        /// 撤销语音
        if ([self.delegate respondsToSelector:@selector(voiceInputViewDidCancelRecording:)]) {
            [self.delegate voiceInputViewDidCancelRecording:self];
        }
    } else if (self.state == WXChatVoiceInputStateRecording) {
        /// 发送语音
        self.state = WXChatVoiceInputStateNormal;
        if ([self.delegate respondsToSelector:@selector(voiceInputViewDidEndRecording:)]) {
            [self.delegate voiceInputViewDidEndRecording:recorder.filePath];
        }
    }
}

- (void)audioRecorderRecordingFailed:(MNAudioRecorder *)recorder {
    [_recordView dismiss];
    if ([self.delegate respondsToSelector:@selector(voiceInputViewDidFailedRecording:)]) {
        [self.delegate voiceInputViewDidFailedRecording:self];
    }
}

- (void)audioRecorder:(MNAudioRecorder *)recorder periodicPower:(NSArray <NSNumber *>*)powers {
    self.recordView.power = powers.firstObject.floatValue;
}

- (void)audioRecorderPeriodicRecording:(MNAudioRecorder *)recorder {
    self.recordView.duration = recorder.duration;
}

#pragma mark - Getter
- (MNAudioRecorder *)recorder {
    if (!_recorder) {
        MNAudioRecorder *recorder = [MNAudioRecorder new];
        recorder.delegate = self;
        recorder.meteringEnabled = YES;
        [recorder addPeriodicTimeObserverForInterval:1.f];
        [recorder addPeriodicPowerObserverForInterval:.1f capacity:1];
        NSString *filePath = [WechatHelper.helper.sessionPath stringByAppendingPathComponent:[MNFileHandle fileNameWithExtension:@"wav"]];
        [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
        [NSFileManager.defaultManager createDirectoryAtPath:filePath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil];
        recorder.filePath = filePath;
        _recorder = recorder;
    }
    return _recorder;
}

- (WXChatVoiceRecordView *)recordView {
    if (!_recordView) {
        WXChatVoiceRecordView *recordView = [[WXChatVoiceRecordView alloc] initWithFrame:UIEdgeInsetsInsetRect([[UIScreen mainScreen] bounds], UIEdgeInsetsMake(0.f, 0.f, self.superview.frame.size.height, 0.f))];
        recordView.delegate = self;
        _recordView = recordView;
    }
    return _recordView;
}

#pragma mark - WXChatVoiceRecordViewDelegate
- (void)voiceRecordTimeoutNeedStop:(int)duration {
    self.backgroundColor = WXChatVoiceNormalBackgroundColor;
    self.titleLabel.textColor = WXChatVoiceNormalTitleColor;
    [self.recorder stop];
}

@end
