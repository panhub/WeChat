//
//  NSTimeZone+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2019/1/14.
//  Copyright © 2019年 小斯. All rights reserved.
//  时区

#import <Foundation/Foundation.h>

@interface NSTimeZone (MNHelper)

/**
 获取时区 
 @param section 所在时区
 @return 时区
 */
+ (NSTimeZone *)timeZoneForSectionFromGMT:(NSUInteger)section;

@end
