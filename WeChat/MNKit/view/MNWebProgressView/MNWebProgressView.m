//
//  MNWebProgressView.m
//  MNKit
//
//  Created by Vincent on 2018/11/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNWebProgressView.h"

@interface MNWebProgressView ()
@property (nonatomic, weak) UIView *progressView;
@end

@implementation MNWebProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.clipsToBounds = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self initialized];
    [self createView];
    return self;
}

- (void)initialized {
    _progress = 0.f;
    _fadeOutDelay = .1f;
    _fadeAnimationDuration = .25f;
    _progressAnimationDuration = .25f;
}

- (void)createView {
    /**背景图,避免layout时重复赋值*/
    UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:contentView];
    /**进度条*/
    CGRect frame = contentView.bounds;
    frame.size.width = 0.f;
    UIView *progressView = [[UIView alloc] initWithFrame:frame];
    progressView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    progressView.backgroundColor = [UIColor colorWithRed:0.f/255.f green:122.f/255.f blue:254.f/255.f alpha:1.f];
    [contentView addSubview:progressView];
    _progressView = progressView;
}

- (void)layoutSubviews {
    [self setProgress:_progress animated:NO];
}

- (void)setTintColor:(UIColor *)tintColor {
    if (!tintColor) return;
    _progressView.backgroundColor = tintColor;
}

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    progress = MAX(0.f, MIN(progress, 1.f));
    if (progress == _progress) return;
    _progress = progress;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:((progress > 0.f && animated) ? _progressAnimationDuration : 0.f)
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect frame = _progressView.frame;
                             frame.size.width = progress*self.bounds.size.width;
                             _progressView.frame = frame;
                         } completion:nil];
        
        if (progress >= 1.f) {
            if (_progressView.alpha != 0.f) {
                [UIView animateWithDuration:(animated ? _fadeAnimationDuration : 0.f)
                                      delay:_fadeOutDelay
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     _progressView.alpha = 0.f;
                                 } completion:^(BOOL finished) {
                                     CGRect frame = _progressView.frame;
                                     frame.size.width = 0.f;
                                     _progressView.frame = frame;
                                 }];
            }
        } else {
            if (_progressView.alpha != 1.f) {
                [UIView animateWithDuration:(animated ? _fadeAnimationDuration : 0.f)
                                      delay:0.f
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     _progressView.alpha = 1.f;
                                 } completion:nil];
            }
        }
    });
}

@end
