//
//  WXVideoPlayTabBar.m
//  MNKit
//
//  Created by Vincent on 2018/3/22.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "WXVideoPlayTabBar.h"
#import "MNSlider.h"

@interface WXVideoPlayTabBar()
@property (nonatomic, strong) MNSlider *slider;
@property (nonatomic, strong) UILabel *currentLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIButton *playButton;
@end

@implementation WXVideoPlayTabBar
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        UIImageView *maskView = [UIImageView imageViewWithFrame:self.bounds image:[MNBundle imageForResource:@"mask_bottom"]];
        maskView.contentMode = UIViewContentModeScaleAspectFill;
        maskView.clipsToBounds = YES;
        maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:maskView];
        
        /**播放暂停*/
        UIButton *playButton = [UIButton buttonWithFrame:CGRectMake(10.f, MEAN(self.height_mn - UITabSafeHeight() - 35.f), 35.f, 35.f)
                                                   image:nil
                                                 title:nil
                                            titleColor:nil
                                                  titleFont:nil];
        playButton.touchInset = UIEdgeInsetWith(-7.f);
        playButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        [playButton setImage:[MNBundle imageForResource:@"video_player_play" inDirectory:@"player"] forState:UIControlStateNormal];
        [playButton setImage:[MNBundle imageForResource:@"video_player_pause" inDirectory:@"player"] forState:UIControlStateSelected];
        [playButton setImage:[MNBundle imageForResource:@"video_player_pause" inDirectory:@"player"] forState:UIControlStateHighlighted];
        playButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        playButton.selected = YES;
        [self addSubview:playButton];
        self.playButton = playButton;
        
        /// 当前时长
        UILabel *currentLabel = [UILabel labelWithFrame:CGRectMake(playButton.right_mn + 7.f, 0.f, 40.f, 13.f) text:@"00:00" textAlignment:NSTextAlignmentRight textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:13.f]];
        currentLabel.centerY_mn = playButton.centerY_mn;
        currentLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:currentLabel];
        self.currentLabel = currentLabel;
        
        /// 总时长
        UILabel *durationLabel = [UILabel labelWithFrame:currentLabel.frame text:@"00:00" textAlignment:NSTextAlignmentLeft textColor:currentLabel.textColor font:currentLabel.font];
        durationLabel.right_mn = self.width_mn - playButton.left_mn;
        durationLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:durationLabel];
        self.durationLabel = durationLabel;
        
        /**进度条*/
        MNSlider *slider = [[MNSlider alloc] initWithFrame:CGRectMake(currentLabel.right_mn + 7.f, 0.f, durationLabel.left_mn - currentLabel.right_mn - 14.f, 18.f)];
        slider.centerY_mn = playButton.centerY_mn;
        slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        slider.borderColor = [UIColor whiteColor];
        slider.thumbColor = [[UIColor whiteColor] colorWithAlphaComponent:.4f];
        [self addSubview:slider];
        self.slider = slider;
    }
    return self;
}

#pragma mark - 播放暂停按钮方法
- (void)playButtonClicked:(UIButton *)button {
    if ([_delegate respondsToSelector:@selector(playTabBarWillChangePlayState:)]) {
        [_delegate playTabBarWillChangePlayState:self];
    }
}

#pragma mark - Setter
- (void)setPlay:(BOOL)play {
    self.playButton.selected = play;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.slider.progress = progress;
}

- (void)setDelegate:(id)delegate {
    _delegate = delegate;
    _slider.delegate = delegate;
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    _timeInterval = timeInterval;
    self.currentLabel.text = [NSDate playTimeStringWithInterval:@(timeInterval)];
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    self.durationLabel.text = [NSDate playTimeStringWithInterval:@(duration)];
}

#pragma mark - Getter
- (BOOL)isPlay {
    return _playButton.selected;
}

@end
