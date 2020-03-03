//
//  UIImage+MNAnimated.h
//  MNFoundation
//
//  Created by Vincent on 2019/9/14.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MNAnimated)

/**GIF循环次数*/
@property (nonatomic) NSUInteger loopCount;

/**是否是GIF*/
@property (nonatomic, readonly, getter=isAnimatedImage) BOOL animatedImage;

/**
 依据数据流构造GIF
 @param data 数据流
 @return GIF
 */
+ (UIImage *)animatedImageWithData:(NSData *)data;

@end


@interface NSData (MNAnimatedData)

/**
 依据GIF构造数据流 <nullable>
 @param image GIF
 @return 数据流
 */
+ (NSData *)dataWithAnimatedImage:(UIImage *)image;

/**
 依据GIF构造数据流 <nullable>
 @param image GIF
 @param duration 动画时长
 @param loopCount 循环次数
 @return 数据流
 */
+ (NSData *)dataWithAnimatedImage:(UIImage *)image duration:(NSTimeInterval)duration loopCount:(NSUInteger)loopCount;

/**
 依据图片获取数据流<PNG GIF>
 @param image 图片
 @return 数据流
 */
+ (NSData *)dataWithImage:(UIImage *)image;

@end

/**
 GIF数据流转换
 @param image GIF
 @return GIF数据流
 */
UIKIT_EXTERN  NSData *UIImageGIFRepresentation(UIImage *image);
