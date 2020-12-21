//
//  NSDictionary+MNAnalytic.m
//  MNKit
//
//  Created by Vicent on 2020/8/15.
//

#import "NSDictionary+MNAnalytic.h"

@implementation NSDictionary (MNAnalytic)

+ (BOOL)boolValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key {
    return [self boolValueWithDictionary:json forKey:key def:NO];
}

+ (BOOL)boolValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(BOOL)def {
    @try {
        if (!json || json.count <= 0 || key.length <= 0) return def;
        id value = [json objectForKey:key];
        if (!value) return def;
        if ([value respondsToSelector:NSSelectorFromString(@"boolValue")]) return [value boolValue];
        return def;
    } @catch (NSException *exception) {
        NSLog(@"解析BOOL异常%@===%@", key, exception.reason);
        return def;
    } @finally {}
}

+ (CGFloat)floatValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key {
    return [self floatValueWithDictionary:json forKey:key def:0.f];
}

+ (CGFloat)floatValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(CGFloat)def {
    @try {
        if (!json || json.count <= 0 || key.length <= 0) return def;
        id value = [json objectForKey:key];
        if (!value) return def;
        if ([value respondsToSelector:NSSelectorFromString(@"floatValue")]) return [value floatValue];
        return def;
    } @catch (NSException *exception) {
        NSLog(@"解析CGFloat异常%@===%@", key, exception.reason);
        return def;
    } @finally {}
}

+ (double)doubleValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key {
    return [self doubleValueWithDictionary:json forKey:key def:0.f];
}

+ (double)doubleValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(double)def {
    @try {
        if (!json || json.count <= 0 || key.length <= 0) return def;
        id value = [json objectForKey:key];
        if (!value) return def;
        if ([value respondsToSelector:NSSelectorFromString(@"doubleValue")]) return [value doubleValue];
        return def;
    } @catch (NSException *exception) {
        NSLog(@"解析double异常%@===%@", key, exception.reason);
        return def;
    } @finally {}
}

+ (int)intValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key {
    return [self intValueWithDictionary:json forKey:key def:0];
}

+ (int)intValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(int)def {
    @try {
        if (!json || json.count <= 0 || key.length <= 0) return def;
        id value = [json objectForKey:key];
        if (!value) return def;
        if ([value respondsToSelector:NSSelectorFromString(@"intValue")]) return [value intValue];
        return def;
    } @catch (NSException *exception) {
        NSLog(@"解析int异常%@===%@", key, exception.reason);
        return def;
    } @finally {}
}

+ (NSInteger)integerValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key {
    return [self integerValueWithDictionary:json forKey:key def:0];
}

+ (NSInteger)integerValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(NSInteger)def {
    @try {
        if (!json || json.count <= 0 || key.length <= 0) return def;
        id value = [json objectForKey:key];
        if (!value) return def;
        if ([value respondsToSelector:NSSelectorFromString(@"integerValue")]) return [value integerValue];
        return def;
    } @catch (NSException *exception) {
        NSLog(@"解析NSInteger异常%@===%@", key, exception.reason);
        return def;
    } @finally {}
}

+ (long)longValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key {
    return [self longValueWithDictionary:json forKey:key def:0];
}

+ (long)longValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(long)def {
    @try {
        if (!json || json.count <= 0 || key.length <= 0) return def;
        id value = [json objectForKey:key];
        if (!value) return def;
        if ([value respondsToSelector:NSSelectorFromString(@"longValue")]) return [value longValue];
        return def;
    } @catch (NSException *exception) {
        NSLog(@"解析long异常%@===%@", key, exception.reason);
        return def;
    } @finally {}
}

+ (long long)longLongValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key {
    return [self longLongValueWithDictionary:json forKey:key def:0];
}

+ (long long)longLongValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(long long)def {
    @try {
        if (!json || json.count <= 0 || key.length <= 0) return def;
        id value = [json objectForKey:key];
        if (!value) return def;
        if ([value respondsToSelector:NSSelectorFromString(@"longLongValue")]) return [value longLongValue];
        return def;
    } @catch (NSException *exception) {
        NSLog(@"解析longLong异常%@===%@", key, exception.reason);
        return def;
    } @finally {}
}

+ (NSString *)stringValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key {
    return [self stringValueWithDictionary:json forKey:key def:nil];
}

+ (NSString *)stringValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(NSString *)def {
    @try {
        if (!json || json.count <= 0 || key.length <= 0) return def;
        id value = [json objectForKey:key];
        if (!value) return def;
        NSString *string;
        if ([value isKindOfClass:[NSString class]]) {
            string = (NSString *)value;
        } else if ([value respondsToSelector:NSSelectorFromString(@"stringValue")]) {
            string = ((id(*)(id, SEL))objc_msgSend)(value, sel_registerName("stringValue"));
        }
        if (string) return string;
        return def;
    } @catch (NSException *exception) {
        NSLog(@"解析NSString异常%@===%@", key, exception.reason);
        return def;
    } @finally {}
}

+ (NSDictionary *)dictionaryValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key {
    return [self dictionaryValueWithDictionary:json forKey:key def:nil];
}

+ (NSDictionary *)dictionaryValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(NSDictionary *)def {
    @try {
        if (!json || json.count <= 0 || key.length <= 0) return def;
        id value = [json objectForKey:key];
        return (value && [value isKindOfClass:NSDictionary.class]) ? (NSDictionary *)value : def;
    } @catch (NSException *exception) {
        NSLog(@"解析NSDictionary异常%@===%@", key, exception.reason);
        return def;
    } @finally {}
}

+ (NSArray *)arrayValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key {
    return [self arrayValueWithDictionary:json forKey:key def:nil];
}

+ (NSArray *)arrayValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(NSArray *)def {
    @try {
        if (!json || json.count <= 0 || key.length <= 0) return def;
        id value = [json objectForKey:key];
        return (value && [value isKindOfClass:NSArray.class]) ? (NSArray *)value : def;
    } @catch (NSException *exception) {
        NSLog(@"解析NSArray异常%@===%@", key, exception.reason);
        return def;
    } @finally {}
}

+ (NSData *)dataValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key {
    return [self dataValueWithDictionary:json forKey:key def:nil];
}

+ (NSData *)dataValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(NSData *)def {
    @try {
        if (!json || json.count <= 0 || key.length <= 0) return def;
        id value = [json objectForKey:key];
        if (!value) return def;
        NSData *data;
        if ([value isKindOfClass:NSData.class]) {
            data = (NSData *)value;
        } else if ([value respondsToSelector:NSSelectorFromString(@"stringValue")]) {
            NSString *string = ((id(*)(id, SEL))objc_msgSend)(value, sel_registerName("stringValue"));
            if (string) data = [string dataUsingEncoding:NSUTF8StringEncoding];
        }
        if (!data) data = def;
        return data;
    } @catch (NSException *exception) {
        NSLog(@"解析NSData异常%@===%@", key, exception.reason);
        return def;
    } @finally {}
}

+ (NSDate *)dateValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key {
    return [self dateValueWithDictionary:json forKey:key def:nil];
}

+ (NSDate *)dateValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(NSDate *)def {
    @try {
        if (!json || json.count <= 0 || key.length <= 0) return def;
        id value = [json objectForKey:key];
        return (value && [value isKindOfClass:NSDate.class]) ? (NSDate *)value : def;
    } @catch (NSException *exception) {
        NSLog(@"解析NSDate异常%@===%@", key, exception.reason);
        return def;
    } @finally {}
}

+ (NSNumber *)numberValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key {
    return [self numberValueWithDictionary:json forKey:key def:nil];
}

+ (NSNumber *)numberValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(NSNumber *)def {
    @try {
        if (!json || json.count <= 0 || key.length <= 0) return def;
        id value = [json objectForKey:key];
        return (value && [value isKindOfClass:NSNumber.class]) ? (NSNumber *)value : def;
    } @catch (NSException *exception) {
        NSLog(@"解析NSNumber异常%@===%@", key, exception.reason);
        return def;
    } @finally {}
}

@end
