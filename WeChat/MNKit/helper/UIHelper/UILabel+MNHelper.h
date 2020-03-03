//
//  UILabel+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2017/12/11.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (MNHelper)

/**
 设置字体 <支持 NSNumber, UIFont>
 */
@property (nonatomic) id textFont;

/**
 内容 <支持 NSAttributedString, NSString>
 */
@property (nonatomic) id string;


/**
 快速实例化
 @param frame {坐标, 大小}
 @param text 文字 <支持 NSAttributedString, NSString>
 @param textColor 文字颜色
 @param font 文字字体 <支持 NSNumber, UIFont>
 @return UILabel实例
 */
+ (instancetype)labelWithFrame:(CGRect)frame
                          text:(id)text
                     textColor:(UIColor*)textColor
                          font:(id)font;

/**
 快速实例化
 
 @param frame {坐标, 大小}
 @param text 文字 <支持 NSAttributedString, NSString>
 @param textAlignment 文字排版
 @param textColor 文字颜色
 @param font 文字字体 <支持 NSNumber, UIFont>
 @return UILabel实例
 */
+ (instancetype)labelWithFrame:(CGRect)frame
                          text:(id)text
                 textAlignment:(NSTextAlignment)textAlignment
                     textColor:(UIColor *)textColor
                          font:(id)font;

@end
