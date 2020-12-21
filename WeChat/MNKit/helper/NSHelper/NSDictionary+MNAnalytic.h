//
//  NSDictionary+MNAnalytic.h
//  MNKit
//
//  Created by Vicent on 2020/8/15.
//  字典取值

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (MNAnalytic)

+ (BOOL)boolValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key;

+ (BOOL)boolValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(BOOL)def;

+ (CGFloat)floatValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key;

+ (CGFloat)floatValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(CGFloat)def;

+ (double)doubleValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key;

+ (double)doubleValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(double)def;

+ (int)intValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key;

+ (int)intValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(int)def;

+ (NSInteger)integerValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key;

+ (NSInteger)integerValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(NSInteger)def;

+ (long)longValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key;

+ (long)longValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(long)def;

+ (long long)longLongValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key;

+ (long long)longLongValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(long long)def;

+ (NSString *_Nullable)stringValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key;

+ (NSString *_Nullable)stringValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(NSString *_Nullable)def;

+ (NSDictionary *_Nullable)dictionaryValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key;

+ (NSDictionary *_Nullable)dictionaryValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(NSDictionary *_Nullable)def;

+ (NSArray *_Nullable)arrayValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key;

+ (NSArray *_Nullable)arrayValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(NSArray *_Nullable)def;

+ (NSData *_Nullable)dataValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key;

+ (NSData *_Nullable)dataValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(NSData *_Nullable)def;

+ (NSDate *_Nullable)dateValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key;

+ (NSDate *_Nullable)dateValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(NSDate *_Nullable)def;

+ (NSNumber *_Nullable)numberValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key;

+ (NSNumber *_Nullable)numberValueWithDictionary:(NSDictionary *)json forKey:(NSString *)key def:(NSNumber *_Nullable)def;

@end

NS_ASSUME_NONNULL_END
