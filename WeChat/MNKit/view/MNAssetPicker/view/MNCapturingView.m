//
//  MNCapturingView.m
//  MNKit
//
//  Created by Vincent on 2019/6/13.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNCapturingView.h"
#import "UIColor+MNHelper.h"

@interface MNCapturingView () <CAAnimationDelegate>
@property (nonatomic, strong) UIView *touchView;
@property (nonatomic, strong) UIView *trackView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@end

#define MNCapturingViewMinHeight   75.f
#define MNCapturingViewBackButtonTag  10
#define MNCapturingViewDoneButtonTag  20
#define MNCapturingViewCloseButtonTag  30

@implementation MNCapturingView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.options = MNCapturingOptionPhoto;
    
        UIView *trackView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 75.f, 75.f)];
        trackView.center_mn = self.bounds_center;
        trackView.layer.cornerRadius = trackView.width_mn/2.f;
        trackView.clipsToBounds = YES;
        trackView.backgroundColor = MN_R_G_B(225.f, 225.f, 230.f);
        [self addSubview:trackView];
        self.trackView = trackView;
        
        UIView *touchView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 55.f, 55.f)];
        touchView.center_mn = trackView.center_mn;
        touchView.layer.cornerRadius = touchView.width_mn/2.f;
        touchView.clipsToBounds = YES;
        touchView.userInteractionEnabled = NO;
        touchView.backgroundColor = [UIColor whiteColor];
        [self addSubview:touchView];
        self.touchView = touchView;
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(trackView.bounds, UIEdgeInsetWith(2.f)) cornerRadius:trackView.layer.cornerRadius];
        CAShapeLayer *progressLayer = [CAShapeLayer layer];
        progressLayer.path = bezierPath.CGPath;
        progressLayer.strokeColor = UIColorWithRGB(7.f, 192.f, 96.f).CGColor;
        progressLayer.fillColor = [UIColor clearColor].CGColor;
        progressLayer.lineWidth = 4.f;
        progressLayer.strokeEnd = 0.f;
        [trackView.layer addSublayer:progressLayer];
        self.progressLayer = progressLayer;
        
        NSArray <NSString *>*imgs = @[@"video_record_return", @"video_record_done"];
        [imgs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 70.f, 70.f) image:[MNBundle imageForResource:obj] title:nil titleColor:nil titleFont:nil];
            button.center_mn = trackView.center_mn;
            [button setBackgroundImage:[MNBundle imageForResource:obj] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self insertSubview:button belowSubview:trackView];
            if (idx == 0) {
                self.backButton = button;
                self.backButton.tag = MNCapturingViewBackButtonTag;
                [self.backButton setBackgroundImage:[MNBundle imageForResource:@"video_record_returnHL"] forState:UIControlStateHighlighted];
            } else {
                self.doneButton = button;
                self.doneButton.tag = MNCapturingViewDoneButtonTag;
            }
        }];
        
        UIButton *closeButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f) image:[MNBundle imageForResource:@"video_record_close"] title:nil titleColor:nil titleFont:nil];
        closeButton.center_mn = CGPointMake(trackView.left_mn/2.f, trackView.centerY_mn);
        closeButton.tag = MNCapturingViewCloseButtonTag;
        [closeButton setBackgroundImage:[MNBundle imageForResource:@"video_record_close"] forState:UIControlStateHighlighted];
        [closeButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        self.closeButton = closeButton;
    }
    return self;
}

#pragma mark - Super
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (!self.superview) return;
    if ((self.options & MNCapturingOptionPhoto) != 0) {
        [self.trackView addGestureRecognizer:UITapGestureRecognizerCreate(self, @selector(handTap:), nil)];
    }
    if ((self.options & MNCapturingOptionVideo) != 0) {
        [self.trackView addGestureRecognizer:UILongPressGestureRecognizerCreate(self, .3f, @selector(handLongPress:), nil)];
    }
}

#pragma mark - Gesture
- (void)handTap:(UITapGestureRecognizer *)recognizer {
    if (self.state == MNCapturingViewStateNormal && [self.delegate respondsToSelector:@selector(capturingViewShoudCapturingStillImage:)]) {
        [self.delegate capturingViewShoudCapturingStillImage:self];
    }
}

- (void)handLongPress:(UILongPressGestureRecognizer *)recognizer {
    UIGestureRecognizerState state = recognizer.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:
        {
            if (self.state != MNCapturingViewStateNormal) return;
            [self beginCapturing];
        } break;
        case UIGestureRecognizerStateEnded:
        {
            if (self.state != MNCapturingViewStateCapturing) return;
            [self endCapturing];
        } break;
        case UIGestureRecognizerStateChanged:
        {
            
        } break;
        default:
        {
            [UIView animateWithDuration:.3f animations:^{
                self.closeButton.alpha = 1.f;
                self.touchView.transform = CGAffineTransformIdentity;
                self.trackView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.progressLayer.hidden = YES;
                [self.progressLayer removeAllAnimations];
                self.progressLayer.strokeEnd = 0.f;
                self.state = MNCapturingViewStateNormal;
            }];
        } break;
    }
}

#pragma mark - 录制/播放
- (void)beginCapturing {
    self.state = MNCapturingViewStateWaiting;
    [self.progressLayer resetAnimation];
    if ([self.delegate respondsToSelector:@selector(capturingViewShoudBeginCapturing:)]) {
        [self.delegate capturingViewShoudBeginCapturing:self];
    }
}

- (void)endCapturing {
    self.state = MNCapturingViewStateWaiting;
    [self.progressLayer pauseAnimation];
    if ([self.delegate respondsToSelector:@selector(capturingViewDidEndCapturing:)]) {
        [self.delegate capturingViewDidEndCapturing:self];
    }
}

#pragma mark - Event
- (void)buttonClicked:(UIButton *)button {
    switch (button.tag) {
        case MNCapturingViewCloseButtonTag:
        {
            if ([self.delegate respondsToSelector:@selector(capturingViewCloseButtonClicked:)]) {
                [self.delegate capturingViewCloseButtonClicked:self];
            }
        } break;
        case MNCapturingViewBackButtonTag:
        {
            if ([self.delegate respondsToSelector:@selector(capturingViewBackButtonClicked:)]) {
                [self.delegate capturingViewBackButtonClicked:self];
            }
        } break;
        default:
        {
            if ([self.delegate respondsToSelector:@selector(capturingViewDoneButtonClicked:)]) {
                [self.delegate capturingViewDoneButtonClicked:self];
            }
        } break;
    }
}

- (void)startCapturing {
    self.state = MNCapturingViewStateWaiting;
    [UIView animateWithDuration:.3f animations:^{
        self.closeButton.alpha = 0.f;
        self.touchView.transform = CGAffineTransformMakeScale(.7f, .7f);
        self.trackView.transform = CGAffineTransformMakeScale(1.35f, 1.35f);
    } completion:^(BOOL finished) {
        self.progressLayer.hidden = NO;
        if (self.timeoutInterval > 0.f) [self.progressLayer addAnimation:self.strokeAnimation forKey:@""];
        self.state = MNCapturingViewStateCapturing;
    }];
}

- (void)stopCapturing {
    self.state = MNCapturingViewStateWaiting;
    [UIView animateWithDuration:.3f animations:^{
        self.touchView.transform = CGAffineTransformIdentity;
        self.trackView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.progressLayer.hidden = YES;
        [self.progressLayer resetAnimation];
        [self.progressLayer removeAllAnimations];
        self.progressLayer.strokeEnd = 0.f;
        [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.closeButton.alpha = self.trackView.alpha = self.touchView.alpha = 0.f;
            self.backButton.left_mn = self.closeButton.left_mn;
            self.doneButton.right_mn = self.width_mn - self.closeButton.left_mn;
        } completion:^(BOOL finished) {
            self.state = MNCapturingViewStateFinished;
        }];
    }];
}

- (void)resetCapturing {
    self.state = MNCapturingViewStateWaiting;
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.closeButton.alpha = self.touchView.alpha = self.trackView.alpha = 1.f;
        self.backButton.center_mn = self.doneButton.center_mn = self.trackView.center_mn;
    } completion:^(BOOL finished) {
        self.state = MNCapturingViewStateNormal;
    }];
}

#pragma mark - Setter
- (void)setFrame:(CGRect)frame {
    frame.size.height = MAX(MNCapturingViewMinHeight, frame.size.height);
    [super setFrame:frame];
}

#pragma mark - Getter
- (CABasicAnimation *)strokeAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.delegate = self;
    animation.duration = self.timeoutInterval;
    animation.fromValue = @(0.f);
    animation.toValue = @(1.f);
    animation.autoreverses = NO;
    animation.beginTime = CACurrentMediaTime();
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    /**结束后不恢复原状态(此两行一块使用)(保持不变才可以使用暂停和开始)*/
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    return animation;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) [self endCapturing];
}

@end
