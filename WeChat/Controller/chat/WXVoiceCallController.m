//
//  WXVoiceCallController.m
//  JLChat
//
//  Created by Vincent on 2020/2/6.
//  Copyright © 2020 AiZhe. All rights reserved.
//

#import "WXVoiceCallController.h"
#import "WXCallTransitionAnimator.h"
#import "WXCallButton.h"

typedef NS_ENUM(NSInteger, VoiceCallButtonTag) {
    VoiceCallButtonTagDecline = 10,
    VoiceCallButtonTagAnswer,
    VoiceCallButtonTagMute,
    VoiceCallButtonTagSpeaker
};

#define WXVoiceCallAnswerTimerName  @"com.wx.voice.call.answer.timer.name"
#define WXVoiceCallWaitingTimerName  @"com.wx.voice.call.waiting.timer.name"

@interface WXVoiceCallController ()<UIAlertViewDelegate>
// 等待提示点个数标记
@property (nonatomic) int callIndex;
// 等待时间记录
@property (nonatomic) int waitIndex;
// 通话时长
@property (nonatomic) int callDuration;
// 是否接通
@property (nonatomic) WXVoiceCallState state;
// 标记是否可手势返回
@property (nonatomic) BOOL interactiveTransitionEnabled;
// 对方账户昵称
@property (nonatomic, strong) UILabel *nickLabel;
// 等待中提示
@property (nonatomic, strong) UILabel *hintLabel;
// 记录通话时长
@property (nonatomic, strong) UILabel *durationLabel;
// 取消/挂断按钮
@property (nonatomic, strong) WXCallButton *declineButton;
// 接通按钮
@property (nonatomic, strong) WXCallButton *answerButton;
// 静音按钮
@property (nonatomic, strong) WXCallButton *muteButton;
// 免提按钮
@property (nonatomic, strong) WXCallButton *speakerButton;
@end

@implementation WXVoiceCallController
- (void)initialized {
    [super initialized];
    self.callIndex = -1;
}

- (instancetype)initWithUser:(WXUser *)user style:(WXVoiceCallStyle)style {
    if (self = [super init]) {
        self.user = user;
        self.style = style;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = UIColor.clearColor;
    self.navigationBar.shadowColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.blackColor;
    
    // 背景图
    UIImage *effectImage = [self.user.avatar blurEffectWithRadius:5.f tintColor:[UIColor colorWithWhite:0.1 alpha:0.88] saturationDeltaFactor:1.9f maskImage:nil];
    UIImageView *backgroundView = [UIImageView imageViewWithFrame:self.contentView.bounds image:effectImage];
    backgroundView.clipsToBounds = YES;
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:backgroundView];
    
    // 头像
    CGFloat avatarWH = 360.f/1242.f*self.contentView.width_mn;
    UIButton *avatarButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, avatarWH, avatarWH) image:self.user.avatar title:nil titleColor:nil titleFont:nil];
    avatarButton.centerX_mn = self.contentView.width_mn/2.f;
    avatarButton.bottom_mn = 975.f/2208.f*self.contentView.height_mn;
    avatarButton.layer.cornerRadius = 5.f;
    avatarButton.clipsToBounds = YES;
    [self.contentView addSubview:avatarButton];
    
    //昵称
    UILabel *nickLabel = [UILabel labelWithFrame:CGRectZero text:self.user.name textAlignment:NSTextAlignmentCenter textColor:UIColorWithAlpha(UIColor.whiteColor, .95f) font:[UIFont systemFontOfSize:29.f]];
    nickLabel.top_mn = avatarButton.bottom_mn + 21.f;
    [nickLabel sizeToFit];
    nickLabel.centerX_mn = self.contentView.width_mn/2.f;
    [self.contentView addSubview:nickLabel];
    
    // 提示信息
    UILabel *hintLabel = [UILabel labelWithFrame:CGRectZero text:(self.style == WXVoiceCallSend ? @"正在等待对方接受邀请" : @"邀请你语音通话") textAlignment:NSTextAlignmentCenter textColor:UIColorWithAlpha(UIColor.whiteColor, .95f) font:[UIFont systemFontOfSize:15.f]];
    hintLabel.top_mn = nickLabel.bottom_mn + 12.f;
    hintLabel.height_mn = 15.f;
    hintLabel.width_mn = self.contentView.width_mn;
    [self.contentView addSubview:hintLabel];
    self.hintLabel = hintLabel;
    
    // 底部按钮
    NSMutableArray <NSString *>*imgs = @[@"call_decline", @"call_answer"].mutableCopy;
    NSMutableArray <NSString *>*titles = @[@"拒绝", @"接听"].mutableCopy;
    NSMutableArray <NSNumber *>*tags = @[@(VoiceCallButtonTagDecline), @(VoiceCallButtonTagAnswer)].mutableCopy;
    if (self.style == WXVoiceCallSend) {
        [imgs removeLastObject];
        [titles removeAllObjects];
        [titles addObject:@"取消"];
        [tags removeLastObject];
    }
    CGFloat x = 37.f; // 左右间隔
    CGFloat wh = 201.f/1242.f*self.contentView.width_mn;
    [imgs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger tag = tags[idx].integerValue;
        WXCallButton *button = [[WXCallButton alloc] init];
        button.size_mn = CGSizeMake(wh, wh + 28.f);
        button.bottom_mn = self.contentView.height_mn - MAX(25.f, (UITabSafeHeight() + 8.f));
        if (self.style == WXVoiceCallSend) {
            button.centerX_mn = self.contentView.width_mn/2.f;
        } else {
            button.left_mn = idx == 0 ? x : (self.contentView.width_mn - wh - x);
        }
        button.title = titles[idx];
        button.image = [UIImage imageNamed:obj];
        button.tag = tag;
        if (tag == VoiceCallButtonTagDecline) {
            self.declineButton = button;
        } else {
            self.answerButton = button;
        }
        [button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
    }];
    
    [imgs removeAllObjects];
    [titles removeAllObjects];
    [tags removeAllObjects];
    [imgs addObjectsFromArray:@[@"call_mute", @"call_speaker"]];
    [titles addObjectsFromArray:@[@"静音", @"免提"]];
    [tags addObjectsFromArray:@[@(VoiceCallButtonTagMute), @(VoiceCallButtonTagSpeaker)]];
    [imgs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger tag = tags[idx].integerValue;
        WXCallButton *button = [[WXCallButton alloc] initWithFrame:self.declineButton.frame];
        button.left_mn = idx == 0 ? x : (self.contentView.width_mn - wh - x);
        button.title = titles[idx];
        button.image = [UIImage imageNamed:obj];
        button.selectedImage = [UIImage imageNamed:[obj stringByAppendingString:@"HL"]];
        button.tag = tag;
        button.alpha = 0.f;
        if (tag == VoiceCallButtonTagMute) {
            self.muteButton = button;
        } else {
            self.speakerButton = button;
        }
        [button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
    }];
    
    UILabel *durationLabel = [UILabel labelWithFrame:CGRectZero text:@"00:01" textAlignment:NSTextAlignmentCenter textColor:UIColorWithAlpha(UIColor.whiteColor, .95f) font:[UIFont systemFontOfSize:16.f]];
    durationLabel.hidden = YES;
    [durationLabel sizeToFit];
    durationLabel.centerX_mn = self.contentView.width_mn/2.f;
    durationLabel.bottom_mn = self.declineButton.top_mn - 35.f;
    durationLabel.touchInset = UIEdgeInsetWith(-10.f);
    [self.contentView addSubview:durationLabel];
    self.durationLabel = durationLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    @weakify(self);
    [self.durationLabel handTapConfiguration:nil eventHandler:^(id sender) {
        @strongify(self);
        [self editCallDuration];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstAppear) [self beginWaitingTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - Event
// 按钮点击
- (void)buttonTouchUpInside:(WXCallButton *)button {
    if (button.tag == VoiceCallButtonTagDecline) {
        [self declineCalling];
    } else if (button.tag == VoiceCallButtonTagAnswer) {
        [self beginAnswer];
    } else {
        button.selected = !button.selected;
    }
}

// 开启通话模式
- (void)beginAnswer {
    dispatch_timer_cancel(WXVoiceCallWaitingTimerName);
    self.hintLabel.text = @"连接中";
    self.state = WXVoiceCallStateAnswer;
    self.view.userInteractionEnabled = NO;
    dispatch_after_main(.5f, ^{
        self.declineButton.centerX_mn = self.contentView.width_mn/2.f;
        [UIView animateWithDuration:.25f animations:^{
            self.answerButton.alpha = 0.f;
            self.muteButton.alpha = self.speakerButton.alpha = 1.f;
        } completion:^(BOOL finished) {
            self.state = WXVoiceCallStateAnswer;
            self.declineButton.title = @"挂断";
            self.hintLabel.hidden = YES;
            self.durationLabel.hidden = NO;
            [self beginAnswerTimer];
            self.view.userInteractionEnabled = YES;
        }];
    });
}

// 挂断
- (void)declineCalling {
    [self endWaitingTimer];
    [self endAnswerTimer];
    if (self.state == WXVoiceCallStateWaiting) self.state = WXVoiceCallStateDecline;
    if (self.didEndCallHandler) self.didEndCallHandler(self);
    [MNPlayer playSoundWithFilePath:[WeChatBundle pathForResource:@"call_close" ofType:@"wav" inDirectory:@"sound"] shake:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

// 手动编辑通话时长
- (void)editCallDuration {
    [self endAnswerTimer];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"修改通话时长"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"确定", nil];
    alertView.delegate = self;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = @"请输入通话时长";
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) return;
    UITextField *textField = [alertView textFieldAtIndex:0];
    int duration = textField.text.intValue;
    if (duration <= 0) {
        [UIAlertView showAlertWithTitle:nil message:@"通话时长不合法" cancelButtonTitle:@"确定"];
    } else {
        self.callDuration = duration;
        [self updateCallDuration];
    }
}

// 更新通话时长
- (void)updateCallDuration {
    self.durationLabel.text = [NSDate playTimeStringWithInterval:@(self.callDuration)];
    [self.durationLabel sizeToFit];
    self.durationLabel.centerX_mn = self.contentView.width_mn/2.f;
}

#pragma mark - Timer
- (void)beginWaitingTimer {
    self.callIndex = -1;
    self.hintLabel.text = self.style == WXVoiceCallSend ? @"正在等待对方接受邀请" : @"邀请你语音通话";
    @weakify(self);
    dispatch_timer_main(WXVoiceCallWaitingTimerName, .7f, ^{
        @strongify(self);
        self.callIndex ++;
        NSString *text = [self.hintLabel.text stringByReplacingOccurrencesOfString:@"." withString:@""];
        if (self.callIndex == 1) {
            text = [text stringByAppendingString:@"."];
        } else if (self.callIndex == 2) {
            text = [text stringByAppendingString:@".."];
        } else if (self.callIndex == 3) {
            text = [text stringByAppendingString:@"..."];
        }
        if (self.callIndex >= 3) {
            self.callIndex = -1;
            if (self.style == WXVoiceCallSend) self.waitIndex ++;
        }
        self.hintLabel.text = text;
        if (self.waitIndex >= 20) {
            self.state = WXVoiceCallStateRefuse;
            [self declineCalling];
        }
    });
}

- (void)endWaitingTimer {
    dispatch_timer_cancel(WXVoiceCallWaitingTimerName);
}

- (void)beginAnswerTimer {
    @weakify(self);
    dispatch_timer_main(WXVoiceCallAnswerTimerName, 1.f, ^{
        @strongify(self);
        self.callDuration ++;
        [self updateCallDuration];
    });
}

- (void)endAnswerTimer {
    dispatch_timer_cancel(WXVoiceCallAnswerTimerName);
}

#pragma mark - Getter
- (NSString *)desc {
    if (self.style == WXVoiceCallSend) {
        if (self.state == WXVoiceCallStateDecline) {
            return @"已取消";
        } else if (self.state == WXVoiceCallStateRefuse) {
            return @"对方已拒绝";
        }
        return [NSString stringWithFormat:@"通话时长 %@", self.durationLabel.text];
    }
    if (self.state == WXVoiceCallStateDecline) {
        return @"已拒绝";
    } else if (self.state == WXVoiceCallStateRefuse) {
        return @"对方已取消";
    }
    return [NSString stringWithFormat:@"通话时长 %@", self.durationLabel.text];
}

#pragma mark - Overwrite
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIImage *image = [UIImage imageNamed:@"call_close_full"];
    UIView *leftBarView = [[UIView alloc] initWithFrame:CGRectZero];
    leftBarView.size_mn = CGSizeMultiplyToWidth(image.size, 30.f);
    UIButton *leftBarButton = [UIButton buttonWithFrame:leftBarView.bounds image:image title:nil titleColor:nil titleFont:nil];
    [leftBarButton setBackgroundImage:image forState:UIControlStateHighlighted];
    if (self.style == WXVoiceCallSend) {
        [leftBarButton addTarget:self action:@selector(beginAnswer) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [leftBarButton addTarget:self action:@selector(declineCalling) forControlEvents:UIControlEventTouchUpInside];
    }
    leftBarView.width_mn += 8.f;
    leftBarView.height_mn += 4.f;
    leftBarButton.right_mn = leftBarView.width_mn;
    leftBarButton.bottom_mn = leftBarView.height_mn;
    leftBarButton.touchInset = UIEdgeInsetsMake(-4.f, -8.f, 0.f, 0.f);
    [leftBarView addSubview:leftBarButton];
    return leftBarView;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    WXCallTransitionAnimator *animator = WXCallTransitionAnimator.new;
    animator.transitionOperation = MNControllerTransitionOperationPush;
    return animator;
}

- (MNTransitionAnimator *)popTransitionAnimator {
    WXCallTransitionAnimator *animator = WXCallTransitionAnimator.new;
    animator.decline = self.state == WXVoiceCallStateDecline || self.state == WXVoiceCallStateRefuse;
    animator.transitionOperation = MNControllerTransitionOperationPop;
    return animator;
}

- (void)dealloc {
    [self endWaitingTimer];
    [self endAnswerTimer];
}

@end
