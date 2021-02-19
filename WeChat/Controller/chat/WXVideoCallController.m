//
//  WXVideoCallController.m
//  JLChat
//
//  Created by Vincent on 2020/2/7.
//  Copyright © 2020 AiZhe. All rights reserved.
//

#import "WXVideoCallController.h"
#import "WXCallTransitionAnimator.h"
#import "WXCallButton.h"
#import "WXUser.h"
#import "MNPlayView.h"

typedef NS_ENUM(NSInteger, VideoCallButtonTag) {
    VideoCallButtonTagDecline = 10,
    VideoCallButtonTagAnswer,
    VideoCallButtonTagVoice,
    VideoCallButtonTagCamera
};

#define WXVideoCallAnswerTimerName  @"com.wx.video.call.answer.timer.name"
#define WXVideoCallWaitingTimerName  @"com.wx.video.call.waiting.timer.name"

@interface WXVideoCallController ()<MNAssetPickerDelegate, UIAlertViewDelegate, MNPlayViewDelegate, MNPlayerDelegate>
// 等待提示点个数标记
@property (nonatomic) int callIndex;
// 等待时间记录
@property (nonatomic) int waitIndex;
// 通话时长
@property (nonatomic) int callDuration;
// 是否接通
@property (nonatomic) WXVideoCallState state;
// 对方账户昵称
@property (nonatomic, strong) UILabel *nickLabel;
// 等待中提示
@property (nonatomic, strong) UILabel *hintLabel;
// 记录通话时长
@property (nonatomic, strong) UILabel *durationLabel;
// 对方账户头像
@property (nonatomic, strong) UIButton *avatarButton;
// 背景播放
@property (nonatomic, strong) MNPlayView *backgroundPlayView;
// 右角影像播放
@property (nonatomic, strong) MNPlayView *badgePlayView;
// 背景图
@property (nonatomic, strong) UIImageView *backgroundImageView;
// 右角图
@property (nonatomic, strong) UIImageView *badgeImageView;
// 顶部遮罩背景
@property (nonatomic, strong) UIImageView *topMaskView;
// 底部遮罩背景
@property (nonatomic, strong) UIImageView *bottomMaskView;
// 未接通切换语音按钮
@property (nonatomic, strong) WXCallButton *switchButton;
// 取消/挂断按钮
@property (nonatomic, strong) WXCallButton *declineButton;
// 接通按钮
@property (nonatomic, strong) WXCallButton *answerButton;
// 接通后切换语音按钮
@property (nonatomic, strong) WXCallButton *voiceButton;
// 切换摄像头按钮
@property (nonatomic, strong) WXCallButton *cameraButton;
// 背景视频播放
@property (nonatomic, strong) MNPlayer *backgroundPlayer;
// 右角视频播放
@property (nonatomic, strong) MNPlayer *badgePlayer;
@end

@implementation WXVideoCallController
- (instancetype)initWithUser:(WXUser *)user style:(WXVideoCallStyle)style {
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
    UIImageView *backgroundImageView = [UIImageView imageViewWithFrame:self.contentView.bounds image:nil];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.clipsToBounds = YES;
    [self.contentView addSubview:backgroundImageView];
    self.backgroundImageView = backgroundImageView;
    
    UILabel *backgroundLabel = [UILabel labelWithFrame:backgroundImageView.bounds text:@"点击添加视频或图片" alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha(UIColor.whiteColor, .95f) font:[UIFont systemFontOfSize:17.f]];
    backgroundLabel.backgroundColor = UIColor.blackColor;
    backgroundImageView.image = backgroundLabel.snapshotImage;
    
    MNPlayView *backgroundPlayView = [[MNPlayView alloc] initWithFrame:backgroundImageView.frame];
    backgroundPlayView.alpha = 0.f;
    backgroundPlayView.delegate = self;
    backgroundPlayView.clipsToBounds = YES;
    backgroundPlayView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundPlayView.touchEnabled = YES;
    backgroundPlayView.scrollEnabled = NO;
    [self.contentView addSubview:backgroundPlayView];
    self.backgroundPlayView = backgroundPlayView;
    
    // 对方账户头像
    CGFloat avatarWH = 200.f/1242.f*self.contentView.width_mn;
    UIButton *avatarButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, avatarWH, avatarWH) image:self.user.avatar title:nil titleColor:nil titleFont:nil];
    avatarButton.right_mn = self.contentView.width_mn - 17.f;
    avatarButton.top_mn = self.navigationBar.leftBarItem.top_mn - self.navigationBar.leftBarItem.touchInset.top;
    avatarButton.layer.cornerRadius = 5.f;
    avatarButton.clipsToBounds = YES;
    avatarButton.userInteractionEnabled = NO;
    [self.contentView addSubview:avatarButton];
    self.avatarButton = avatarButton;
    
    /// 对方账户昵称
    UILabel *nickLabel = [UILabel labelWithFrame:CGRectZero text:self.user.nickname alignment:NSTextAlignmentRight textColor:UIColorWithAlpha(UIColor.whiteColor, .95f) font:[UIFont systemFontOfSize:29.f]];
    [nickLabel sizeToFit];
    nickLabel.right_mn = avatarButton.left_mn - 13.f;
    [self.contentView addSubview:nickLabel];
    self.nickLabel = nickLabel;
    
    // 提示信息
    UILabel *hintLabel = [UILabel labelWithFrame:CGRectZero text:(self.style == WXVideoCallSend ? @"正在等待对方接受邀请" : @"邀请你视频通话") alignment:NSTextAlignmentRight textColor:UIColorWithAlpha(UIColor.whiteColor, .95f) font:[UIFont systemFontOfSize:15.f]];
    hintLabel.height_mn = hintLabel.font.pointSize;
    hintLabel.width_mn = nickLabel.right_mn;
    hintLabel.right_mn = nickLabel.right_mn;
    hintLabel.userInteractionEnabled = NO;
    [self.contentView addSubview:hintLabel];
    self.hintLabel = hintLabel;
    
    CGFloat y = (avatarWH - nickLabel.height_mn - hintLabel.height_mn - 1.f)/2.f;
    nickLabel.top_mn = avatarButton.top_mn + y;
    hintLabel.top_mn = nickLabel.bottom_mn + 1.f;
    
    // 底部按钮
    NSMutableArray <NSString *>*imgs = @[@"call_decline", @"call_video_answer"].mutableCopy;
    NSMutableArray <NSString *>*titles = @[@"拒绝", @"接听"].mutableCopy;
    NSMutableArray <NSNumber *>*tags = @[@(VideoCallButtonTagDecline), @(VideoCallButtonTagAnswer)].mutableCopy;
    if (self.style == WXVideoCallSend) {
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
        button.bottom_mn = self.contentView.height_mn - MAX(25.f, (MN_TAB_SAFE_HEIGHT + 5.f));
        if (self.style == WXVideoCallSend) {
            button.centerX_mn = self.contentView.width_mn/2.f;
        } else {
            button.left_mn = idx == 0 ? x : (self.contentView.width_mn - wh - x);
        }
        button.title = titles[idx];
        button.image = [UIImage imageNamed:obj];
        button.tag = tag;
        if (tag == VideoCallButtonTagDecline) {
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
    [imgs addObjectsFromArray:@[@"call_video_voice", @"call_video_camera"]];
    [titles addObjectsFromArray:@[@"切到语音通话", @"切换摄像头"]];
    [tags addObjectsFromArray:@[@(VideoCallButtonTagVoice), @(VideoCallButtonTagCamera)]];
    [imgs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger tag = tags[idx].integerValue;
        WXCallButton *button = [[WXCallButton alloc] initWithFrame:self.declineButton.frame];
        button.left_mn = idx == 0 ? x : (self.contentView.width_mn - wh - x);
        button.title = titles[idx];
        button.image = [UIImage imageNamed:obj];
        button.tag = tag;
        button.alpha = 0.f;
        if (tag == VideoCallButtonTagVoice) {
            self.voiceButton = button;
        } else {
            self.cameraButton = button;
        }
        [button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
    }];
    
    // 切换语音视图
    WXCallButton *switchButton = [[WXCallButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 42.f, 57.f)];
    switchButton.title = @"切到语音接听";
    switchButton.image = [UIImage imageNamed:@"call_voice_icon"];
    switchButton.bottom_mn = self.declineButton.top_mn - 35.f;
    if (self.style == WXVideoCallSend) {
        switchButton.centerX_mn = self.declineButton.centerX_mn;
    } else {
        switchButton.right_mn = self.cameraButton.right_mn;
    }
    [self.contentView addSubview:switchButton];
    self.switchButton = switchButton;
    
    // 计时
    UILabel *durationLabel = [UILabel labelWithFrame:CGRectZero text:@"00:01" alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha(UIColor.whiteColor, .95f) font:[UIFont systemFontOfSize:16.f]];
    durationLabel.hidden = YES;
    [durationLabel sizeToFit];
    durationLabel.centerX_mn = self.contentView.width_mn/2.f;
    durationLabel.bottom_mn = self.declineButton.top_mn - 35.f;
    durationLabel.touchInset = UIEdgeInsetWith(-10.f);
    [self.contentView addSubview:durationLabel];
    self.durationLabel = durationLabel;
    
    // 右角影像图
    CGFloat badgeViewWidth = 280.f/1242.f*self.view.width_mn;
    CGFloat badgeViewHeight = 550.f/2208.f*self.view.height_mn;
    UIImageView *badgeImageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, badgeViewWidth, badgeViewHeight) image:nil];
    badgeImageView.top_mn = MN_STATUS_BAR_HEIGHT;
    badgeImageView.right_mn = self.view.width_mn - 5.f;
    badgeImageView.alpha = 0.f;
    badgeImageView.clipsToBounds = YES;
    badgeImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:badgeImageView];
    self.badgeImageView = badgeImageView;
    
    UILabel *badgeLabel = [UILabel labelWithFrame:badgeImageView.bounds text:@"点击添加视频或图片" alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha(UIColor.whiteColor, .95f) font:[UIFont systemFontOfSize:15.f]];
    badgeLabel.numberOfLines = 2;
    badgeLabel.backgroundColor = UIColor.blackColor;
    badgeImageView.image = badgeLabel.snapshotImage;
    
    MNPlayView *badgePlayView = [[MNPlayView alloc] initWithFrame:badgeImageView.frame];
    badgePlayView.delegate = self;
    badgePlayView.clipsToBounds = YES;
    badgePlayView.contentMode = UIViewContentModeScaleAspectFill;
    badgePlayView.autoresizingMask = UIViewAutoresizingNone;
    badgePlayView.alpha = 0.f;
    badgePlayView.scrollEnabled = NO;
    badgePlayView.touchEnabled = YES;
    [self.view addSubview:badgePlayView];
    self.badgePlayView = badgePlayView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 修改通话时长
    @weakify(self);
    [self.durationLabel handTapConfiguration:nil eventHandler:^(id sender) {
        @strongify(self);
        [self editCallDuration];
    }];
    // 背景图片点击
    [self.backgroundImageView handTapConfiguration:nil eventHandler:^(id sender) {
        [self selectBackgroundImage:self.backgroundImageView];
    }];
    // 右角图片点击
    [self.badgeImageView handTapConfiguration:nil eventHandler:^(id sender) {
        [self selectBackgroundImage:self.badgeImageView];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstAppear) [self beginWaitingTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Event
- (void)buttonTouchUpInside:(WXCallButton *)sender {
    if (sender.tag == VideoCallButtonTagDecline) {
        // 挂断
        [self declineCalling];
    } else if (sender.tag == VideoCallButtonTagAnswer) {
        // 接通
        [self beginAnswer];
    }
}

// 开启通话模式
- (void)beginAnswer {
    dispatch_timer_cancel(WXVideoCallWaitingTimerName);
    self.hintLabel.text = @"连接中";
    self.state = WXVideoCallStateAnswer;
    self.view.userInteractionEnabled = NO;
    dispatch_after_main(.5f, ^{
        self.hintLabel.hidden = YES;
        self.declineButton.centerX_mn = self.contentView.width_mn/2.f;
        [UIView animateWithDuration:.25f animations:^{
            self.badgeImageView.alpha = self.voiceButton.alpha = self.cameraButton.alpha = 1.f;
            self.switchButton.alpha = self.answerButton.alpha = 0.f;
            self.nickLabel.alpha = self.avatarButton.alpha = 0.f;
        } completion:^(BOOL finished) {
            self.declineButton.title = @"挂断";
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
    if (self.state == WXVideoCallStateWaiting) self.state = WXVideoCallStateDecline;
    [MNPlayer playSoundWithFilePath:[WeChatBundle pathForResource:@"call_close" ofType:@"wav" inDirectory:@"sound"] shake:NO];
    if (self.didEndCallHandler) self.didEndCallHandler(self);
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
    self.durationLabel.text = [NSDate timeStringWithInterval:@(self.callDuration)];
    [self.durationLabel sizeToFit];
    self.durationLabel.centerX_mn = self.durationLabel.superview.width_mn/2.f;
}

// 选择背景图
- (void)selectBackgroundImage:(id)userInfo {
    MNAssetPicker *picker = [MNAssetPicker picker];
    picker.configuration.delegate = self;
    picker.configuration.allowsPickingGif = NO;
    picker.configuration.allowsPickingPhoto = YES;
    picker.configuration.allowsPickingVideo = YES;
    picker.configuration.allowsPickingLivePhoto = NO;
    picker.configuration.requestGifUseingPhotoPolicy = YES;
    picker.configuration.requestLivePhotoUseingPhotoPolicy = YES;
    picker.configuration.allowsEditing = NO;
    picker.configuration.allowsTakeAsset = NO;
    picker.configuration.maxPickingCount = 1;
    picker.configuration.maxExportPixel = 1000;
    picker.user_info = userInfo;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Timer
- (void)beginWaitingTimer {
    self.callIndex = -1;
    self.hintLabel.text = self.style == WXVideoCallSend ? @"正在等待对方接受邀请" : @"邀请你视频通话";
    @weakify(self);
    dispatch_timer_main(WXVideoCallWaitingTimerName, .7f, ^{
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
            if (self.style == WXVideoCallSend) self.waitIndex ++;
        }
        self.hintLabel.text = text;
        if (self.waitIndex >= 20) {
            self.state = WXVideoCallStateRefuse;
            [self declineCalling];
        }
    });
}

- (void)endWaitingTimer {
    dispatch_timer_cancel(WXVideoCallWaitingTimerName);
}

- (void)beginAnswerTimer {
    @weakify(self);
    dispatch_timer_main(WXVideoCallAnswerTimerName, 1.f, ^{
        @strongify(self);
        self.callDuration ++;
        [self updateCallDuration];
    });
}

- (void)endAnswerTimer {
    dispatch_timer_cancel(WXVideoCallAnswerTimerName);
}

#pragma mark - Getter
- (NSString *)desc {
    if (self.style == WXVideoCallSend) {
        if (self.state == WXVideoCallStateDecline) {
            return @"已取消";
        } else if (self.state == WXVideoCallStateRefuse) {
            return @"对方已拒绝";
        }
        return [NSString stringWithFormat:@"通话时长 %@", self.durationLabel.text];
    }
    if (self.state == WXVideoCallStateDecline) {
        return @"已拒绝";
    } else if (self.state == WXVideoCallStateRefuse) {
        return @"对方已取消";
    }
    return [NSString stringWithFormat:@"通话时长 %@", self.durationLabel.text];
}

#pragma mark - MNPlayViewDelegate
- (void)playViewDidClicked:(MNPlayView *)playView {
    [self selectBackgroundImage:playView];
}

#pragma mark - MNAssetPickerDelegate
- (void)assetPicker:(MNAssetPicker *)picker didFinishPickingAssets:(NSArray<MNAsset *> *)assets {
    [picker dismissViewControllerAnimated:YES completion:^{
        if (assets.count <= 0) {
            [self.view showInfoDialog:@"选择资源失败"];
            return;
        }
        UIView *view = picker.user_info;
        MNAsset *asset = assets.firstObject;
        if (asset.type == MNAssetTypeVideo) {
            if (view == self.backgroundPlayView || view == self.backgroundImageView) {
                self.backgroundPlayView.alpha = 1.f;
                self.backgroundImageView.alpha = 0.f;
                self.backgroundImageView.image = asset.thumbnail;
                [self.backgroundPlayer removeAllURLs];
                [self.backgroundPlayer addURL:[NSURL fileURLWithPath:asset.content]];
                [self.backgroundPlayer play];
            } else {
                self.badgePlayView.alpha = 1.f;
                self.badgeImageView.alpha = 0.f;
                self.badgeImageView.image = asset.thumbnail;
                [self.badgePlayer removeAllURLs];
                [self.badgePlayer addURL:[NSURL fileURLWithPath:asset.content]];
                [self.badgePlayer play];
            }
        } else if (asset.type == MNAssetTypePhoto) {
            if (view == self.backgroundPlayView || view == self.backgroundImageView) {
                [self->_backgroundPlayer pause];
                self.backgroundImageView.image = asset.content;
                self.backgroundImageView.alpha = 1.f;
                self.backgroundPlayView.alpha = 0.f;
            } else {
                [self->_badgePlayer pause];
                self.badgeImageView.image = asset.content;
                self.badgeImageView.alpha = 1.f;
                self.badgePlayView.alpha = 0.f;
            }
        } else {
            [self.view showInfoDialog:@"资源不匹配"];
        }
    }];
}

#pragma mark - MNAVPlayerDelegate
- (BOOL)playerShouldPlayNextItem:(MNPlayer *)player {
    return YES;
}

- (void)playerDidPlayFailure:(MNPlayer *)player {
    [self.view showInfoDialog:player.error.localizedDescription];
    if (player == self.badgePlayer) {
        self.badgePlayView.alpha = 0.f;
        self.badgeImageView.alpha = 1.f;
    } else {
        self.backgroundPlayView.alpha = 0.f;
        self.backgroundImageView.alpha = 1.f;
    }
}

#pragma mark - Getter
- (MNPlayer *)badgePlayer {
    if (!_badgePlayer) {
        MNPlayer *badgePlayer = MNPlayer.new;
        badgePlayer.delegate = self;
        badgePlayer.volume = 0.f;
        badgePlayer.layer = self.badgePlayView.layer;
        _badgePlayer = badgePlayer;
    }
    return _badgePlayer;
}

- (MNPlayer *)backgroundPlayer {
    if (!_backgroundPlayer) {
        MNPlayer *backgroundPlayer = MNPlayer.new;
        backgroundPlayer.delegate = self;
        backgroundPlayer.volume = 0.f;
        backgroundPlayer.layer = self.backgroundPlayView.layer;
        _backgroundPlayer = backgroundPlayer;
    }
    return _backgroundPlayer;
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
    if (self.style == WXVideoCallSend) {
        [leftBarButton addTarget:self action:@selector(beginAnswer) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [leftBarButton addTarget:self action:@selector(declineCalling) forControlEvents:UIControlEventTouchUpInside];
    }
    leftBarView.width_mn += 8.f;
    leftBarView.height_mn += 6.f;
    leftBarButton.right_mn = leftBarView.width_mn;
    leftBarButton.bottom_mn = leftBarView.height_mn;
    leftBarButton.touchInset = UIEdgeInsetsMake(-leftBarButton.top_mn, -leftBarButton.left_mn, 0.f, 0.f);
    leftBarView.touchInset = UIEdgeInsetWith(leftBarButton.touchInset.top);
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
    animator.decline = self.state == WXVideoCallStateDecline || self.state == WXVideoCallStateRefuse;
    animator.transitionOperation = MNControllerTransitionOperationPop;
    return animator;
}

- (void)dealloc {
    [self endWaitingTimer];
    [self endAnswerTimer];
}

@end
