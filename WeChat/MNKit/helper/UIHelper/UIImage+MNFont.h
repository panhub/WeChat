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

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (MNFont)
/**
 *通过 icon font 获取对应的 icon image (无需指定字体库, 取默认字体库)
 *@param unicode unicode编码
 *@param color  颜色
 *@param size   尺寸
 *@return icon image
 */
+ (UIImage *_Nullable)imageWithUnicode:(NSString *)unicode
                    color:(UIColor *_Nullable)color
                     size:(CGFloat)size;

UIKIT_EXTERN UIImage * _Nullable UIImageWithUnicode (NSString *unicode, UIColor *_Nullable color, CGFloat size);

/**
 *通过 icon font 获取对应的 icon image
 *@param fontName iconfont的文件(字体库)名
 *@param unicode unicode编码
 *@param color        颜色
 *@param size         尺寸
 *@return icon image
 */
+ (UIImage *_Nullable)imageWithFontName:(NSString *_Nullable)fontName
                        unicode:(NSString *)unicode
                          color:(UIColor *_Nullable)color
                           size:(CGFloat)size;
@end
NS_ASSUME_NONNULL_END
