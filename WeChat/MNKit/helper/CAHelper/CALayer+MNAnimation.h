//
//  CALayer+MNAnimation.h
//  MNKit
//
//  Created by 冯盼 on 2019/10/6.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (MNAnimation)

@property (nonatomic) CGFloat transformRotation;       ///< key path "tranform.rotation"
@property (nonatomic) CGFloat transformRotationX;    ///< key path "tranform.rotation.x"
@property (nonatomic) CGFloat transformRotationY;    ///< key path "tranform.rotation.y"
@property (nonatomic) CGFloat transformRotationZ;    ///< key path "tranform.rotation.z"
@property (nonatomic) CGFloat transformScale;        ///< key path "tranform.scale"
@property (nonatomic) CGFloat transformScaleX;       ///< key path "tranform.scale.x"
@property (nonatomic) CGFloat transformScaleY;       ///< key path "tranform.scale.y"
@property (nonatomic) CGFloat transformScaleZ;       ///< key path "tranform.scale.z"
@property (nonatomic) CGFloat transformTranslationX; ///< key path "tranform.translation.x"
@property (nonatomic) CGFloat transformTranslationY; ///< key path "tranform.translation.y"
@property (nonatomic) CGFloat transformTranslationZ; ///< key path "tranform.translation.z"

/**
 屏蔽隐式动画<内部显式提交>
 @param actionsWithoutAnimation 回调
 */
+ (void)performWithoutAnimation:(void (^)(void))actionsWithoutAnimation;

/**
 显式提交动画
 @param duration 动画时长
 @param animations 动画数组
 */
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations;

/**
 显式提交动画
 @param duration 动画时长
 @param animations 动画数组
 @param completion 事务结束回调
 */
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(void))completion;

/**
 提交转场动画
 @param type 动画类型
 @param duration 动画时长
 @param animations 动画回掉
*/
- (void)transitionWithDuration:(NSTimeInterval)duration
                          type:(CATransitionType)type
                    animations:(void (^)(CALayer *transitionLayer))animations;

/**
 提交转场动画
 @param type 动画类型
 @param subtype 动画方向
 @param duration 动画时长
 @param animations 动画回掉
 @param completion 结束回调
*/
- (void)transitionWithDuration:(NSTimeInterval)duration
                          type:(CATransitionType)type
                       subtype:(CATransitionSubtype)subtype
                    animations:(void (^)(CALayer *transitionLayer))animations
                    completion:(void (^)(void))completion;

/**
 *暂停/恢复动画
 */
- (void)pauseAnimation;
- (void)resumeAnimation;
- (void)resetAnimation;

@end
