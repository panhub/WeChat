//
//  CAAnimation+MNHelper.m
//  MNKit
//
//  Created by 冯盼 on 2019/10/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "CAAnimation+MNHelper.h"

/* 形变*/
CAKeyPath const kCATransform = @"transform";

/* 旋转x,y,z分别是绕x,y,z轴旋转 */
CAKeyPath const kCARotation = @"transform.rotation";
CAKeyPath const kCARotationX = @"transform.rotation.x";
CAKeyPath const kCARotationY = @"transform.rotation.y";
CAKeyPath const kCARotationZ = @"transform.rotation.z";

/* 缩放x,y,z分别是对x,y,z方向进行缩放 */
CAKeyPath const kCAScale = @"transform.scale";
CAKeyPath const kCAScaleX = @"transform.scale.x";
CAKeyPath const kCAScaleY = @"transform.scale.y";
CAKeyPath const kCAScaleZ = @"transform.scale.z";

/* 平移x,y,z同上 */
CAKeyPath const kCATranslation = @"transform.translation";
CAKeyPath const kCATranslationX = @"transform.translation.x";
CAKeyPath const kCATranslationY = @"transform.translation.y";
CAKeyPath const kCATranslationZ = @"transform.translation.z";

/* 平面 */
/* CGPoint中心点改变位置，针对平面 */
CAKeyPath const kCAPosition = @"position";
CAKeyPath const kCAPositionX = @"position.x";
CAKeyPath const kCAPositionY = @"position.y";

/* CGRect */
CAKeyPath const kCABounds = @"bounds";
CAKeyPath const kCABoundsSize = @"bounds.size";
CAKeyPath const kCABoundsSizeWidth = @"bounds.size.width";
CAKeyPath const kCABoundsSizeHeight = @"bounds.size.height";
CAKeyPath const kCABoundsOriginX = @"bounds.origin.x";
CAKeyPath const kCABoundsOriginY = @"bounds.origin.y";

/* 透明度 */
CAKeyPath const kCAOpacity = @"opacity";
/* 内容 */
CAKeyPath const kCAContents = @"contents";
/* 开始路径 */
CAKeyPath const kCAStrokeStart = @"strokeStart";
/* 结束路径 */
CAKeyPath const kCAStrokeEnd = @"strokeEnd";
/* 背景色 */
CAKeyPath const kCABackgroundColor = @"backgroundColor";
/* 圆角 */
CAKeyPath const kCACornerRadius = @"cornerRadius";
/* 边框 */
CAKeyPath const kCABorderWidth = @"borderWidth";
/* 阴影颜色 */
CAKeyPath const kCAShadowColor = @"shadowColor";
/* 偏移量CGSize */
CAKeyPath const kCAShadowOffset = @"shadowOffset";
/* 阴影透明度 */
CAKeyPath const kCAShadowOpacity = @"shadowOpacity";
/* 阴影圆角 */
CAKeyPath const kCAShadowRadius = @"shadowRadius";

@implementation CAAnimation (MNHelper)
+ (CABasicAnimation *)basicAnimationWithKeyPath:(NSString *)keyPath
                                       duration:(CFTimeInterval)duration
                                      fromValue:(id)fromValue
                                        toValue:(id)toValue
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.duration = duration;
    if (fromValue) animation.fromValue = fromValue;
    if (toValue) animation.toValue = toValue;
    animation.autoreverses = NO;
    animation.beginTime = 0.f;//CACurrentMediaTime();
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    /**结束后不恢复原状态(此两行一块使用)(保持不变才可以使用暂停和开始)*/
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    /**结束后不恢复原状态(此两行一块使用)(保持不变才可以使用暂停和开始)*/
    return animation;
}

+ (CABasicAnimation *)animationWithRotation:(CGFloat)rotation duration:(CFTimeInterval)duration {
    CABasicAnimation *animation = [self basicAnimationWithKeyPath:kCARotationZ
                                                         duration:duration
                                                        fromValue:nil
                                                          toValue:@(rotation)];
    animation.repeatCount = FLT_MAX;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    return animation;
}

+ (CABasicAnimation *)animationWithContents:(id)contents duration:(CFTimeInterval)duration {
    CABasicAnimation *animation = [self basicAnimationWithKeyPath:kCAContents
                                                         duration:duration
                                                        fromValue:nil
                                                          toValue:contents];
    return animation;
}

+ (CAKeyframeAnimation *)keyframeAnimationWithKeyPath:(NSString *)keyPath
                                             duration:(CFTimeInterval)duration
                                               values:(NSArray *)values
                                             keyTimes:(NSArray <NSNumber *>*)keyTimes
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    animation.autoreverses = NO;
    animation.beginTime = 0.f;//CACurrentMediaTime();
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = duration;
    if (values.count) animation.values = values.copy;
    if (keyTimes.count) animation.keyTimes = keyTimes.copy;
    return animation;
}

@end
