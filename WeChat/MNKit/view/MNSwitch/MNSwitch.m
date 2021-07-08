//
//  MNSwitch.m
//  MNKit
//
//  Created by Vicent on 2020/6/2.
//  Copyright © 2020 Vicent. All rights reserved.
//

#import "MNSwitch.h"
#import "UIView+MNLayout.h"
#import <objc/message.h>

@interface MNSwitch ()
@property (nonatomic) SEL valueChangedSelector;
@property (nonatomic) SEL valueShouldChangeSelector;
@property (nonatomic, unsafe_unretained) id valueChangedTarget;
@property (nonatomic, unsafe_unretained) id valueShouldChangeTarget;
@property (nonatomic) CGSize initialSize;
@property (nonatomic, strong) UIView *thumbView;
@property (nonatomic, getter=isAnimating) BOOL animating;
@end

#define MNSwitchMargin  2.f

@implementation MNSwitch
@synthesize onTintColor = _onTintColor;

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0.f, 0.f, 40.f, 20.f)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.height = MAX(frame.size.height, MNSwitchMargin*2.f + 1.f);
    frame.size.width = MAX(frame.size.width, frame.size.height + MNSwitchMargin*2.f + 1.f);
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = self.height_mn/2.f;
        self.clipsToBounds = YES;
        
        self.initialSize = self.size_mn;

        UIView *thumbView = [[UIView alloc] initWithFrame:CGRectMake(MNSwitchMargin, MNSwitchMargin, self.height_mn - MNSwitchMargin*2.f, self.height_mn - MNSwitchMargin*2.f)];
        thumbView.left_mn = MNSwitchMargin;
        thumbView.backgroundColor = UIColor.whiteColor;
        thumbView.layer.cornerRadius = thumbView.height_mn/2.f;
        thumbView.clipsToBounds = YES;
        [self addSubview:thumbView];
        self.thumbView = thumbView;
        
        self.tintColor = [UIColor colorWithRed:245.f/255.f green:245.f/255.f blue:245.f/255.f alpha:1.f];
    }
    return self;
}

- (void)update {
    [super setBackgroundColor:self.isOn ? self.onTintColor : self.tintColor];
}

- (void)addTarget:(id)target forValueChanged:(SEL)action {
    self.valueChangedTarget = target;
    self.valueChangedSelector = action;
}

- (void)addTarget:(id)target forValueShouldChange:(SEL)action {
    self.valueShouldChangeTarget = target;
    self.valueShouldChangeSelector = action;
}

#pragma mark - Setter
- (void)setOnTintColor:(UIColor *)onTintColor {
    _onTintColor = onTintColor;
    [self update];
}

- (void)setThumbTintColor:(UIColor *)thumbTintColor {
    self.thumbView.backgroundColor = thumbTintColor;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor ? : [UIColor colorWithRed:245.f/255.f green:245.f/255.f blue:245.f/255.f alpha:1.f]];
    [self update];
}

- (void)setFrame:(CGRect)frame {
    if (!CGSizeIsEmpty(self.initialSize)) frame.size = self.initialSize;
    [super setFrame:frame];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {}

- (void)setOn:(BOOL)on {
    [self setOn:on animated:YES];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    [self setOn:on animated:animated touched:NO];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated touched:(BOOL)touched {
    if (self.isAnimating || self.isOn == on) return;
    BOOL isAllowsChangeValue = YES;
    if (touched && self.valueShouldChangeTarget && [self.valueShouldChangeTarget respondsToSelector:self.valueShouldChangeSelector]) {
        isAllowsChangeValue = ((BOOL (*)(void*, SEL, MNSwitch *))objc_msgSend)((__bridge void *)(self.valueShouldChangeTarget), self.valueShouldChangeSelector, self);
    }
    if (!isAllowsChangeValue) return;
    self.animating = YES;
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:animated ? .16f : 0.f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong typeof(self) self = weakself;
        self.thumbView.left_mn = on ? self.width_mn - self.thumbView.width_mn - MNSwitchMargin : MNSwitchMargin;
        [self update];
    } completion:^(BOOL finished) {
        __strong typeof(self) self = weakself;
        self.animating = NO;
        if (touched && self.valueChangedTarget && [self.valueChangedTarget respondsToSelector:self.valueChangedSelector]) {
            ((void (*)(void*, SEL, MNSwitch *))objc_msgSend)((__bridge void *)(self.valueChangedTarget), self.valueChangedSelector, self);
        }
    }];
}

#pragma mark - Getter
- (UIColor *)onTintColor {
    return _onTintColor ? : [UIColor colorWithRed:0.f/255.f green:122.f/255.f blue:254.f/255.f alpha:1.f];
}

- (UIColor *)thumbTintColor {
    return self.thumbView.backgroundColor;
}

- (BOOL)isOn {
    return self.thumbView.left_mn > MNSwitchMargin;
}

#pragma mark - TouchEnded
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self setOn:!self.isOn animated:YES touched:YES];
}

@end
