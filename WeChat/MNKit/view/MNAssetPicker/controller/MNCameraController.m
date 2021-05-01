//
//  MNCameraController.m
//  MNKit
//
//  Created by Vincent on 2019/6/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNCameraController.h"
#import "MNAssetPickConfiguration.h"
#import "MNCameraPreview.h"
#import "MNCaptureToolBar.h"
#import "MNPlayView.h"

@interface MNCameraController () <MNCaptureToolDelegate, MNMovieRecordDelegate>
@property (nonatomic) CGRect movieRect;
@property (nonatomic, strong) UILabel *liveLabel;
@property (nonatomic, strong) UIView *movieView;
@property (nonatomic, strong) UIButton *liveButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIImageView *focusView;
@property (nonatomic, strong) MNCaptureToolBar *toolBar;
@property (nonatomic, strong) MNCameraPreview *preview;
@property (nonatomic, strong) MNMovieRecorder *recorder;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation MNCameraController
- (instancetype)init {
    if (self = [super init]) {
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"MNKit/video/user_capture.mp4"];
        [NSFileManager.defaultManager removeItemAtPath:filePath error:NULL];
        self.videoURL = [NSURL fileURLWithPath:filePath];
    }
    return self;
}

- (void)createView {
    [super createView];

    self.contentView.backgroundColor = UIColor.blackColor;

    UIView *movieView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    movieView.clipsToBounds = YES;
    movieView.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [tapGestureRecognizer addTarget:self action:@selector(movieViewTouchUpInside:)];
    [movieView addGestureRecognizer:tapGestureRecognizer];
    [self.contentView addSubview:movieView];
    self.movieView = movieView;
    
    MNCameraPreview *preview = [[MNCameraPreview alloc] initWithFrame:self.contentView.bounds];
    preview.alpha = 0.f;
    [self.contentView addSubview:preview];
    self.preview = preview;
    
    MNCaptureToolBar *toolBar = [[MNCaptureToolBar alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, 0.f)];
    toolBar.delegate = self;
    toolBar.bottom_mn = self.contentView.height_mn - MN_TAB_SAFE_HEIGHT - 60.f;
    toolBar.timeoutInterval = MAX(self.configuration.maxCaptureDuration, self.configuration.maxExportDuration);
    MNCaptureOptions options = MNCaptureOptionNone;
    if (self.configuration.isAllowsPickingVideo) options |= MNCaptureOptionVideo;
    if (self.configuration.isAllowsPickingPhoto) options |= MNCaptureOptionPhoto;
    toolBar.options = options;
    [self.contentView addSubview:toolBar];
    self.toolBar = toolBar;
    
    UIButton *cameraButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f) image:[MNBundle imageForResource:@"video_record_camera_switch"] title:nil titleColor:nil titleFont:nil];
    cameraButton.right_mn = self.contentView.width_mn - 20.f;
    cameraButton.top_mn =  floor((MN_NAV_BAR_HEIGHT - cameraButton.height_mn)/2.f) + MN_STATUS_BAR_HEIGHT;
    [cameraButton addTarget:self action:@selector(cameraButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:cameraButton];
    self.cameraButton = cameraButton;
    
    UIButton *liveButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 32.f, 32.f) image:[MNBundle imageForResource:@"livePhoto"] title:nil titleColor:nil titleFont:nil];
    liveButton.hidden = YES;
    liveButton.left_mn = self.contentView.width_mn - cameraButton.right_mn;
    liveButton.centerY_mn = cameraButton.centerY_mn;
    liveButton.touchInset = UIEdgeInsetsMake(-5.f, -5.f, -5.f, -5.f);
    [liveButton setBackgroundImage:[[MNBundle imageForResource:@"livePhoto"] imageWithColor:THEME_COLOR] forState:UIControlStateSelected];
    [liveButton addTarget:self action:@selector(liveButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:liveButton];
    self.liveButton = liveButton;
    
    UILabel *liveLabel = [UILabel labelWithFrame:CGRectZero text:@"实况" alignment:NSTextAlignmentCenter textColor:UIColor.whiteColor font:[UIFont systemFontOfSize:13.f]];
    liveLabel.alpha = 0.f;
    liveLabel.numberOfLines = 1;
    [liveLabel sizeToFit];
    liveLabel.width_mn += 10.f;
    liveLabel.height_mn += 5.f;
    liveLabel.userInteractionEnabled = NO;
    liveLabel.centerY_mn = cameraButton.centerY_mn;
    liveLabel.centerX_mn = self.contentView.width_mn/2.f;
    liveLabel.layer.cornerRadius = 3.f;
    liveLabel.clipsToBounds = YES;
    liveLabel.backgroundColor = THEME_COLOR;
    [self.contentView addSubview:liveLabel];
    self.liveLabel = liveLabel;
    
    UIImageView *focusView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 55.f, 55.f) image:[MNBundle imageForResource:@"video_record_focusing"]];
    focusView.hidden = YES;
    [movieView addSubview:focusView];
    self.focusView = focusView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MNMovieRecorder *recorder = [MNMovieRecorder new];
    recorder.delegate = self;
    recorder.URL = self.videoURL;
    recorder.movieOrientation = MNMovieOrientationAuto;
    recorder.resizeMode = MNMovieResizeModeResizeAspectFill;
    recorder.outputView = self.movieView;
    self.recorder = recorder;
    
    CGSize presetSize = CGSizeMultiplyToWidth((recorder.presetSizeRatio == MNMovieSizeRatio9x16 ? CGSizeMake(9.f, 16.f) : CGSizeMake(3.f, 4.f)), self.contentView.width_mn);
    presetSize.height = ceil(presetSize.height);
    if (fabs(presetSize.height - self.contentView.height_mn) <= 2.f) presetSize.height = self.contentView.height_mn;
    if (self.contentView.height_mn != presetSize.height) {
        // 屏幕尺寸不合适
        self.preview.size_mn = self.movieView.size_mn = presetSize;
        CGFloat interval = floor((self.contentView.height_mn - self.cameraButton.bottom_mn - MN_TAB_SAFE_HEIGHT - presetSize.height - self.toolBar.height_mn)/3.f);
        if (interval > ceil(MNCaptureToolBarMaxHeight - MNCaptureToolBarMinHeight)) {
            self.preview.top_mn = self.movieView.top_mn = self.cameraButton.bottom_mn + interval;
            self.toolBar.top_mn = self.cameraButton.bottom_mn + presetSize.height + interval*2.f;
            self.liveButton.centerY_mn = self.liveLabel.centerY_mn = self.cameraButton.centerY_mn;
            self.liveButton.left_mn = self.contentView.width_mn - self.cameraButton.right_mn;
        } else {
            interval = floor((self.contentView.height_mn - self.cameraButton.bottom_mn - MN_TAB_SAFE_HEIGHT - presetSize.height)/2.f);
            self.preview.top_mn = self.movieView.top_mn = self.cameraButton.bottom_mn + interval;
            self.toolBar.bottom_mn = self.cameraButton.bottom_mn + interval + presetSize.height - (MNCaptureToolBarMaxHeight - MNCaptureToolBarMinHeight);
            self.liveButton.centerY_mn = self.liveLabel.centerY_mn = self.cameraButton.centerY_mn;
            self.liveButton.left_mn = self.contentView.width_mn - self.cameraButton.right_mn;
        }
    } else {
        self.cameraButton.top_mn = MN_STATUS_BAR_HEIGHT;
        self.liveButton.centerY_mn = self.liveLabel.centerY_mn = self.cameraButton.centerY_mn;
        CGFloat height = ceil(CGSizeMultiplyToWidth(CGSizeMake(3.f, 4.f), self.contentView.width_mn).height);
        CGFloat interval = floor((self.contentView.height_mn - height - self.cameraButton.bottom_mn - self.toolBar.height_mn)/3.f);
        self.toolBar.bottom_mn = self.contentView.height_mn - interval;
    }
    
    self.movieRect = self.movieView.frame;
    
    if ((self.toolBar.options & MNCaptureOptionPhoto) && (self.toolBar.options & MNCaptureOptionVideo)) {
        [self.recorder prepareCapturing];
    } else if (self.toolBar.options & MNCaptureOptionPhoto) {
        [self.recorder prepareTaking];
    } else if (self.toolBar.options & MNCaptureOptionVideo) {
        [self.recorder prepareRecording];
    }
    
    if ((self.toolBar.options & MNCaptureOptionPhoto) && self.configuration.isAllowsPickingLivePhoto && !self.configuration.requestLivePhotoUseingPhotoPolicy) {
#ifdef __IPHONE_10_0
        if (@available(iOS 10.0, *)) {
            self.liveButton.hidden = NO;
        }
#endif
    }
    
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
    if (self.preview.alpha == 0.f) {
        [self.recorder startRunning];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    if (self.preview.alpha == 1.f) {
        [self.preview pause];
    } else {
        [self.recorder stopRunning];
    }
}

#pragma mark - Tap
- (void)movieViewTouchUpInside:(UITapGestureRecognizer *)tap {
    if (!self.focusView.hidden) return;
    CGPoint point = [tap locationInView:tap.view];
    [self.recorder setFocus:point];
    self.focusView.center_mn = point;
    self.focusView.hidden = NO;
    [UIView animateWithDuration:MNCaptureToolBarAnimationDuration animations:^{
        self.focusView.transform = CGAffineTransformMakeScale(.5f, .5f);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((MNCaptureToolBarAnimationDuration + .25f) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.focusView.hidden = YES;
        self.focusView.transform = CGAffineTransformIdentity;
    });
}

#pragma mark - Event
- (void)cameraButtonTouchUpInside:(UIButton *)sender {
    sender.enabled = NO;
    __weak typeof(self) weakself = self;
    [self.recorder convertCameraWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) [weakself.view showInfoDialog:error.localizedDescription];
        sender.enabled = YES;
    }];
}

- (void)liveButtonTouchUpInside:(UIButton *)sender {
    self.view.userInteractionEnabled = NO;
    if (sender.isSelected) {
        [self.recorder stopTakingLivePhoto];
    } else {
        [self.recorder startTakingLivePhoto];
    }
}

#pragma mark - MNCaptureToolDelegate
- (void)captureToolBarCloseButtonClicked:(MNCaptureToolBar *)toolBar {
    self.recorder.delegate = nil;
    [self.recorder cancelRecording];
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

- (void)captureToolBarBackButtonClicked:(MNCaptureToolBar *)toolBar {
    [toolBar resetCapturing];
    [self.recorder startRunning];
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:MNCaptureToolBarAnimationDuration animations:^{
        weakself.preview.alpha = 0.f;
        weakself.movieView.alpha = weakself.cameraButton.alpha = weakself.liveButton.alpha = 1.f;
    } completion:^(BOOL finished) {
        [weakself.preview stop];
        [weakself.recorder deleteRecording];
    }];
}

- (void)captureToolBarDoneButtonClicked:(MNCaptureToolBar *)toolBar {
    // 获取拍摄内容
    id contents = self.preview.contents;
    if (!contents) {
        [self.view showInfoDialog:@"发生未知错误"];
        return;
    }
    // 暂停播放
    [self.preview pause];
    // 判断资源类型
    if ([contents isKindOfClass:UIImage.class] || [contents isKindOfClass:NSClassFromString(@"PHLivePhoto")]) {
        if ([self.delegate respondsToSelector:@selector(cameraController:didFinishWithContents:)]) {
            [self.delegate cameraController:self didFinishWithContents:contents];
        }
    } else {
        // 判断时长是否符合限制要求
        NSTimeInterval duration = ceil(self.recorder.duration);
        if (self.configuration.minExportDuration > 0.f && floor(duration) < self.configuration.minExportDuration) {
            [self.view showInfoDialog:[NSString stringWithFormat:@"请拍摄大于%@s的视频", @(floor(self.configuration.minExportDuration))]];
            return;
        }
        if (self.configuration.maxExportDuration > 0.f && ceil(duration) > self.configuration.maxExportDuration && (!self.configuration.isAllowsEditing || self.configuration.maxPickingCount > 1)) {
            [self.view showInfoDialog:[NSString stringWithFormat:@"请拍摄小于%@s的视频", @(ceil(self.configuration.maxExportDuration))]];
            return;
        }
        // 回调结果
        if ([self.delegate respondsToSelector:@selector(cameraController:didFinishWithContents:)]) {
            [self.delegate cameraController:self didFinishWithContents:contents];
        }
    }
}

- (BOOL)captureToolBarShouldCapturingVideo:(MNCaptureToolBar *)toolBar {
    return self.liveButton.isSelected == NO;
}

- (BOOL)captureToolBarShouldTakingPhoto:(MNCaptureToolBar *)toolBar {
    return self.liveLabel.alpha == 0.f;
}

- (void)captureToolBarDidBeginCapturingVideo:(MNCaptureToolBar *)toolBar {
    [self.recorder startRecording];
}

- (void)captureToolBarDidEndCapturingVideo:(MNCaptureToolBar *)toolBar {
    [self.recorder stopRecording];
}

- (void)captureToolBarDidBeginTakingPhoto:(MNCaptureToolBar *)toolBar {
    self.view.userInteractionEnabled = NO;
    if (self.liveButton.isSelected) {
        [self.recorder takeLivePhoto];
    } else {
        [self.recorder takePhoto];
    }
}

#pragma mark - MNMovieRecordDelegate
- (void)movieRecorderDidStartRecording:(MNMovieRecorder *)recorder {
    [self.toolBar startCapturing];
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:MNCaptureToolBarAnimationDuration animations:^{
        weakself.liveButton.alpha = 0.f;
    }];
}

- (void)movieRecorderDidFinishRecording:(MNMovieRecorder *)recorder {
    [self.toolBar stopCapturing];
    // 先停止Run是因为动画结束时再停止会导致已经播放的视频无故暂停
    [self.recorder stopRunning];
    [self.preview previewVideoOfURL:recorder.URL];
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:MNCaptureToolBarAnimationDuration animations:^{
        weakself.preview.alpha = 1.f;
        weakself.movieView.alpha = weakself.cameraButton.alpha = weakself.liveButton.alpha = 0.f;
    }];
}

- (void)movieRecorderDidCancelRecording:(MNMovieRecorder *)recorder {
    [self.toolBar resetCapturing];
}

- (void)movieRecorderDidChangeSessionPreset:(MNMovieRecorder *)recorder error:(NSError *)error {
    if (error) {
        self.view.userInteractionEnabled = YES;
        [self.view showInfoDialog:error.localizedDescription];
        return;
    }
    self.liveButton.selected = [recorder.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto];
    CGRect movieRect = self.movieRect;
    if (self.liveButton.isSelected) {
        CGSize presetSize = CGSizeMultiplyToWidth(CGSizeMake(3.f, 4.f), self.contentView.width_mn);
        presetSize.height = ceil(presetSize.height);
        movieRect.size = presetSize;
        movieRect.origin.y = floor((self.toolBar.top_mn - self.cameraButton.bottom_mn - presetSize.height)/2.f + self.cameraButton.bottom_mn);
    }
    self.preview.frame = movieRect;
    self.movieView.frame = movieRect;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    recorder.previewLayer.frame = self.movieView.bounds;
    [CATransaction commit];
    self.view.userInteractionEnabled = YES;
}

- (void)movieRecorder:(MNMovieRecorder *)recorder didBeginTakingPhoto:(BOOL)isLivePhoto {
    self.view.userInteractionEnabled = NO;
    if (isLivePhoto && self.liveLabel.alpha == 0.f) {
        __weak typeof(self) weakself = self;
        [UIView animateWithDuration:MNCaptureToolBarAnimationDuration animations:^{
            weakself.liveLabel.alpha = 1.f;
        }];
    }
}

- (void)movieRecorderDidTakingPhoto:(MNCapturePhoto *)photo error:(NSError *)error {
    if (self.liveLabel.alpha == 1.f) {
        __weak typeof(self) weakself = self;
        [self.liveLabel.layer removeAllAnimations];
        [UIView animateWithDuration:MNCaptureToolBarAnimationDuration animations:^{
            weakself.liveLabel.alpha = 0.f;
        }];
    }
    if (error) {
        self.view.userInteractionEnabled = YES;
        [self.view showInfoDialog:error.localizedDescription];
        return;
    }
    [self.toolBar stopCapturing];
    if (photo.isLivePhoto) {
        MNCaptureLivePhoto *livePhoto = (MNCaptureLivePhoto *)photo;
        [self.preview previewLivePhotoUsingImageData:livePhoto.imageData videoURL:livePhoto.videoURL];
    } else {
        [self.preview previewImage:photo.image];
    }
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:MNCaptureToolBarAnimationDuration animations:^{
        weakself.preview.alpha = 1.f;
        weakself.movieView.alpha = weakself.cameraButton.alpha = weakself.liveButton.alpha = 0.f;
    } completion:^(BOOL finished) {
        [weakself.recorder stopRunning];
        weakself.view.userInteractionEnabled = YES;
    }];
}

- (void)movieRecorder:(MNMovieRecorder *)recorder didFailWithError:(NSError *)error {
    if (error.code == AVErrorApplicationIsNotAuthorized) {
        __weak typeof(self) weakself = self;
        [[MNAlertView alertViewWithTitle:nil message:error.localizedDescription handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
            if ([weakself.delegate respondsToSelector:@selector(cameraControllerDidCancel:)]) {
                [weakself.delegate cameraControllerDidCancel:weakself];
            }
        } ensureButtonTitle:@"确定" otherButtonTitles:nil] showInView:self.view];
    } else {
        [self.toolBar resetCapturing];
        [self.view showInfoDialog:error.localizedDescription];
    }
}

#pragma mark - 后台通知
- (void)didEnterBackgroundNotification:(NSNotification *)notify {
    self.recorder.delegate = nil;
    [self.recorder cancelRecording];
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
