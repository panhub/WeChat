//
//  WXMomentWebView.m
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
// 

#import "WXMomentWebView.h"
#import "WXWebpage.h"
#import "WXTimeline.h"

@interface WXMomentWebView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation WXMomentWebView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;
        self.backgroundColor = WXMomentCommentViewBackgroundColor;
        
        /// 配图
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
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
    }
    return self;
}

#pragma mark - Setter
- (void)setWebpage:(WXWebpage *)webpage {
    _webpage = webpage;
    if (webpage) {
        self.titleLabel.text = webpage.title;
        self.imageView.image = webpage.image;
    }
}

#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGRectEqualToRect(self.frame, CGRectZero) || self.titleLabel.width_mn != 0.f) return;
    CGFloat margin = 5.f;
    CGFloat height = self.height_mn - margin*2.f;
    self.imageView.frame = CGRectMake(margin, margin, height, height);
    self.titleLabel.frame = CGRectMake(self.imageView.right_mn + margin, margin, self.width_mn - self.imageView.right_mn - margin*2.f, height);
}

@end
