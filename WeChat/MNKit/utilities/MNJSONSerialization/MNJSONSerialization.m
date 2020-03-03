//
//  MNJSONSerialization.m
//  MNKit
//
//  Created by Vincent on 2018/9/22.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNJSONSerialization.h"

@implementation MNJSONSerialization

+ (BOOL)boolValueWithJSON:(NSDictionary *)json forKey:(NSString *)key {
    if (!json || key.length <= 0) return NO;
    id value = json[key];
    if (!value) return NO;
    if ([value isKindOfClass:[NSNumber class]] ||
        [value isKindOfClass:[NSString class]] ||
        [value isKindOfClass:[NSValue class]]) {
        return [value boolValue];
    }
    return NO;
}

+ (CGFloat)floatValueWithJSON:(NSDictionary *)json forKey:(NSString *)key {
    if (!json || key.length <= 0) return 0.f;
    id value = json[key];
    if (!value) return 0.f;
    if ([value isKindOfClass:[NSNumber class]] ||
        [value isKindOfClass:[NSString class]] ||
        [value isKindOfClass:[NSValue class]]) {
        return [value floatValue];
    }
    return 0.f;
}

+ (NSInteger)integerValueWithJSON:(NSDictionary *)json forKey:(NSString *)key {
    if (!json || key.length <= 0) return 0;
    id value = json[key];
    if (!value) return 0;
    if ([value isKindOfClass:[NSNumber class]] ||
        [value isKindOfClass:[NSString class]] ||
        [value isKindOfClass:[NSValue class]]) {
        return [value integerValue];
    }
    return 0;
}

+ (nullable NSString *)stringValueWithJSON:(NSDictionary *)json forKey:(NSString *)key {
    return [self stringValueWithJSON:json forKey:key def:@""];
}

+ (nullable NSString *)stringValueWithJSON:(NSDictionary *)json forKey:(NSString *)key def:(nullable NSString *)def {
    if (!json || key.length <= 0) return def;
    id value = json[key];
    if (!value) return def;
    NSString *string;
    if ([value isKindOfClass:[NSString class]]) {
        string = (NSString *)value;
    } else if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSValue class]]) {
        string = [NSString stringWithFormat:@"%@",value];
    }
    if (!string) string = def;
    return string;
}

+ (nullable NSDictionary *)dictionaryValueWithJSON:(NSDictionary *)json forKey:(NSString *)key {
    return [self dictionaryValueWithJSON:json forKey:key def:nil];
}

+ (nullable NSDictionary *)dictionaryValueWithJSON:(NSDictionary *)json forKey:(NSString *)key def:(nullable NSDictionary *)def {
    if (!json || key.length <= 0) return def;
    id value = json[key];
    if (!value) return def;
    NSDictionary *dic;
    if ([value isKindOfClass:[NSDictionary class]]) {
        dic = (NSDictionary *)value;
    }
    if (!dic) dic = def;
    return dic;
}

+ (nullable NSArray *)arrayValueWithJSON:(NSDictionary *)json forKey:(NSString *)key {
    return [self arrayValueWithJSON:json forKey:key def:nil];
}

+ (nullable NSArray *)arrayValueWithJSON:(NSDictionary *)json forKey:(NSString *)key def:(nullable NSArray *)def {
    if (!json || key.length <= 0) return def;
    id value = json[key];
    if (!value) return def;
    NSArray *array;
    if ([value isKindOfClass:[NSArray class]]) {
        array = (NSArray *)value;
    }
    if (!array) array = def;
    return array;
}

+ (nullable NSData *)dataValueWithJSON:(NSDictionary *)json forKey:(NSString *)key {
    return [self dataValueWithJSON:json forKey:key def:nil];
}

+ (nullable NSData *)dataValueWithJSON:(NSDictionary *)json forKey:(NSString *)key def:(nullable NSData *)def {
    if (!json || key.length <= 0) return def;
    id value = json[key];
    if (!value) return def;
    NSData *data;
    if ([value isKindOfClass:[NSData class]]) {
        data = (NSData *)value;
    } else if (value && [value isKindOfClass:[NSString class]]) {
        data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
    }
    if (!data) data = def;
    return data;
}

+ (nullable NSDate *)dateValueWithJSON:(NSDictionary *)json forKey:(NSString *)key {
    return [self dateValueWithJSON:json forKey:key def:nil];
}

+ (nullable NSDate *)dateValueWithJSON:(NSDictionary *)json forKey:(NSString *)key def:(nullable NSDate *)def {
    if (!json || key.length <= 0) return def;
    id value = json[key];
    if (!value) return def;
    NSDate *date;
    if ([value isKindOfClass:[NSDate class]]) {
        date = (NSDate *)value;
    }
    if (!date) date = def;
    return date;
}

+ (nullable NSNumber *)numberValueWithJSON:(NSDictionary *)json forKey:(NSString *)key {
    return [self numberValueWithJSON:json forKey:key def:nil];
}

+ (nullable NSNumber *)numberValueWithJSON:(NSDictionary *)json forKey:(NSString *)key def:(nullable NSNumber *)def {
    if (!json || key.length <= 0) return def;
    id value = json[key];
    if (!value) return def;
    NSNumber *number;
    if ([value isKindOfClass:[NSNumber class]]) {
        number = (NSNumber *)value;
    }
    if (!number) number = def;
    return number;
}

@end
