//
//  MNQRCode.h
//  MNKit
//
//  Created by Vincent on 2018/7/4.
//  Copyright © 2018年 小斯. All rights reserved.
//  二维码生成者

#import <Foundation/Foundation.h>

@interface MNQRCode : NSObject

#pragma mark - 制作二维码
/**
 制作二维码
 @param metadata 元数据
 @param pixel 像素
 @return 二维码图片
 */
+ (UIImage *)createQRCodeWithMetadata:(NSData *)metadata pixel:(CGFloat)pixel;

/**
 制作二维码<异步>
 @param metadata 元数据
 @param pixel 像素
 @param completion 完成回调
 */
+ (void)createQRCodeWithMetadata:(NSData *)metadata pixel:(CGFloat)pixel completion:(void(^)(UIImage *image))completion;

/**
 制作二维码
 @param metadata 元数据
 @param color 颜色
 @param pixel 像素
 @return 二维码
 */
+ (UIImage *)createQRCodeWithMetadata:(NSData *)metadata color:(UIColor *)color pixel:(CGFloat)pixel;

/**
 制作二维码<异步>
 @param metadata 元数据
 @param color 颜色
 @param pixel 像素
 @param completion 完成回调
 */
+ (void)createQRCodeWithMetadata:(NSData *)metadata color:(UIColor *)color pixel:(CGFloat)pixel completion:(void(^)(UIImage *image))completion;

#pragma mark - 优化
/**
 修改二维码颜色
 @param image 二维码
 @param color 颜色
 @return 修改后的二维码
 */
+ (UIImage *)changeQRCode:(UIImage *)image withColor:(UIColor *)color;

/**
 修改二维码颜色<异步>
 @param img 二维码
 @param color 颜色
 @param completion 完成回调
 */
+ (void)changeQRCode:(UIImage *)img withColor:(UIColor *)color completion:(void(^)(UIImage *, UIColor *))completion;

/**
 往二维码上添加图片<头像, logo>
 @param QRCodeImage 二维码
 @param image 需要添加的图片
 @param size 图片大小
 @return 修改后的二维码
 */
+ (UIImage *)insertImageToQRCodeAtFront:(UIImage *)QRCodeImage image:(UIImage *)image size:(CGSize)size;

/**
 往二维码上添加图片<异步>
 @param QRCodeImage 二维码
 @param image 需要添加的图片
 @param size 图片大小
 @param completion 修改后的二维码回调
 */
+ (void)insertImageToQRCodeAtFront:(UIImage *)QRCodeImage image:(UIImage *)image size:(CGSize)size completion:(void(^)(UIImage *image))completion;

@end
