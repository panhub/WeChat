//
//  MNWechatDialog.m
//  MNChat
//
//  Created by Vincent on 2019/6/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNWechatDialog.h"

@interface MNWechatDialog ()
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation MNWechatDialog
- (void)createView {
    [super createView];
    
    self.containerView.size_mn = CGSizeMake(37.f, 37.f);
    [self.contentView addSubview:self.containerView];
    
    [self.contentView addSubview:self.textLabel];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.color = UIColor.whiteColor;
    indicatorView.hidesWhenStopped = YES;
    indicatorView.center_mn = self.containerView.layer.position;
    [self.containerView addSubview:indicatorView];
    self.indicatorView = indicatorView;
    
    self.contentView.layer.cornerRadius = 5.f;
    
    [self layoutSubviewIfNeeded];
}

- (void)layoutSubviewIfNeeded {
    // layout textLabel
    self.containerView.top_mn = 28.f;
    NSAttributedString *attributedString = self.attributedString;
    if ([self.textLabel.text isEqualToString:attributedString.string]) return;
    CGSize size = [attributedString sizeOfLimitWidth:MNLoadDialogMaxWidth - 67.f];
    if (size.width <= 0.f) size.height = 0.f;
    CGFloat margin = size.width <= 0.f ? 0.f : 20.f;
    size.width = MAX(size.width, self.containerView.width_mn);
    self.textLabel.size_mn = size;
    self.textLabel.top_mn = self.containerView.bottom_mn + margin;
    self.textLabel.attributedText = attributedString;
    // layout contentView
    CGFloat width = size.width + 67.f;
    CGFloat height = self.textLabel.bottom_mn + 16.f;
    if (size.height < MNLoadDialogFontSize*2.f) width = MIN(MAX(width, height), MNLoadDialogMaxWidth);
    self.contentView.size_mn = CGSizeMake(width, height);
    self.containerView.centerX_mn = self.textLabel.centerX_mn = self.contentView.width_mn/2.f;
    if (self.superview && self.interactionEnabled) {
        self.size_mn = self.contentView.size_mn;
        self.center_mn = self.superview.bounds_center;
    }
    if (!CGRectIsEmpty(self.bounds)) self.contentView.center_mn = self.bounds_center;
}

- (BOOL)updateMessage:(NSString *)message {
    return NO;
}

- (NSString *)message {
    NSString *msg = [super message];
    return msg.length <= 0 ? @"请稍候..." : msg;
}

- (NSDictionary *)attributes {
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 0.f;
    paragraphStyle.paragraphSpacing = 1.f;
    paragraphStyle.lineHeightMultiple = 1.f;
    paragraphStyle.paragraphSpacingBefore = 1.f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    return @{NSFontAttributeName:[UIFont systemFontOfSize:14.f],
                 NSForegroundColorAttributeName:UIColor.whiteColor,
                 NSParagraphStyleAttributeName:paragraphStyle};
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
