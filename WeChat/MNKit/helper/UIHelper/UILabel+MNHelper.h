//
//  UILabel+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2017/12/11.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (MNHelper)
/**
 设置字体 <支持 NSNumber, UIFont>
 */
@property (nonatomic, nullable) id textFont;
/**
 内容 <支持 NSAttributedString, NSString>
 */
@property (nonatomic, nullable) id string;
/**
 获取文字大小<单行>
 */
@property (nonatomic, readonly) CGSize stringSize;
/**
 获取文字大小<多行 以宽度为限>
 */
@property (nonatomic, readonly) CGSize boundingSizeByWidth;
/**
 获取文字大小<多行 以高度为限>
 */
@property (nonatomic, readonly) CGSize boundingSizeByHeight;


/**
 快速实例化
 @param frame {坐标, 大小}
 @param text 文字 <支持 NSAttributedString, NSString>
 @param textColor 文字颜色
 @param textFont 文字字体 <支持 NSNumber, UIFont>
 @return UILabel实例
 */
+ (__kindof UILabel *)labelWithFrame:(CGRect)frame
                                text:(id _Nullable)text
                           textColor:(UIColor *_Nullable)textColor
                                font:(id _Nullable)textFont;

/**
 快速实例化
 
 @param frame {坐标, 大小}
 @param text 文字 <支持 NSAttributedString, NSString>
 @param alignment 文字排版
 @param textColor 文字颜色
 @param font 文字字体 <支持 NSNumber, UIFont>
 @return UILabel实例
 */
+ (__kindof UILabel *)labelWithFrame:(CGRect)frame
                                text:(id _Nullable)text
                           alignment:(NSTextAlignment)alignment
                           textColor:(UIColor *_Nullable)textColor
                                font:(id _Nullable)font;

@end

NS_ASSUME_NONNULL_END
