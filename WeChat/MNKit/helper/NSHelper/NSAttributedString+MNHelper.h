//
//  NSAttributedString+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/4/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (MNHelper)

/**
 获取自身Range
 */
@property (nonatomic, readonly) NSRange rangeOfAll;

/**
 获取自身大小
 @param width 限制宽度
 @return 自身大小
 */
- (CGSize)sizeOfLimitWidth:(CGFloat)width;

/**
 获取自身大小
 @param height 限制高度
 @return 自身大小
 */
- (CGSize)sizeOfLimitHeight:(CGFloat)height;

@end


@interface NSMutableAttributedString (MNHelper)

@end
