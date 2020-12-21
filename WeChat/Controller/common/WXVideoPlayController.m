//
//  WXVideoPlayController.m
//  MNChat
//
//  Created by Vincent on 2019/6/17.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXVideoPlayController.h"
#import "MNPlayView.h"
#import "WXVideoPlayTopBar.h"
#import "WXVideoPlayTabBar.h"

@interface WXVideoPlayController ()<MNPlayerDelegate, WXVideoPlayTopBarDelegate, WXVideoPlayTabBarDelegate>
@property (nonatomic, strong) MNPlayer *player;
@property (nonatomic, strong) MNPlayView *playView;
@property (nonatomic, strong) WXVideoPlayTopBar *topBar;
@property (nonatomic, strong) WXVideoPlayTabBar *tabBar;
@property (nonatomic, strong) NSArray <NSURL *>*items;
@end

@implementation WXVideoPlayController
- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithItems:@[URL]];
}

- (instancetype)initWithItems:(NSArray <NSURL *>*)items {
    if (self = [super init]) {
        self.items = items;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.contentView.frame = self.view.bounds;
    //self.contentView.autoresizingMask = UIViewAutoresizingNone;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    MNPlayView *playView = [[MNPlayView alloc] initWithFrame:self.contentView.bounds];
    playView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:playView];
    self.playView = playView;
    
    WXVideoPlayTopBar *topBar = [[WXVideoPlayTopBar alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, MN_TOP_BAR_HEIGHT)];
    topBar.delegate = self;
    [self.contentView addSubview:topBar];
    self.topBar = topBar;
    
    WXVideoPlayTabBar *tabBar = [[WXVideoPlayTabBar alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, MN_TAB_SAFE_HEIGHT + 70.f)];
    tabBar.delegate = self;
    tabBar.bottom_mn = self.contentView.height_mn;
    [self.contentView addSubview:tabBar];
    self.tabBar = tabBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isFirstAppear) [self.player play];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactiveTransitionEnabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactiveTransitionEnabled = YES;
}

#pragma mark - WXVideoPlayTopBarDelegate
- (void)playTopBarBackButtonClicked:(WXVideoPlayTopBar *)topbar {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [UIDevice rotateInterfaceToOrientation:UIInterfaceOrientationPortrait];
    }
}

#pragma mark - WXVideoPlayTabBarDelegate
- (void)sliderWillBeginDragging:(MNSlider *)slider {
    [self.player pause];
}

- (void)sliderDidDragging:(MNSlider *)slider {
    [self.player seekToProgress:slider.progress completion:^(BOOL finished) {
        if (finished) {
            [self.player play];
        }
    }];
}

- (void)playTabBarWillChangePlayState:(WXVideoPlayTabBar *)tabbar {
    if (self.player.isPlaying) {
        tabbar.play = NO;
        [self.player pause];
    } else {
        tabbar.play = YES;
        [self.player play];
    }
}

#pragma mark - MNPlayerDelegate
- (void)playerDidEndDecode:(MNPlayer *)player {
    self.tabBar.duration = player.duration;
}

- (void)playerDidPlayTimeInterval:(MNPlayer *)player {
    self.tabBar.progress = player.progress;
    self.tabBar.timeInterval = player.currentTimeInterval;
}

- (void)playerDidChangeState:(MNPlayer *)player {
    self.tabBar.play = player.state == MNPlayerStatePlaying;
}

- (void)playerDidPlayFailure:(MNPlayer *)player {
    [self.view showInfoDialog:player.error.localizedDescription];
}

#pragma mark - Getter
- (MNPlayer *)player {
    if (!_player) {
        MNPlayer *player = [[MNPlayer alloc] initWithURLs:self.items];
        player.delegate = self;
        player.layer = self.playView.layer;
        _player = player;
    }
    return _player;
}

#pragma mark - Super
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - 旋转支持
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft;
}

#pragma mark - dealloc
- (void)dealloc {}

@end
