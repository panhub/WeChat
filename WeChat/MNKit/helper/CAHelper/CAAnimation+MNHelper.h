//
//  CAAnimation+MNHelper.h
//  MNKit
//
//  Created by 冯盼 on 2019/10/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef NSString * CAKeyPath;

/* 形变*/
CA_EXTERN CAKeyPath const kCATransform;

/* 旋转x,y,z分别是绕x,y,z轴旋转 */
CA_EXTERN CAKeyPath const kCARotation;
CA_EXTERN CAKeyPath const kCARotationX;
CA_EXTERN CAKeyPath const kCARotationY;
CA_EXTERN CAKeyPath const kCARotationZ;

/* 缩放x,y,z分别是对x,y,z方向进行缩放 */
CA_EXTERN CAKeyPath const kCAScale;
CA_EXTERN CAKeyPath const kCAScaleX;
CA_EXTERN CAKeyPath const kCAScaleY;
CA_EXTERN CAKeyPath const kCAScaleZ;

/* 平移x,y,z同上 */
CA_EXTERN CAKeyPath const kCATranslation;
CA_EXTERN CAKeyPath const kCATranslationX;
CA_EXTERN CAKeyPath const kCATranslationY;
CA_EXTERN CAKeyPath const kCATranslationZ;

/* 平面 */
/* CGPoint中心点改变位置，针对平面 */
CA_EXTERN CAKeyPath const kCAPosition;
CA_EXTERN CAKeyPath const kCAPositionX;
CA_EXTERN CAKeyPath const kCAPositionY;

/* CGRect */
CA_EXTERN CAKeyPath const kCABounds;
CA_EXTERN CAKeyPath const kCABoundsSize;
CA_EXTERN CAKeyPath const kCABoundsSizeWidth;
CA_EXTERN CAKeyPath const kCABoundsSizeHeight;
CA_EXTERN CAKeyPath const kCABoundsOriginX;
CA_EXTERN CAKeyPath const kCABoundsOriginY;

/* 透明度 */
CA_EXTERN CAKeyPath const kCAOpacity;
/* 内容 */
CA_EXTERN CAKeyPath const kCAContents;
/* 开始路径 */
CA_EXTERN CAKeyPath const kCAStrokeStart;
/* 结束路径 */
CA_EXTERN CAKeyPath const kCAStrokeEnd;
/* 背景色 */
CA_EXTERN CAKeyPath const kCABackgroundColor;
/* 圆角 */
CA_EXTERN CAKeyPath const kCACornerRadius;
/* 边框 */
CA_EXTERN CAKeyPath const kCABorderWidth;
/* 阴影颜色 */
CA_EXTERN CAKeyPath const kCAShadowColor;
/* 偏移量CGSize */
CA_EXTERN CAKeyPath const kCAShadowOffset;
/* 阴影透明度 */
CA_EXTERN CAKeyPath const kCAShadowOpacity;
/* 阴影圆角 */
CA_EXTERN CAKeyPath const kCAShadowRadius;

@interface CAAnimation (MNHelper)
/**
 *实例化基础动画
 *@param keyPath keyPath
 *@param duration 时长
 *@param fromValue 开始值
 *@param toValue 结束值
 *@return CABasicAnimation 实例
 */
+ (CABasicAnimation *)basicAnimationWithKeyPath:(NSString *)keyPath
                                       duration:(CFTimeInterval)duration
                                      fromValue:(id)fromValue
                                        toValue:(id)toValue;

/**
 *旋转动画实例化
 *@param rotation 结束值
 *@param duration 时长
 *@return 旋转动画 实例
 */
+ (CABasicAnimation *)animationWithRotation:(CGFloat)rotation duration:(CFTimeInterval)duration;

/**
 *内容动画实例化
 *@param contents 内容
 *@param duration 时长
 *@return 内容动画 实例
 */
+ (CABasicAnimation *)animationWithContents:(id)contents duration:(CFTimeInterval)duration;

/**
 关键帧动画
 @param keyPath keyPath
 @param duration 时长
 @param values 点
 @param keyTimes 时间段 0 - 1
 @return 关键帧动画 实例
 */
+ (CAKeyframeAnimation *)keyframeAnimationWithKeyPath:(NSString *)keyPath
                                             duration:(CFTimeInterval)duration
                                               values:(NSArray *)values
                                             keyTimes:(NSArray <NSNumber *>*)keyTimes;

@end
