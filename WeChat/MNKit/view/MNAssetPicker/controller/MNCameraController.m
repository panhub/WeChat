//
//  MNCameraController.m
//  MNKit
//
//  Created by Vincent on 2019/6/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNCameraController.h"
#import "MNAssetPickConfiguration.h"
#import "MNCapturingView.h"
#import "MNPlayView.h"

@interface MNCameraController () <MNCapturingViewDelegate, MNCaptureSessionDelegate, MNPlayerDelegate>
@property (nonatomic, strong) MNPlayer *player;
@property (nonatomic, strong) UIView *displayView;
@property (nonatomic, strong) UIControl *cameraControl;
@property (nonatomic, strong) UIImageView *focusView;
@property (nonatomic, strong) UIImageView *previewView;
@property (nonatomic, strong) MNCaptureSession *capturer;
@property (nonatomic, strong) MNPlayView *playView;
@property (nonatomic, strong) MNCapturingView *capturingView;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation MNCameraController
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
    cameraControl.top_mn =  (MN_NAV_BAR_HEIGHT - cameraControl.height_mn)/2.f + MN_STATUS_BAR_HEIGHT;
    cameraControl.backgroundImage = [MNBundle imageForResource:@"video_record_camera_switch"];
    [cameraControl addTarget:self action:@selector(cameraSwitchControlClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:cameraControl];
    self.cameraControl = cameraControl;
    
    UIImageView *focusView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 55.f, 55.f) image:[MNBundle imageForResource:@"video_record_focusing"]];
    focusView.hidden = YES;
    [displayView addSubview:focusView];
    self.focusView = focusView;
    
    MNPlayView *playView = [[MNPlayView alloc] initWithFrame:self.contentView.bounds];
    playView.alpha = 0.f;
    playView.touchEnabled = NO;
    playView.scrollEnabled = NO;
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
    capturingView.bottom_mn = self.contentView.height_mn - MN_TAB_SAFE_HEIGHT - 60.f;
    capturingView.timeoutInterval = MAX(self.configuration.maxCaptureDuration, self.configuration.maxExportDuration);
    if (self.configuration.isAllowsPickingPhoto && self.configuration.isAllowsPickingVideo) {
        capturingView.options = MNCapturingOptionPhoto|MNCapturingOptionVideo;
    } else if (self.configuration.isAllowsPickingVideo) {
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
    
    MNCaptureSession *capturer = [MNCaptureSession new];
    capturer.delegate = self;
    capturer.outputView = self.displayView;
    [capturer prepareCapturing];
    self.capturer = capturer;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    if (!self.isFirstAppear && self.playView.alpha == 0.f && self.previewView.alpha == 0.f) [self.capturer startRunning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.playView.alpha == 1.f && self.player.state > MNPlayerStatePlaying) [self.player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    if (self.playView.alpha == 1.f && self.player.isPlaying) [self.player pause];
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
    [self.capturer stopRecording];
    [self.capturer deleteRecording];
    if ([self.delegate respondsToSelector:@selector(cameraControllerDidCancel:)]) {
        [self.delegate cameraControllerDidCancel:self];
    } else if (!self.configuration || self.configuration.isAllowsAutoDismiss) {
        BOOL animated = UIApplication.sharedApplication.applicationState == UIApplicationStateActive;
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
        [self.capturer deleteRecording];
    }];
}

- (void)capturingViewDoneButtonClicked:(MNCapturingView *)capturingView {
    // 判断资源类型
    if (self.previewView.alpha) {
        if ([self.delegate respondsToSelector:@selector(cameraController:didFinishWithStillImage:)]) {
            [self.delegate cameraController:self didFinishWithStillImage:self.previewView.image];
        }
    } else {
        // 判断时长是否符合限制要求
        NSTimeInterval duration = floor(self.capturer.duration);
        if (self.configuration.minExportDuration > 0.f && duration < self.configuration.minExportDuration) {
            [self.view showInfoDialog:[NSString stringWithFormat:@"请拍摄大于%@s的视频", @(ceil(self.configuration.minExportDuration))]];
            return;
        }
        if (self.configuration.maxExportDuration > 0.f && (!self.configuration.isAllowsEditing || self.configuration.maxPickingCount > 1) && duration > self.configuration.maxExportDuration) {
            [self.view showInfoDialog:[NSString stringWithFormat:@"请拍摄小于%@s的视频", @(floor(self.configuration.maxExportDuration))]];
            return;
        }
        // 回调结果
        if ([self.delegate respondsToSelector:@selector(cameraController:didFinishWithVideoAtPath:)]) {
            [self.delegate cameraController:self didFinishWithVideoAtPath:self.capturer.outputPath];
        }
    }
    // 回调内容
    if ([self.delegate respondsToSelector:@selector(cameraController:didFinishWithContents:)]) {
        [self.delegate cameraController:self didFinishWithContents:(self.previewView.alpha ? self.previewView.image : self.capturer.outputPath)];
    }
}

- (void)capturingViewShoudBeginCapturing:(MNCapturingView *)capturingView {
    self.capturer.outputPath = self.filePath;
    [self.capturer startRecording];
}

- (void)capturingViewDidEndCapturing:(MNCapturingView *)capturingView {
    [self.capturer stopRecording];
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

#pragma mark - MNCaptureSessionDelegate
- (void)captureSessionDidStartRecording:(MNCaptureSession *)capturer {
    [self.capturingView startCapturing];
}

- (void)captureSessionDidFinishRecording:(MNCaptureSession *)capturer {
    if (capturer.error) [self.view showInfoDialog:capturer.error.localizedDescription];
    [self.capturingView stopCapturing];
    [UIView animateWithDuration:.3f animations:^{
        self.playView.alpha = 1.f;
        self.previewView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.capturer stopRunning];
        NSString *s = self.capturer.outputPath;
        if ([NSFileManager.defaultManager fileExistsAtPath:s]) {
            NSLog(@"");
        }
        [self.player addURL:[NSURL fileURLWithPath:self.capturer.outputPath]];
        [self.player play];
    }];
}

- (void)captureSessionDidFailureWithError:(MNCaptureSession *)capturer {
    if (capturer.error.code == AVErrorApplicationIsNotAuthorized) {
        [[MNAlertView alertViewWithTitle:nil message:capturer.error.localizedDescription handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
            if ([self.delegate respondsToSelector:@selector(cameraControllerDidCancel:)]) {
                [self.delegate cameraControllerDidCancel:self];
            }
        } ensureButtonTitle:@"确定" otherButtonTitles:nil] showInView:self.view];
    } else {
        [self.view showInfoDialog:capturer.error.localizedDescription];
    }
}

#pragma mark - 后台通知
- (void)didEnterBackgroundNotification:(NSNotification *)notify {
    self.player.delegate = nil;
    self.capturer.delegate = nil;
    [self.player removeAllURLs];
    [self.capturer stopRunning];
    if ([self.delegate respondsToSelector:@selector(cameraControllerDidCancel:)]) {
        [self.delegate cameraControllerDidCancel:self];
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
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
#pragma clang diagnostic pop
