//
//  MNNumberLabel.m
//  MNKit
//
//  Created by Vincent on 2018/12/13.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNNumberLabel.h"

@interface MNNumberLabel ()
@property (nonatomic, assign) CGFloat fromValue;
@property (nonatomic, assign) CGFloat toValue;
@property (nonatomic, assign, readwrite) CGFloat currentValue;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval lastReference;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation MNNumberLabel

- (void)runFrom:(CGFloat)fromValue to:(CGFloat)toValue duration:(NSTimeInterval)duration {
    [self runFrom:fromValue to:toValue duration:duration completion:nil];
}

- (void)runFrom:(CGFloat)fromValue to:(CGFloat)toValue duration:(NSTimeInterval)duration completion:(MNNumberLabelCompletionCallback)completion {
    
    [self invalidate];
    
    if (completion) {
        self.completionCallback = nil;
        self.completionCallback = completion;
    }
    
    if (self.format.length <= 0) {
        self.format = @"%.2f";
    }
    
    if (duration <= 0.f || toValue <= fromValue) {
        [self setNumberText:toValue];
        [self runCompletionCallback];
        return;
    }
    
    self.fromValue = fromValue;
    self.toValue = toValue;
    self.duration = duration;
    self.currentValue = fromValue;
    self.lastReference = [NSDate timeIntervalSinceReferenceDate];
    
    [self setNumberText:fromValue];
    
    [self run];
}

- (void)setNumberText:(CGFloat)value {
    if (self.attributedFormatCallback) {
        self.attributedText = self.attributedFormatCallback(value);
    } else if (self.formatCallback) {
        self.text = self.formatCallback(value);
    } else {
        self.text = [NSString stringWithFormat:self.format, value];
    }
}

- (void)runCompletionCallback {
    if (self.completionCallback) {
        self.completionCallback();
        self.completionCallback = nil;
    }
}

- (void)updateValue {
    NSTimeInterval reference = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval interval = reference - self.lastReference;
    CGFloat progress = interval/(self.duration);
    
    if (progress >= 1.f) {
        self.currentValue = self.toValue;
    } else {
        self.currentValue = self.fromValue + (self.toValue - self.fromValue)*progress;
    }
    
    [self setNumberText:self.currentValue];
    
    if (progress >= 1.f) {
        [self invalidate];
        [self runCompletionCallback];
    }
}

- (void)run {
    [self invalidate];
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateValue)];
    displayLink.frameInterval = 2;
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink = displayLink;
}

- (void)invalidate {
    if (self.displayLink) {
        [self.displayLink invalidate];
        [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink = nil;
    }
}

- (void)dealloc {
    [self invalidate];
}

@end
