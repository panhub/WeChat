//
//  WXArtworkViewController.m
//  MNChat
//
//  Created by Vincent on 2020/2/3.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXArtworkViewController.h"
#import "WXMusicArtworkView.h"
#import "WXSong.h"

#define WXMusicPlayerDarkColor     [UIColor.darkTextColor colorWithAlphaComponent:.8f]
#define WXMusicPlayerWhiteColor    MN_R_G_B(248.f, 248.f, 255.f)
#define WXMusicPlayerNeedleAnimationDuration  .3f
#define WXMusicPlayerNeedleTransform  CGAffineTransformMakeRotation(-M_PI_4/2.f)

@interface WXArtworkViewController ()<MNSegmentSubpageDataSource>
@property (nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic, strong) UILabel *lyricLabel;
@property (nonatomic, strong) UIImageView *discView;
@property (nonatomic, strong) UIImageView *needleView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) WXMusicArtworkView *artworkView;
@end

@implementation WXArtworkViewController
- (void)createView {
    [super createView];
    // 创建视图
    self.contentView.backgroundColor = self.view.backgroundColor = UIColor.clearColor;
    
    UIScrollView *scrollView = [UIScrollView scrollViewWithFrame:self.contentView.bounds delegate:nil];
    scrollView.alwaysBounceVertical = YES;
    scrollView.backgroundColor = UIColor.clearColor;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;
    
    UILabel *lyricLabel = [UILabel labelWithFrame:CGRectMake(20.f, 0.f, scrollView.width_mn - 40.f, 25.f) text:nil alignment:NSTextAlignmentCenter textColor:nil font:UIFontRegular(16.f)];
    lyricLabel.centerX_mn = scrollView.width_mn/2.f;
    lyricLabel.bottom_mn = self.contentMaxY - 6.f;
    lyricLabel.userInteractionEnabled = NO;
    [scrollView addSubview:lyricLabel];
    self.lyricLabel = lyricLabel;
    
    CGFloat wh = MIN(lyricLabel.top_mn - self.contentMinY, scrollView.width_mn) - 57.f;
    
    // 黑色背景
    UIImageView *coverView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, wh, wh) image:[UIImage imageNamed:@"music_player_cover_program"]];
    coverView.centerX_mn = scrollView.width_mn/2.f;
    coverView.bottom_mn = lyricLabel.top_mn - 10.f;
    coverView.layer.cornerRadius = coverView.height_mn/2.f;
    coverView.clipsToBounds = YES;
    coverView.userInteractionEnabled = NO;
    [scrollView addSubview:coverView];

    UIImageView *discView = [UIImageView imageViewWithFrame:coverView.bounds image:[UIImage imageNamed:@"music_player_disc"]];
    discView.userInteractionEnabled = NO;
    [discView.layer addAnimation:[CAAnimation animationWithRotation:M_PI*2.f duration:9.f] forKey:nil];
    [discView.layer pauseAnimation];
    [coverView addSubview:discView];
    self.discView = discView;
    
    wh = 308.f/476.f*discView.width_mn;
    
    // 缩略图
    WXMusicArtworkView *artworkView = [[WXMusicArtworkView alloc] initWithFrame:CGRectMake(0.f, 0.f, wh, wh)];
    artworkView.center_mn = discView.bounds_center;
    artworkView.backgroundColor = UIColor.clearColor;
    artworkView.layer.cornerRadius = artworkView.height_sd/2.f;
    artworkView.clipsToBounds = YES;
    artworkView.userInteractionEnabled = NO;
    artworkView.image = self.song.artwork;
    [discView addSubview:artworkView];
    self.artworkView = artworkView;
    
    // 播放指针
    UIImageView *needleView = [UIImageView imageViewWithFrame:CGRectZero image:[UIImage imageNamed:@"music_player_needle"]];
    needleView.top_mn = self.contentMinY;
    needleView.height_mn = 75.f/476.f*discView.height_mn + coverView.top_mn - needleView.top_mn;
    needleView.size_mn = CGSizeMultiplyToHeight(needleView.image.size, needleView.height_mn);
    needleView.centerX_mn = coverView.centerX_mn;
    [scrollView addSubview:needleView];
    self.needleView = needleView;
    
    // 优化指针
    // 将指针中心点移动中间位置
    CGFloat x = UIScreen.mainScreen.scale <= 2.f ? 28.f/175.f*needleView.width_mn : 48.f/322.f*needleView.width_mn;
    CGFloat y = UIScreen.mainScreen.scale <= 2.f ? 28.f/252.f*needleView.height_mn : 48.f/495.f*needleView.height_mn;
    needleView.left_mn += needleView.bounds_center.x - x;
    // 不改变视觉位置的前提下修改指针锚点, 便于动画
    needleView.layer.anchorsite = CGPointMake(x/needleView.width_mn, y/needleView.height_mn);
    needleView.transform = WXMusicPlayerNeedleTransform;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isAnimating) [self __startArtworkAnimation];
}

- (void)startArtworkAnimation {
    if (self.isAnimating) return;
    self.animating = YES;
    if (self.isAppear) [self __startArtworkAnimation];
}

- (void)__startArtworkAnimation {
    [UIView animateWithDuration:WXMusicPlayerNeedleAnimationDuration animations:^{
        self.needleView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.discView.layer resumeAnimation];
        self.playTimeInterval = self.playTimeInterval;
    }];
}

- (void)stopArtworkAnimation {
    self.animating = NO;
    [self.discView.layer pauseAnimation];
    [UIView animateWithDuration:WXMusicPlayerNeedleAnimationDuration animations:^{
        self.needleView.transform = WXMusicPlayerNeedleTransform;
    }];
}

- (void)setSong:(WXSong *)song {
    if (song == _song) return;
    _song = song;
    self.lyricLabel.text = @"";
    self.artworkView.song = song;
}

- (void)setPlayTimeInterval:(NSTimeInterval)playTimeInterval {
    _playTimeInterval = playTimeInterval;
    if (!self.isAppear || self.song.lyrics.count <= 0) return;
    __block WXLyric *lyric = nil;
    [self.song.lyrics enumerateObjectsUsingBlock:^(WXLyric * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.begin <= playTimeInterval && obj.end >= playTimeInterval) {
            lyric = obj;
            *stop = YES;
        }
    }];
    self.lyricLabel.text = lyric ? lyric.content : @"";
}

#pragma mark - 更新背景
- (void)updateSubviews {
    self.lyricLabel.textColor = WXPreference.preference.playStyle == WXPlayStyleDark ? WXMusicPlayerWhiteColor : WXMusicPlayerDarkColor;
}

#pragma mark - MNSegmentSubpageDataSource
- (UIScrollView *)segmentSubpageScrollView {
    return self.scrollView;
}

@end
