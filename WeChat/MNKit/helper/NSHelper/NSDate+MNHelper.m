//
//  NSDate+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/8/3.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSDate+MNHelper.h"

NSDateFormatter * NSDateFormatterLocal (void) {
    static NSDateFormatter *_date_formatter_local;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _date_formatter_local = [NSDateFormatter new];
        [_date_formatter_local setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
        [_date_formatter_local setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return _date_formatter_local;
}

static NSDateFormatter * NSDateFormatterNormal (void) {
    static NSDateFormatter *_date_formatter_normal;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _date_formatter_normal = [NSDateFormatter new];
        [_date_formatter_normal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [_date_formatter_normal setDateFormat:@"yyyy:M:d:H:m:s"];
    });
    return _date_formatter_normal;
}

static NSDateFormatter * NSDateFormatterPlayTime (void) {
    static NSDateFormatter *_date_formatter_time;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _date_formatter_time = [NSDateFormatter new];
        [_date_formatter_time setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [_date_formatter_time setDateFormat:@"mm:ss"];
    });
    return _date_formatter_time;
}

static NSDateFormatter * NSDateFormatterFrom (id obj) {
    NSDateFormatter *dateFormatter;
    if (!obj) {
        dateFormatter = NSDateFormatterLocal();
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    } else if ([obj isKindOfClass:[NSString class]]) {
        dateFormatter = NSDateFormatterLocal();
        [dateFormatter setDateFormat:(NSString *)obj];
    } else if ([obj isKindOfClass:[NSDateFormatter class]]) {
        dateFormatter = (NSDateFormatter *)obj;
    }
    return dateFormatter;
}

 static NSUInteger NSDateTimestampFrom (id obj) {
     NSUInteger timestamp = 0;
     if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
         /// 判断是否是毫秒
         NSString *string = [NSString stringWithFormat:@"%@",obj];
         if (string.length > 10) {
             string = [string substringToIndex:10];
         }
         timestamp = [string integerValue];
     } else if ([obj isKindOfClass:[NSDate class]]) {
         /// 获取时间戳
         timestamp = [((NSDate *)obj) timeIntervalSince1970];
     }
     return timestamp;
}

@implementation NSDate (MNHelper)
#pragma mark - 时间戳
+ (NSInteger)timestamp {
    return (NSInteger)[[NSDate date] timeIntervalSince1970];
}

inline NSInteger NSDateTimestamp (void) {
    return [NSDate timestamp];
}

+ (long long)shortTimestamp {
    return (long long)([[NSDate date] timeIntervalSince1970]*1000);
}

inline long long NSDateShortTimestamp (void) {
    return [NSDate shortTimestamp];
}

+ (NSString *)timestamps {
    return [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:[self timestamp]]];
}

inline NSString * NSDateTimestamps (void) {
    return [NSDate timestamps];
}

+ (NSString *)shortTimestamps {
    return [NSString stringWithFormat:@"%@",[NSNumber numberWithLongLong:[self shortTimestamp]]];
}

inline NSString * NSDateShortTimestamps (void) {
    return [NSDate shortTimestamps];
}

#pragma mark - 时间字符串
- (NSString *)dateString {
    NSDateFormatter *dateFormatter = NSDateFormatterLocal();
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dateStringWithFormat:(id)obj {
    NSDateFormatter *dateFormatter = NSDateFormatterFrom(obj);
    return [dateFormatter stringFromDate:self];
}

+ (NSString *)dateStringWithTimestamp:(id)obj format:(id)format {
    NSDateFormatter *dateFormatter = NSDateFormatterFrom(format);
    NSInteger timestamp = NSDateTimestampFrom(obj);
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
}

+ (NSString *)dateStringWithTimestamp:(id)obj options:(MNDateComponents)options {
    NSDateFormatter *dateFormatter = [self dateFormatterWithOptions:options];
    NSInteger timestamp = NSDateTimestampFrom(obj);
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
}

+ (NSString *)playTimeStringWithInterval:(id)obj {
    NSInteger timestamp = NSDateTimestampFrom(obj);
    NSDateFormatter *dateFormatter = NSDateFormatterPlayTime();
    if (timestamp >= 3600) {
        [dateFormatter setDateFormat:@"H:mm:ss"];
    } else {
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
}

- (NSString *)weekday {
    return [NSDate weekdayFromDate:self];
}

+ (NSString *)weekdayFromDate:(id)obj {
    NSDate *date;
    if ([obj isKindOfClass:NSDate.class]) {
        date = (NSDate *)obj;
    } else {
        NSUInteger timestamp = NSDateTimestampFrom(obj);
        if (timestamp == 0) {
            date = [NSDate date];
        } else {
            date = [self dateWithTimeIntervalSince1970:timestamp];
        }
    }
    static NSCalendar *calendar;
    static NSArray <NSString *>*weekdays;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8*3600];
        weekdays = @[@"", @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", @""];
    });
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:date];
    return [weekdays objectAtIndex:components.weekday];
}

#pragma mark - 比较时间间隔
- (NSDateComponents *)dateComponentSince:(id)obj {
    NSInteger timestamp = NSDateTimestampFrom(obj);
    NSInteger interval = [self timeIntervalSince1970];
    interval = ABS(interval - timestamp);
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSString *dateString = [NSDateFormatterNormal() stringFromDate:date];
    if (dateString.length <= 0) return nil;
    
    NSArray *components = [dateString componentsSeparatedByString:@":"];
    if (components.count >= 6) {
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.year = [components[0] integerValue] - 1970;
        dateComponents.month = [components[1] integerValue] - 1;
        dateComponents.day = [components[2] integerValue] - 1;
        dateComponents.hour = [components[3] integerValue];
        dateComponents.minute = [components[4] integerValue];
        dateComponents.second = [components[5] integerValue];
        return dateComponents;
    }
    return nil;
}

+ (NSDateComponents *)dateComponentSince:(id)obj {
    return [[self date] dateComponentSince:obj];
}

- (NSString *)dateIntervalSince:(id)obj options:(MNDateComponents)options {
    NSDateComponents *dateComponents = [self dateComponentSince:obj];
    if (!dateComponents) return @"";
    if (options == MNDateComponentAll) {
        return [NSString stringWithFormat:@"%@年%@月%@日%@时%@分%@秒", @(dateComponents.year), @(dateComponents.month), @(dateComponents.day), @(dateComponents.hour), @(dateComponents.minute), @(dateComponents.second)];
    }
    NSMutableString *mutableString = [@"" mutableCopy];
    if ((options & MNDateComponentYear)) {
        [mutableString appendString:[NSString stringWithFormat:@"%@年", @(dateComponents.year)]];
    }
    if ((options & MNDateComponentMonth)) {
        [mutableString appendString:[NSString stringWithFormat:@"%@月", @(dateComponents.month)]];
    }
    if ((options & MNDateComponentDay)) {
        [mutableString appendString:[NSString stringWithFormat:@"%@日", @(dateComponents.day)]];
    }
    if ((options & MNDateComponentHour)) {
        [mutableString appendString:[NSString stringWithFormat:@"%@时", @(dateComponents.hour)]];
    }
    if ((options & MNDateComponentMinute)) {
        [mutableString appendString:[NSString stringWithFormat:@"%@分", @(dateComponents.minute)]];
    }
    if ((options & MNDateComponentSecond)) {
        [mutableString appendString:[NSString stringWithFormat:@"%@秒", @(dateComponents.second)]];
    }
    return [mutableString copy];
}

+ (NSString *)dateIntervalSince:(id)obj options:(MNDateComponents)options {
    return [[self date] dateIntervalSince:obj options:options];
}

#pragma mark - 时间格式化器
+ (NSDateFormatter *)dateFormatterWithOptions:(MNDateComponents)options {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
    if (options == MNDateComponentAll) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    } else {
        NSMutableString *mutableString = [@"" mutableCopy];
        if ((options & MNDateComponentYear)) {
            [mutableString appendString:@"yyyy"];
        }
        if ((options & MNDateComponentMonth)) {
            [mutableString appendString:(mutableString.length > 0 ? @"-MM" : @"MM")];
        }
        if ((options & MNDateComponentDay)) {
            [mutableString appendString:(mutableString.length > 0 ? @"-dd" : @"dd")];
        }
        if ((options & MNDateComponentHour)) {
            [mutableString appendString:(mutableString.length > 0 ? @" HH" : @"HH")];
        }
        if ((options & MNDateComponentMinute)) {
            [mutableString appendString:(mutableString.length > 0 ? @":mm" : @"mm")];
        }
        if ((options & MNDateComponentSecond)) {
            [mutableString appendString:(mutableString.length > 0 ? @":ss" : @"ss")];
        }
        [dateFormatter setDateFormat:[mutableString copy]];
    }
    return dateFormatter;
}

@end
