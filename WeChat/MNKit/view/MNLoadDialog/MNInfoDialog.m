//
//  MNInfoDialog.m
//  MNKit
//
//  Created by Vincent on 2018/7/31.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNInfoDialog.h"

#define kMNInfoDialogMargin  10.f

@implementation MNInfoDialog
- (void)initialized {
    if (self.message.length <= 0) {
        [self setValue:@"~Unknown Error~" forKeyPath:@"message"];
    }
}

- (void)createView {
    [super createView];
    
    NSAttributedString *attributedString = self.attributedString;
    self.textLabel.top_mn = kMNInfoDialogMargin;
    self.textLabel.left_mn = kMNInfoDialogMargin;
    self.textLabel.size_mn = [attributedString sizeOfLimitWidth:MNLoadDialogMaxWidth - kMNInfoDialogMargin*2.f];
    self.textLabel.attributedText = attributedString;
    
    self.contentView.layer.cornerRadius = 4.f;
    self.contentView.frame = UIEdgeInsetsInsetRect(self.textLabel.bounds, UIEdgeInsetWith(-kMNInfoDialogMargin));
    [self.contentView addSubview:self.textLabel];
}

- (void)dismiss {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopAnimation) object:nil];
    [self.layer removeAllAnimations];
    [self removeFromSuperview];
}

- (void)startAnimation {
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:.19f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakself.alpha = 1.f;
        weakself.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (finished) [weakself performSelector:@selector(stopAnimation) withObject:nil afterDelay:1.f];
    }];
}

- (void)stopAnimation {
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:.2f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakself.contentView.alpha = .0f;
        weakself.contentView.transform = CGAffineTransformMakeScale(0.95f, 0.95f);
    } completion:^(BOOL finished) {
        [weakself removeFromSuperview];
    }];
}

- (BOOL)interactionEnabled {
    return YES;
}

- (BOOL)motionEffectEnabled {
    return NO;
}

- (BOOL)updateMessage:(NSString *)message {
    return NO;
}

@end
