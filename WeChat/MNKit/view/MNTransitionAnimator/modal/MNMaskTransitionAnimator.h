//
//  MNMaskTransitionAnimator.h
//  MNKit
//
//  Created by Vincent on 2018/1/10.
//  Copyright © 2018年 小斯. All rights reserved.
//  Mask缩放转场<原用于音乐播放转场>

#import "MNTransitionAnimator.h"

@interface MNMaskTransitionAnimator : MNTransitionAnimator

@property(nonatomic, assign) CGRect rect;

+ (instancetype)animatorWithMaskRect:(CGRect)rect;

@end
