//
//  WXPhotoCell.m
//  WeChat
//
//  Created by Vicent on 2021/4/22.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXPhotoCell.h"
#import "WXProfile.h"
#import "MNPlayView.h"
#import "MNAssetScrollView.h"

@interface WXPhotoCell ()<UIScrollViewDelegate, MNPlayerDelegate>
@property (nonatomic, strong) MNPlayer *player;
@property (nonatomic, strong) MNPlayView *playView;
@property (nonatomic, strong) MNAssetScrollView *scrollView;
@end

@implementation WXPhotoCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    
        self.backgroundColor = self.contentView.backgroundColor = UIColor.blackColor;
        
        MNAssetScrollView *scrollView = [[MNAssetScrollView alloc] initWithFrame:self.contentView.bounds];
        scrollView.backgroundColor = UIColor.blackColor;
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:scrollView];
        self.scrollView = scrollView;
        
        MNPlayView *playView = [[MNPlayView alloc] initWithFrame:scrollView.bounds];
        playView.coverView.alpha = 0.f;
        playView.coverView.hidden = NO;
        playView.tapGestureRecognizer.enabled = NO;
        playView.panGestureRecognizer.enabled = NO;
        playView.backgroundColor = UIColor.clearColor;
        playView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [scrollView.contentView addSubview:playView];
        self.playView = playView;
        
        self.imageView.frame = scrollView.contentView.bounds;
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.imageView removeFromSuperview];
        [scrollView.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)didBeginDisplaying {
    if (self.picture.type == WXProfileTypeVideo) {
        [self.player play];
    }
}

- (void)didEndDisplaying {
    if (self.picture.type == WXProfileTypeVideo) {
        [_player removeAllURLs];
        self.playView.coverView.image = nil;
    } else {
        self.imageView.image = nil;
    }
}

- (void)endDisplaying {
    if (self.picture.type == WXProfileTypeVideo) {
        [_player pause];
    }
}

#pragma mark - Setter
- (void)setPicture:(WXProfile *)picture {
    _picture = picture;
    
    self.playView.hidden = picture.type != WXProfileTypeVideo;
    self.imageView.hidden = picture.type != WXProfileTypeImage;
    
    self.scrollView.zoomScale = 1.f;
    self.scrollView.contentOffset = CGPointZero;
    
    self.scrollView.contentView.size_mn = [WXPhotoCell aspectImage:picture.image inSize:self.scrollView.size_mn];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width_mn, MAX(self.scrollView.contentView.height_mn, self.scrollView.height_mn));
    self.scrollView.contentView.center_mn = self.scrollView.bounds_center;
    if (self.scrollView.contentView.height_mn > self.scrollView.height_mn) {
        self.scrollView.contentView.top_mn = 0.f;
        self.scrollView.contentOffset = CGPointMake(0.f, (self.scrollView.contentView.height_mn - self.scrollView.height_mn)/2.f);
    }
    
    if (picture.type == WXProfileTypeImage) {
        self.imageView.image = picture.image;
    } else {
        self.playView.coverView.alpha = 1.f;
        self.player.layer = self.playView.layer;
        self.playView.coverView.image = picture.image;
        [self.player addURL:[NSURL fileURLWithPath:self.picture.content]];
    }
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

#pragma mark - MNPlayerDelegate
- (void)playerDidChangeState:(MNPlayer *)player {
    if (player.state > MNPlayerStateFailed) {
        if (self.playView.coverView.alpha != 0.f) {
            __weak typeof(self) weakself = self;
            [UIView animateWithDuration:.2f animations:^{
                weakself.playView.coverView.alpha = 0.f;
            }];
        }
    } else {
        self.playView.coverView.alpha = 1.f;
    }
}

- (void)playerDidPlayFailure:(MNPlayer *)player {
    [self.contentView showInfoDialog:player.error.localizedDescription];
}

- (BOOL)playerShouldPlayNextItem:(MNPlayer *)player {
    return YES;
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
