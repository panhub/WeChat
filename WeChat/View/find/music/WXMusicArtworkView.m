//
//  WXMusicArtworkView.m
//  MNChat
//
//  Created by Vincent on 2020/2/8.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXMusicArtworkView.h"
#import "WXSong.h"

#define WXMusicPlayBackgroundAnimationKey  @"com.music.background.animation.key"

@interface WXMusicArtworkView ()
/**背景图片*/
@property (nonatomic, strong) UIImageView *backgroundView;
@end

@implementation WXMusicArtworkView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.type = kCATransitionFade;
        self.contentMode = UIViewContentModeScaleToFill;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    image = [self effectImageWithOriginal:image];
    [super setImage:image];
}

- (void)setSong:(WXSong *)song {
    _song = song;
    UIImage *image = [self effectImageWithOriginal:song.artwork];
    @weakify(self);
    [self.layer transitionWithDuration:.27f type:self.type subtype:self.subtype animations:^(CALayer *transitionLayer) {
        transitionLayer.contents = (__bridge id)(image.CGImage);
    } completion:^{
        @strongify(self);
        self.layer.contents = (__bridge id)(image.CGImage);
    }];
}

- (UIImage *)effectImageWithOriginal:(UIImage *)image {
    if (self.allowsAddEffect) {
        image = WXPreference.preference.playStyle == WXMusicPlayStyleLight ? image.extraLightEffect : image.darkEffect;
    }
    return image;
}

@end
