//
//  UIImageView+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2017/11/30.
//  Copyright © 2017年 小斯. All rights reserved.
//  UIImageView 扩展

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (MNHelper)

/**
 设置图片颜色<可支持的话>
 */
@property (nonatomic, strong, nullable) UIColor *tint_color;

/**
 *UIImageView 实例化快捷入口
 *@param image <UIImage/NSString/NSURL>
 *@return UIImageView实例
 */
+ (__kindof UIImageView *)imageViewWithFrame:(CGRect)frame image:(id _Nullable)image;

/**
 *设置图片
 *@param image image/NSString/NSURL
 *@param placeholderImage 占位图
 */
- (void)setImage:(id _Nullable)image placeholderImage:(UIImage *_Nullable)placeholderImage;

/**
 *使ImageView接收事件以及contentMode等
 */
- (void)layoutImage;

/**
 依据image,适配到宽度
 */
- (void)sizeFitToWidth;

/**
 依据image,适配到高度
*/
- (void)sizeFitToHeight;

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
                      completion:(void(^_Nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
