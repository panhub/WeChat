//
//  UIImageView+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2017/11/30.
//  Copyright © 2017年 小斯. All rights reserved.
//  UIImageView 扩展

#import <UIKit/UIKit.h>

@interface UIImageView (MNHelper)
/**
 *UIImageView 实例化快捷入口
 *@param image image对象/NSString/NSURL
 *@return UIImageView实例
 */
+ (UIImageView *)imageViewWithFrame:(CGRect)frame image:(id)image;

/**
 *设置图片
 *@param image image/NSString/NSURL
 *@param placeholderImage 占位图
 */
- (void)setImage:(id)image placeholderImage:(UIImage *)placeholderImage;

/**
 *使ImageView接收事件以及contentMode等
 */
- (void)layoutImage;

/**
 *开启动画
 *@param images 动画图片数组
 *@param duration 时长
 *@param repeat 重复次数(0为一直重复)
 */
- (void)startAnimationWithImages:(NSArray <UIImage *>*)images
                           duration:(NSTimeInterval)duration
                             repeat:(NSInteger)repeat;

/**
 *开启动画
 *@param images 动画图片数组
 *@param duration 时长
 *@param repeat 重复次数(0为一直重复)
 *@param completion 结束回调
 */
- (void)startAnimationWithImages:(NSArray <UIImage *>*)images
                        duration:(NSTimeInterval)duration
                          repeat:(NSUInteger)repeat
                      completion:(void(^)(void))completion;

@end
