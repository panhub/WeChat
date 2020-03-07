//
//  CALayer+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/3/8.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CALayer (MNHelper)

/**
 设置锚点<不改变相对位置>
 */
@property (nonatomic) CGPoint anchorsite;

/**
 *设置背景图片
 */
@property (nonatomic) UIImage *backgroundImage;

/**
 获取一个显示图片的Layer实例
 @param frame 你懂得
 @param image 图片资源
 @return layer实例
 */
+ (instancetype)layerWithFrame:(CGRect)frame image:(UIImage *)image;

/**
 *Mask方式设置圆角
 *@param radius 圆角半径
 */
- (void)setMaskRadius:(CGFloat)radius;
void CALayerSetMaskRadius (CALayer *layer, CGFloat radius);

/**
 *Mask方式设置圆角
 *@param radius 圆角半径
 *@param corners 指定圆角
 */
- (void)setMaskRadius:(CGFloat)radius byCorners:(UIRectCorner)corners;

/**
 *设置变宽颜色,线条宽度
 *@param color 颜色
 *@param width 线条宽度
 */
- (void)setBorderColor:(UIColor *)color width:(CGFloat)width;
void CALayerSetBorderColor (CALayer *layer, CGFloat width, UIColor *color);

/**
 获取边框layer
 @param lineWidth 画笔宽度<边框宽度>
 @param edges 边框线条
 @return 边框layer
 */
- (CAShapeLayer *)borderLayerWithLineWidth:(CGFloat)lineWidth byEdges:(UIRectEdge)edges;

/**
 删除所有子layer
*/
- (void)removeAllSublayers;

@end
