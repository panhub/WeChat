//
//  WXMusicPlayController.m
//  MNChat
//
//  Created by Vincent on 2020/2/3.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXMusicPlayController.h"
#import "WXArtworkViewController.h"
#import "WXLyricViewController.h"
#import "WXMusicPlayerButton.h"
#import "WXMusicArtworkView.h"
#import "WXSong.h"

#define WXMusicPlayerDarkColor     [UIColor.darkTextColor colorWithAlphaComponent:.8f]
#define WXMusicPlayerWhiteColor    MN_R_G_B(248.f, 248.f, 255.f)
#define WXMusicPlayerNormalColor  MN_R_G_B(145.f, 154.f, 165.f)

@interface WXMusicPlayController ()<MNSegmentControllerDelegate, MNSegmentControllerDataSource, MNSliderDelegate, MNPageControlDelegate, MNPlayerDelegate>
@property (nonatomic, strong) MNSlider *slider;
@property (nonatomic, strong) MNPlayer *player;
@property (nonatomic, strong) UILabel *singerLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic, strong) UIView *darkBlurView;
@property (nonatomic, strong) UIView *lightBlurView;
@property (nonatomic, strong) MNPageControl *pageControl;
@property (nonatomic, strong) WXMusicPlayerButton *playButton;
@property (nonatomic, strong) WXMusicPlayerButton *prevButton;
@property (nonatomic, strong) WXMusicPlayerButton *nextButton;
@property (nonatomic, strong) MNSegmentController *segmentController;
@property (nonatomic, strong) WXLyricViewController *lyricViewController;
@property (nonatomic, strong) WXArtworkViewController *artworkViewController;
@property (nonatomic, strong) WXMusicArtworkView *backgroundView;
@end

@implementation WXMusicPlayController
- (instancetype)initWithSongs:(NSArray <WXSong *>*)songs {
    return [self initWithSongs:songs atIndex:0];
}

- (instancetype)initWithSongs:(NSArray <WXSong *>*)songs atIndex:(NSInteger)playIndex {
    if (self = [super init]) {
        self.songs = songs;
        self.playIndex = playIndex;
        self.title = songs[playIndex].title;
    }
    return self;
}

- (void)initialized {
    [super initialized];
    self.playIndex = 0;
}

- (void)createView {
    [super createView];
    // 创建视图
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowColor = UIColor.clearColor;
    self.navigationBar.backgroundColor = UIColor.clearColor;
    self.navigationBar.titleFont = [UIFont systemFontOfSize:17.f];
    self.contentView.clipsToBounds = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 背景图控制
    WXMusicArtworkView *backgroundView = [[WXMusicArtworkView alloc] initWithFrame:self.contentView.bounds];
    backgroundView.allowsAddEffect = YES;
    backgroundView.image = self.songs[self.playIndex].artwork;
    [self.contentView addSubview:backgroundView];
    self.backgroundView = backgroundView;
    
    // 切换控制
    MNSegmentController *segmentController = [[MNSegmentController alloc] initWithFrame:UIEdgeInsetsInsetRect(self.contentView.bounds, UIEdgeInsetsMake(-30.f, 0.f, 0.f, 0.f))];
    segmentController.delegate = self;
    segmentController.dataSource = self;
    segmentController.view.backgroundColor = UIColor.clearColor;
    [self addChildViewController:segmentController inView:self.contentView];
    self.segmentController = segmentController;
    
    // 播放控制
    UIView *controlView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_sd, 0.f)];
    controlView.backgroundColor = UIColor.clearColor;
    
    MNSlider *slider = [[MNSlider alloc] initWithFrame:CGRectMake(58.f, 8.f, controlView.width_sd - 116.f, 17.f)];
    slider.delegate = self;
    slider.buffer = 1.f;
    slider.trackHeight = 2.2f;
    slider.borderWidth = 0.f;
    slider.touchInset = UIEdgeInsetWith(-10.f);
    slider.borderColor = WXMusicPlayerNormalColor;
    slider.trackColor = WXMusicPlayerNormalColor;
    slider.bufferColor = WXMusicPlayerNormalColor;
    slider.progressColor = THEME_COLOR;
    [controlView addSubview:slider];
    self.slider = slider;
    
    UILabel *durationLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, slider.left_mn - 7.f, 13.f) text:@"00:00" alignment:NSTextAlignmentRight textColor:WXMusicPlayerNormalColor font:[UIFont systemFontOfSize:13.f]];
    durationLabel.centerY_mn = slider.centerY_mn;
    [controlView addSubview:durationLabel];
    self.durationLabel = durationLabel;
    
    UILabel *totalLabel = durationLabel.viewCopy;
    totalLabel.textAlignment = NSTextAlignmentLeft;
    totalLabel.left_mn = controlView.width_mn - durationLabel.right_mn;
    [controlView addSubview:totalLabel];
    self.totalLabel = totalLabel;
    
    WXMusicPlayerButton *playButton = [[WXMusicPlayerButton alloc] init];
    playButton.size_sd = CGSizeMake(62.f, 62.f);
    playButton.centerX_mn = controlView.width_mn/2.f;
    playButton.top_mn = slider.bottom_mn + 35.f;
    playButton.image = [UIImage imageNamed:@"music_player_play"];
    playButton.selectedImage = [UIImage imageNamed:@"music_player_pause"];
    playButton.enabled = NO;
    [playButton addTarget:self action:@selector(playButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:playButton];
    self.playButton = playButton;
    
    WXMusicPlayerButton *prevButton = [[WXMusicPlayerButton alloc] init];
    prevButton.size_sd = CGSizeMake(42.f, 42.f);
    prevButton.centerX_mn = controlView.width_mn/4.f;
    prevButton.centerY_mn = playButton.centerY_mn;
    prevButton.image = [UIImage imageNamed:@"music_player_pre"];
    prevButton.selectedImage = [UIImage imageNamed:@"music_player_pre"];
    prevButton.enabled = NO;
    [prevButton addTarget:self action:@selector(prevButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:prevButton];
    self.prevButton = prevButton;
    
    WXMusicPlayerButton *nextButton = [[WXMusicPlayerButton alloc] init];
    nextButton.size_sd = prevButton.size_sd;
    nextButton.right_mn = controlView.width_mn - prevButton.left_mn;
    nextButton.centerY_mn = prevButton.centerY_mn;
    nextButton.image = [UIImage imageNamed:@"music_player_next"];
    nextButton.selectedImage = [UIImage imageNamed:@"music_player_next"];
    nextButton.enabled = NO;
    [nextButton addTarget:self action:@selector(nextButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:nextButton];
    self.nextButton = nextButton;
    
    controlView.height_mn = playButton.bottom_sd + MAX(35.f, MN_TAB_SAFE_HEIGHT + 10.f);
    controlView.bottom_mn = self.contentView.height_mn;
    [self.contentView addSubview:controlView];
    
    MNPageControl *pageControl = [[MNPageControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 70.f, 25.f)];
    pageControl.delegate = self;
    pageControl.centerX_mn = self.contentView.width_mn/2.f;
    pageControl.bottom_mn = controlView.top_mn;
    pageControl.direction = MNPageControlDirectionHorizontal;
    pageControl.pageSize = CGSizeMake(7.f, 7.f);
    pageControl.numberOfPages = 2;
    pageControl.pageInterval = 15.f;
    pageControl.pageIndicatorTintColor = WXMusicPlayerNormalColor;
    pageControl.currentPageIndicatorTintColor = THEME_COLOR;
    [self.contentView addSubview:pageControl];
    self.pageControl = pageControl;
    
    [self updateSubviews];
}

- (void)loadData {
    NSMutableArray <NSURL *>*URLs = @[].mutableCopy;
    [self.songs enumerateObjectsUsingBlock:^(WXSong * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [URLs addObject:[NSURL fileURLWithPath:obj.filePath]];
    }];
    MNPlayer *player = [[MNPlayer alloc] initWithURLs:URLs];
    player.delegate = self;
    player.observeTime = CMTimeMake(1, 30);
    [self.player replaceCurrentPlayIndexWithIndex:self.playIndex];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstAppear) [self.player play];
}

- (void)prevButtonTouchUpInside:(WXMusicPlayerButton *)button {
    [self.player playPreviousItem];
}

- (void)nextButtonTouchUpInside:(WXMusicPlayerButton *)button {
    [self.player playNextItem];
}

- (void)playButtonTouchUpInside:(WXMusicPlayerButton *)button {
    if (button.isSelected) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

#pragma mark - MNSegmentControllerDelegate && MNSegmentControllerDataSource
- (NSArray <NSString *>*)segmentControllerShouldLoadPageTitles:(MNSegmentController *)segmentController {
    return @[@" ", @" "];
}

- (UIViewController *)segmentController:(MNSegmentController *)segmentController childControllerOfPageIndex:(NSUInteger)pageIndex {
    return pageIndex == 0 ? self.artworkViewController : self.lyricViewController;
}

- (void)segmentControllerInitializedConfiguration:(MNSegmentConfiguration *)configuration {
    configuration.height = 30.f;
    configuration.titleMargin = 30.f;
    configuration.contentMode = MNSegmentContentModeFill;
    configuration.shadowMask = MNSegmentShadowMaskFit;
    configuration.backgroundColor = UIColor.clearColor;
    configuration.titleFont = UIFontSystem(16.f);
    configuration.titleColor = UIColor.clearColor;
    configuration.selectedColor = UIColor.clearColor;
    configuration.shadowColor = UIColor.clearColor;
    configuration.separatorColor = UIColor.clearColor;
}

- (void)segmentControllerProfileViewDidScroll:(MNSegmentController *)segmentController {
    self.navigationBar.rightBarItem.alpha = 1.f - segmentController.contentOffset.x/segmentController.view.width_mn;
}

- (void)segmentController:(MNSegmentController *)segmentController didLeavePageOfIndex:(NSUInteger)fromPageIndex toPageOfIndex:(NSUInteger)toPageIndex {
    self.pageControl.currentPageIndex = toPageIndex;
}

#pragma mark - MNPageControlDelegate
- (void)pageControl:(MNPageControl *)pageControl didSelectPageOfIndex:(NSUInteger)index {
    [self.segmentController scrollPageToIndex:index];
}

#pragma mark - MNSliderDelegate
- (BOOL)sliderShouldBeginDragging:(MNSlider *)slider {
    return (self.player.state != MNPlayerStateUnknown && self.player.state != MNPlayerStateFailed);
}

- (void)sliderWillBeginDragging:(MNSlider *)slider {
    if (slider.isTouching) return;
    slider.user_info = @(self.player.isPlaying);
    [self.player pause];
}

- (void)sliderDidDragging:(MNSlider *)slider {
    [self.player seekToProgress:slider.progress completion:nil];
}

- (void)sliderDidEndDragging:(MNSlider *)slider {
    if (slider.isTouching) return;
    if ([slider.user_info boolValue]) {
        [self.player play];
    }
}

#pragma mark - MNPlayerDelegate
- (void)playerDidPlayTimeInterval:(MNPlayer *)player {
    float progress = player.progress;
    self.slider.progress = progress;
    float playTimeInterval = player.duration*progress;
    self.artworkViewController.playTimeInterval = playTimeInterval;
    _lyricViewController.playTimeInterval = playTimeInterval;
    self.durationLabel.text = [NSDate timeStringWithInterval:@(playTimeInterval)];
}

- (void)playerDidChangeState:(MNPlayer *)player {
    if (player.state == MNPlayerStateUnknown) return;
    if (player.state == MNPlayerStatePlaying) {
        self.playButton.selected = YES;
        [self.artworkViewController startArtworkAnimation];
    } else if (self.slider.isDragging == NO) {
        self.playButton.selected = NO;
        [self.artworkViewController stopArtworkAnimation];
    }
}

- (void)playerDidEndDecode:(MNPlayer *)player {
    self.playButton.enabled = YES;
    self.prevButton.enabled = player.playIndex > 0;
    self.nextButton.enabled = player.playIndex < self.songs.count - 1;
    self.playIndex = player.playIndex;
    WXSong *song = self.songs[player.playIndex];
    self.singerLabel.text = song.artist;
    self.backgroundView.song = song;
    self.navigationBar.titleView.titleLabel.text = song.title;
    self.artworkViewController.song = song;
    _lyricViewController.song = song;
    self.totalLabel.text = [NSDate timeStringWithInterval:@(player.duration)];
}

- (void)playerDidPlayFailure:(MNPlayer *)player {
    self.playButton.enabled = NO;
    [self.view showErrorDialog:player.error.localizedDescription];
}

#pragma mark - 更新背景
- (void)updateSubviews {
    self.navigationBar.titleColor = WXPreference.preference.playStyle == WXPlayStyleDark ? WXMusicPlayerWhiteColor : WXMusicPlayerDarkColor;
    self.singerLabel.textColor = self.navigationBar.titleColor;
    self.darkBlurView.alpha = WXPreference.preference.playStyle == WXPlayStyleDark;
    self.lightBlurView.alpha = WXPreference.preference.playStyle == WXPlayStyleLight;
    self.slider.thumbColor = self.navigationBar.titleColor;
    self.slider.touchColor = self.slider.thumbColor;
    self.playButton.style = WXPreference.preference.playStyle;
    self.prevButton.style = WXPreference.preference.playStyle;
    self.nextButton.style = WXPreference.preference.playStyle;
}

#pragma mark - Getter
//- (MNPlayer *)player {
//    if (!_player) {
//        MNPlayer *player = MNPlayer.new;
//        player.delegate = self;
//        player.observeTime = CMTimeMake(1, 30);
//        _player = player;
//    }
//    return _player;
//}
- (WXArtworkViewController *)artworkViewController {
    if (!_artworkViewController) {
        WXArtworkViewController *vc = [[WXArtworkViewController alloc] initWithFrame:self.segmentController.view.bounds];
        vc.contentMinY = self.navigationBar.bottom_mn - 5.f;
        vc.contentMaxY = self.pageControl.top_mn;
        vc.song = self.songs[self.playIndex];
        _artworkViewController = vc;
    }
    return _artworkViewController;
}

- (WXLyricViewController *)lyricViewController {
    if (!_lyricViewController) {
        WXLyricViewController *vc = [[WXLyricViewController alloc] initWithFrame:self.segmentController.view.bounds];
        vc.contentMinY = self.navigationBar.bottom_mn + self.segmentController.configuration.height;
        vc.contentMaxY = self.pageControl.top_mn + self.segmentController.configuration.height;
        vc.song = self.artworkViewController.song;
        _lyricViewController = vc;
    }
    return _lyricViewController;
}

#pragma mark - Overwrite
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return WXPreference.preference.playStyle == WXPlayStyleDark ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    WXMusicPlayerButton *leftBarItem = [[WXMusicPlayerButton alloc] init];
    leftBarItem.size_mn = CGSizeMake(30.f, 30.f);
    leftBarItem.image = [UIImage imageNamed:@"music_player_back"];
    leftBarItem.tintColor = WXMusicPlayerNormalColor;
    [leftBarItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftBarItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    WXMusicPlayerButton *rightBarItem = [[WXMusicPlayerButton alloc] init];
    rightBarItem.size_mn = CGSizeMake(30.f, 30.f);
    rightBarItem.image = [[UIImage imageNamed:@"music_player_lyric"] templateImage];
    rightBarItem.tintColor = WXMusicPlayerNormalColor;
    [rightBarItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightBarItem;
}

- (void)navigationBarDidCreateBarItem:(MNNavigationBar *)navigationBar {
    navigationBar.titleView.autoresizingMask = UIViewAutoresizingNone;
    navigationBar.titleView.height_mn = 19.f;
    navigationBar.titleView.titleLabel.text = self.songs[self.playIndex].title;
    // 歌手
    UILabel *singerLabel = [UILabel labelWithFrame:CGRectMake(navigationBar.titleView.left_mn, 0.f, navigationBar.titleView.width_mn, 14.f) text:self.songs[self.playIndex].artist alignment:NSTextAlignmentCenter textColor:nil font:UIFontRegular(12.f)];
    //singerLabel.bottom_mn = navigationBar.height_mn - 1.f;
    [navigationBar addSubview:singerLabel];
    self.singerLabel = singerLabel;
    // 约束
    CGFloat margin = 3.f;
    CGFloat y = (navigationBar.height_mn - MN_STATUS_BAR_HEIGHT - navigationBar.titleView.height_mn - singerLabel.height_mn - margin)/2.f + MN_STATUS_BAR_HEIGHT;
    navigationBar.titleView.top_mn = y;
    singerLabel.top_mn = navigationBar.titleView.bottom_mn;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    [self.segmentController scrollPageToIndex:1];
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

@end
