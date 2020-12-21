//
//  UIButton+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2017/11/30.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (MNHelper)
/**
 标题字号/字体
 */
@property (nonatomic, nullable) id titleFont;
/**
 标题 UIControlStateNormal
 */
@property (nonatomic, nullable) id buttonTitle;
/**
 背景图片 UIControlStateNormal
 */
@property (nonatomic, nullable) id backgroundImage;

/**
 *UIButton 实例化快捷入口
 *@param frame 位置
 *@param image image对象/NSString/NSURL
 *@param title    标题
 *@param titleColor    标题颜色
 *@param font    字体/字号
 *@return UIButton实例
 */
+ (__kindof UIButton *)buttonWithFrame:(CGRect)frame
                          image:(id _Nullable)image
                          title:(id _Nullable)title
                     titleColor:(UIColor * _Nullable)titleColor
                           titleFont:(id _Nullable)font;

/**
 *设置图片
 *@param image NSString/NSURL
 *@param state 按钮状态
 *@param placeholderImage 占位图片
 */
- (void)setBackgroundImage:(id _Nullable)image
                  forState:(UIControlState)state
          placeholderImage:(UIImage *_Nullable)placeholderImage;

/**
 *设置标题
 *@param title NSString/NSAttributedString
 *@param state 按钮状态
 */
- (void)setButtonTitle:(id _Nullable)title forState:(UIControlState)state;

/**
 依据图片及宽度适应大小
 */
- (void)sizeFitToWidth;

/**
 依据图片及高度适应大小
 */
- (void)sizeFitToHeight;

/**
 取消按钮高亮效果
 */
- (void)cancelHighlightedEffect;

/**
 取消不可用效果
 */
- (void)cancelDisabledEffect;

@end

NS_ASSUME_NONNULL_END
