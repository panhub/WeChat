//
//  MNEmojiButton.h
//  MNKit
//
//  Created by Vincent on 2019/2/1.
//  Copyright © 2019年 小斯. All rights reserved.
//  表情按钮

#import <UIKit/UIKit.h>
@class MNEmoji;

@interface MNEmojiButton : UIControl
/**标题位置*/
@property (nonatomic) UIEdgeInsets titleInset;
/**图片位置*/
@property (nonatomic) UIEdgeInsets imageInset;
/**图片拉伸方式*/
@property (nonatomic) UIViewContentMode contentMode;
/**标题*/
@property (nonatomic, copy) NSString *title;
/**标题字体*/
@property (nonatomic, copy) UIFont *titleFont;
/**标题颜色*/
@property (nonatomic, copy) UIColor *titleColor;
/**图片*/
@property (nonatomic, copy) UIImage *image;
/**按钮代表的表情*/
@property (nonatomic, strong) MNEmoji *emoji;

/**
 固定图片尺寸不受约束影响
 */
- (void)fixedImageSize;

/**
 固定标题尺寸不受约束影响
*/
- (void)fixedTitleSize;

@end

