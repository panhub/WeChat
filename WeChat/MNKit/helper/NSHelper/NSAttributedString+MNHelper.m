//
//  NSAttributedString+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/4/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSAttributedString+MNHelper.h"

@implementation NSAttributedString (MNHelper)

- (NSRange)rangeOfAll {
    return NSMakeRange(0, self.length);
}

- (CGSize)sizeOfLimitWidth:(CGFloat)width {
    return [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
}

- (CGSize)sizeOfLimitHeight:(CGFloat)height {
    return [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
}

@end


@implementation NSMutableAttributedString (MNHelper)

@end
