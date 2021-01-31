//
//  WXSelectCoverController.m
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXSelectCoverController.h"
#import "WXSelectCoverView.h"
#import "NSBundle+MNHelper.h"
#import "WXDataValueModel.h"
#import "MNFileHandle.h"
#import "MNFileManager.h"
#import "MNAsset.h"
#import "MNAssetPreviewController.h"
#import "MNAssetExporter+MNExportMetadata.h"

#define MNVideoTailorMargin 15.f
#define MNVideoTailorInterval 20.f
#define MNVideoTailorButtonTag  100

@interface WXSelectCoverController ()<MNPlayerDelegate, WXCoverViewDelegate, MNAssetPreviewDelegate>
@property (nonatomic, strong) MNPlayer *player;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIControl *playControl;
@property (nonatomic, strong) MNPlayView *playView;
@property (nonatomic, strong) MNLivePhoto *livePhoto;
@property (nonatomic, strong) UIImageView *badgeView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) WXSelectCoverView *coverView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation WXSelectCoverController
- (instancetype)initWithVideoPath:(NSString *)videoPath {
    if (self = [super init]) {
        self.videoPath = videoPath.copy;
    }
    return self;
}

- (void)createView {
    [super createView];
    // Do any additional setup after loading the view.
    
    self.contentView.backgroundColor = UIColor.blackColor;
    
    UIButton *closeButton = [UIButton buttonWithFrame:CGRectZero image:[MNBundle imageForResource:@"player_close"] title:nil titleColor:nil titleFont:nil];
    closeButton.size_mn = CGSizeMake(30.f, 30.f);
    closeButton.left_mn = MNVideoTailorMargin;
    closeButton.bottom_mn = self.contentView.height_mn - MAX(MNVideoTailorMargin, MN_TAB_SAFE_HEIGHT + 7.f);
    closeButton.touchInset = UIEdgeInsetWith(-7.f);
    [closeButton setBackgroundImage:[closeButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closeButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:closeButton];
    
    UIButton *doneButton = [UIButton buttonWithFrame:CGRectZero image:[MNBundle imageForResource:@"player_done"] title:nil titleColor:nil titleFont:nil];
    doneButton.size_mn = closeButton.size_mn;
    doneButton.right_mn = self.contentView.width_mn - closeButton.left_mn;
    doneButton.centerY_mn = closeButton.centerY_mn;
    doneButton.touchInset = closeButton.touchInset;
    doneButton.enabled = NO;
    [doneButton setBackgroundImage:[doneButton backgroundImageForState:UIControlStateNormal] forState:UIControlStateHighlighted];
    [doneButton addTarget:self action:@selector(doneButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:doneButton];
    self.doneButton = doneButton;
    
    UILabel *timeLabel = [UILabel labelWithFrame:CGRectZero text:[NSString stringWithFormat:@"00:00/%@", [NSDate timeStringWithInterval:@(self.duration)]] alignment:NSTextAlignmentCenter textColor:[UIColor colorWithHex:@"F7F7F7"] font:[UIFont systemFontOfSize:12.f]];
    timeLabel.width_mn = doneButton.left_mn - closeButton.right_mn - closeButton.left_mn*2.f;
    timeLabel.height_mn = timeLabel.font.pointSize;
    timeLabel.centerX_mn = self.contentView.width_mn/2.f;
    timeLabel.centerY_mn = closeButton.centerY_mn;
    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    UIControl *playControl = [[UIControl alloc] initWithFrame:CGRectMake(closeButton.left_mn, 0.f, 48.f, 48.f)];
    playControl.bottom_mn = closeButton.top_mn - MNVideoTailorInterval;
    playControl.userInteractionEnabled = NO;
    playControl.backgroundColor = [UIColor colorWithRed:51.f/255.f green:51.f/255.f blue:51.f/255.f alpha:1.f];
    [playControl.layer setMaskRadius:4.f byCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft];
    [playControl addTarget:self action:@selector(playControlTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:playControl];
    self.playControl = playControl;
    
    UIImageView *badgeView = [UIImageView imageViewWithFrame:CGRectZero image:[MNBundle imageForResource:@"player_play"]];
    badgeView.highlightedImage = [MNBundle imageForResource:@"player_pause"];
    badgeView.size_mn = CGSizeMultiplyToWidth(badgeView.image.size, 25.f);
    badgeView.center_mn = playControl.bounds_center;
    badgeView.userInteractionEnabled = NO;
    [playControl addSubview:badgeView];
    self.badgeView = badgeView;
    
    WXSelectCoverView *coverView = [[WXSelectCoverView alloc] initWithFrame:CGRectMake(playControl.right_mn + 2.f, 0.f, doneButton.right_mn - playControl.right_mn - 2.f, playControl.height_mn) videoPath:self.videoPath];
    coverView.delegate = self;
    coverView.bottom_mn = playControl.bottom_mn;
    [self.contentView addSubview:coverView];
    self.coverView = coverView;
    
    // 计算播放尺寸
    CGFloat top = MN_STATUS_BAR_HEIGHT + MN_NAV_BAR_HEIGHT/2.f;
    CGFloat width = self.contentView.width_mn;
    CGFloat height = playControl.top_mn - MNVideoTailorInterval - top;
    CGSize naturalSize = self.naturalSize;
    if (naturalSize.width >= naturalSize.height) {
        // 横向视频
        naturalSize = CGSizeMultiplyToWidth(naturalSize, width);
        if (naturalSize.height > height) {
            naturalSize = CGSizeMultiplyToHeight(naturalSize, height);
        }
    } else {
        // 纵向视频
        naturalSize = CGSizeMultiplyToHeight(naturalSize, height);
        if (naturalSize.width > width) {
            naturalSize = CGSizeMultiplyToWidth(naturalSize, width);
        }
    }
    MNPlayView *playView = [[MNPlayView alloc] initWithFrame:CGRectMake(0.f, 0.f, naturalSize.width, naturalSize.height)];
    playView.scrollEnabled = NO;
    playView.touchEnabled = NO;
    playView.autoresizingMask = UIViewAutoresizingNone;
    playView.center_mn = CGPointMake(self.contentView.width_mn/2.f, height/2.f + top);
    playView.backgroundColor = [UIColor colorWithRed:51.f/255.f green:51.f/255.f blue:51.f/255.f alpha:1.f];
    playView.backgroundImage = self.thumbnail;
    [self.contentView addSubview:playView];
    self.playView = playView;
    
    // 进度条
    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    progressLayer.path = [UIBezierPath bezierPathWithRect:playView.bounds].CGPath;
    progressLayer.lineWidth = 1.f;
    progressLayer.fillColor = UIColor.clearColor.CGColor;
    progressLayer.strokeColor = THEME_COLOR.CGColor;
    progressLayer.strokeStart = 0.f;
    progressLayer.strokeEnd = 0.f;
    [playView.layer addSublayer:progressLayer];
    self.progressLayer = progressLayer;
    
    // 加载动画
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.color = [UIColor colorWithHex:@"F7F7F7"];
    indicatorView.hidesWhenStopped = YES;
    indicatorView.center_mn = playView.bounds_center;
    [playView addSubview:indicatorView];
    self.indicatorView = indicatorView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.player.isPlaying) [self.player pause];
}

- (void)loadData {
    MNPlayer *player = [[MNPlayer alloc] initWithURL:[NSURL fileURLWithPath:self.videoPath]];
    player.delegate = self;
    player.layer = self.playView.layer;
    player.observeTime = CMTimeMake(1, 60);
    self.player = player;
    [self.coverView loadThumbnails];
}

#pragma mark - MNPlayerDelegate
- (void)playerDidEndDecode:(MNPlayer *)player {
    self.doneButton.enabled = YES;
    self.playControl.userInteractionEnabled = YES;
    [self.indicatorView stopAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.playView.backgroundImage = nil;
    });
}

- (void)playerDidChangeState:(MNPlayer *)player {
    self.badgeView.highlighted = player.state == MNPlayerStatePlaying;
}

- (void)playerDidPlayTimeInterval:(MNPlayer *)player {
    if (player.state != MNPlayerStatePlaying) return;
    NSString *text = self.timeLabel.text;
    NSArray *components = [text componentsSeparatedByString:@"/"];
    if (components.count <= 1) return;
    NSString *duration = [NSDate timeStringWithInterval:@(player.currentTimeInterval)];
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", duration, components.lastObject];
    [CALayer performWithoutAnimation:^{
        self.progressLayer.strokeEnd = player.progress;
    }];
}

- (void)playerDidPlayFailure:(MNPlayer *)player {
    @weakify(self);
    [self.indicatorView stopAnimating];
    [[MNAlertView alertViewWithTitle:nil message:player.error.localizedDescription handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    } ensureButtonTitle:@"确定" otherButtonTitles:nil] showInView:self.view];
}

#pragma mark - WXCoverViewDelegate
/**开始加载截图*/
- (void)coverViewBeginLoadThumbnails:(WXSelectCoverView *)coverView {
    [self.indicatorView startAnimating];
}
/**已经加载截图*/
- (void)coverViewDidLoadThumbnails:(WXSelectCoverView *)coverView {
    [self.player play];
}
/**加载截图失败*/
- (void)coverViewLoadThumbnailsFailed:(WXSelectCoverView *)coverView {
    __weak typeof(self) weakself = self;
    [[MNAlertView alertViewWithTitle:nil message:@"无法获取视频内容" handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
        [weakself closeButtonTouchUpInside:nil];
    } ensureButtonTitle:@"确定" otherButtonTitles:nil] showInView:self.view];
}
/**选择截图*/
- (void)coverViewDidSelectThumbnail:(WXDataValueModel *)model {
    @weakify(self);
    CGFloat progress = [model.value floatValue];
    [self.player seekToProgress:progress completion:^(BOOL finished) {
        if (!weakself.player.isPlaying && finished) {
            [CALayer performWithoutAnimation:^{
                weakself.progressLayer.strokeEnd = progress;
            }];
        }
    }];
}

#pragma mark - MNAssetPreviewDelegate
- (void)previewController:(MNAssetPreviewController *)previewController rightBarItemTouchUpInside:(UIControl *)sender {
    @weakify(self);
    @weakify(previewController);
    [previewController.view showActivityDialog:@"请稍后"];
    [MNAssetHelper writeLivePhoto:self.livePhoto.content completion:^(NSString * _Nullable identifier, NSError * _Nullable error) {
        if (identifier.length <= 0 || error) {
            [weakpreviewController.view showInfoDialog:@"LivePhoto保存失败"];
        } else {
            [weakpreviewController.view closeDialogWithCompletionHandler:^{
                [weakself.livePhoto removeFiles];
                UIViewController *vc = weakself.navigationController.viewControllers[[weakself.navigationController.viewControllers indexOfObject:weakself] - 1];
                [weakself.navigationController popToViewController:vc animated:YES];
            }];
        }
    }];
}

#pragma mark - Event
- (void)playControlTouchUpInside {
    if (self.player.isPlaying) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

- (void)closeButtonTouchUpInside:(UIButton *)closeButton {
    [self.player pause];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonTouchUpInside:(UIButton *)closeButton {
    if (self.player.isPlaying) [self.player pause];
    if (self.livePhoto) [self.livePhoto removeFiles];
    @weakify(self);
    [self.view showProgressDialog:@"LivePhoto导出中"];
    WXDataValueModel *model = self.coverView.coverModel;
    [MNLivePhoto requestLivePhotoWithVideoFileAtPath:self.videoPath stillSeconds:[model.value floatValue]*self.duration progressHandler:^(float progress) {
        [weakself.view updateDialogProgress:progress];
    } completionHandler:^(MNLivePhoto *livePhoto) {
        if (livePhoto) {
            [weakself.view closeDialogWithCompletionHandler:^{
                weakself.livePhoto = livePhoto;
                MNAssetPreviewController *vc = [[MNAssetPreviewController alloc] initWithAssets:@[[MNAsset assetWithContent:livePhoto.content]]];
                vc.delegate = weakself;
                vc.cleanAssetWhenDealloc = YES;
                vc.events = MNAssetPreviewEventDone;
                [weakself.navigationController pushViewController:vc animated:YES];
            }];
        } else {
            [weakself.view showInfoDialog:@"LivePhoto导出失败"];
        }
    }];
}

#pragma mark - Setter
- (void)setVideoPath:(NSString *)videoPath {
    _videoPath = videoPath.copy;
    if (videoPath.length && [NSFileManager.defaultManager fileExistsAtPath:videoPath]) {
        if (self.duration <= 0.f) self.duration = [MNAssetExporter exportDurationWithMediaAtPath:videoPath];
        if (!self.thumbnail) self.thumbnail = [MNAssetExporter exportThumbnailOfVideoAtPath:videoPath];
        if (CGSizeEqualToSize(self.naturalSize, CGSizeZero)) self.naturalSize = [MNAssetExporter exportNaturalSizeOfVideoAtPath:videoPath];
    }
}

#pragma mark - dealloc
- (void)dealloc {
    if (self.livePhoto) [self.livePhoto removeFiles];
}

@end
