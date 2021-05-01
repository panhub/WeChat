//
//  MNEmojiPacketCell.h
//  MNKit
//
//  Created by Vincent on 2019/2/5.
//  Copyright © 2019年 小斯. All rights reserved.
//  表情类型控制Cell

#import <UIKit/UIKit.h>
@class MNEmojiKeyboardConfiguration;

@interface MNEmojiPacketCell : UICollectionViewCell

/**
 设置表情包
 @param image 表情包图片
 @param selected 是否选择状态
 @param configuration 表情键盘设置
 */
- (void)setImage:(UIImage *)image selected:(BOOL)selected configuration:(MNEmojiKeyboardConfiguration *)configuration;

@end
