//
//  MNContext.h
//  MNKit
//
//  Created by Vincent on 2019/8/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNContextConfig.h"
@class MNContext;

typedef void(^MNContextDrawHandler)(MNContext *context);

@interface MNContext : NSObject

/**
 上下文
 */
@property (nonatomic) CGContextRef context;

/**
 配置
 */
@property (nonatomic, strong) MNContextConfig *config;

/**
 依据上下文实例化入口
 @param context 上下文
 @return 绘制实例
 */
- (instancetype)initWithContext:(CGContextRef)context;

/**
 依据配置实例化入口
 @param config 配置
 @return 绘制实例
 */
- (instancetype)initWithConfig:(MNContextConfig *)config;

/**
 依据上下文/配置实例化入口
 @param context 上下文
 @param config 配置
 @return 绘制实例
 */
- (instancetype)initWithContext:(CGContextRef)context config:(MNContextConfig *)config;

/**
 使用配置
 @param config 配置
 */
- (void)useConfig:(MNContextConfig *)config;

/**
 使用配置
 @param config 配置
 @param update 是否更新当前配置
 */
- (void)useConfig:(MNContextConfig *)config update:(BOOL)update;

/**
 移动到某点
 @param point 指定点
 */
- (void)moveToPoint:(CGPoint)point;

/**
 添加线条
 @param point 目标点
 */
- (void)addLineToPoint:(CGPoint)point;

/**
 添加路径点
 @param points 路径点集合
 */
- (void)addLinePoints:(NSArray <NSValue *>*)points;

/**
 添加弧线
 @param endPoint 目标点
 @param controlPoint 控制点
 */
- (void)addQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint;

/**
 添加弧线
 @param endPoint 目标点
 @param controlPoint1 控制点1
 @param controlPoint2 控制点2
 */
- (void)addCurveToPoint:(CGPoint)endPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2;

/**
 添加矩形
 @param rect 矩形边界
 */
- (void)addRect:(CGRect)rect;

/**
 添加圆
 @param center 圆心
 @param radius 半径
 @param startAngle 开始弧度
 @param endAngle 结束弧度
 @param clockwise 是否顺时针
 */
- (void)addArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise;

/**
 绘制线条
 @param handler 回调
 */
- (void)drawStrokePathWithHandler:(MNContextDrawHandler)handler;

/**
 绘制条
 @param config 配置
 @param handler 回调
 */
- (void)drawStrokePathUseConfig:(MNContextConfig *)config handler:(MNContextDrawHandler)handler;

/**
 绘制图形
 @param handler 回调
 */
- (void)drawFillPathWithHandler:(MNContextDrawHandler)handler;

/**
 绘制图形
 @param config 配置
 @param handler 回调
 */
- (void)drawFillPathUseConfig:(MNContextConfig *)config handler:(MNContextDrawHandler)handler;

/**
 设置绘制模式
 @param drawingMode 绘制模式
 */
- (void)drawPathWithMode:(CGPathDrawingMode)drawingMode;

/**
 在指定点绘制文字
 @param string 文字
 @param point 指定点
 @param attributes 描述
 */
- (void)drawString:(NSString *)string atPoint:(CGPoint)point withAttributes:(NSDictionary *)attributes;

/**
 在指定位置绘制文字
 @param string 文字
 @param rect 位置
 @param attributes 描述
 */
- (void)drawString:(NSString *)string inRect:(CGRect)rect withAttributes:(NSDictionary *)attributes;

/**
 在指定点绘制富文本
 @param string 富文本
 @param point 指定点
 */
- (void)drawAttributedString:(NSAttributedString *)string atPoint:(CGPoint)point;

/**
 在指定位置绘制富文本
 @param string 富文本
 @param rect 指定位置
 */
- (void)drawAttributedString:(NSAttributedString *)string inRect:(CGRect)rect;

/**
 在指定点绘制图像
 @param image 图像
 @param point 指定点
 */
- (void)drawImage:(UIImage *)image atPoint:(CGPoint)point;

/**
 在指定点绘制图像
 @param image 图像
 @param point 指定点
 @param blendMode 模式
 @param alpha 透明度
 */
- (void)drawImage:(UIImage *)image atPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

/**
 在指定位置绘制图像
 @param image 图像
 @param rect 指定位置
 */
- (void)drawImage:(UIImage *)image inRect:(CGRect)rect;

/**
 在指定位置绘制图像
 @param image 图像
 @param rect 指定位置
 @param blendMode 模式
 @param alpha 透明度
 */
- (void)drawImage:(UIImage *)image inRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

/**
 在指定位置绘制图案
 @param image 图案
 @param rect 指定位置
 */
- (void)drawImage:(UIImage *)image asPatternInRect:(CGRect)rect;

/**
 设置透明度
 @param alpha 透明度
 */
- (void)setAlpha:(CGFloat)alpha;

/**
 绘制区域颜色
 @param color 颜色
 @param rect 区域
 */
- (void)setFillColor:(UIColor *)color inRect:(CGRect)rect;

/**
 开始绘制
 */
- (void)beginPath;

/**
 关闭k路径
 */
- (void)closePath;

/**
 绘制线条
 */
- (void)strokePath;

/**
 绘制图形
 */
- (void)fillPath;

/**
 保存上下文
 */
- (void)saveGState;

/**
 恢复上下文
 */
- (void)restoreGState;

@end
