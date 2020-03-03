//
//  UIImage+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2017/10/10.
//  Copyright © 2017年 小斯. All rights reserved.
//  Image

#import <UIKit/UIKit.h>

@interface UIImage (MNHelper)
/**
 利用图片转换为颜色
 */
@property (nonatomic, readonly) UIColor *patternColor;

/**获取Assets图片*/
UIImage * UIImageNamed (NSString *name);

/**根据颜色生成纯色图片*/
+ (UIImage *)imageWithColor:(UIColor *)color;
UIImage * UIImageWithColor (UIColor *color);

/**根据颜色生成纯色图片 color:颜色 size:大小 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**取图片某一像素的颜色*/
- (UIColor *)colorAtPoint:(CGPoint)point;
UIColor * UIColorAtImagePoint (UIImage *image, CGPoint point);

/**layer转换为image*/
+ (UIImage *)imageWithLayer:(CALayer *)layer;
+ (UIImage *)imageWithLayer:(CALayer *)layer rect:(CGRect)rect;

/** UIView -- UIImage */
+ (UIImage *)imageWithView:(UIView *)view afterScreenUpdates:(BOOL)afterScreenUpdates;

/** 原图, 避免着色渲染 */
- (UIImage *)originalImage;

/** 模板图 */
- (UIImage *)templateImage;

/**
 *获取图片
 *@obj name, image, url
 *@return UIImage<nulladle>
 */
+ (UIImage *)imageWithObject:(id)obj;

/**
 APP图标
 @return APP图标
 */
+ (UIImage *)logoImage;

/**
 开屏图
 @return 开屏图
 */
+ (UIImage *)launchImage;

/**
 获取图片尺寸
 @param url 图片地址<图片名,本地路径>
 @param animated 是否是动图
 @return 图片尺寸
 */
+ (CGSize)imageSizeWithUrl:(NSString *)url animated:(BOOL *)animated;

/**
 获取网络图片尺寸
 @param URL 图片地址
 @param animated 是否是动图
 @return 图片尺寸
 */
+ (CGSize)imageSizeWithURL:(NSURL *)URL animated:(BOOL *)animated;

@end


@interface UIImage (MNCoding)
/**
 获取jpeg数据, 转换率为1
 */
@property (nonatomic, readonly) NSData *PNGData;

/**
 获取png数据, 转换率为1
 */
@property (nonatomic, readonly) NSData *JPEGData;

/**
 UIImage转NSString
 @return NSString
 */
- (NSString *)JPEGBase64Encoding;
- (NSString *)PNGBase64Encoding;

/**
 NSString转UIImage
 @param base64String base64String
 @return UIImage
 */
+ (UIImage *)imageWithBase64EncodedString:(NSString *)base64String;

@end


@interface UIImage (MNResizing)
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
void UIImageMaskRadius (UIImage **, CGFloat);

/** 调整图片至指定像素 */
- (UIImage *)resizingToPix:(CGFloat )pix;

/** 调整图片至指定尺寸 */
- (UIImage *)resizingToSize:(CGSize)size;

/** 截取当前image对象rect区域内的图像 */
- (UIImage *)cropImageInRect:(CGRect)rect;

/**获得灰度图*/
- (UIImage *)grayImage;

/** 纠正图片的方向 */
- (UIImage *)resizingOrientation;
- (UIImage *)normalOrientationImage;

/** 按给定的方向旋转图片 */
- (UIImage*)rotateToOrientation:(UIImageOrientation)orient;

/** 垂直翻转 */
- (UIImage *)flipVertical;

/** 水平翻转 */
- (UIImage *)flipHorizontal;

/** 将图片旋转degrees角度 */
- (UIImage *)rotateToDegrees:(CGFloat)degrees;

/** 将图片旋转radians弧度 */
- (UIImage *)rotateToRadians:(CGFloat)radians;

/** 在指定的size里面生成一个平铺的图片 */
- (UIImage *)imageWithTiledSize:(CGSize)size;

/** 将两个图片生成一张图片 */
+ (UIImage *)mergeImage:(UIImage *)firstImage withImage:(UIImage *)secondImage;
- (UIImage *)imageWithMergeImage:(UIImage *)image;

@end
