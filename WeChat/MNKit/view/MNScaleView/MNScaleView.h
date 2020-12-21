//
//  MNScaleView.h
//  MNKit
//
//  Created by Vincent on 2019/5/1.
//  Copyright © 2019 Vincent. All rights reserved.
//  刻度view

#import <UIKit/UIKit.h>

@interface MNScaleView : UIView
/**
 *  圆盘开始弧度
 */
@property (nonatomic) CGFloat startAngle;
/**
 *  圆盘结束弧度
 */
@property (nonatomic) CGFloat endAngle;
/**
 *  内外环间隔
 */
@property (nonatomic) CGFloat innerInterval;
/**
 *  刻度与外环间隔
 */
@property (nonatomic) CGFloat scaleInterval;
/**
 *  环画笔宽度
 */
@property (nonatomic) CGFloat lineWidth;
/**
 *  正常刻度画笔宽度
 */
@property (nonatomic) CGFloat scaleLineMinWidth;
/**
 *  较长刻度画笔宽度
 */
@property (nonatomic) CGFloat scaleLineMaxWidth;
/**
 *  每份弧度是刻度的多少倍
 */
@property (nonatomic) NSUInteger scaleLinePer;
/**
 *  画笔颜色
 */
@property (nonatomic, strong) UIColor *strokeColor;
/**
 *  填充颜色
 */
@property (nonatomic, strong) UIColor *fillColor;
/**
 *  分为多少份
 */
@property (nonatomic) int divide;
/**
 *  分为多少份
 */
@property (nonatomic) int subdivide;
/**
 *  刻度描述回调
 */
@property (nonatomic, copy) UIView *(^detailViewHandler) (NSUInteger idx);


/**
 *  创建视图
 */
- (void)createView;


@end
