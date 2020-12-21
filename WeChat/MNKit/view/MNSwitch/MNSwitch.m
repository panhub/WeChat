//
//  MNSwitch.m
//  SHPhoto
//
//  Created by Vicent on 2020/6/2.
//  Copyright © 2020 Vicent. All rights reserved.
//

#import "MNSwitch.h"
#import "UIView+MNLayout.h"

@interface MNSwitch ()
@property (nonatomic, strong) UIView *thumbView;
@property (nonatomic) CGSize initialSize;
@property (nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic, strong) NSInvocation *valueChangedInvocation;
@property (nonatomic, strong) NSInvocation *valueShouldChangeInvocation;
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
        self.tintColor = [UIColor colorWithRed:245.f/255.f green:245.f/255.f blue:245.f/255.f alpha:1.f];
        
        self.initialSize = self.size_mn;

        UIView *thumbView = [[UIView alloc] initWithFrame:CGRectMake(MNSwitchMargin, MNSwitchMargin, self.height_mn - MNSwitchMargin*2.f, self.height_mn - MNSwitchMargin*2.f)];
        thumbView.left_mn = MNSwitchMargin;
        thumbView.backgroundColor = UIColor.whiteColor;
        thumbView.layer.cornerRadius = thumbView.height_mn/2.f;
        thumbView.clipsToBounds = YES;
        [self addSubview:thumbView];
        self.thumbView = thumbView;
        
        [self updateBackgroundColor];
    }
    return self;
}

- (void)updateBackgroundColor {
    [super setBackgroundColor:self.isOn ? self.onTintColor : self.tintColor];
}

- (void)addTarget:(id)target forValueChanged:(SEL)action {
    if (!target || action == NULL || ![target respondsToSelector:action]) {
        self.valueChangedInvocation = nil;
        return;
    }
    self.valueChangedInvocation = [NSInvocation invocationWithTarget:target selector:action objects:[NSStringFromSelector(action) hasSuffix:@":"] ? self : nil, nil];
}

- (void)addTarget:(id)target forValueShouldChange:(SEL)action {
    if (!target || action == NULL || ![target respondsToSelector:action]) {
        self.valueShouldChangeInvocation = nil;
        return;
    }
    self.valueShouldChangeInvocation = [NSInvocation invocationWithTarget:target selector:action objects:[NSStringFromSelector(action) hasSuffix:@":"] ? self : nil, nil];
}

#pragma mark - Setter
- (void)setOnTintColor:(UIColor *)onTintColor {
    _onTintColor = onTintColor;
    [self updateBackgroundColor];
}

- (void)setThumbTintColor:(UIColor *)thumbTintColor {
    self.thumbView.backgroundColor = thumbTintColor;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor ? : [UIColor colorWithRed:245.f/255.f green:245.f/255.f blue:245.f/255.f alpha:1.f]];
    [self updateBackgroundColor];
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
    if (touched && self.valueShouldChangeInvocation) {
        [self.valueShouldChangeInvocation invoke];
        [self.valueShouldChangeInvocation getReturnValue:&isAllowsChangeValue];
    }
    if (!isAllowsChangeValue) return;
    self.animating = YES;
    [UIView animateWithDuration:animated ? .16f : 0.f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.thumbView.left_mn = on ? self.width_mn - self.thumbView.width_mn - MNSwitchMargin : MNSwitchMargin;
        [self updateBackgroundColor];
    } completion:^(BOOL finished) {
        self.animating = NO;
        if (touched && self.valueChangedInvocation) [self.valueChangedInvocation invoke];
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
