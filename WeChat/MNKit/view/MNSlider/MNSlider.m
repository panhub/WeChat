//
//  MNSlider.m
//  MMC_SchoolShip
//
//  Created by Vincent on 2018/8/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNSlider.h"
#import "UIView+MNLayout.h"
#import "UIGestureRecognizer+MNHelper.h"

@interface MNSlider () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *touchView;
@property (nonatomic, strong) UIView *thumbView;
@property (nonatomic, strong) UIView *trackView;
@property (nonatomic, strong) UIView *bufferView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, getter=isDragging) BOOL dragging;
@property (nonatomic, getter=isTouching) BOOL touching;
@end

#define MNSliderTrackNormalHeight  4.f
@implementation MNSlider
- (instancetype)initWithFrame:(CGRect)frame {
    if (frame.size.height < MNSliderTrackNormalHeight) {
        NSLog(@"slider height less than 4.f");
        return nil;
    }
    if (frame.size.width <= frame.size.height) {
        NSLog(@"slider width less than slider height");
        return nil;
    }
    if (self = [super initWithFrame:frame]) {
        [self initialized];
        [self createView];
    }
    return self;
}

- (void)initialized {
    _buffer = 0.f;
    _progress = 0.f;
    _selected = NO;
}

- (void)createView {
    /**背景(避免修改子视图位置时触发layoutSubviews)*/
    UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:contentView];
    _contentView = contentView;
    
    /**轨迹*/
    UIView *trackView = [[UIView alloc] initWithFrame:CGRectMake(contentView.height_mn/2.f, (contentView.height_mn - MNSliderTrackNormalHeight)/2.f, contentView.width_mn - contentView.height_mn, MNSliderTrackNormalHeight)];
    trackView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    trackView.layer.cornerRadius = trackView.height_mn/2.f;
    trackView.layer.borderColor = [[UIColor darkTextColor] CGColor];
    trackView.layer.borderWidth = .8f;
    [contentView addSubview:trackView];
    _trackView = trackView;
    
    /**缓冲条*/
    UIView *bufferView = [[UIView alloc] initWithFrame:trackView.bounds];
    bufferView.backgroundColor = [UIColor darkTextColor];
    bufferView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [trackView addSubview:bufferView];
    _bufferView = bufferView;
    
    /**进度条 要遮盖轨迹,才能挡住边框*/
    UIView *progressView = [[UIView alloc] initWithFrame:trackView.frame];
    progressView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    progressView.backgroundColor = [UIColor whiteColor];
    progressView.layer.cornerRadius = progressView.height_mn/2.f;
    [contentView addSubview:progressView];
    _progressView = progressView;
    
    /**滑块*/
    UIView *thumbView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, contentView.height_mn, contentView.height_mn)];
    thumbView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    thumbView.touchInset = UIEdgeInsetsMake(-5.f, -5.f, -5.f, -5.f);
    thumbView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    thumbView.layer.cornerRadius = thumbView.width_mn/2.f;
    thumbView.layer.masksToBounds = NO;
    thumbView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.3f].CGColor;
    thumbView.layer.shadowOffset = CGSizeMake(1.f, 1.f);
    thumbView.layer.shadowOpacity = .3f;
    thumbView.layer.shadowRadius = 1.f;
    UIPanGestureRecognizer *pan = UIPanGestureRecognizerCreate(self, @selector(handPan:), nil);
    pan.delegate = self;
    [thumbView addGestureRecognizer:pan];
    [contentView addSubview:thumbView];
    _thumbView = thumbView;
    
    /**滑块上的小圆点*/
    CGFloat margin = thumbView.height_mn/4.f;
    UIView *touchView = [[UIView alloc] initWithFrame:UIEdgeInsetsInsetRect(thumbView.bounds, UIEdgeInsetsMake(margin, margin, margin, margin))];
    touchView.layer.cornerRadius = touchView.height_mn/2.f;
    touchView.backgroundColor = [UIColor whiteColor];
    [thumbView addSubview:touchView];
    _touchView = touchView;
    
    UITapGestureRecognizer *tap = UITapGestureRecognizerCreate(self, @selector(handTap:), nil);
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    [tap requireGestureRecognizerToFail:pan];
}

- (void)setFrame:(CGRect)frame {
    if (_trackView) {
        frame.size.height = self.height_mn;
        if (frame.size.width <= frame.size.height) return;
    }
    [super setFrame:frame];
}

#pragma mark - 滑动手势
- (void)handPan:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.dragging = YES;
            if ([_delegate respondsToSelector:@selector(sliderWillBeginDragging:)]) {
                [_delegate sliderWillBeginDragging:self];
            }
        } break;
        case UIGestureRecognizerStateChanged: {
            //移动变化
            UIView *thumb = recognizer.view;
            CGPoint point = [recognizer translationInView:thumb];
            //将translation清空，免得重复叠加
            [recognizer setTranslation:CGPointZero inView:thumb];
            thumb.left_mn += point.x;
            if (thumb.left_mn < 0.f) {
                thumb.left_mn = 0.f;
            } else if (thumb.right_mn > _contentView.width_mn) {
                thumb.right_mn = _contentView.width_mn;
            }
            [self didChangeProgress];
        } break;
        case UIGestureRecognizerStateEnded: {
            [self didChangeProgress];
            if ([_delegate respondsToSelector:@selector(sliderDidEndDragging:)]) {
                [_delegate sliderDidEndDragging:self];
            }
            self.dragging = NO;
        } break;
        default:
        {
            self.dragging = NO;
        } break;
    }
}

#pragma mark - 点击手势
- (void)handTap:(UITapGestureRecognizer *)recognizer {
    self.touching = YES;
    CGPoint point = [recognizer locationInView:recognizer.view];
    if ([_delegate respondsToSelector:@selector(sliderWillBeginDragging:)]) {
        [_delegate sliderWillBeginDragging:self];
    }
    _thumbView.centerX_mn = point.x;
    if (_trackView.left_mn < 0.f) {
        _trackView.left_mn = 0.f;
    } else if (_trackView.right_mn > _contentView.width_mn) {
        _trackView.right_mn = _contentView.width_mn;
    }
    [self didChangeProgress];
    if ([_delegate respondsToSelector:@selector(sliderDidEndDragging:)]) {
        [_delegate sliderDidEndDragging:self];
    }
    self.touching = NO;
}

#pragma mark - 滑块位置变化
- (void)didChangeProgress {
    [self didChangeThumb];
    if ([_delegate respondsToSelector:@selector(sliderDidDragging:)]) {
        [_delegate sliderDidDragging:self];
    }
}

- (void)didChangeThumb {
    _progressView.width_mn = _thumbView.left_mn;
    _progress = _progressView.width_mn/_trackView.width_mn;
}

#pragma mark - set data
- (void)setProgress:(float)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    if (self.selected) return;
    progress = MIN(MAX(0.f, progress), 1.f);
    _progress = progress;
    if (animated) {
        [UIView animateWithDuration:.25f animations:^{
            self.progressView.width_mn = self.trackView.width_mn*progress;
            self.thumbView.right_mn = self.progressView.right_mn + self.thumbView.width_mn/2.f;
        }];
    } else {
        _progressView.width_mn = _trackView.width_mn*progress;
        _thumbView.right_mn = _progressView.right_mn + _thumbView.width_mn/2.f;
    }
}

- (void)setBuffer:(float)buffer {
    [self setBuffer:buffer animated:NO];
}

- (void)setBuffer:(float)buffer animated:(BOOL)animated {
    buffer = MIN(MAX(0.f, buffer), 1.f);
    _buffer = buffer;
    if (animated) {
        [UIView animateWithDuration:.25f animations:^{
            self.bufferView.width_mn = self.trackView.width_mn*buffer;
        }];
    } else {
        _bufferView.width_mn = _trackView.width_mn*buffer;
    }
}

#pragma mark - Buid UI
- (void)setTrackHeight:(CGFloat)trackHeight {
    trackHeight = MIN(MAX(trackHeight, 0.f), _contentView.height_mn);
    if (trackHeight == _trackView.height_mn) return;
    //轨迹
    UIViewAutoresizing autoresizingMask = _trackView.autoresizingMask;
    _trackView.autoresizingMask = UIViewAutoresizingNone;
    _trackView.top_mn = (_contentView.height_mn - trackHeight)/2.f;
    _trackView.height_mn = trackHeight;
    _trackView.autoresizingMask = autoresizingMask;
    //进度条
    autoresizingMask = _progressView.autoresizingMask;
    _progressView.autoresizingMask = UIViewAutoresizingNone;
    _progressView.top_mn = _trackView.top_mn;
    _progressView.height_mn = trackHeight;
    _progressView.autoresizingMask = autoresizingMask;
}

- (CGFloat)trackHeight {
    return _trackView.height_mn;
}

- (void)setTrackColor:(UIColor *)trackColor {
    _trackView.backgroundColor = trackColor;
}

- (UIColor *)trackColor {
    return _trackView.backgroundColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _trackView.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor {
    return [UIColor colorWithCGColor:_trackView.layer.borderColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _trackView.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth {
    return _trackView.layer.borderWidth;
}

- (void)setThumbColor:(UIColor *)thumbColor {
    _thumbView.backgroundColor = thumbColor;
}

- (UIColor *)thumbColor {
    return _thumbView.backgroundColor;
}

- (void)setTouchColor:(UIColor *)touchColor {
    _touchView.backgroundColor = touchColor;
}

- (UIColor *)touchColor {
    return _touchView.backgroundColor;
}

- (void)setThumbImage:(UIImage *)thumbImage {
    _thumbView.layer.contents = (__bridge id)[thumbImage CGImage];
}

- (void)setBufferColor:(UIColor *)bufferColor {
    _bufferView.backgroundColor = bufferColor;
}

- (UIColor *)bufferColor {
    return _bufferView.backgroundColor;
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressView.backgroundColor = progressColor;
}

- (UIColor *)progressColor {
    return _progressView.backgroundColor;
}

- (void)setTintColor:(UIColor *)tintColor {
    if (!tintColor) return;
    _trackView.backgroundColor = tintColor;
}

- (UIColor *)tintColor {
    return _trackView.backgroundColor;
}

- (void)setTouchInset:(UIEdgeInsets)touchInset {
    self.thumbView.touchInset = touchInset;
}

#pragma mark - LayoutSubviews
- (void)layoutSubviews {
    self.progress = _progress;
    self.buffer = _buffer;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([self.delegate respondsToSelector:@selector(sliderShouldBeginDragging:)]) {
        return [self.delegate sliderShouldBeginDragging:self];
    }
    return YES;
}

@end
