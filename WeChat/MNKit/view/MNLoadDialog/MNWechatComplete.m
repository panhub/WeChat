//
//  MNWechatComplete.m
//  WeChat
//
//  Created by Vicent on 2021/3/20.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "MNWechatComplete.h"

@interface MNWechatComplete ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation MNWechatComplete
- (void)createView {
    [super createView];
    
    self.containerView.size_mn = CGSizeMake(60.f, 60.f);
    [self.contentView addSubview:self.containerView];
    
    self.textLabel.numberOfLines = 1;
    self.textLabel.font = [UIFont systemFontOfSize:14.f];
    self.textLabel.textColor = MNLoadDialogContentColor();
    [self.contentView addSubview:self.textLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.containerView.bounds];
    imageView.userInteractionEnabled = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [MNBundle imageForResource:@"wechat_complete"];
    [self.containerView addSubview:imageView];
    self.imageView = imageView;
    
    [self layoutSubviewIfNeeded];
}

- (void)layoutSubviewIfNeeded {
    
    if ([self.textLabel.text isEqualToString:self.message]) return;
    
    self.textLabel.text = self.message;
    
    CGSize size = [NSString stringSize:self.message font:self.textLabel.font];
    CGFloat h = ceil(self.containerView.height_mn + size.height + (size.height > 0.f ? MNLoadDialogMargin*2.f : 30.f));
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
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself dismiss];
    });
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (BOOL)interactionEnabled {
    return NO;
}

- (BOOL)motionEffectEnabled {
    return NO;
}

@end
