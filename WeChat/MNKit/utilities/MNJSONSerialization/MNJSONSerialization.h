//
//  MNJSONSerialization.h
//  MNKit
//
//  Created by Vincent on 2018/9/22.
//  Copyright © 2018年 小斯. All rights reserved.
//  JSON解析

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNJSONSerialization : NSObject

+ (BOOL)boolValueWithJSON:(NSDictionary *)json forKey:(NSString *)key;

+ (CGFloat)floatValueWithJSON:(NSDictionary *)json forKey:(NSString *)key;

+ (NSInteger)integerValueWithJSON:(NSDictionary *)json forKey:(NSString *)key;

+ (nullable NSString *)stringValueWithJSON:(NSDictionary *)json forKey:(NSString *)key;

+ (nullable NSString *)stringValueWithJSON:(NSDictionary *)json forKey:(NSString *)key def:(nullable NSString *)def;

+ (nullable NSDictionary *)dictionaryValueWithJSON:(NSDictionary *)json forKey:(NSString *)key;

+ (nullable NSDictionary *)dictionaryValueWithJSON:(NSDictionary *)json forKey:(NSString *)key def:(nullable NSDictionary *)def;

+ (nullable NSArray *)arrayValueWithJSON:(NSDictionary *)json forKey:(NSString *)key;

+ (nullable NSArray *)arrayValueWithJSON:(NSDictionary *)json forKey:(NSString *)key def:(nullable NSArray *)def;

+ (nullable NSData *)dataValueWithJSON:(NSDictionary *)json forKey:(NSString *)key;

+ (nullable NSData *)dataValueWithJSON:(NSDictionary *)json forKey:(NSString *)key def:(nullable NSData *)def;

+ (nullable NSDate *)dateValueWithJSON:(NSDictionary *)json forKey:(NSString *)key;

+ (nullable NSDate *)dateValueWithJSON:(NSDictionary *)json forKey:(NSString *)key def:(nullable NSDate *)def;

+ (nullable NSNumber *)numberValueWithJSON:(NSDictionary *)json forKey:(NSString *)key;

+ (nullable NSNumber *)numberValueWithJSON:(NSDictionary *)json forKey:(NSString *)key def:(nullable NSNumber *)def;

@end

NS_ASSUME_NONNULL_END
