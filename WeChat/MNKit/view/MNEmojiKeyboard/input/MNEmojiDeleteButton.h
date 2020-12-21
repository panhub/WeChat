//
//  MNEmojiDeleteButton.h
//  MNKit
//
//  Created by Vincent on 2019/2/5.
//  Copyright © 2019年 小斯. All rights reserved.
//  表情键盘删除按钮

#import <UIKit/UIKit.h>

@interface MNEmojiDeleteButton : UIControl

/**
 箭头偏移
 */
@property (nonatomic, assign) UIOffset offset;

/**
 标题字体
 */
@property (nonatomic, weak) UIFont *titleFont;

@end
