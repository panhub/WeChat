//
//  WXSpeechView.m
//  WeChat
//
//  Created by Vicent on 2021/3/21.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXSpeechView.h"
#if __has_include(<Speech/Speech.h>)
#import <Speech/Speech.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
@interface WXSpeechView ()<SFSpeechRecognizerDelegate>
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *languageLabel;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UIImageView *speechView;
@property (nonatomic, strong) UIControl *languageControl;
// 语音引擎, 负责提供语音输入
@property (nonatomic, strong) AVAudioEngine *audioEngine;
// 输出语音识别对象的结果
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
// 语音识别器
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
// 处理语音识别请求
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@end

@implementation WXSpeechView
- (void)setFrame:(CGRect)frame {
    [super setFrame:UIScreen.mainScreen.bounds];
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        contentView.backgroundColor = UIColor.whiteColor;
        [self addSubview:contentView];
        self.contentView = contentView;
        
        UILabel *textLabel = [UILabel labelWithFrame:CGRectMake(16.f, 16.f, contentView.width_mn - 32.f, 0.f) text:nil textColor:UIColor.grayColor font:[UIFont systemFontOfSize:17.f]];
        textLabel.hidden = YES;
        textLabel.numberOfLines = 0;
        [contentView addSubview:textLabel];
        self.textLabel = textLabel;
        
        UIControl *languageControl = [[UIControl alloc] init];
        languageControl.top_mn = 25.f;
        languageControl.touchInset = UIEdgeInsetWith(-5.f);
        languageControl.user_info = @"zh_CN";
        languageControl.backgroundColor = UIColor.clearColor;
        [languageControl addTarget:self action:@selector(language) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:languageControl];
        self.languageControl = languageControl;
        
        UILabel *languageLabel = [UILabel labelWithFrame:CGRectZero text:@"普通话" textColor:UIColor.darkTextColor font:UIFontRegular(17.f)];
        languageLabel.numberOfLines = 1;
        languageLabel.textAlignment = NSTextAlignmentCenter;
        [languageLabel sizeToFit];
        [languageControl addSubview:languageLabel];
        self.languageLabel = languageLabel;
        
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectZero image:[UIImage imageNamed:@"language_select_arrow"]];
        arrowView.height_mn = 6.f;
        [arrowView sizeFitToHeight];
        [languageControl addSubview:arrowView];
        self.arrowView = arrowView;
        
        languageControl.height_mn = ceil(languageLabel.height_mn);
        languageControl.width_mn = ceil(languageLabel.width_mn) + ceil(arrowView.width_mn) + 2.f;
        
        arrowView.right_mn = languageControl.width_mn;
        arrowView.centerY_mn = languageLabel.centerY_mn = languageControl.height_mn/2.f;
        languageControl.left_mn = (contentView.width_mn - languageControl.width_mn)/2.f;
        
        UIImageView *speechView = [UIImageView imageViewWithFrame:CGRectZero image:[[UIImage imageNamed:@"wx_speech_input"] imageWithColor:UIColor.whiteColor]];
        speechView.width_mn = 60.f;
        speechView.top_mn = languageControl.bottom_mn + 150.f;
        speechView.centerX_mn = contentView.width_mn/2.f;
        [speechView sizeFitToWidth];
        speechView.backgroundColor = THEME_COLOR;
        speechView.userInteractionEnabled = YES;
        speechView.layer.cornerRadius = speechView.height_mn/2.f;
        speechView.clipsToBounds = YES;
        speechView.touchInset = UIEdgeInsetWith(-5.f);
        [speechView addGestureRecognizer:UILongPressGestureRecognizerCreate(self, .1f, @selector(press:), nil)];
        [contentView addSubview:speechView];
        self.speechView = speechView;
        
        UILabel *hintLabel = [UILabel labelWithFrame:CGRectZero text:@"按住说话" textColor:UIColor.grayColor font:UIFontRegular(14.f)];
        hintLabel.numberOfLines = 1;
        [hintLabel sizeToFit];
        hintLabel.bottom_mn = speechView.top_mn - 20.f;
        hintLabel.centerX_mn = speechView.centerX_mn;
        [contentView addSubview:hintLabel];
        self.hintLabel = hintLabel;
        
        UIButton *backButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 30.f, 30.f) image:[[UIImage imageNamed:@"music_player_back"] imageWithColor:UIColor.darkTextColor] title:nil titleColor:nil titleFont:nil];
        backButton.centerY_mn = speechView.centerY_mn;
        backButton.right_mn = speechView.left_mn/2.f;
        backButton.touchInset = UIEdgeInsetWith(-5.f);
        [backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:backButton];
        self.backButton = backButton;
        
        UIButton *cancelButton = [UIButton buttonWithFrame:CGRectZero image:nil title:@"取消" titleColor:UIColor.darkGrayColor titleFont:[UIFont systemFontOfSize:17.f]];
        [cancelButton sizeToFit];
        cancelButton.hidden = YES;
        cancelButton.height_mn = 35.f;
        cancelButton.width_mn += 20.f;
        cancelButton.center_mn = backButton.center_mn;
        [cancelButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:cancelButton];
        self.cancelButton = cancelButton;
        
        UIButton *sendButton = [UIButton buttonWithFrame:CGRectZero image:nil title:@"发送" titleColor:THEME_COLOR titleFont:[UIFont systemFontOfSize:17.f]];
        [sendButton sizeToFit];
        sendButton.hidden = YES;
        sendButton.height_mn = 35.f;
        sendButton.width_mn += 20.f;
        sendButton.centerY_mn = cancelButton.centerY_mn;
        sendButton.centerX_mn = contentView.width_mn - cancelButton.centerX_mn;
        [sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:sendButton];
        self.sendButton = sendButton;
        
        contentView.height_mn = speechView.bottom_mn + 40.f + MN_TAB_SAFE_HEIGHT;
        contentView.top_mn = self.height_mn;
        contentView.user_info = [NSNumber numberWithFloat:contentView.height_mn];
        
        languageControl.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        hintLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        speechView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        backButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        cancelButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return self;
}

- (instancetype)initWithSpeechHandler:(void(^_Nullable)(NSString *_Nullable))speechHandler {
    if (self = [self initWithFrame:CGRectZero]) {
        self.speechHandler = speechHandler;
    }
    return self;
}

#pragma mark - Speeching
- (void)start {
    
    NSError *error;
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeMeasurement options:AVAudioSessionCategoryOptionDuckOthers error:&error];
    if (error) {
        [self showInfoDialog:@"设置会话类型失败"];
        return;
    }
    [AVAudioSession.sharedInstance setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        [self showInfoDialog:@"设置会话类型失败"];
        return;
    }
    
    if (self.recognitionRequest) [self.recognitionRequest endAudio];
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    self.recognitionRequest.shouldReportPartialResults = YES;
    
    __weak typeof(self) weakself = self;
    
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:self.languageControl.user_info]];
    self.speechRecognizer.delegate = self;
    self.speechRecognizer.queue = NSOperationQueue.new;
    [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) self = weakself;
                if (self.recognitionRequest) [self showInfoDialog:error.localizedDescription];
                [self end];
            });
            return;
        }
        //BOOL isFinal = result.isFinal;
        NSString *string = [[result bestTranscription] formattedString];
        if (string.length <= 0) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) self = weakself;
            self.textLabel.text = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
            [self update];
        });
    }];

    AVAudioFormat *recordingFormat = [[self.audioEngine inputNode] outputFormatForBus:0];
    [[self.audioEngine inputNode] installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        __strong typeof(self) self = weakself;
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    [self.audioEngine prepare];
    
    [self.audioEngine startAndReturnError:&error];
    if (error) {
        [self stop];
        [self showInfoDialog:@"初始化失败"];
        return;
    }
    
    self.textLabel.hidden = NO;
    self.hintLabel.hidden = YES;
    self.backButton.hidden = YES;
    self.sendButton.hidden = YES;
    self.cancelButton.hidden = YES;
    self.languageControl.hidden = YES;
    
    self.speechView.highlighted = YES;
}

- (void)end {
    
    if (!_audioEngine || !_audioEngine.isRunning) return;
    
    [self stop];
    
    self.speechView.highlighted = NO;
    
    if (self.textLabel.text.length) {
        self.textLabel.hidden = NO;
        self.hintLabel.hidden = YES;
        self.sendButton.hidden = NO;
        self.backButton.hidden = YES;
        self.cancelButton.hidden = NO;
        self.languageControl.hidden = YES;
    } else {
        self.hintLabel.hidden = NO;
        self.textLabel.hidden = YES;
        self.backButton.hidden = NO;
        self.sendButton.hidden = YES;
        self.cancelButton.hidden = YES;
        self.languageControl.hidden = NO;
    }
}

- (void)cancel {
    
    [self stop];
    
    self.speechView.highlighted = NO;
    
    if (self.textLabel.text.length) {
        self.textLabel.hidden = NO;
        self.hintLabel.hidden = YES;
        self.sendButton.hidden = NO;
        self.backButton.hidden = YES;
        self.cancelButton.hidden = NO;
        self.languageControl.hidden = YES;
    } else {
        self.hintLabel.hidden = NO;
        self.textLabel.hidden = YES;
        self.backButton.hidden = NO;
        self.sendButton.hidden = YES;
        self.cancelButton.hidden = YES;
        self.languageControl.hidden = NO;
    }
}

- (void)stop {
    [self.audioEngine.inputNode removeTapOnBus:0];
    if (self.audioEngine.isRunning) [self.audioEngine stop];
    [self.recognitionRequest endAudio];
    self.speechRecognizer = nil;
    self.recognitionRequest = nil;
}

- (void)update {
    
    if (self.textLabel.isHidden) return;
    
    NSString *text = self.textLabel.text;
    
    if (!text || text.length <= 0) {
        self.textLabel.height_mn = 0.f;
        self.contentView.height_mn = [self.contentView.user_info floatValue];
        self.contentView.bottom_mn = self.height_mn;
    } else {
        CGSize size = [NSString boundingSizeWithString:text size:CGSizeMake(self.textLabel.width_mn, CGFLOAT_MAX) attributes:@{NSFontAttributeName:self.textLabel.font}];
        self.textLabel.height_mn = size.height;
        if (self.textLabel.bottom_mn > (self.speechView.top_mn - 16.f)) {
            CGFloat m = ceil(self.textLabel.bottom_mn - self.speechView.top_mn + 16.f);
            self.contentView.height_mn += m;
            self.contentView.bottom_mn = self.height_mn;
        }
    }
}

#pragma mark - SFSpeechRecognizerDelegate
// 可用性变化
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {}
#pragma mark - SFSpeechRecognitionTaskDelegate
// 当开始检测音频源中的语音时首先调用此方法
- (void)speechRecognitionDidDetectSpeech:(SFSpeechRecognitionTask *)task {}
// 当识别出一条可用的信息后 会调用
// apple的语音识别服务会根据提供的音频源识别出多个可能的结果 每有一条结果可用 都会调用此方法 */
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription {}
// 当识别完成所有可用的结果后调用
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult {}
// 当不再接受音频输入时调用 即开始处理语音识别任务时调用
- (void)speechRecognitionTaskFinishedReadingAudio:(SFSpeechRecognitionTask *)task {}
// 当语音识别任务被取消时调用
- (void)speechRecognitionTaskWasCancelled:(SFSpeechRecognitionTask *)task {}
// 语音识别任务完成时被调用
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishSuccessfully:(BOOL)successfully {}

#pragma mark - Getter
- (AVAudioEngine *)audioEngine {
    if (!_audioEngine) {
        _audioEngine = [[AVAudioEngine alloc] init];
    }
    return _audioEngine;
}

#pragma mark - Event
- (void)language {
    @weakify(self);
    [[MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        @strongify(self);
        if (buttonIndex == actionSheet.cancelButtonIndex) return;
        CGFloat y = self.languageControl.centerY_mn;
        self.languageControl.autoresizingMask = UIViewAutoresizingNone;
        self.languageLabel.text = buttonIndex == 0 ? @"普通话" : @"英语";
        [self.languageLabel sizeToFit];
        self.languageControl.height_mn = ceil(self.languageLabel.height_mn);
        self.languageControl.width_mn = ceil(self.languageLabel.width_mn + self.arrowView.width_mn + 2.f);
        self.arrowView.right_mn = self.languageControl.width_mn;
        self.arrowView.centerY_mn = self.languageLabel.centerY_mn = self.languageControl.height_mn/2.f;
        self.languageControl.left_mn = (self.contentView.width_mn - self.languageControl.width_mn)/2.f;
        self.languageControl.centerY_mn = y;
        self.languageControl.user_info = buttonIndex == 0 ? @"zh_CN" : @"en_US";
        self.languageControl.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    } otherButtonTitles:@"普通话", @"英语", nil] showInView:self];
}

- (void)press:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (self.speechView.isHighlighted) return;
            [self start];
        } break;
        case UIGestureRecognizerStateCancelled:
        {
            [self cancel];
        } break;
        case UIGestureRecognizerStateEnded:
        {
            [self end];
        } break;
        default:
            break;
    }
}

- (void)send {
    [self __dismiss:YES];
}

- (void)reset {
    
    [self stop];
    
    self.textLabel.text = nil;
    [self update];
    
    self.hintLabel.hidden = NO;
    self.textLabel.hidden = YES;
    self.backButton.hidden = NO;
    self.sendButton.hidden = YES;
    self.cancelButton.hidden = YES;
    self.languageControl.hidden = NO;
}

#pragma mark - Show & Dismiss
- (void)show {
    [self showInView:UIApplication.sharedApplication.keyWindow];
}

- (void)showInView:(UIView *)superview {
    if (self.superview) return;
    if (!superview) superview = UIApplication.sharedApplication.keyWindow;
    [superview addSubview:self];
    [UIView animateWithDuration:.3f animations:^{
        self.contentView.bottom_mn = superview.height_mn;
    }];
}

- (void)dismiss {
    [self __dismiss:NO];
}

- (void)__dismiss:(BOOL)flag {
    if (!self.superview) return;
    [UIView animateWithDuration:.3f animations:^{
        self.contentView.top_mn = self.height_mn;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (flag && self.speechHandler) self.speechHandler(self.textLabel.text);
    }];
}

#pragma mark - Touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEstimatedPropertiesUpdated:(NSSet<UITouch *> *)touches {}

@end
#pragma clang diagnostic pop
#endif
