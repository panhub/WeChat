//
//  UIImage+MNFont.h
//  MNKit
//
//  Created by Vincent on 2018/2/2.
//  Copyright © 2018年 小斯. All rights reserved.
//  IconFont 处理
//  IconFont 文件
//  下载地址:
//  http://www.iconfont.cn
//  http://iconfont.imweb.io

#import <UIKit/UIKit.h>

@interface UIImage (MNFont)
/**
 *通过 icon font 获取对应的 icon image (无需指定字体库, 取默认字体库)
 *@param unicode unicode编码
 *@param color  颜色
 *@param size   尺寸
 *@return icon image
 */
+ (UIImage *)imageWithUnicode:(NSString *)unicode
                    color:(UIColor *)color
                     size:(CGFloat)size;

UIImage * UIImageWithUnicode (NSString *unicode, UIColor *color, CGFloat size);

/**
 *通过 icon font 获取对应的 icon image
 *@param fontName iconfont的文件(字体库)名
 *@param unicode unicode编码
 *@param color        颜色
 *@param size         尺寸
 *@return icon image
 */
+ (UIImage  *)imageWithFontName:(NSString *)fontName
                        unicode:(NSString *)unicode
                          color:(UIColor *)color
                           size:(CGFloat)size;
@end
