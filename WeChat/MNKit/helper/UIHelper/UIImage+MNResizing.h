//
//  UIImage+MNResizing.h
//  MNKit
//
//  Created by Vicent on 2021/2/27.
//  Copyright © 2021 Vincent. All rights reserved.
//  图片调整/压缩

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MNResizing)

/**获得灰度图*/
@property (nonatomic, readonly, nullable) UIImage *grayImage;

/**垂直翻转图*/
@property (nonatomic, readonly) UIImage *verticalFlipImage;

/**水平翻转图*/
@property (nonatomic, readonly) UIImage *horizontalFlipImage;

/**
 拉伸图像
 @param imgName 图片名
 @return 拉伸后的图像
 */
+ (UIImage *)resizableImage:(NSString *)imgName;

/**
 拉伸图像
 @param imgName 图片名
 @param capInsets 拉伸位置
 @return 拉伸后的图像
 */
+ (UIImage *)resizableImage:(NSString *)imgName capInsets:(UIEdgeInsets)capInsets;

/**图片圆角处理*/
- (UIImage *)maskRadius:(CGFloat)radius;

/** 截取当前image对象rect区域内的图像 */
- (UIImage *)cropInRect:(CGRect)rect;

/** 截取当前image对象rect区域内的图像 */
- (UIImage *)cropByRect:(CGRect)rect;

/** 纠正图片的方向 */
- (UIImage *)resizingOrientation;
- (UIImage *)normalOrientationImage;

/** 按给定的方向旋转图片 */
- (UIImage*)rotateToOrientation:(UIImageOrientation)orient;

/** 将图片旋转degrees角度 */
- (UIImage *)rotateToDegrees:(CGFloat)degrees;

/** 将图片旋转radians弧度 */
- (UIImage *)rotateToRadians:(CGFloat)radians;

/** 在指定的size里面生成一个平铺的图片 */
- (UIImage *)imageWithTiledSize:(CGSize)size;

/** 将两个图片生成一张图片 */
+ (UIImage *)mergeImage:(UIImage *)firstImage withImage:(UIImage *)secondImage;

/** 将两个图片生成一张图片 */
- (UIImage *)imageWithMergeImage:(UIImage *)image;

@end

@interface UIImage (MNCompress)

/**获取压缩图 近似微信朋友圈压缩结果<以1280为界以0.5为压缩系数>*/
@property (nonatomic, readonly) UIImage *compressImage;

/** 调整图片至指定像素 */
- (UIImage *)resizingToPix:(NSUInteger)pix;

/** 调整图片至指定最大像素 */
- (UIImage *)resizingToMaxPix:(NSUInteger)pix;

/** 调整图片至指定尺寸 */
- (UIImage *)resizingToSize:(CGSize)size;

/**压缩图片到大约指定质量 K为单位*/
- (NSData *)dataWithQuality:(CGFloat)representation;

/**压缩图片到大约指定质量 K为单位*/
- (UIImage *)resizingToQuality:(CGFloat)representation;

/**压缩图片到指定像素内 大约质量 K为单位*/
- (UIImage *)resizingToPix:(NSUInteger)pix quality:(CGFloat)representation;

/**压缩图片到最大像素 大约质量 K为单位*/
- (UIImage *)resizingToMaxPix:(NSUInteger)pix quality:(CGFloat)representation;

@end

NS_ASSUME_NONNULL_END
