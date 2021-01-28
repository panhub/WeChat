//
//  MNAssetBrowseCell.m
//  MNKit
//
//  Created by Vincent on 2019/9/7.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNAssetBrowseCell.h"
#import "MNAssetProgressView.h"
#import "MNPlayView.h"
#import "MNAssetHelper.h"
#import <Photos/Photos.h>
#if __has_include(<PhotosUI/PHLivePhotoView.h>)
#import <PhotosUI/PHLivePhotoView.h>
#endif

@interface MNAssetBrowseCell ()<UIScrollViewDelegate, MNPlayerDelegate, MNSliderDelegate>
@property (nonatomic, strong) MNSlider *slider;
@property (nonatomic, strong) MNPlayer *player;
@property (nonatomic, strong) MNPlayView *playView;
@property (nonatomic, strong) UIView *livePhotoView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIImageView *playToolBar;
@property (nonatomic, strong) UIImageView *videoSnapshotView;
@property (nonatomic, strong) MNAssetScrollView *scrollView;
@property (nonatomic, strong) MNAssetProgressView *progressView;
@property (nonatomic, getter=isAllowsAutoPlaying) BOOL allowsAutoPlaying;
@end

@implementation MNAssetBrowseCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    
        self.backgroundColor = self.contentView.backgroundColor = [UIColor clearColor];
        
        MNAssetScrollView *scrollView = [[MNAssetScrollView alloc] initWithFrame:self.contentView.bounds];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:scrollView];
        self.scrollView = scrollView;
        
        UIImageView *videoSnapshotView = [UIImageView imageViewWithFrame:scrollView.contentView.bounds image:nil];
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
        
        if (@available(iOS 9.1, *)) {
            PHLivePhotoView *livePhotoView = [[PHLivePhotoView alloc] initWithFrame:scrollView.contentView.bounds];
            livePhotoView.clipsToBounds = YES;
            livePhotoView.contentMode = UIViewContentModeScaleAspectFit;
            livePhotoView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [scrollView.contentView addSubview:livePhotoView];
            self.livePhotoView = livePhotoView;
            /*
            UIImageView *badgeView = [UIImageView imageViewWithFrame:CGRectMake(13.f, 13.f, 17.f, 17.f) image:[MNBundle imageForResource:@"icon_live_photo"]];
            badgeView.contentMode = UIViewContentModeScaleAspectFill;
            badgeView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
            [livePhotoView addSubview:badgeView];
            */
        }
        
        self.imageView.frame = scrollView.contentView.bounds;
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.imageView removeFromSuperview];
        [scrollView.contentView addSubview:self.imageView];
        
        MNAssetProgressView *progressView = [[MNAssetProgressView alloc] initWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
        progressView.center_mn = self.contentView.bounds_center;
        progressView.hidden = YES;
        progressView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.15f];
        progressView.layer.cornerRadius = 20.f;
        progressView.clipsToBounds = YES;
        [self.contentView addSubview:progressView];
        self.progressView = progressView;
        
        UIImageView *playToolBar = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, MN_TAB_SAFE_HEIGHT + 60.f) image:[MNBundle imageForResource:@"shadow_line_bottom"]];
        playToolBar.bottom_mn = self.contentView.bottom_mn;
        playToolBar.userInteractionEnabled = YES;
        playToolBar.contentMode = UIViewContentModeScaleToFill;
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
        
        UILabel *durationLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, 0.f, 12.f) text:@"00:00" textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:12.f]];
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
    return self;
}

- (void)displayContentIfNeeded {
    if (!self.asset.content || self.state != MNAssetBrowseStatePreviewing) return;
    if (self.asset.type == MNAssetTypeVideo) {
        [self.player addURL:[NSURL fileURLWithPath:self.asset.content]];
        if (self.isAllowsAutoPlaying) [self.player play];
    } else if (self.asset.type == MNAssetTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            PHLivePhotoView *livePhotoView = (PHLivePhotoView *)self.livePhotoView;
            livePhotoView.layer.contents = nil;
            livePhotoView.livePhoto = self.asset.content;
            if (self.isAllowsAutoPlaying) [livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        }
    } else {
        self.imageView.image = self.asset.content;
    }
}

- (void)didBeginDisplaying {
    self.state = MNAssetBrowseStatePreviewing;
    [self displayContentIfNeeded];
}

- (void)didEndDisplaying {
    self.state = MNAssetBrowseStateNormal;
    if (self.asset.type == MNAssetTypeVideo) {
        [_player removeAllURLs];
        self.slider.progress = 0.f;
        self.playButton.selected = NO;
        self.playToolBar.hidden = YES;
        self.videoSnapshotView.image = nil;
        self.currentTimeLabel.text = @"00:00";
    } else if (self.asset.type == MNAssetTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            PHLivePhotoView *livePhotoView = (PHLivePhotoView *)self.livePhotoView;
            if (livePhotoView.livePhoto) {
                [livePhotoView stopPlayback];
                livePhotoView.livePhoto = nil;
            }
        }
    } else {
        self.imageView.image = nil;
    }
    [MNAssetHelper cancelAssetRequest:self.asset];
}

#pragma mark - Setter
- (void)setPlayToolBarVisible:(BOOL)isVisible animated:(BOOL)animated {
    [UIView animateWithDuration:(animated ? UIApplication.sharedApplication.statusBarOrientationAnimationDuration : CGFLOAT_MIN) animations:^{
        self.playToolBar.top_mn = self.contentView.height_mn - (isVisible ? self.playToolBar.height_mn : 0.f);
    }];
}

- (void)setDelegate:(id<MNAssetBrowseCellDelegate>)delegate {
    _delegate = delegate;
    if (delegate && [delegate respondsToSelector:@selector(assetBrowseCellShouldAutoPlaying:)]) {
        self.allowsAutoPlaying = [delegate assetBrowseCellShouldAutoPlaying:self];
    }
}

- (void)setAsset:(MNAsset *)asset {
    _asset = asset;
    
    self.state = MNAssetBrowseStateThumbnailLoading;
    
    self.progressView.hidden = YES;
    self.imageView.hidden = (asset.type != MNAssetTypePhoto && asset.type != MNAssetTypeGif);
    self.livePhotoView.hidden = asset.type != MNAssetTypeLivePhoto;
    self.playToolBar.hidden = self.videoSnapshotView.hidden = asset.type != MNAssetTypeVideo;
    
    self.scrollView.zoomScale = 1.f;
    self.scrollView.contentOffset = CGPointZero;
    
    /// 获取缩略图
    __weak typeof(self) weakself = self;
    [[MNAssetHelper helper] requestAssetThumbnail:asset completion:^(MNAsset *model) {
        
        __strong typeof(self) self = weakself;
        
        if (model != self.asset || self.state != MNAssetBrowseStateThumbnailLoading) return;
        
        self.state = MNAssetBrowseStateContentLoading;
        
        UIImage *image = model.thumbnail;
        if ([model.content isKindOfClass:UIImage.class]) image = model.content;
        if (image.images.count > 1) image = image.images.firstObject;
        
        self.scrollView.contentView.size_mn = [MNAssetBrowseCell aspectImage:image inSize:self.scrollView.size_mn];
        self.scrollView.contentSize = CGSizeMake(self.scrollView.width_mn, MAX(self.scrollView.contentView.height_mn, self.scrollView.height_mn));
        self.scrollView.contentView.center_mn = self.scrollView.bounds_center;
        if (self.scrollView.contentView.height_mn > self.scrollView.height_mn) {
            self.scrollView.contentView.top_mn = 0.f;
            self.scrollView.contentOffset = CGPointMake(0.f, (self.scrollView.contentView.height_mn - self.scrollView.height_mn)/2.f);
        }
        
        if (model.type == MNAssetTypePhoto || model.type == MNAssetTypeGif) {
            self.imageView.image = image;
        } else if (model.type == MNAssetTypeVideo) {
            self.player.layer = self.playView.layer;
            self.videoSnapshotView.image = model.thumbnail;
            self.durationLabel.text = model.durationString;
        } else {
            if (@available(iOS 9.1, *)) {
                PHLivePhotoView *livePhotoView = (PHLivePhotoView *)self.livePhotoView;
                livePhotoView.backgroundImage = image;
            }
        }
        /// 获取内容
        [MNAssetHelper requestAssetContent:model progress:^(double pro, NSError *error, MNAsset *m) {
            
            __strong typeof(self) self = weakself;
    
            if (error) {
                self.progressView.hidden = YES;
                self.progressView.progress = 0.f;
            } else {
                self.progressView.progress = pro;
                self.progressView.hidden = NO;
            }
        } completion:^(MNAsset *m) {
            __strong typeof(self) self = weakself;
            self.progressView.hidden = YES;
            self.progressView.progress = 0.f;
            if (!m || m != self.asset) return;
            [self displayContentIfNeeded];
        }];
    }];
}

#pragma mark - Getter
- (MNPlayer *)player {
    if (!_player) {
        MNPlayer *player = [MNPlayer new];
        player.delegate = self;
        player.observeTime = CMTimeMake(1, 60);
        _player = player;
    }
    return _player;
}

- (UIImageView *)currentImageView {
    return [UIImageView imageViewWithFrame:self.scrollView.contentView.frame image:self.currentImage];
}

- (UIImage *)currentImage {
    if (self.asset.type == MNAssetTypeVideo || self.asset.type == MNAssetTypeLivePhoto) return self.asset.thumbnail;
    UIImage *image = self.asset.content ? : self.asset.thumbnail;
    return image.images.count ? image.images.firstObject : image;
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
    if (self.player.state == MNPlayerStateFailed || self.player.playURLs.count <= 0) return;
    if (self.player.state == MNPlayerStatePlaying) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

- (void)endDisplaying {
    if (self.asset.type == MNAssetTypeVideo) {
        [_player pause];
    } else if (self.asset.type == MNAssetTypeLivePhoto) {
        if (@available(iOS 9.1, *)) {
            PHLivePhotoView *livePhotoView = (PHLivePhotoView *)self.livePhotoView;
            [livePhotoView stopPlayback];
        }
    }
}

#pragma mark - Method
+ (CGSize)aspectImage:(UIImage *)image inSize:(CGSize)size {
    size.width = floor(size.width);
    size.height = floor(size.height);
    CGFloat width = size.width;
    CGFloat height = image.size.height/image.size.width*width;
    if (isnan(height) || height < 1.f) height = size.height;
    height = floor(height);
    if (height >= size.height) {
        height = size.height - 1.f;
        width = image.size.width/image.size.height*height;
        if (isnan(width) || width < 1.f) width = size.width;
        width = floor(width);
    }
    return CGSizeMake(width, height);
}

@end
