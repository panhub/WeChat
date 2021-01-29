//
//  MNAssetTouchController.m
//  MNKit
//
//  Created by Vincent on 2019/9/6.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNAssetTouchController.h"
#import "MNAsset.h"
#import "MNPlayView.h"
#import "MNAssetScrollView.h"
#import "MNAssetProgressView.h"
#import "MNAssetSelectButton.h"
#if __has_include(<Photos/Photos.h>)
#import "MNAssetHelper.h"
#endif
#if __has_include(<PhotosUI/PHLivePhotoView.h>)
#import <PhotosUI/PHLivePhotoView.h>
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@interface MNAssetTouchController ()<MNSliderDelegate, MNPlayerDelegate>
@property (nonatomic, strong) MNPlayer *player;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) MNPlayView *playView;
@property (nonatomic, strong) MNSlider *slider;
@property (nonatomic, strong) UIView *livePhotoView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIImageView *badgeView;
@property (nonatomic, strong) MNAssetScrollView *scrollView;
@property (nonatomic, strong) UIImageView *playToolBar;
@property (nonatomic, strong) UIImageView *videoSnapshotView;
@property (nonatomic, strong) MNAssetSelectButton *selectButton;
@property (nonatomic, strong) MNAssetProgressView *progressView;
@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;

@end

@implementation MNAssetTouchController
- (instancetype)init {
    if (self = [super init]) {
        self.events = MNAssetTouchEventNone;
        self.statusBarHidden = UIApplication.sharedApplication.isStatusBarHidden;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.alpha = 0.f;
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.backgroundColor = UIColor.clearColor;
    
    self.contentView.backgroundColor = UIColor.blackColor;
    
    /*
    UIImageView *backgroundView = [UIImageView imageViewWithFrame:self.contentView.bounds image:self.asset.thumbnail.darkEffect];
    backgroundView.clipsToBounds = YES;
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:backgroundView];
    */
    MNAssetScrollView *scrollView = [[MNAssetScrollView alloc] initWithFrame:self.contentView.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;
    
    if (self.asset.type == MNAssetTypePhoto || self.asset.type == MNAssetTypeGif) {
        UIImageView *imageView = [UIImageView imageViewWithFrame:scrollView.contentView.bounds image:self.asset.thumbnail];
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [scrollView.contentView addSubview:imageView];
        self.imageView = imageView;
    } else if (self.asset.type == MNAssetTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            PHLivePhotoView *livePhotoView = [[PHLivePhotoView alloc] initWithFrame:scrollView.contentView.bounds];
            livePhotoView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            livePhotoView.clipsToBounds = YES;
            livePhotoView.backgroundImage = self.asset.thumbnail;
            livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
            [scrollView.contentView addSubview:livePhotoView];
            self.livePhotoView = livePhotoView;
            
            UIImageView *badgeView = [UIImageView imageViewWithFrame:CGRectMake(13.f, 13.f, 20.f, 20.f) image:[MNBundle imageForResource:@"icon_live_photo"]];
            badgeView.contentMode = UIViewContentModeScaleAspectFill;
            badgeView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
            [livePhotoView addSubview:badgeView];
            self.badgeView = badgeView;
        }
    } else {
        UIImageView *videoSnapshotView = [UIImageView imageViewWithFrame:scrollView.contentView.bounds image:self.asset.thumbnail];
        videoSnapshotView.contentMode = UIViewContentModeScaleAspectFit;
        videoSnapshotView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [scrollView.contentView addSubview:videoSnapshotView];
        self.videoSnapshotView = videoSnapshotView;
        
        MNPlayView *playView = [[MNPlayView alloc] initWithFrame:videoSnapshotView.bounds];
        playView.touchEnabled = NO;
        playView.scrollEnabled = NO;
        playView.backgroundColor = [UIColor clearColor];
        playView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [videoSnapshotView addSubview:playView];
        self.playView = playView;
        
        UIImageView *playToolBar = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, MN_TAB_SAFE_HEIGHT + 60.f) image:[MNBundle imageForResource:@"shadow_line_bottom"]];
        playToolBar.hidden = YES;
        playToolBar.bottom_mn = self.contentView.bottom_mn;
        playToolBar.userInteractionEnabled = YES;
        playToolBar.contentMode = UIViewContentModeScaleToFill;
        playToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addSubview:playToolBar];
        self.playToolBar = playToolBar;
        
        UIButton *playButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f) image:[MNBundle imageForResource:@"icon_play"] title:nil titleColor:nil titleFont:nil];
        playButton.left_mn = 7.f;
        playButton.centerY_mn = (playToolBar.height_mn - MN_TAB_SAFE_HEIGHT)/2.f;
        [playButton setBackgroundImage:[MNBundle imageForResource:@"icon_pause"] forState:UIControlStateSelected];
        playButton.adjustsImageWhenHighlighted = NO;
        [playButton.layer removeAllAnimations];
        [playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [playToolBar addSubview:playButton];
        self.playButton = playButton;
        
        UILabel *currentTimeLabel = [UILabel labelWithFrame:CGRectMake(playButton.right_mn + 5.f, 0.f, 0.f, 12.f) text:@"00:00" textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:12.f]];
        [currentTimeLabel sizeToFit];
        currentTimeLabel.width_mn += 8.f;
        currentTimeLabel.centerY_mn = playButton.centerY_mn;
        [playToolBar addSubview:currentTimeLabel];
        self.currentTimeLabel = currentTimeLabel;
        
        UILabel *durationLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, 0.f, 12.f) text:self.asset.durationString textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:12.f]];
        [durationLabel sizeToFit];
        durationLabel.width_mn += 8.f;
        durationLabel.textAlignment = NSTextAlignmentRight;
        durationLabel.right_mn = playToolBar.width_mn - 15.f;
        durationLabel.centerY_mn = playButton.centerY_mn;
        [playToolBar addSubview:durationLabel];
        self.durationLabel = durationLabel;
        
        MNSlider *slider = [[MNSlider alloc] initWithFrame:CGRectMake(currentTimeLabel.right_mn, 0.f, durationLabel.left_mn - currentTimeLabel.right_mn, 16.f)];
        slider.centerY_mn = playButton.centerY_mn;
        slider.delegate = self;
        slider.trackHeight = 3.f;
        slider.borderWidth = 0.f;
        slider.touchInset = UIEdgeInsetWith(-3.f);
        slider.progressColor = [UIColor whiteColor];
        slider.trackColor = [[UIColor whiteColor] colorWithAlphaComponent:.2f];
        slider.bufferColor = [[UIColor whiteColor] colorWithAlphaComponent:.2f];
        [playToolBar addSubview:slider];
        self.slider = slider;
    }
    
    MNAssetProgressView *progressView = [[MNAssetProgressView alloc] initWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
    progressView.center_mn = self.contentView.bounds_center;
    progressView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    progressView.hidden = YES;
    progressView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.15f];
    progressView.layer.cornerRadius = 20.f;
    progressView.clipsToBounds = YES;
    [self.contentView addSubview:progressView];
    self.progressView = progressView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.contentView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    //singleTap.delegate = self;
    singleTap.numberOfTapsRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.contentView addGestureRecognizer:singleTap];
}

- (void)loadData {
    if (self.state == MNAssetTouchStateWeight) return;
#if __has_include(<Photos/Photos.h>)
    [MNAssetHelper requestAssetContent:self.asset progress:^(double pro, NSError *error, MNAsset *model) {
        if (error) {
            self.progressView.hidden = YES;
            self.progressView.progress = 0.f;
        } else if (self.state == MNAssetTouchStateWeight) {
            self.progressView.progress = pro;
            self.progressView.hidden = NO;
        }
    } completion:^(MNAsset *model) {
        self.progressView.hidden = YES;
        self.progressView.progress = 0.f;
        if (!model || model != self.asset) return;
        [self displayContentIfNeeded];
    }];
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.state != MNAssetTouchStateWeight || self.navigationBar.alpha) return;
    self.badgeView.hidden = YES;
    [UIView animateWithDuration:.2f animations:^{
        self.navigationBar.alpha = 1.f;
    }];
    [self updateContentIfNeeded];
    [self displayContentIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:(self.navigationBar.bottom_mn <= 0.f) withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:self.isStatusBarHidden withAnimation:UIStatusBarAnimationFade];
    if (_player) [_player pause];
}

#pragma mark - 更新内容
- (void)updateContentIfNeeded {
    UIImage *image = self.asset.thumbnail;
    CGFloat width = self.scrollView.width_mn;
    CGFloat height = image.size.height/image.size.width*width;
    if (isnan(height) || height < 1.f) height = self.scrollView.height_mn;
    height = floor(height);
    if (height > self.scrollView.height_mn && height - self.scrollView.height_mn <= 1.f) height = self.scrollView.height_mn;
    
    self.scrollView.zoomScale = 1.f;
    self.scrollView.contentOffset = CGPointZero;
    
    self.scrollView.contentView.size_mn = CGSizeMake(width, height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentView.width_mn, MAX(self.scrollView.contentView.height_mn, self.scrollView.height_mn));
    self.scrollView.contentView.center_mn = self.scrollView.bounds_center;
    if (self.scrollView.contentView.height_mn > self.scrollView.height_mn) {
        self.scrollView.contentView.top_mn = 0.f;
        self.scrollView.contentOffset = CGPointMake(0.f, (self.scrollView.contentView.height_mn - self.scrollView.height_mn)/2.f);
    }
}

- (void)displayContentIfNeeded {
    if (!self.asset.content) return;
    if (self.asset.type == MNAssetTypeVideo) {
        self.videoSnapshotView.image = self.asset.thumbnail;
        if (self.state != MNAssetTouchStateWeight) return;
        self.playToolBar.hidden = NO;
        [self.player addURL:[NSURL fileURLWithPath:self.asset.content]];
        [self.player play];
    } else if (self.asset.type == MNAssetTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            PHLivePhotoView *livePhotoView = (PHLivePhotoView *)self.livePhotoView;
            livePhotoView.layer.contents = nil;
            livePhotoView.livePhoto = self.asset.content;
            [livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        }
    } else {
        self.imageView.image = self.asset.content;
    }
}

#pragma mark - Event
- (void)singleTap:(UITapGestureRecognizer *)recognizer {
    BOOL isStatusBarHidden = UIApplication.sharedApplication.isStatusBarHidden;
    [UIView animateWithDuration:UIApplication.sharedApplication.statusBarOrientationAnimationDuration animations:^{
        self.navigationBar.top_mn = isStatusBarHidden ? 0.f : -self.navigationBar.height_mn;
        if (self.playToolBar) self.playToolBar.top_mn = self.contentView.height_mn - (isStatusBarHidden ?  self.playToolBar.height_mn : 0.f);
        [UIApplication.sharedApplication setStatusBarHidden:!isStatusBarHidden animated:UIStatusBarAnimationFade];
    }];
}

- (void)doubleTap:(UITapGestureRecognizer *)recognizer {
    if (self.scrollView.zoomScale > 1.f) {
        [self.scrollView setZoomScale:1.f animated:YES];
    } else {
        CGPoint touchPoint = [recognizer locationInView:self.scrollView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.scrollView.width_mn/newZoomScale;
        CGFloat ysize = self.scrollView.height_mn/newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2.f, touchPoint.y - ysize/2.f, xsize, ysize) animated:YES];
    }
}

#pragma mark - MNPlayerDelegate
- (void)playerDidChangeState:(MNPlayer *)player {
    self.playButton.selected = player.state == MNPlayerStatePlaying;
}

- (void)playerDidPlayTimeInterval:(MNPlayer *)player {
    self.slider.progress = player.progress;
    self.currentTimeLabel.text = [NSDate timeStringWithInterval:@(player.currentTimeInterval)];
}

- (void)playerDidPlayFailure:(MNPlayer *)player {
    [self.contentView showInfoDialog:player.error.localizedDescription];
}

#pragma mark - MNSliderDelegate
- (BOOL)sliderShouldBeginDragging:(MNSlider *)slider {
    return self.player.state > MNPlayerStateFailed;
}

- (void)sliderWillBeginDragging:(MNSlider *)slider {
    [self.player pause];
}

- (void)sliderDidDragging:(MNSlider *)slider {
    [self.player seekToProgress:slider.progress completion:nil];
}

- (void)sliderDidEndDragging:(MNSlider *)slider {
    [self.player play];
}

#pragma mark - Event
- (void)playButtonClicked:(UIButton *)sender {
    if (self.player.state == MNPlayerStateFailed) return;
    if (self.player.state == MNPlayerStatePlaying) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

#pragma mark - Setter
- (void)setAsset:(MNAsset *)asset {
    _asset = asset;
    if (self.selectButton) [self.selectButton updateAsset:asset];
}

#pragma mark - Getter
- (MNPlayer *)player {
    if (!_player) {
        MNPlayer *player = [MNPlayer new];
        player.delegate = self;
        player.layer = self.playView.layer;
        player.observeTime = CMTimeMake(1, 60);
        _player = player;
    }
    return _player;
}

#ifdef NSFoundationVersionNumber_iOS_9_0
#pragma mark - 上拉菜单
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    return self.actions;
}
#endif

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIButton *leftItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 33.f, 33.f) image:[[MNBundle imageForResource:@"icon_down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] title:nil titleColor:nil titleFont:nil];
    leftItem.tintColor = [UIColor whiteColor];
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIView *rightBarItem = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 25.f)];
    if (self.events & MNAssetTouchEventSelect) {
        MNAssetSelectButton *selectButton = [[MNAssetSelectButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, rightBarItem.height_mn)];
        selectButton.centerY_mn = rightBarItem.height_mn/2.f;
        selectButton.tag = MNAssetTouchEventSelect;
        selectButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [selectButton addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        if (self.asset) [selectButton updateAsset:self.asset];
        [rightBarItem addSubview:selectButton];
        rightBarItem.width_mn = selectButton.right_mn;
        self.selectButton = selectButton;
    }
    if (self.events & MNAssetTouchEventDone) {
        // 确定
        UIButton *doneButton = [UIButton buttonWithFrame:CGRectZero image:nil title:@"确定" titleColor:UIColor.whiteColor titleFont:[UIFont systemFontOfSize:16.5f]];
        [doneButton sizeToFit];
        doneButton.height_mn = rightBarItem.height_mn;
        doneButton.left_mn = rightBarItem.width_mn + 15.f;
        doneButton.centerY_mn = rightBarItem.height_mn/2.f;
        doneButton.tag = MNAssetTouchEventDone;
        doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [doneButton addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [rightBarItem addSubview:doneButton];
        rightBarItem.width_mn = doneButton.right_mn + 15.f;
    }
    return rightBarItem;
}

- (void)navigationBarDidCreateBarItem:(MNNavigationBar *)navigationBar {
    UIImageView *shadowView = [UIImageView imageViewWithFrame:navigationBar.bounds image:[MNBundle imageForResource:@"shadow_line_top"]];
    shadowView.userInteractionEnabled = NO;
    shadowView.contentMode = UIViewContentModeScaleToFill;
    [navigationBar insertSubview:shadowView atIndex:0];
}

- (void)navigationBarRightBarItemTouchUpInside:(UIControl *)rightItem {
    if ([self.delegate respondsToSelector:@selector(touchController:rightBarItemTouchUpInside:)]) {
        [self.delegate touchController:self rightBarItemTouchUpInside:rightItem];
        if (rightItem.tag == MNAssetTouchEventSelect) {
            [kTransform(MNAssetSelectButton *, rightItem) updateAsset:self.asset];
        }
    }
}

#pragma mark - Super
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

#pragma mark - dealloc
- (void)dealloc {
    _player.delegate = nil;
    if (self.isCleanAssetWhenDealloc) self.asset.content = nil;
#if __has_include(<Photos/Photos.h>)
    [MNAssetHelper cancelAssetRequest:self.asset];
#endif
}

@end
#pragma clang diagnostic pop
#pragma clang diagnostic pop
