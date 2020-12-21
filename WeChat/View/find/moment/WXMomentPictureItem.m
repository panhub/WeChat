//
//  WXMomentPictureItem.m
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentPictureItem.h"
#import "WXMomentPicture.h"

@interface WXMomentPictureItem ()
@property (nonatomic, strong) UIImageView *playView;
@end

#define WXMomentPicturePlayItemSize          43.f

@implementation WXMomentPictureItem
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialized];
        [self createView];
    }
    return self;
}

- (void)initialized {
    self.clipsToBounds = YES;
    self.exclusiveTouch = YES;
    self.userInteractionEnabled = YES;
}

- (void)createView {
    UIImageView *playView = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_video_preview")];
    playView.contentMode = UIViewContentModeScaleToFill;
    playView.hidden = YES;
    playView.userInteractionEnabled = NO;
    [self addSubview:playView];
    self.playView = playView;
}

- (void)setPicture:(WXMomentPicture *)picture {
    _picture = picture;
    UIImage *image = picture.image;
    self.image = image;
    int width = image.size.width;
    int height = image.size.height;
    CGFloat scale = (height/width)/(self.height_mn/self.width_mn);
    if (scale < .99f || isnan(scale)) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.layer.contentsRect = CGRectMake(0.f, 0.f, 1.f, 1.f);
    } else {
        self.contentMode = UIViewContentModeScaleToFill;
        self.layer.contentsRect = CGRectMake(0.f, 0.f, 1.f, (float)width/height);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.playView.left_mn > 0.f || self.playView.top_mn > 0.f) return;
    self.playView.frame = CGRectMake(MEAN(self.width_mn - WXMomentPicturePlayItemSize), MEAN(self.height_mn - WXMomentPicturePlayItemSize), WXMomentPicturePlayItemSize, WXMomentPicturePlayItemSize);
    self.playView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
}

@end
