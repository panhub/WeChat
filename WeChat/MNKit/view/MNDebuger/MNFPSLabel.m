//
//  MNFPSLabel.m
//  MNKit
//
//  Created by Vincent on 2019/9/18.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNFPSLabel.h"


#define kMNFPSLabelMargin   3.f
#define kMNFPSLabelSize CGSizeMake(55.f, 20.f)
const CGFloat MNFPSLabelAnimationDuration = .25f;

@interface MNFPSLabel ()<UIGestureRecognizerDelegate>
@property (nonatomic) int fps;
@property (nonatomic) MNFPSLabelState state;
@end

@implementation MNFPSLabel
{
    UIFont *__font;
    UIFont *_subFont;
    NSUInteger _count;
    CADisplayLink *_link;
    NSTimeInterval _lastTime;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0.f;
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 4.f;
        self.userInteractionEnabled = YES;
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:.7f];
        
        __font = [UIFont fontWithName:@"Menlo" size:14.f];
        if (__font) {
            _subFont = [UIFont fontWithName:@"Menlo" size:4.f];
        } else {
            __font = [UIFont fontWithName:@"Courier" size:14.f];
            _subFont = [UIFont fontWithName:@"Courier" size:4.f];
        }
        
        self.fps = 60;
        
        _link = [CADisplayLink displayLinkWithTarget:[MNWeakProxy proxyWithTarget:self] selector:@selector(tick:)];
        [_link setPaused:YES];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handPan:)];
        pan.delegate = self;
        pan.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:pan];
    }
    return self;
}

#pragma mark - Event
- (void)show {
    if (self.alpha == 1.f) return;
    [UIView animateWithDuration:MNFPSLabelAnimationDuration animations:^{
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [_link setPaused:NO];
    }];
}

- (void)dismiss {
    if (self.alpha == 0.f) return;
    [_link setPaused:YES];
    [UIView animateWithDuration:MNFPSLabelAnimationDuration animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        _count = 0;
        _lastTime = 0;
        self.fps = 60;
    }];
}

#pragma mark - Update
- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    float fps = _count/delta;
    _count = 0;
    self.fps = round(fps);
}

#pragma mark - Setter
- (void)setFps:(int)fps {
    if (fps == _fps) return;
    _fps = fps;
    CGFloat progress = fps/60.f;
    UIColor *color = [UIColor colorWithHue:.27f*(progress - .2f) saturation:1.f brightness:.9f alpha:1.f];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d FPS",(int)round(fps)]];
    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, text.length - 3)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(text.length - 3, 3)];
    [text addAttribute:NSFontAttributeName value:__font range:NSMakeRange(0, text.length)];
    [text addAttribute:NSFontAttributeName value:_subFont range:NSMakeRange(text.length - 4, 1)];
    self.attributedText = text;
}

#pragma mark - Super
- (void)setFrame:(CGRect)frame {
    frame.size = kMNFPSLabelSize;
    [super setFrame:frame];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return kMNFPSLabelSize;
}

- (void)setFont:(UIFont *)font {
    [super setFont:__font];
}

- (UIFont *)font {
    return __font;
}

#pragma mark - Gesture Event
- (void)handPan:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.state = MNFPSLabelStateDraging;
        } break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [recognizer translationInView:self];
            [recognizer setTranslation:CGPointZero inView:self];
            self.left_mn += point.x;
            self.top_mn += point.y;
            if (self.left_mn < CGRectGetMinX(self.superview.bounds) + kMNFPSLabelMargin) {
                self.left_mn = CGRectGetMinX(self.superview.bounds) + kMNFPSLabelMargin;
            } else if (self.right_mn > CGRectGetMaxX(self.superview.bounds) - kMNFPSLabelMargin){
                self.right_mn = CGRectGetMaxX(self.superview.bounds) - kMNFPSLabelMargin;
            }
            if (self.top_mn < CGRectGetMinY(self.superview.bounds) + kMNFPSLabelMargin) {
                self.top_mn = CGRectGetMinY(self.superview.bounds) + kMNFPSLabelMargin;
            } else if (self.bottom_mn > CGRectGetMaxY(self.superview.bounds) - kMNFPSLabelMargin) {
                self.bottom_mn = CGRectGetMaxY(self.superview.bounds) - kMNFPSLabelMargin;
            }
        } break;
        case UIGestureRecognizerStateEnded:
        {
            self.state = MNFPSLabelStateAnimating;
            CGRect frame = self.frame;
            if (self.centerX_mn >= CGRectGetMinX(self.superview.bounds) + CGRectGetWidth(self.superview.bounds)/2.f) {
                frame = CGRectMake(CGRectGetMaxX(self.superview.bounds) - self.width_mn - kMNFPSLabelMargin, self.top_mn, self.width_mn, self.height_mn);
            } else {
                frame = CGRectMake(CGRectGetMinX(self.superview.bounds) + kMNFPSLabelMargin, self.top_mn, self.width_mn, self.height_mn);
            }
            [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.frame = frame;
            } completion:^(BOOL finished) {
                self.state = MNFPSLabelStateNormal;
            }];
        } break;
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.state == MNFPSLabelStateNormal;
}

#pragma mark - dealloc
- (void)dealloc {
    if (_link) {
        _link.paused = YES;
        [_link removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
        [_link invalidate];
    }
}

@end
