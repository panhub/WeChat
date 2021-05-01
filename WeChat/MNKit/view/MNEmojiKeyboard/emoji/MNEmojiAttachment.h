//
//  MNEmojiAttachment.h
//  MNKit
//
//  Created by Vincent on 2019/2/11.
//  Copyright © 2019年 小斯. All rights reserved.
//  表情附件

#import <UIKit/UIKit.h>

@interface MNEmojiAttachment : NSTextAttachment

/**
 表情文字范围
 */
@property (nonatomic, assign) NSRange range;

/**
 表情文字描述
 */
@property (nonatomic, strong) NSString *desc;

@end
