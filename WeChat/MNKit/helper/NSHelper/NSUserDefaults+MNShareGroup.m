//
//  NSUserDefaults+MNShareGroup.m
//  MNKit
//
//  Created by Vicent on 2020/11/19.
//

#import "NSUserDefaults+MNShareGroup.h"

@implementation NSUserDefaults (MNShareGroup)

+ (BOOL)setObject:(id)value forKey:(NSString *)defaultName withGroup:(NSString *)suitename {
    if (!defaultName || defaultName.length <= 0 || !suitename || suitename.length <= 0) return NO;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suitename];
    [userDefaults setObject:value forKey:defaultName];
    return [userDefaults synchronize];
}

+ (BOOL)setBool:(BOOL)value forKey:(NSString *)defaultName withGroup:(NSString *)suitename {
    if (!defaultName || defaultName.length <= 0 || !suitename || suitename.length <= 0) return NO;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suitename];
    [userDefaults setBool:value forKey:defaultName];
    return [userDefaults synchronize];
}

+ (BOOL)setInteger:(NSInteger)value forKey:(NSString *)defaultName withGroup:(NSString *)suitename {
    if (!defaultName || defaultName.length <= 0 || !suitename || suitename.length <= 0) return NO;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suitename];
    [userDefaults setInteger:value forKey:defaultName];
    return [userDefaults synchronize];
}

+ (BOOL)setDouble:(double)value forKey:(NSString *)defaultName withGroup:(NSString *)suitename {
    if (!defaultName || defaultName.length <= 0 || !suitename || suitename.length <= 0) return NO;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suitename];
    [userDefaults setDouble:value forKey:defaultName];
    return [userDefaults synchronize];
}

+ (id)objectForKey:(NSString *)defaultName withGroup:(NSString *)suitename {
    if (!defaultName || defaultName.length <= 0 || !suitename || suitename.length <= 0) return nil;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suitename];
    return [userDefaults objectForKey:defaultName];
}

+ (BOOL)boolForKey:(NSString *)defaultName withGroup:(NSString *)suitename {
    if (!defaultName || defaultName.length <= 0 || !suitename || suitename.length <= 0) return NO;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suitename];
    return [userDefaults boolForKey:defaultName];
}

+ (NSInteger)integerForKey:(NSString *)defaultName withGroup:(NSString *)suitename {
    if (!defaultName || defaultName.length <= 0 || !suitename || suitename.length <= 0) return 0;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suitename];
    return [userDefaults integerForKey:defaultName];
}

+ (double)doubleForKey:(NSString *)defaultName withGroup:(NSString *)suitename {
    if (!defaultName || defaultName.length <= 0 || !suitename || suitename.length <= 0) return 0.0;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suitename];
    return [userDefaults doubleForKey:defaultName];
}

+ (void)removeObjectForKey:(NSString *)defaultName withGroup:(NSString *)suitename {
    if (!defaultName || defaultName.length <= 0 || !suitename || suitename.length <= 0) return;
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suitename];
    [userDefaults removeObjectForKey:defaultName];
}

@end
