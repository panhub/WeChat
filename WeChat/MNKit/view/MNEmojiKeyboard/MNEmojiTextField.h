//
//  MNEmojiTextField.h
//  SQB_ScreenShot
//
//  Created by Vincent on 2019/2/13.
//  Copyright © 2019年 AiZhe. All rights reserved.
//  表情输入辅助

#import <UIKit/UIKit.h>

@interface MNEmojiTextField : UITextField

/**
 富文本样式
 */
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *attributes;

@end
