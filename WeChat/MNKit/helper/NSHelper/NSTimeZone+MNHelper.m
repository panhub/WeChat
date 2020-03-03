//
//  NSTimeZone+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2019/1/14.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "NSTimeZone+MNHelper.h"

@implementation NSTimeZone (MNHelper)
#pragma mark - 时区
+ (NSTimeZone *)timeZoneForSectionFromGMT:(NSUInteger)section {
    section = MIN(section, 24);
    return [NSTimeZone timeZoneForSecondsFromGMT:(section*3600)];
}

@end
