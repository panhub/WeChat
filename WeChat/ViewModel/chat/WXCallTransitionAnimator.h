//
//  WXCallTransitionAnimator.h
//  MNChat
//
//  Created by Vincent on 2020/2/6.
//  Copyright © 2020 Vincent. All rights reserved.
//  音视频聊天转场模型

#import "MNTransitionAnimator.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXCallTransitionAnimator : MNTransitionAnimator

/**是否是拒绝通话*/
@property (nonatomic, getter=isDecline) BOOL decline;

@end

NS_ASSUME_NONNULL_END
