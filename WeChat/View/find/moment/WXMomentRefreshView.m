//
//  WXMomentRefreshView.m
//  WeChat
//
//  Created by Vicent on 2021/3/27.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXMomentRefreshView.h"
#import <objc/message.h>
#import <AudioToolbox/AudioToolbox.h>

typedef NS_ENUM(NSInteger, WXMomentRefreshState) {
    WXMomentRefreshStateIdle = 0, // 闲置
    WXMomentRefreshAnimating, // 正在做动画
    WXMomentRefreshPreparing, // 松开开始刷新
    WXMomentRefreshRefreshing // 刷新中
};

#define radians(angle) ((angle)/180.f*M_PI)
#define WXMomentRefreshAnimationDuration    .25f
#define WXMomentRefreshY -120.f
#define WXMomentRefreshMinY -self.frame.size.height
#define WXMomentRefreshMaxY (MN_TOP_BAR_HEIGHT + 20.f)
#define WXMomentRefreshObserveKeyPath   @"contentOffset"
#define WXMomentRefreshObserveOptions   NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew


@interface WXMomentRefreshView ()
@property (nonatomic) SEL action;
@property (nonatomic, unsafe_unretained) id target;
@property (nonatomic) WXMomentRefreshState state;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, unsafe_unretained) UIScrollView *scrollView;
@end

@implementation WXMomentRefreshView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size = CGSizeMake(30.f, 30.f);
    frame.origin.x = 22.f;
    frame.origin.y = -frame.size.height;
    if (self = [super initWithFrame:frame]) {
        
        self.alpha = 0.f;
        self.backgroundColor = UIColor.clearColor;
        
        self.userInteractionEnabled = NO;
        
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        contentView.backgroundColor = UIColor.clearColor;
        contentView.transform = CGAffineTransformIdentity;
        [self addSubview:contentView];
        self.contentView = contentView;
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:self.bounds image:[UIImage imageNamed:@"moment_refresh"]];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [contentView addSubview:imageView];
        self.imageView = imageView;
        
        CABasicAnimation *animation = [CAAnimation animationWithRotation:(M_PI*2.f) duration:1.f];
        [imageView.layer addAnimation:animation forKey:nil];
        [imageView.layer pauseAnimation];
    }
    return self;
}

- (void)setTarget:(id)target forRefreshAction:(SEL)action {
    self.target = target;
    self.action = action;
}

- (void)observeScrollView:(UIScrollView *)scrollView {
    if (self.scrollView) [self.scrollView removeObserver:self forKeyPath:WXMomentRefreshObserveKeyPath];
    self.scrollView = scrollView;
    if (scrollView) [scrollView addObserver:self forKeyPath:WXMomentRefreshObserveKeyPath options:WXMomentRefreshObserveOptions context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    UIScrollView *scrollView = object;
    if (scrollView != self.scrollView) return;
    
    CGFloat offsetY = [change[NSKeyValueChangeNewKey] CGPointValue].y;
    
    if (offsetY >= WXMomentRefreshY) {
        if (self.state == WXMomentRefreshStateIdle) {
            if (self.isHidden && !scrollView.isDragging) {
                self.alpha = 0.f;
                self.hidden = NO;
                self.top_mn = WXMomentRefreshMinY;
            }
        } else if (self.state == WXMomentRefreshPreparing) {
            if (scrollView.isDragging) {
                self.hidden = YES;
                self.state = WXMomentRefreshStateIdle;
            } else {
                [self dismiss];
            }
        }
    } else {
        if (self.state == WXMomentRefreshAnimating || self.state == WXMomentRefreshRefreshing) return;
        if (self.state == WXMomentRefreshStateIdle) {
            if (self.isHidden) {
                self.hidden = NO;
                self.state = WXMomentRefreshPreparing;
            } else {
                AudioServicesPlaySystemSound(1519);
                [self show];
            }
        }
        if (self.state == WXMomentRefreshPreparing) {
            if (scrollView.isDragging) {
                // 旋转
                CGFloat oldOffsetY = [change[NSKeyValueChangeOldKey] CGPointValue].y;
                self.contentView.transform = CGAffineTransformRotate(self.contentView.transform, radians(offsetY - oldOffsetY));
            } else {
                // 开始刷新
                self.state = WXMomentRefreshRefreshing;
                [self.imageView.layer resumeAnimation];
                [self send_msg];
            }
        }
    }
}

- (void)update {
    if (self.scrollView.isDragging) {
        if (self.scrollView.contentOffset.y >= WXMomentRefreshY) {
            self.hidden = YES;
            self.state = WXMomentRefreshStateIdle;
        } else {
            self.state = WXMomentRefreshPreparing;
        }
    } else {
        // 通知刷新数据开始
        self.state = WXMomentRefreshRefreshing;
        [self.imageView.layer resumeAnimation];
        [self send_msg];
    }
}

- (void)send_msg {
    if (self.target && [self.target respondsToSelector:self.action]) {
        ((void (*)(void *, SEL, UIView *))objc_msgSend)((__bridge void *)(self.target), self.action, self);
    }
}

- (void)show {
    __weak typeof(self) weakself = self;
    self.state = WXMomentRefreshAnimating;
    [self.imageView.layer pauseAnimation];
    [UIView animateWithDuration:WXMomentRefreshAnimationDuration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __strong typeof(self) self = weakself;
        self.alpha = 1;
        self.top_mn = WXMomentRefreshMaxY;
    } completion:^(BOOL finished) {
        __strong typeof(self) self = weakself;
        [self update];
    }];
}

- (void)dismiss {
    if (self.state == WXMomentRefreshStateIdle) return;
    __weak typeof(self) weakself = self;
    self.state = WXMomentRefreshAnimating;
    [UIView animateWithDuration:WXMomentRefreshAnimationDuration animations:^{
        __strong typeof(self) self = weakself;
        self.alpha = 0.f;
        self.top_mn = WXMomentRefreshMinY;
    } completion:^(BOOL finished) {
        __strong typeof(self) self = weakself;
        self.state = WXMomentRefreshStateIdle;
    }];
}

- (void)endRefreshing {
    if (self.state == WXMomentRefreshRefreshing) {
        [self dismiss];
    }
}

- (BOOL)isRefreshing {
    return self.state == WXMomentRefreshRefreshing;
}

@end
