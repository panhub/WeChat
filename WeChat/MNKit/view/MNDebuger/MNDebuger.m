//
//  MNDebuger.m
//  MNKit
//
//  Created by Vincent on 2019/9/18.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNDebuger.h"
#import "MNDebugButton.h"

typedef NS_ENUM(NSInteger, MNDebugerState) {
    MNDebugerStateNormal = 0,
    MNDebugerStateDraging,
    MNDebugerStateAnimating,
    MNDebugerStateShowing
};

@interface MNDebuger ()<UIGestureRecognizerDelegate>
@property (nonatomic) CGRect rect;
@property (nonatomic) MNDebugerState state;
@property (nonatomic, strong) UIView *lockView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) MNLogView *logView;
@property (nonatomic, strong) MNFPSLabel *fpsLabel;
@property (nonatomic, strong) MNStreamView *streamView;
@property (nonatomic, strong) NSMutableArray <MNDebugButton *>*buttons;
@end

#define MNDebugViewDragMargin    3.f
#define MNDebugViewShowMargin   100.f
#define MNDebugViewShowWH        (MN_SCREEN_MIN/4.f*2.8f)

static MNDebuger *_debuger;
@implementation MNDebuger
+ (void)startDebug {
    if ([self isDebuging]) {
        [_debuger.superview bringSubviewToFront:_debuger];
        return;
    }
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    if (!keyWindow) return;
    [MNLoger startLog];
    [keyWindow addSubview:MNDebuger.debuger];
}

+ (void)endDebug {
    if (![self isDebuging]) return;
    [MNLoger endLog];
    MNDebuger *debuger = [MNDebuger debuger];
    [debuger->_logView dismiss];
    [debuger->_fpsLabel dismiss];
    [debuger->_streamView dismiss];
    [debuger.buttons enumerateObjectsUsingBlock:^(MNDebugButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type != MNDebugButtonTypeMain) obj.selected = NO;
    }];
    if (debuger.state == MNDebugerStateShowing) {
        __weak typeof(debuger) weakdebuger = debuger;
        [debuger dismissWithCompletionHandler:^(BOOL finished) {
            [weakdebuger removeFromSuperview];
        }];
    } else {
        [debuger removeFromSuperview];
    }
}

+ (void)setAllowsDebug:(BOOL)allowsDebug {
    if (allowsDebug) {
        [self startDebug];
    } else {
        [self endDebug];
    }
}

+ (instancetype)debuger {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_debuger) {
            _debuger = [[MNDebuger alloc] init];
        }
    });
    return _debuger;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _debuger = [super allocWithZone:zone];
    });
    return _debuger;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _debuger = [super initWithFrame:(CGRect){frame.origin, CGSizeMake(MNDebugButtonWH, MNDebugButtonWH)}];
        if (_debuger) {
            _debuger.clipsToBounds = YES;
            _debuger.layer.cornerRadius = 12.f;
            _debuger.backgroundColor = [UIColor clearColor];
            [_debuger createView];
            [_debuger bindGesture];
        }
    });
    return _debuger;
}

- (void)createView {
    
    UIVisualEffectView *effectView = UIBlurEffectCreate(self.bounds, UIBlurEffectStyleDark);
    effectView.userInteractionEnabled = NO;
    [self addSubview:effectView];
    
    CGFloat margin = 20.f;
    CGFloat max = MNDebugViewShowWH;
    
    MNDebugButton *outputButton = [MNDebugButton buttonWithType:MNDebugButtonTypeLog];
    outputButton.top_mn = margin;
    outputButton.centerX_mn = max/2.f;
    [outputButton addTarget:self action:@selector(debugButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:outputButton];
    [self.buttons addObject:outputButton];
    
    MNDebugButton *cropButton = [MNDebugButton buttonWithType:MNDebugButtonTypeStream];
    cropButton.left_mn = margin;
    cropButton.centerY_mn = max/2.f;
    [cropButton addTarget:self action:@selector(debugButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cropButton];
    [self.buttons addObject:cropButton];
    
    MNDebugButton *fpsButton = [MNDebugButton buttonWithType:MNDebugButtonTypeFPS];
    fpsButton.right_mn = max - margin;
    fpsButton.centerY_mn = max/2.f;
    [fpsButton addTarget:self action:@selector(debugButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:fpsButton];
    [self.buttons addObject:fpsButton];
    
    MNDebugButton *mainButton = [MNDebugButton buttonWithType:MNDebugButtonTypeMain];
    mainButton.bottom_mn = max - margin;
    mainButton.centerX_mn = max/2.f;
    [mainButton addTarget:self action:@selector(debugButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mainButton];
    [self.buttons addObject:mainButton];
}

- (void)bindGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handPan:)];
    pan.delegate = self;
    pan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap:)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    [tap requireGestureRecognizerToFail:pan];
    [self addGestureRecognizer:tap];
}

#pragma mark - Event
- (void)handTap:(UITapGestureRecognizer *)recognizer {
    self.alpha = 1.f;
    [self cancelSleepRequests];
    if (self.state == MNDebugerStateNormal) {
        [self showWithCompletionHandler:nil];
    } else if (self.state == MNDebugerStateShowing) {
        [self dismissWithCompletionHandler:nil];
    }
}

- (void)handPan:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.alpha = 1.f;
            self.state = MNDebugerStateDraging;
            [self cancelSleepRequests];
        } break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [recognizer translationInView:self];
            [recognizer setTranslation:CGPointZero inView:self];
            self.left_mn += point.x;
            self.top_mn += point.y;
            if (self.left_mn < CGRectGetMinX(self.superview.bounds) + MNDebugViewDragMargin) {
                self.left_mn = CGRectGetMinX(self.superview.bounds) + MNDebugViewDragMargin;
            } else if (self.right_mn > CGRectGetMaxX(self.superview.bounds) - MNDebugViewDragMargin){
                self.right_mn = CGRectGetMaxX(self.superview.bounds) - MNDebugViewDragMargin;
            }
            if (self.top_mn < CGRectGetMinY(self.superview.bounds) + MNDebugViewDragMargin) {
                self.top_mn = CGRectGetMinY(self.superview.bounds) + MNDebugViewDragMargin;
            } else if (self.bottom_mn > CGRectGetMaxY(self.superview.bounds) - MNDebugViewDragMargin) {
                self.bottom_mn = CGRectGetMaxY(self.superview.bounds) - MNDebugViewDragMargin;
            }
        } break;
        case UIGestureRecognizerStateEnded:
        {
            self.state = MNDebugerStateAnimating;
            CGRect frame = self.frame;
            if (self.centerX_mn >= CGRectGetMidX(self.superview.bounds)) {
                frame = CGRectMake(CGRectGetMaxX(self.superview.bounds) - self.width_mn - MNDebugViewDragMargin, self.top_mn, self.width_mn, self.height_mn);
            } else {
                frame = CGRectMake(CGRectGetMinX(self.superview.bounds) + MNDebugViewDragMargin, self.top_mn, self.width_mn, self.height_mn);
            }
            self.userInteractionEnabled = NO;
            [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.frame = frame;
            } completion:^(BOOL finished) {
                self.userInteractionEnabled = YES;
                self.state = MNDebugerStateNormal;
                [self startSleepRequests];
            }];
        } break;
        default:
            break;
    }
}

- (void)__handPan:(UIPanGestureRecognizer *)recognizer {}

- (void)debugButtonClicked:(MNDebugButton *)sender {
    [self dismissWithCompletionHandler:^(BOOL finished) {
        switch (sender.type) {
            case MNDebugButtonTypeFPS:
            {
                sender.selected = !sender.selected;
                if (sender.selected) {
                    [self.fpsLabel show];
                } else {
                    [self.fpsLabel dismiss];
                }
            } break;
            case MNDebugButtonTypeLog:
            {
                sender.selected = !sender.selected;
                if (sender.selected) {
                    [self.logView show];
                } else {
                    [self.logView dismiss];
                }
            } break;
            case MNDebugButtonTypeStream:
            {
                sender.selected = !sender.selected;
                if (sender.selected) {
                    [self.streamView show];
                } else {
                    [self.streamView dismiss];
                }
            } break;
            default:
                break;
        }
    }];
}

#pragma mark - Animation
- (void)showWithCompletionHandler:(void (^)(BOOL finished))completion {
    self.rect = self.frame;
    self.state = MNDebugerStateAnimating;
    self.lockView.hidden = NO;
    [self.superview insertSubview:self.lockView belowSubview:self];
    [UIView animateWithDuration:MNDebugAnimationDuration delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = self.showRect;
        self.layer.cornerRadius = 15.f;
        [self.buttons makeObjectsPerformSelector:@selector(show)];
    } completion:^(BOOL finished) {
        self.state = MNDebugerStateShowing;
        if (completion) completion(finished);
    }];
}

- (void)dismissWithCompletionHandler:(void (^)(BOOL finished))completion {
    self.state = MNDebugerStateAnimating;
    [self.buttons makeObjectsPerformSelector:@selector(makeTitleHidden)];
    [UIView animateWithDuration:MNDebugAnimationDuration delay:0.f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = self.rect;
        self.layer.cornerRadius = 12.f;
        [self.buttons makeObjectsPerformSelector:@selector(dismiss)];
    } completion:^(BOOL finished) {
        [self startSleepRequests];
        self.lockView.hidden = YES;
        self.state = MNDebugerStateNormal;
        if (completion) completion(finished);
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:UITapGestureRecognizer.class]) return touch.view == self;
    return self.state == MNDebugerStateNormal;
}

#pragma mark - 更新透明度
- (void)startSleep {
    [self startSleepWithAnimated:YES];
}

#pragma mark - 设置透明度
- (void)startSleepWithAnimated:(BOOL)animated {
    [UIView animateWithDuration:(animated ? .3f : 0.f) animations:^{
        self.alpha = .43f;
    }];
}

#pragma mark - 取消闲置动画
- (void)cancelSleepRequests {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(startSleep) object:nil];
}

#pragma mark - 开启闲置动画
- (void)startSleepRequests {
    [self cancelSleepRequests];
    [self performSelector:@selector(startSleep) withObject:nil afterDelay:5.f];
}

#pragma mark - Super
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        self.centerY_mn = CGRectGetMaxY(self.superview.bounds)/2.f;
        self.right_mn = CGRectGetMaxX(self.superview.bounds) - MNDebugViewDragMargin;
        [self startSleepWithAnimated:NO];
    }
}

#pragma mark - Getter
- (CGRect)showRect {
    CGRect rect = CGRectMake(0.f, 0.f, MNDebugViewShowWH, MNDebugViewShowWH);
    rect.origin.x = (self.superview.width_mn - rect.size.width)/2.f;
    rect.origin.y = self.centerY_mn - rect.size.height/2.f;
    if (rect.origin.y < 100.f) {
        rect.origin.y = 100.f;
    } else if (CGRectGetMaxY(rect) > self.superview.height_mn - 100.f) {
        rect.origin.y = self.superview.height_mn - 100.f - rect.size.height;
    }
    return rect;
}

- (MNFPSLabel *)fpsLabel {
    if (!_fpsLabel) {
        MNFPSLabel *fpsLabel = [MNFPSLabel new];
        fpsLabel.centerX_mn = self.superview.width_mn/2.f;
        fpsLabel.bottom_mn = MN_STATUS_BAR_HEIGHT + MN_NAV_BAR_HEIGHT - 2.f;
        fpsLabel.touchInset = UIEdgeInsetWith(-7.f);
        [self.superview insertSubview:fpsLabel belowSubview:self];
        _fpsLabel = fpsLabel;
    }
    return _fpsLabel;
}

- (MNStreamView *)streamView {
    if (!_streamView) {
        MNStreamView *streamView = [MNStreamView new];
        streamView.centerX_mn = self.superview.width_mn/2.f;
        streamView.bottom_mn = MN_STATUS_BAR_HEIGHT + MN_NAV_BAR_HEIGHT - 2.f;
        streamView.touchInset = UIEdgeInsetWith(-7.f);
        [self.superview insertSubview:streamView belowSubview:_fpsLabel ? _fpsLabel : self];
        _streamView = streamView;
    }
    return _streamView;
}

- (MNLogView *)logView {
    if (!_logView) {
        MNLogView *logView = [MNLogView new];
        if (_streamView) {
            [self.superview insertSubview:logView belowSubview:_streamView];
        } else if (_fpsLabel) {
            [self.superview insertSubview:logView belowSubview:_fpsLabel];
        } else {
            [self.superview insertSubview:logView belowSubview:self];
        }
        _logView = logView;
    }
    return _logView;
}

- (UIView *)lockView {
    if (!_lockView) {
        UIView *lockView = [[UIView alloc] initWithFrame:self.superview.bounds];
        [lockView addGestureRecognizer:UITapGestureRecognizerCreate(self, @selector(handTap:), nil)];
        [lockView addGestureRecognizer:UIPanGestureRecognizerCreate(self, @selector(__handPan:), nil)];
        _lockView = lockView;
    }
    return _lockView;
}

- (NSMutableArray <MNDebugButton *>*)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray arrayWithCapacity:4];
    }
    return _buttons;
}

+ (BOOL)isDebuging {
    if (_debuger) {
        return (_debuger.superview != nil);
    }
    return NO;
}

@end
