//
//  MNCameraPreview.m
//  MNKit
//
//  Created by Vicent on 2021/3/9.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "MNCameraPreview.h"
#import "MNPlayer.h"
#import "MNPlayView.h"
#import "MNAssetScrollView.h"
#import "UIImage+MNResizing.h"
#import "MNAssetHelper.h"
#import "MNAssetExporter+MNExportMetadata.h"
#import <AssertMacros.h>

@interface MNCameraPreview ()<MNPlayerDelegate, MNPlayViewDelegate>
@property (nonatomic, strong) MNPlayer *player;
@property (nonatomic, strong) MNPlayView *playView;
@property (nonatomic, strong) UIImageView *badgeView;
@property (nonatomic, strong) UIView *livePhotoView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) MNAssetScrollView *scrollView;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@implementation MNCameraPreview
- (instancetype)init {
    return [self initWithFrame:UIScreen.mainScreen.bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColor.clearColor;
        
        MNAssetScrollView *scrollView = [[MNAssetScrollView alloc] initWithFrame:self.bounds];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:scrollView];
        self.scrollView = scrollView;

        MNPlayView *playView = [[MNPlayView alloc] initWithFrame:scrollView.contentView.bounds];
        playView.delegate = self;
        playView.panGestureRecognizer.enabled = NO;
        playView.hidden = YES;
        playView.backgroundColor = UIColor.clearColor;
        playView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [scrollView.contentView addSubview:playView];
        self.playView = playView;
        
#ifdef __IPHONE_9_1
        if (@available(iOS 9.1, *)) {
            PHLivePhotoView *livePhotoView = [[PHLivePhotoView alloc] initWithFrame:scrollView.contentView.bounds];
            livePhotoView.hidden = YES;
            livePhotoView.clipsToBounds = YES;
            livePhotoView.contentMode = UIViewContentModeScaleAspectFit;
            livePhotoView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [scrollView.contentView addSubview:livePhotoView];
            self.livePhotoView = livePhotoView;
        }
#endif
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:scrollView.contentView.bounds image:nil];
        imageView.hidden = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [scrollView.contentView addSubview:imageView];
        self.imageView = imageView;
        
        UIImageView *badgeView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 43.f, 43.f) image:[MNBundle imageForResource:@"record_play"]];
        badgeView.alpha = 0.f;
        badgeView.userInteractionEnabled = NO;
        badgeView.center_mn = self.bounds_center;
        badgeView.highlightedImage = [MNBundle imageForResource:@"record_pause"];
        badgeView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:badgeView];
        self.badgeView = badgeView;
        
        // 交互事件
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tapGestureRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tapGestureRecognizer];
        
        [playView.tapGestureRecognizer requireGestureRecognizerToFail:tapGestureRecognizer];
    }
    return self;
}

#pragma mark - GestureEvent
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

#pragma mark - 展示控制
- (void)play {
    if (self.playView.hidden == NO) {
        if (self.player.state != MNPlayerStateFailed) {
            [self.player play];
        }
    }
}

- (void)pause {
    if (self.playView.hidden == NO) {
        if (self.player.state != MNPlayerStateFailed) {
            [self.player pause];
        }
    } else if (self.livePhotoView && self.livePhotoView.hidden == NO) {
        PHLivePhotoView *livePhotoView = (PHLivePhotoView *)self.livePhotoView;
        [livePhotoView stopPlayback];
    }
}

- (void)stop {
    self.imageView.image = nil;
    if (self.playView.hidden == NO) [_player removeAllURLs];
    if (self.livePhotoView && self.livePhotoView.hidden == NO) {
        [((PHLivePhotoView *)self.livePhotoView) stopPlayback];
        ((PHLivePhotoView *)self.livePhotoView).livePhoto = nil;
    }
    self.badgeView.alpha = 0.f;
    self.imageView.hidden = self.playView.hidden = self.livePhotoView.hidden = YES;
}

#pragma mark - 展示内容
- (void)previewImage:(UIImage *)image {
    self.badgeView.alpha = 0.f;
    self.imageView.hidden = NO;
    self.playView.hidden = self.livePhotoView.hidden = YES;
    [self aspectScrollViewUsingImage:image];
    self.imageView.image = image;
}

- (void)previewVideoOfURL:(NSURL *)videoURL {
    // 先展示预览图
    [self previewImage:[MNAssetExporter exportThumbnailOfVideoAtPath:videoURL.path atSeconds:.3f].resizingOrientation];
    // 准备视频播放
    [self.player removeAllURLs];
    self.player.playURLs = @[videoURL];
    [self.player play];
}

- (void)previewLivePhotoUsingImageData:(NSData *)imageData videoURL:(NSURL *)videoURL {
    if (!self.livePhotoView) {
        [self.superview showInfoDialog:@"无法预览LivePhoto"];
        return;
    }
    NSURL *imageURL = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"MN-LivePhoto/MN-LIVE.JPEG"]];
    [NSFileManager.defaultManager removeItemAtURL:imageURL error:nil];
    if (![NSFileManager.defaultManager createFileAtPath:imageURL.path contents:imageData attributes:nil]) {
        [self.superview showInfoDialog:@"LivePhoto合成失败"];
        return;
    }
    // 先预览瞬时照片
    [self previewImage:[UIImage imageWithContentsOfFile:imageURL.path]];
    // 请求LivePhoto
    __weak typeof(self) weakself = self;
    [MNAssetHelper requestLivePhotoWithResourceFileURLs:@[imageURL, videoURL] completion:^(PHLivePhoto * _Nullable livePhoto, NSError * _Nullable error) {
        if (weakself.alpha == 0.f) return;
        if (error) {
            [weakself.superview showInfoDialog:error.localizedDescription];
            return;
        }
        PHLivePhotoView *livePhotoView = (PHLivePhotoView *)weakself.livePhotoView;
        livePhotoView.livePhoto = livePhoto;
        [livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        livePhotoView.hidden = NO;
        weakself.imageView.hidden = YES;
    }];
}

#pragma mark - 适配大小
- (void)aspectScrollViewUsingImage:(UIImage *)image {
    self.scrollView.zoomScale = 1.f;
    self.scrollView.contentOffset = CGPointZero;
    CGSize size = self.scrollView.size_mn;
    size.width = floor(size.width);
    size.height = floor(size.height);
    CGFloat width = size.width;
    CGFloat height = size.height;
    __Require_noErr_Quiet(CGSizeEqualToSize(size, CGSizeZero), _out);
    height = image.size.height/image.size.width*width;
    if (isnan(height) || height < 1.f) height = size.height;
    height = floor(height);
    if (height >= size.height) {
        height = size.height - 1.f;
        width = image.size.width/image.size.height*height;
        if (isnan(width) || width < 1.f) width = size.width;
        width = floor(width);
    }
_out:
    self.scrollView.contentView.size_mn = CGSizeMake(width, height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width_mn, MAX(self.scrollView.contentView.height_mn, self.scrollView.height_mn));
    self.scrollView.contentView.center_mn = self.scrollView.bounds_center;
    if (self.scrollView.contentView.height_mn > self.scrollView.height_mn) {
        self.scrollView.contentView.top_mn = 0.f;
        self.scrollView.contentOffset = CGPointMake(0.f, (self.scrollView.contentView.height_mn - self.scrollView.height_mn)/2.f);
    }
}

#pragma mark - MNPlayerDelegate
- (void)playerDidEndDecode:(MNPlayer *)player {
    self.playView.hidden = NO;
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakself.imageView.hidden = YES;
    });
}

- (void)playerDidChangeState:(MNPlayer *)player {
    if (player.state == MNPlayerStatePlaying) {
        if (self.badgeView.alpha == 1.f) {
            __weak typeof(self) weakself = self;
            self.badgeView.highlighted = YES;
            [self.badgeView.layer removeAllAnimations];
            self.badgeView.transform = CGAffineTransformIdentity;
            [UIView animateWithDuration:.3f animations:^{
                weakself.badgeView.alpha = 0.f;
                weakself.badgeView.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
            }];
        }
    } else {
        if (self.badgeView.alpha != 1.f) {
            self.badgeView.alpha = 1.f;
            self.badgeView.highlighted = NO;
            [self.badgeView.layer removeAllAnimations];
            self.badgeView.transform = CGAffineTransformIdentity;
        }
    }
}

- (BOOL)playerShouldPlayNextItem:(MNPlayer *)player {
    return YES;
}

- (void)playerDidPlayFailure:(MNPlayer *)player {
    [self.superview showInfoDialog:player.error.localizedDescription];
}

#pragma mark - MNPlayViewDelegate
- (void)playViewDidClicked:(MNPlayView *)playView {
    if (self.player.state <= MNPlayerStateFailed) return;
    if (self.player.isPlaying) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

#pragma mark - Getter
- (MNPlayer *)player {
    if (!_player) {
        MNPlayer *player = MNPlayer.new;
        player.delegate = self;
        player.layer = self.playView.layer;
        _player = player;
    }
    return _player;
}

- (id)contents {
#ifdef __IPHONE_9_1
    if (@available(iOS 9.1, *)) {
        if (self.livePhotoView && self.livePhotoView.hidden == NO) return ((PHLivePhotoView *)self.livePhotoView).livePhoto;
    }
#endif
    if (self.playView.hidden == NO) return self.player.playURLs.firstObject.path;
    if (self.imageView.hidden == NO) return self.imageView.image;
    return nil;
}

@end
#pragma clang diagnostic pop
