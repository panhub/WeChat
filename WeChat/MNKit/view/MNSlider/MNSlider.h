//
//  MNSlider.h
//  MMC_SchoolShip
//
//  Created by Vincent on 2018/8/29.
//  Copyright © 2018年 小斯. All rights reserved.
//  进度条

#import <UIKit/UIKit.h>
@class MNSlider;

@protocol MNSliderDelegate <NSObject>
@optional
- (BOOL)sliderShouldBeginDragging:(MNSlider *)slider;
- (void)sliderWillBeginDragging:(MNSlider *)slider;
- (void)sliderDidDragging:(MNSlider *)slider;
- (void)sliderDidEndDragging:(MNSlider *)slider;
@end

@interface MNSlider : UIView

@property (nonatomic, weak) id<MNSliderDelegate> delegate;
/**缓冲区颜色*/
@property (nonatomic, strong) UIColor *bufferColor;
/**滑块颜色*/
@property (nonatomic, strong) UIColor *thumbColor;
/**滑块上原点颜色*/
@property (nonatomic, strong) UIColor *touchColor;
/**滑块设置图片*/
@property (nonatomic, strong) UIImage *thumbImage;
/**进度条颜色*/
@property (nonatomic, strong) UIColor *progressColor;
/**轨迹颜色*/
@property (nonatomic, strong) UIColor *trackColor;
/**轨迹边框颜色*/
@property (nonatomic, strong) UIColor *borderColor;
/**轨迹边框宽度*/
@property (nonatomic) CGFloat borderWidth;
/**轨迹高度*/
@property (nonatomic) CGFloat trackHeight;
/**是否在拖拽*/
@property (nonatomic, readonly, getter=isDragging) BOOL dragging;
/**是否在点击*/
@property (nonatomic, readonly, getter=isTouching) BOOL touching;

/**进度值, 0 - 1*/
@property (nonatomic) float progress;
@property (nonatomic) float buffer;

/**标记是否在交互*/
@property (nonatomic, readonly, getter=isSelected) BOOL selected;

/**弃用(请使用initWithFrame:实例化方法)*/
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 设置进度
 @param progress 进度值
 @param animated 是否动态
 */
- (void)setProgress:(float)progress animated:(BOOL)animated;

/**
 设置缓冲
 @param buffer 缓冲值
 @param animated 是否动态
 */
- (void)setBuffer:(float)buffer animated:(BOOL)animated;

@end

