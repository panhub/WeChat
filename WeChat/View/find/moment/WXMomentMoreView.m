//
//  WXMomentMoreView.m
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentMoreView.h"
#import "WXTimeline.h"

@interface WXMomentMoreView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *likeButton;
@end

@implementation WXMomentMoreView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIView *contentView = UIView.new;
        contentView.clipsToBounds = YES;
        contentView.layer.cornerRadius = 6.f;
        contentView.userInteractionEnabled = YES;
        contentView.backgroundColor = UIColorWithRGB(76.f, 81.f, 84.f);
        [self addSubview:contentView];
        self.contentView = contentView;
        
        NSArray <NSString *>*titles = @[@" 赞", @" 评论"];
        NSArray <NSString *>*selecteds = @[@" 取消", @" 评论"];
        NSArray <NSString *>*imgs = @[@"wx_moment_more_like", @"wx_moment_more_comment"];
        CGFloat interval = (WXMomentMoreViewWidth - (titles.count - 1)*.5f)/titles.count;
        [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
            /// 按钮
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = idx;
            button.adjustsImageWhenHighlighted = NO;
            button.frame = CGRectMake((interval + .5f)*idx, 0.f, interval, WXMomentMoreViewHeight);
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitle:selecteds[idx] forState:UIControlStateSelected];
            [button.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
            [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [button setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
            [button setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
            [button setImage:[UIImage imageNamed:imgs[idx]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:imgs[idx]] forState:UIControlStateSelected];
            [button setImage:[UIImage imageNamed:imgs[idx]] forState:UIControlStateHighlighted];
            button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:button];
            if (idx == 0) self.likeButton = button;
            /// 分割线
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(interval + (interval + .5f)*idx, (WXMomentMoreViewHeight - 23.f)/2.f, .5f, 23.f)];
            imageView.hidden = idx > 0;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.image = [UIImage imageNamed:@"wx_moment_moreview_line"];
            [contentView addSubview:imageView];
        }];
    }
    return self;
}

#pragma mark - Button Event
- (void)buttonClicked:(UIButton *)sender {
    [self dismissWithAnimated:YES completion:^(BOOL finished) {
        if (self.eventHandler) self.eventHandler(sender.tag);
    }];
}

#pragma mark - Show Or Hiden
- (void)show {
    [self showAtView:self.targetView];
}

- (void)showAtView:(UIView *)view {
    [self showAtView:view animated:YES];
}

- (void)showAtView:(UIView *)view animated:(BOOL)animated {
    if (!view || self.superview) return;
    self.targetView = view;
    self.contentView.size_mn = CGSizeMake(0.f, WXMomentMoreViewHeight);
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect frame = [view.superview convertRect:view.frame toView:keyWindow];
    self.contentView.right_mn = CGRectGetMinX(frame) - 10.f;
    CGFloat y = CGRectGetMinY(frame) - (WXMomentMoreViewHeight - CGRectGetHeight(frame))/2.f;
    y = MIN(y, self.height_mn - WXMomentMoreViewHeight);
    self.contentView.top_mn = y;
    [keyWindow addSubview:self];
    [UIView animateWithDuration:(animated ? WXMommentMoreViewAnimationDuration : 0.f) delay:0.f usingSpringWithDamping:1.f initialSpringVelocity:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.contentView.width_mn = WXMomentMoreViewWidth;
        self.contentView.left_mn = self.contentView.left_mn - self.contentView.width_mn;
    } completion:nil];
}

- (void)dismiss {
    [self dismissWithAnimated:YES];
}

- (void)dismissWithAnimated:(BOOL)animated {
    [self dismissWithAnimated:animated completion:nil];
}

- (void)dismissWithCompletionHandler:(void (^)(BOOL finished))completion {
    [self dismissWithAnimated:YES completion:completion];
}

- (void)dismissWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (!self.superview) return;
    [UIView animateWithDuration:(animated ? WXMommentMoreViewAnimationDuration : 0.f) delay:0.f usingSpringWithDamping:1.f initialSpringVelocity:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.contentView.left_mn = self.contentView.right_mn;
        self.contentView.width_mn = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (completion) completion(finished);
    }];
}

#pragma mark - Setter
- (void)setFrame:(CGRect)frame {
    frame = [[UIScreen mainScreen] bounds];
    [super setFrame:frame];
}

- (void)setLiked:(BOOL)liked {
    _liked = liked;
    self.likeButton.selected = liked;
    [self.likeButton setTitle:self.likeButton.currentTitle forState:UIControlStateHighlighted|UIControlStateSelected];
}

#pragma mark - Super
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

@end
