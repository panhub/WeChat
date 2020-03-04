//
//  MNDragView.m
//  MNKit
//
//  Created by Vincent on 2017/12/16.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "MNDragView.h"
#import "UIView+MNLayout.h"
#import "UIGestureRecognizer+MNHelper.h"

const CGFloat MNDragViewMargin = 3.f;

@interface MNDragView() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *contentView;

@end

@implementation MNDragView
- (instancetype)init {
    return [self initWithFrame:CGRectMake(0.f, 0.f, 60.f, 60.f)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self initialized];
        
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFit;
        
        UIImageView *contentView = [UIImageView imageViewWithFrame:self.bounds image:nil];
        contentView.clipsToBounds = YES;
        contentView.userInteractionEnabled = NO;
        contentView.layer.cornerRadius = contentView.height_mn/2.f;
        contentView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:contentView];
        self.contentView = contentView;
        
        [self addGestureRecognizer:UITapGestureRecognizerCreate(self, @selector(handTap), self)];
        [self addGestureRecognizer:UIPanGestureRecognizerCreate(self, @selector(handPan:), self)];
    }
    return self;
}

- (void)initialized {
    _sleepAlpha = .43f;
    _timeoutInterval = 5.f;
    _touchEnabled = YES;
    _scrollEnabled = YES;
}

#pragma mark - 点击处理
- (void)handTap {
    if (self.alpha != 1.f) {
        self.alpha = 1.f;
        if ([self.delegate respondsToSelector:@selector(dragViewDidEndSleeping:)]) {
            [self.delegate dragViewDidEndSleeping:self];
        }
    }
    [self startSleepRequests];
    if ([self.delegate respondsToSelector:@selector(dragViewDidClicking:)]) {
        [self.delegate dragViewDidClicking:self];
    }
}

#pragma mark - 拖拽处理
- (void)handPan:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (self.alpha != 1.f) {
                self.alpha = 1.f;
                if ([self.delegate respondsToSelector:@selector(dragViewDidEndSleeping:)]) {
                    [self.delegate dragViewDidEndSleeping:self];
                }
            }
            [self cancelSleepRequests];
            if ([self.delegate respondsToSelector:@selector(dragViewWillBeginDragging:)]) {
                [self.delegate dragViewWillBeginDragging:self];
            }
        } break;
        case UIGestureRecognizerStateChanged:
        {
            //移动变化
            CGPoint point = [pan translationInView:self];
            //将translation清空，免得重复叠加
            [pan setTranslation:CGPointZero inView:self];
            self.left_mn += point.x;
            self.top_mn += point.y;
            if (self.left_mn < CGRectGetMinX(_bounding) + MNDragViewMargin) {
                self.left_mn = CGRectGetMinX(_bounding) + MNDragViewMargin;
            } else if (self.right_mn > CGRectGetMaxX(_bounding) - MNDragViewMargin){
                self.right_mn = CGRectGetMaxX(_bounding) - MNDragViewMargin;
            }
            if (self.top_mn < CGRectGetMinY(_bounding) + MNDragViewMargin) {
                self.top_mn = CGRectGetMinY(_bounding) + MNDragViewMargin;
            } else if (self.bottom_mn > CGRectGetMaxY(_bounding) - MNDragViewMargin) {
                self.bottom_mn = CGRectGetMaxY(_bounding) - MNDragViewMargin;
            }
            if ([self.delegate respondsToSelector:@selector(dragViewDidDragging:)]) {
                [self.delegate dragViewDidDragging:self];
            }
        } break;
        case UIGestureRecognizerStateEnded:
        {
            CGRect rect = self.frame;
            CGRect frame = rect;
            if (self.centerX_mn >= CGRectGetMinX(_bounding) + MEAN(CGRectGetWidth(_bounding))) {
                frame.origin.x = CGRectGetMaxX(_bounding) - self.width_mn - MNDragViewMargin;
            } else {
                frame.origin.x = CGRectGetMinX(_bounding) + MNDragViewMargin;
            }
            BOOL decelerate = frame.origin.x != rect.origin.x;
            if ([self.delegate respondsToSelector:@selector(dragViewDidEndDragging:willDecelerate:)]) {
                [self.delegate dragViewDidEndDragging:self willDecelerate:decelerate];
            }
            if (decelerate) {
                if ([self.delegate respondsToSelector:@selector(dragViewWillBeginDecelerating:)]) {
                    [self.delegate dragViewWillBeginDecelerating:self];
                }
                self.userInteractionEnabled = NO;
                [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.frame = frame;
                } completion:^(BOOL finished) {
                    self.userInteractionEnabled = YES;
                    [self startSleepRequests];
                    if ([self.delegate respondsToSelector:@selector(dragViewDidEndDecelerating:)]) {
                        [self.delegate dragViewDidEndDecelerating:self];
                    }
                }];
            }
        } break;
        default:
            break;
    }
}

#pragma mark - 取消闲置动画
- (void)cancelSleepRequests {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(startSleep) object:nil];
}

#pragma mark - 开启闲置动画
- (void)startSleepRequests {
    if (_timeoutInterval < 0.f) return;
    [self cancelSleepRequests];
    [self performSelector:@selector(startSleep) withObject:nil afterDelay:_timeoutInterval];
}

#pragma mark - 闲置动画
- (void)startSleep {
    if ([self.delegate respondsToSelector:@selector(dragViewWillBeginSleeping:)]) {
        [self.delegate dragViewWillBeginSleeping:self];
    }
    [self setAlpha:_sleepAlpha animated:YES];
}

#pragma mark - 设置透明度
- (void)setAlpha:(CGFloat)alpha animated:(BOOL)animated {
    [UIView animateWithDuration:(animated ? .3f : 0.f) animations:^{
        self.alpha = alpha;
    }];
}

#pragma mark - Setter
- (void)setBounding:(CGRect)bounding {
    _bounding = bounding;
    self.left_mn = CGRectGetMaxX(bounding) - self.width_mn - MNDragViewMargin;
    self.centerY_mn = CGRectGetHeight(bounding)/2.f + CGRectGetMinY(bounding);
    [self setAlpha:_sleepAlpha animated:NO];
}

- (void)setSleepAlpha:(CGFloat)sleepAlpha {
    sleepAlpha = MIN(MAX(.1f, sleepAlpha), 1.f);
    if (sleepAlpha == _sleepAlpha) return;
    _sleepAlpha = sleepAlpha;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.contentView.highlighted = highlighted;
}

#pragma mark - Super
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) self.bounding = self.superview.bounds;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
        if (!self.isScrollEnabled) return NO;
        if ([self.delegate respondsToSelector:@selector(dragViewShouldBeginDragging:)]) {
            return [self.delegate dragViewShouldBeginDragging:self];
        }
        return YES;
    } else if ([gestureRecognizer isKindOfClass:UITapGestureRecognizer.class]) {
        if (!self.isTouchEnabled) return NO;
        BOOL allows = YES;
        if ([self.delegate respondsToSelector:@selector(dragViewShouldBeginClicking:)]) {
            allows = [self.delegate dragViewShouldBeginClicking:self];
        }
        if (allows && [self.delegate respondsToSelector:@selector(dragViewWillBeginClicking:)]) {
            [self.delegate dragViewWillBeginClicking:self];
        }
        return allows;
    }
    return YES;
}

@end
