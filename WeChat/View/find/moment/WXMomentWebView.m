//
//  WXMomentWebView.m
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
// 

#import "WXMomentWebView.h"
#import "WXMomentWebpage.h"

@interface WXMomentWebView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *playView;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation WXMomentWebView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialized];
        [self createView];
    }
    return self;
}

#pragma mark - 初始化
- (void)initialized {
    self.clipsToBounds = YES;
    self.backgroundColor = WXMomentCommentViewBackgroundColor;
}

#pragma mark - 初始化子空间
- (void)createView {
    /// 配图
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.userInteractionEnabled = NO;
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:imageView];
    self.imageView = imageView;
    
    /// 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 2;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = UIFontRegular(14.f);
    titleLabel.userInteractionEnabled = NO;
    titleLabel.textColor = [UIColor.darkTextColor colorWithAlphaComponent:.88f];
    [self addSubview:titleLabel];
    self.titleLabel  = titleLabel;
    
    /// 播放
    UIImageView *playView = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_video_preview")];
    playView.userInteractionEnabled = NO;
    playView.contentMode = UIViewContentModeScaleToFill;
    [imageView addSubview:playView];
    self.playView = playView;
}

- (void)setWebpage:(WXMomentWebpage *)webpage {
    _webpage = webpage;
    if (webpage) {
        self.titleLabel.text = webpage.title;
        self.imageView.image = webpage.picture.image;
        self.playView.hidden = !webpage.isVideo;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGRectEqualToRect(self.frame, CGRectZero) || self.titleLabel.width_mn != 0.f) return;
    CGFloat margin = 5.f;
    CGFloat height = self.height_mn - margin*2.f;
    self.imageView.frame = CGRectMake(margin, margin, height, height);
    self.titleLabel.frame = CGRectMake(self.imageView.right_mn + margin, margin, self.width_mn - self.imageView.right_mn - margin*2.f, height);
    self.playView.frame = UIEdgeInsetsInsetRect(self.imageView.bounds, UIEdgeInsetWith(8.f));
}

@end
