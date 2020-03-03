//
//  MNEmojiBackedString.h
//  MNKit
//
//  Created by Vincent on 2019/2/7.
//  Copyright © 2019年 小斯. All rights reserved.
//  表情文字描述模型

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSAttributedStringKey MNEmojiBackedAttributeName;

@interface MNEmojiBackedString : NSObject<NSCopying, NSCoding>

/**
 代表的文字
 */
@property (nonatomic, copy) NSString *string;

/**
 实例化入口一
 @param string 表情文字
 @return 描述模型
 */
+ (instancetype)backedWithString:(NSString *)string;

/**
 实例化入口
 @param string 表情文字
 @return 描述模型
 */
- (instancetype)initWithString:(NSString *)string;

@end
