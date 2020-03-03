//
//  MNCapturingController.m
//  MNChat
//
//  Created by Vincent on 2019/6/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNCapturingController.h"
#import "MNAssetPickConfiguration.h"
#import "MNCapturingView.h"
#import "MNPlayView.h"

@interface MNCapturingController () <MNCapturingViewDelegate, MNCapturerDelegate, MNPlayerDelegate>
@property (nonatomic, strong) MNPlayer *player;
@property (nonatomic, strong) UIView *displayView;
@property (nonatomic, strong) UIControl *cameraControl;
@property (nonatomic, strong) UIImageView *focusView;
@property (nonatomic, strong) UIImageView *previewView;
@property (nonatomic, strong) MNCapturer *capturer;
@property (nonatomic, strong) MNPlayView *playView;
@property (nonatomic, strong) MNCapturingView *capturingView;
@end

@implementation MNCapturingController
- (instancetype)init {
    if (self = [super init]) {
        self.filePath = MNCacheDirectoryAppending([@"video" stringByAppendingPathComponent:[MNFileHandle fileNameWithExtension:@"mp4"]]);
    }
    return self;
}

- (void)createView {
    [super createView];

    self.contentView.backgroundColor = [UIColor blackColor];
    
    UIView *displayView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    displayView.backgroundColor = [UIColor blackColor];
    [displayView addGestureRecognizer:UITapGestureRecognizerCreate(self, @selector(handTap:), nil)];
    [self.contentView addSubview:displayView];
    self.displayView = displayView;
    
    UIControl *cameraControl = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
    cameraControl.right_mn = self.contentView.width_mn - 20.f;
    cameraControl.top_mn =  (UINavBarHeight() - cameraControl.height_mn)/2.f + UIStatusBarHeight();
    cameraControl.backgroundImage = [MNBundle imageForResource:@"video_record_camera_switch"];
    [cameraControl addTarget:self action:@selector(cameraSwitchControlClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:cameraControl];
    self.cameraControl = cameraControl;
    
    UIImageView *focusView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 55.f, 55.f) image:[MNBundle imageForResource:@"video_record_focusing"]];
    focusView.hidden = YES;
    [displayView addSubview:focusView];
    self.focusView = focusView;
    
    MNPlayView *playView = [[MNPlayView alloc] initWithFrame:self.contentView.bounds];
    playView.touchEnabled = NO;
    playView.scrollEnabled = NO;
    playView.alpha = 0.f;
    [self.contentView addSubview:playView];
    self.playView = playView;
    
    UIImageView *previewView = [UIImageView imageViewWithFrame:self.contentView.bounds image:nil];
    previewView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    previewView.alpha = 0.f;
    previewView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:previewView];
    self.previewView = previewView;
    
    MNCapturingView *capturingView = [[MNCapturingView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, 0.f)];
    capturingView.delegate = self;
    capturingView.bottom_mn = self.contentView.height_mn - UITabSafeHeight() - 60.f;
    capturingView.timeoutInterval = self.configuration.maxCaptureDuration;
    if (self.configuration.allowsPickingPhoto && self.configuration.allowsPickingVideo) {
        capturingView.options = MNCapturingOptionPhoto|MNCapturingOptionVideo;
    } else if (self.configuration.allowsPickingVideo) {
        capturingView.options = MNCapturingOptionVideo;
    }
    [self.contentView addSubview:capturingView];
    self.capturingView = capturingView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MNPlayer *player = [MNPlayer new];
    player.delegate = self;
    player.layer = self.playView.layer;
    self.player = player;
    
    MNCapturer *capturer = [MNCapturer new];
    capturer.delegate = self;
    capturer.outputView = self.displayView;
    self.capturer = capturer;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.capturer startRunning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.capturer startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Tap
- (void)handTap:(UITapGestureRecognizer *)tap {
    if (!self.focusView.hidden) return;
    CGPoint point = [tap locationInView:self.displayView];
    [self.capturer setFocusPoint:point];
    self.focusView.center_mn = point;
    self.focusView.hidden = NO;
    [UIView animateWithDuration:.4f animations:^{
        self.focusView.transform = CGAffineTransformMakeScale(.5f, .5f);
    }];
    dispatch_after_main(.6f, ^{
        self.focusView.hidden = YES;
        self.focusView.transform = CGAffineTransformIdentity;
    });
}

#pragma mark - Camera Switch
- (void)cameraSwitchControlClicked:(UIControl *)control {
    [self.capturer convertCapturePosition];
}

#pragma mark - MNPlayerDelegate
- (void)playerDidPlayFailure:(MNPlayer *)player {
    [self.view showInfoDialog:player.error.localizedDescription];
}

- (void)playerDidPlayToEndTime:(MNPlayer *)player {
    [player play];
}

#pragma mark - MNCapturingViewDelegate
- (void)capturingViewCloseButtonClicked:(MNCapturingView *)capturingView {
    self.player.delegate = nil;
    self.capturer.delegate = nil;
    [self.player removeAllURLs];
    [self.capturer stopCapturing];
    [self.capturer deleteCapturing];
    if ([self.delegate respondsToSelector:@selector(capturingControllerDidCancel:)]) {
        [self.delegate capturingControllerDidCancel:self];
    } else {
        BOOL animated = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (self.navigationController) {
            if (self.navigationController.viewControllers.count > 1) {
                [self.navigationController popViewControllerAnimated:animated];
            } else if (self.navigationController.presentingViewController) {
                [self.navigationController dismissViewControllerAnimated:animated completion:nil];
            }
        } else if (self.presentingViewController) {
            [self dismissViewControllerAnimated:animated completion:nil];
        }
    }
}

- (void)capturingViewBackButtonClicked:(MNCapturingView *)capturingView {
    [capturingView resetCapturing];
    [self.capturer startRunning];
    [UIView animateWithDuration:.3f animations:^{
        self.previewView.alpha = self.playView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.player removeAllURLs];
        [self.capturer deleteCapturing];
    }];
}

- (void)capturingViewDoneButtonClicked:(MNCapturingView *)capturingView {
    /// 获取视频信息
    if (self.previewView.alpha) {
        if ([self.delegate respondsToSelector:@selector(capturingController:didFinishWithStillImage:)]) {
            [self.delegate capturingController:self didFinishWithStillImage:self.previewView.image];
        }
    } else {
        // 判断时长是否符合限制要求
        NSTimeInterval duration = [[AVAsset assetWithContentsOfPath:self.capturer.filePath] seconds];
        if (self.configuration.minVideoDuration > 0.f && duration < self.configuration.minVideoDuration) {
            [self.view showInfoDialog:[NSString stringWithFormat:@"请选择大于%@s的视频", @(self.configuration.minVideoDuration)]];
            return;
        }
        if (self.configuration.maxCaptureDuration > 0.f && duration > self.configuration.maxCaptureDuration) {
            [self.view showInfoDialog:[NSString stringWithFormat:@"请选择小于%@s的视频", @(self.configuration.maxVideoDuration)]];
            return;
        }
        if ([self.delegate respondsToSelector:@selector(capturingController:didFinishWithContentOfFile:)]) {
            [self.delegate capturingController:self didFinishWithContentOfFile:self.capturer.filePath];
        }
    }
    // 回调内容
    if ([self.delegate respondsToSelector:@selector(capturingController:didFinishWithContent:)]) {
        [self.delegate capturingController:self didFinishWithContent:(self.previewView.alpha ? self.previewView.image : self.capturer.filePath)];
    }
}

- (void)capturingViewShoudBeginCapturing:(MNCapturingView *)capturingView {
    self.capturer.filePath = self.filePath;
    [self.capturer startCapturing];
}

- (void)capturingViewDidEndCapturing:(MNCapturingView *)capturingView {
    [self.capturer stopCapturing];
}

- (void)capturingViewShoudCapturingStillImage:(MNCapturingView *)capturingView {
    [self.capturer captureStillImageAsynchronously:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                [self.capturingView stopCapturing];
                self.previewView.image = image;
                [UIView animateWithDuration:.3f animations:^{
                    self.previewView.alpha = 1.f;
                    self.playView.alpha = 0.f;
                } completion:^(BOOL finished) {
                    [self.capturer stopRunning];
                }];
            } else {
                [self.view showInfoDialog:@"获取图像失败"];
            }
        });
    }];
}

#pragma mark - MNCapturerDelegate
- (void)capturer:(MNCapturer *)capturer didStartCapturingWithContentsOfFile:(NSString *)filePath {
    [self.capturingView startCapturing];
}

- (void)capturer:(MNCapturer *)capturer didFinishCapturingWithContentsOfFile:(NSString *)filePath {
    [self.capturingView stopCapturing];
    [UIView animateWithDuration:.3f animations:^{
        self.playView.alpha = 1.f;
        self.previewView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.capturer stopRunning];
        [self.player addURL:[NSURL fileURLWithPath:self.capturer.filePath]];
        [self.player play];
    }];
}

- (void)capturer:(MNCapturer *)capturer didCapturingFailure:(NSString *)message {
    [[MNAlertView alertViewWithTitle:@"提示" message:message handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
        if ([self.delegate respondsToSelector:@selector(capturingControllerDidCancel:)]) {
            [self.delegate capturingControllerDidCancel:self];
        }
    } ensureButtonTitle:@"确定" otherButtonTitles:nil] show];
}

#pragma mark - 后台通知
- (void)didEnterBackgroundNotification:(NSNotification *)notify {
    self.player.delegate = nil;
    self.capturer.delegate = nil;
    [self.player removeAllURLs];
    [self.capturer stopRunning];
    if ([self.delegate respondsToSelector:@selector(capturingControllerDidCancel:)]) {
        [self.delegate capturingControllerDidCancel:self];
    }
}

#pragma mark - Super
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModel];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModel];
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
