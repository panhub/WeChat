//
//  MNWechatLoading.m
//  WeChat
//
//  Created by Vincent on 2019/6/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNWechatLoading.h"

@interface MNWechatLoading ()
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation MNWechatLoading
- (void)createView {
    [super createView];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.color = UIColor.whiteColor;
    indicatorView.hidesWhenStopped = YES;
    
    self.containerView.size_mn = indicatorView.size_mn;
    indicatorView.center_mn = self.containerView.layer.position;
    
    [self.containerView addSubview:indicatorView];
    self.indicatorView = indicatorView;
    
    [self.contentView addSubview:self.containerView];
    
    self.textLabel.numberOfLines = 1;
    self.textLabel.font = [UIFont systemFontOfSize:14.f];
    self.textLabel.textColor = MNLoadDialogContentColor();
    [self.contentView addSubview:self.textLabel];
    
    self.contentView.layer.cornerRadius = 5.f;
    
    [self layoutSubviewIfNeeded];
}

- (void)layoutSubviewIfNeeded {
    
    if ([self.textLabel.text isEqualToString:self.message]) return;
    
    self.textLabel.text = self.message;
    
    CGSize size = [NSString stringSize:self.message font:self.textLabel.font];
    CGFloat h = ceil(self.containerView.height_mn + size.height + (size.height > 0.f ? (MNLoadDialogMargin + 45.f) : 60.f));
    CGFloat w = MAX(MIN(MNLoadDialogMaxWidth, ceil(size.width + 20.f)), h);
    
    self.contentView.size_mn = CGSizeMake(w, h);
    
    self.textLabel.width_mn = self.contentView.width_mn - 20.f;
    self.textLabel.height_mn = size.height;
    self.textLabel.centerX_mn = self.contentView.width_mn/2.f;
    self.textLabel.bottom_mn = self.contentView.height_mn - (size.height > 0.f ? MNLoadDialogMargin : 0.f);
    
    self.containerView.centerX_mn = self.contentView.width_mn/2.f;
    self.containerView.centerY_mn = self.textLabel.top_mn/2.f + (size.height > 0.f ? self.textLabel.font.capHeight/2.f : 0.f);
    
    if (self.superview && self.interactionEnabled) {
        self.size_mn = self.contentView.size_mn;
        self.center_mn = self.superview.layer.position;
    }
    
    if (!CGRectIsEmpty(self.bounds)) self.contentView.center_mn = self.layer.position;
}

- (BOOL)updateMessage:(NSString *)message {
    return YES;
}

- (NSString *)message {
    NSString *msg = [super message];
    return msg.length <= 0 ? @"" : msg;
}

- (void)startAnimation {
    [super startAnimation];
    [self __startAnimation];
}

- (void)__startAnimation {
    [self.indicatorView startAnimating];
}

- (void)dismiss {
    [self.indicatorView stopAnimating];
    [self removeFromSuperview];
}

- (void)didEnterBackgroundNotification {
    [self.indicatorView stopAnimating];
}

- (void)willEnterForegroundNotification {
    [self __startAnimation];
}

- (BOOL)interactionEnabled {
    return NO;
}

- (BOOL)motionEffectEnabled {
    return NO;
}

@end
