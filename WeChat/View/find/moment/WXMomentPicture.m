//
//  WXMomentPicture.m
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentPicture.h"
#import "WXProfile.h"

@interface WXMomentPicture ()
@property (nonatomic, strong) UIImageView *badgeView;
@end

@implementation WXMomentPicture
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.clipsToBounds = YES;
        self.exclusiveTouch = YES;
        self.userInteractionEnabled = NO;
        self.contentMode = UIViewContentModeScaleAspectFill;
        
        UIImageView *badgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wx_moment_video_preview"]];
        badgeView.contentMode = UIViewContentModeScaleToFill;
        badgeView.hidden = YES;
        badgeView.userInteractionEnabled = NO;
        badgeView.width_mn = 33.f;
        [badgeView sizeFitToWidth];
        [self addSubview:badgeView];
        self.badgeView = badgeView;
    }
    return self;
}

- (void)setPicture:(WXProfile *)picture {
    _picture = picture;
    self.image = picture.image;
    self.badgeView.hidden = picture.type == WXProfileTypeImage;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.badgeView.center_mn = self.bounds_center;
}

@end
