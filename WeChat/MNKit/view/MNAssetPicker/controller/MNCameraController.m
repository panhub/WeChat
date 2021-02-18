//
//  MNCameraController.m
//  MNKit
//
//  Created by Vincent on 2019/6/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNCameraController.h"
#import "MNAssetPickConfiguration.h"
#import "MNCapturingToolBar.h"
#import "MNPlayView.h"

@interface MNCameraController () <MNCapturingToolDelegate, MNMovieRecordDelegate, MNPlayerDelegate>
@property (nonatomic, strong) MNPlayer *player;
@property (nonatomic, strong) UIView *displayView;
@property (nonatomic, strong) UIControl *cameraControl;
@property (nonatomic, strong) UIImageView *focusView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) MNMovieRecorder *recorder;
@property (nonatomic, strong) MNPlayView *playView;
@property (nonatomic, strong) MNCapturingToolBar *toolBar;
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
    
    MNPlayView *playView = [[MNPlayView alloc] initWithFrame:self.contentView.bounds];
    playView.alpha = 0.f;
    playView.touchEnabled = NO;
    playView.scrollEnabled = NO;
    [self.contentView addSubview:playView];
    self.playView = playView;
    
    UIImageView *imageView = [UIImageView imageViewWithFrame:self.contentView.bounds image:nil];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageView.alpha = 0.f;
    imageView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
    MNCapturingToolBar *toolBar = [[MNCapturingToolBar alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, 0.f)];
    toolBar.delegate = self;
    toolBar.bottom_mn = self.contentView.height_mn - MN_TAB_SAFE_HEIGHT - 60.f;
    toolBar.timeoutInterval = MAX(self.configuration.maxCaptureDuration, self.configuration.maxExportDuration);
    if (self.configuration.isAllowsPickingPhoto && self.configuration.isAllowsPickingVideo) {
        toolBar.options = MNCapturingOptionPhoto|MNCapturingOptionVideo;
    } else if (self.configuration.isAllowsPickingVideo) {
        toolBar.options = MNCapturingOptionVideo;
    }
    [self.contentView addSubview:toolBar];
    self.toolBar = toolBar;
    
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MNPlayer *player = [MNPlayer new];
    player.delegate = self;
    player.layer = self.playView.layer;
    self.player = player;
    
    MNMovieRecorder *recorder = [MNMovieRecorder new];
    recorder.delegate = self;
    recorder.outputView = self.displayView;
    [recorder prepareCapturing];
    self.recorder = recorder;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.playView.alpha == 1.f) {
        if (self.player.state > MNPlayerStatePlaying) [self.player play];
    } else if (self.imageView.alpha == 0.f) {
        [self.recorder startRunning];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    if (self.playView.alpha == 1.f) {
        if (self.player.isPlaying) [self.player pause];
    } else if (self.imageView.alpha == 0.f) {
        [self.recorder stopRunning];
    }
}

#pragma mark - Tap
- (void)handTap:(UITapGestureRecognizer *)tap {
    if (!self.focusView.hidden) return;
    CGPoint point = [tap locationInView:self.displayView];
    [self.recorder setFocus:point];
    self.focusView.center_mn = point;
    self.focusView.hidden = NO;
    [UIView animateWithDuration:.4f animations:^{
        self.focusView.transform = CGAffineTransformMakeScale(.5f, .5f);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.6f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.focusView.hidden = YES;
        self.focusView.transform = CGAffineTransformIdentity;
    });
}

#pragma mark - Camera Switch
- (void)cameraSwitchControlClicked:(UIControl *)control {
    [self.recorder convertCapturePosition];
}

#pragma mark - MNPlayerDelegate
- (void)playerDidPlayFailure:(MNPlayer *)player {
    [self.view showInfoDialog:player.error.localizedDescription];
}

- (void)playerDidPlayToEndTime:(MNPlayer *)player {
    [player play];
}

#pragma mark - MNCapturingToolDelegate
- (void)capturingToolBarCloseButtonClicked:(MNCapturingToolBar *)toolBar {
    self.player.delegate = nil;
    self.recorder.delegate = nil;
    [self.player removeAllURLs];
    [self.recorder stopRecording];
    [self.recorder deleteRecording];
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

- (void)capturingToolBarBackButtonClicked:(MNCapturingToolBar *)toolBar {
    [toolBar resetCapturing];
    [self.recorder startRunning];
    [UIView animateWithDuration:.3f animations:^{
        self.imageView.alpha = self.playView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.player removeAllURLs];
        [self.recorder deleteRecording];
    }];
}

- (void)capturingToolBarDoneButtonClicked:(MNCapturingToolBar *)toolBar {
    // 判断资源类型
    if (self.imageView.alpha) {
        if ([self.delegate respondsToSelector:@selector(cameraController:didFinishWithContents:)]) {
            [self.delegate cameraController:self didFinishWithContents:self.imageView.image];
        }
    } else {
        // 判断时长是否符合限制要求
        NSTimeInterval duration = ceil(self.recorder.duration);
        if (self.configuration.minExportDuration > 0.f && floor(duration) < self.configuration.minExportDuration) {
            [self.view showInfoDialog:[NSString stringWithFormat:@"请拍摄大于%@s的视频", @(floor(self.configuration.minExportDuration))]];
            return;
        }
        if (self.configuration.maxExportDuration > 0.f && (!self.configuration.isAllowsEditing || self.configuration.maxPickingCount > 1) && ceil(duration) > self.configuration.maxExportDuration) {
            [self.view showInfoDialog:[NSString stringWithFormat:@"请拍摄小于%@s的视频", @(ceil(self.configuration.maxExportDuration))]];
            return;
        }
        // 回调结果
        if ([self.delegate respondsToSelector:@selector(cameraController:didFinishWithContents:)]) {
            [self.delegate cameraController:self didFinishWithContents:self.recorder.URL.path];
        }
    }
}

- (void)capturingToolBarShoudBeginCapturing:(MNCapturingToolBar *)toolBar {
    self.recorder.URL = [NSURL fileURLWithPath:self.filePath];
    [self.recorder startRecording];
}

- (void)capturingToolBarDidEndCapturing:(MNCapturingToolBar *)toolBar {
    [self.recorder stopRecording];
}

- (void)capturingToolBarShoudTakeStillImage:(MNCapturingToolBar *)toolBar {
    __weak typeof(self) weakself = self;
    [self.recorder takeStillImageAsynchronously:^(UIImage * _Nullable image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) self = weakself;
            if (image) {
                [self.toolBar stopCapturing];
                self.imageView.image = image;
                [UIView animateWithDuration:.3f animations:^{
                    self.playView.alpha = 0.f;
                    self.imageView.alpha = 1.f;
                } completion:^(BOOL finished) {
                    [self.recorder stopRunning];
                }];
            } else {
                [self.view showInfoDialog:@"获取图像失败"];
            }
        });
    }];
}

#pragma mark - MNMovieRecordDelegate
- (void)movieRecorderDidStartRecording:(MNMovieRecorder *)recorder {
    [self.toolBar startCapturing];
}

- (void)movieRecorderDidFinishRecording:(MNMovieRecorder *)recorder {
    [self.toolBar stopCapturing];
    [UIView animateWithDuration:.3f animations:^{
        self.playView.alpha = 1.f;
        self.imageView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.recorder stopRunning];
        [self.player addURL:self.recorder.URL];
        [self.player play];
    }];
}

- (void)movieRecorder:(MNMovieRecorder *)recorder didFailWithError:(NSError *)error {
    if (error.code == AVErrorApplicationIsNotAuthorized) {
        [[MNAlertView alertViewWithTitle:nil message:error.localizedDescription handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
            if ([self.delegate respondsToSelector:@selector(cameraControllerDidCancel:)]) {
                [self.delegate cameraControllerDidCancel:self];
            }
        } ensureButtonTitle:@"确定" otherButtonTitles:nil] showInView:self.view];
    } else {
        [self.view showInfoDialog:error.localizedDescription];
    }
}

#pragma mark - 后台通知
- (void)didEnterBackgroundNotification:(NSNotification *)notify {
    self.player.delegate = nil;
    self.recorder.delegate = nil;
    [self.player removeAllURLs];
    [self.recorder stopRunning];
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
