//
//  UIImage+MNAnimated.h
//  MNKit
//
//  Created by Vincent on 2019/9/14.
//  Copyright © 2019 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MNAnimated)

/**GIF循环次数*/
@property (nonatomic) NSUInteger loopCount;

/**是否是GIF*/
@property (nonatomic, readonly, getter=isAnimatedImage) BOOL animatedImage;

/**
 依据数据流创建图片对象
 @param imageData 图片数据流
 @return 图片对象
 */
+ (UIImage *_Nullable)imageWithBlurryData:(NSData *)imageData;

/**
 依据数据流构造GIF
 @param imageData 数据流
 @return GIF/PNG
 */
+ (UIImage *_Nullable)animatedImageWithData:(NSData *)imageData;

/**
 依据数据流构造GIF
 @param imageData 数据流
 @return GIF/PNG
 */
+ (UIImage *_Nullable)animatedImageWithData:(NSData *)imageData scale:(CGFloat)scale;

/**
 加载本地图片
 @param path 图片路径
 @return 图片
 */
+ (UIImage *_Nullable)imageWithContentsAtFile:(NSString *)path;

@end


@interface NSData (MNAnimatedData)

/**
 依据图片获取数据流<PNG GIF>
 @param image 图片
 @return 数据流
 */
+ (NSData *_Nullable)dataWithImage:(UIImage *)image;

/**
 依据GIF构造数据流 <nullable>
 @param image GIF
 @param duration 动画时长
 @param loopCount 循环次数
 @return 数据流
 */
+ (NSData *_Nullable)dataWithAnimatedImage:(UIImage *)image duration:(NSTimeInterval)duration loopCount:(NSUInteger)loopCount;

@end

/**
 GIF数据流转换
 @param image GIF
 @return GIF数据流
 */
UIKIT_EXTERN  NSData *_Nullable UIImageGIFRepresentation(UIImage *image);

NS_ASSUME_NONNULL_END
