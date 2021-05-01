//
//  CALayer+MNAnimation.m
//  MNKit
//
//  Created by 冯盼 on 2019/10/6.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "CALayer+MNAnimation.h"

@implementation CALayer (MNAnimation)
#pragma mark - Animation Key Value
- (CGFloat)transformRotation {
    NSNumber *v = [self valueForKeyPath:@"transform.rotation"];
    return v.doubleValue;
}

- (void)setTransformRotation:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.rotation"];
}

- (CGFloat)transformRotationX {
    NSNumber *v = [self valueForKeyPath:@"transform.rotation.x"];
    return v.doubleValue;
}

- (void)setTransformRotationX:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.rotation.x"];
}

- (CGFloat)transformRotationY {
    NSNumber *v = [self valueForKeyPath:@"transform.rotation.y"];
    return v.doubleValue;
}

- (void)setTransformRotationY:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.rotation.y"];
}

- (CGFloat)transformRotationZ {
    NSNumber *v = [self valueForKeyPath:@"transform.rotation.z"];
    return v.doubleValue;
}

- (void)setTransformRotationZ:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.rotation.z"];
}

- (CGFloat)transformScale {
    NSNumber *v = [self valueForKeyPath:@"transform.scale"];
    return v.doubleValue;
}

- (void)setTransformScale:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.scale"];
}

- (CGFloat)transformScaleX {
    NSNumber *v = [self valueForKeyPath:@"transform.scale.x"];
    return v.doubleValue;
}

- (void)setTransformScaleX:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.scale.x"];
}

- (CGFloat)transformScaleY {
    NSNumber *v = [self valueForKeyPath:@"transform.scale.y"];
    return v.doubleValue;
}

- (void)setTransformScaleY:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.scale.y"];
}

- (CGFloat)transformScaleZ {
    NSNumber *v = [self valueForKeyPath:@"transform.scale.z"];
    return v.doubleValue;
}

- (void)setTransformScaleZ:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.scale.z"];
}

- (CGFloat)transformTranslationX {
    NSNumber *v = [self valueForKeyPath:@"transform.translation.x"];
    return v.doubleValue;
}

- (void)setTransformTranslationX:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.translation.x"];
}

- (CGFloat)transformTranslationY {
    NSNumber *v = [self valueForKeyPath:@"transform.translation.y"];
    return v.doubleValue;
}

- (void)setTransformTranslationY:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.translation.y"];
}

- (CGFloat)transformTranslationZ {
    NSNumber *v = [self valueForKeyPath:@"transform.translation.z"];
    return v.doubleValue;
}

- (void)setTransformTranslationZ:(CGFloat)v {
    [self setValue:@(v) forKeyPath:@"transform.translation.z"];
}


#pragma mark - Animation
+ (void)performWithoutAnimation:(void (^)(void))actionsWithoutAnimation {
    [self animateWithDuration:0.f animations:actionsWithoutAnimation completion:nil];
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations {
    [self animateWithDuration:duration animations:animations completion:nil];
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(void))completion {
    [CATransaction begin];
    [CATransaction setDisableActions:(duration <= 0.f)];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setCompletionBlock:completion];
    if (animations) animations();
    [CATransaction commit];
}

- (void)transitionWithDuration:(NSTimeInterval)duration type:(CATransitionType)typ animations:(void (^)(CALayer *transitionLayer))animations {
    [self transitionWithDuration:duration type:typ subtype:nil animations:animations completion:nil];
}

- (void)transitionWithDuration:(NSTimeInterval)duration type:(CATransitionType)type subtype:(CATransitionSubtype)subtype animations:(void (^)(CALayer *transitionLayer))animations completion:(void (^)(void))completion {
    CATransition *transition = [CATransition new];
    if (type) transition.type = type;
    if (subtype) transition.subtype = subtype;
    transition.duration = duration;
    transition.autoreverses = NO;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.removedOnCompletion = NO;
    transition.fillMode = kCAFillModeForwards;
    if (animations) animations(self);
    [self addAnimation:transition forKey:type];
    if (!completion) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) completion();
    });
}

#pragma mark - pause&resume&reset
- (void)pauseAnimation {
    if (self.speed == 0.f) return;
    CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    self.speed = 0.f;
    self.timeOffset = pausedTime;
}

- (void)resumeAnimation {
    if (self.speed == 1.f) return;
    CFTimeInterval pausedTime = [self timeOffset];
    self.speed = 1.f;
    self.timeOffset = 0.f;
    self.beginTime = 0.f;
    CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.beginTime = timeSincePause;
}

- (void)resetAnimation {
    self.speed = 1.f;
    self.timeOffset = 0.f;
    self.beginTime = 0.f;
}

@end
