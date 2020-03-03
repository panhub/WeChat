//
//  MNEmojiKeyboardConfiguration.h
//  MNChat
//
//  Created by Vincent on 2020/2/16.
//  Copyright © 2020 Vincent. All rights reserved.
//  表情键盘配置信息

#import <Foundation/Foundation.h>

/**
 表情键盘风格
 - MNEmojiKeyboardStyleLight: 新版微信风格
 - MNEmojiKeyboardStyleRegular: 旧版微信风格
*/
typedef NS_ENUM(NSInteger, MNEmojiKeyboardStyle) {
    MNEmojiKeyboardStyleLight = 0,
    MNEmojiKeyboardStyleRegular
};

@interface MNEmojiKeyboardConfiguration : NSObject
/**
 键盘风格<键盘添加前有效>
*/
@property (nonatomic) MNEmojiKeyboardStyle style;
/**
 键盘按钮类型<由此推测按钮标题>
 */
@property (nonatomic) UIReturnKeyType returnKeyType;
/**
 是否允许使用表情包
*/
@property (nonatomic, getter=isAllowsUseEmojiPackets) BOOL allowsUseEmojiPackets;
/**
 Return键颜色
 */
@property (nonatomic, strong) UIColor *returnKeyColor;
/**
 Return键字体
 */
@property (nonatomic, strong) UIFont *returnKeyTitleFont;
/**
 Return键字体颜色
 */
@property (nonatomic, strong) UIColor *returnKeyTitleColor;
/**
 键盘分割线颜色
*/
@property (nonatomic, copy) UIColor *separatorColor;
/**
 背景色
*/
@property (nonatomic, copy) UIColor *backgroundColor;
/**
 表情包选择器颜色
*/
@property (nonatomic, copy) UIColor *tintColor;
/**
 表情包选择颜色
*/
@property (nonatomic, copy) UIColor *selectedColor;
/**
 页码指示器高度
*/
@property (nonatomic) CGFloat pageIndicatorHeight;
/**
 页码指示器颜色
*/
@property (nonatomic, copy) UIColor *pageIndicatorColor;
/**
 当前页码指示器颜色
*/
@property (nonatomic, copy) UIColor *currentPageIndicatorColor;

@end
