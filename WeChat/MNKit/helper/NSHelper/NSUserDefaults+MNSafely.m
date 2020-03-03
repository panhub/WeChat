//
//  NSUserDefaults+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/9/24.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSUserDefaults+MNSafely.h"
#import "NSObject+MNSwizzle.h"

@implementation NSUserDefaults (MNSafely)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(setObject:forKey:)
                       withSelector:@selector(mn_setObject:forKey:)];
        [self swizzleInstanceMethod:@selector(setInteger:forKey:)
                       withSelector:@selector(mn_setInteger:forKey:)];
        [self swizzleInstanceMethod:@selector(setFloat:forKey:)
                       withSelector:@selector(mn_setFloat:forKey:)];
        [self swizzleInstanceMethod:@selector(setDouble:forKey:)
                       withSelector:@selector(mn_setDouble:forKey:)];
        [self swizzleInstanceMethod:@selector(setBool:forKey:)
                       withSelector:@selector(mn_setBool:forKey:)];
        [self swizzleInstanceMethod:@selector(setURL:forKey:)
                       withSelector:@selector(mn_setURL:forKey:)];
        [self swizzleInstanceMethod:@selector(objectForKey:)
                       withSelector:@selector(mn_objectForKey:)];
        [self swizzleInstanceMethod:@selector(boolForKey:)
                       withSelector:@selector(mn_boolForKey:)];
        [self swizzleInstanceMethod:@selector(integerForKey:)
                       withSelector:@selector(mn_integerForKey:)];
        [self swizzleInstanceMethod:@selector(stringForKey:)
                       withSelector:@selector(mn_stringForKey:)];
        [self swizzleInstanceMethod:@selector(removeObjectForKey:)
                       withSelector:@selector(mn_removeObjectForKey:)];
    });
}

#pragma mark - Setter
- (void)mn_setObject:(id)value forKey:(NSString *)defaultName {
    if (defaultName.length > 0) {
        [self mn_setObject:value forKey:defaultName];
    }
}

- (void)mn_setInteger:(NSInteger)value forKey:(NSString *)defaultName {
    if (defaultName.length > 0) {
        [self mn_setInteger:value forKey:defaultName];
    }
}

- (void)mn_setFloat:(float)value forKey:(NSString *)defaultName {
    if (defaultName.length > 0) {
        [self mn_setFloat:value forKey:defaultName];
    }
}

- (void)mn_setDouble:(double)value forKey:(NSString *)defaultName {
    if (defaultName.length > 0) {
        [self mn_setDouble:value forKey:defaultName];
    }
}

- (void)mn_setBool:(BOOL)value forKey:(NSString *)defaultName {
    if (defaultName.length > 0) {
        [self mn_setBool:value forKey:defaultName];
    }
}

- (void)mn_setURL:(NSURL *)url forKey:(NSString *)defaultName {
    if (defaultName.length > 0) {
        [self mn_setURL:url forKey:defaultName];
    }
}

- (void)mn_removeObjectForKey:(NSString *)defaultName {
    if (defaultName.length > 0) {
        [self mn_removeObjectForKey:defaultName];
    }
}

#pragma mark - Getter
- (id)mn_objectForKey:(NSString *)defaultName {
    if (defaultName.length > 0) {
        return [self mn_objectForKey:defaultName];
    }
    return nil;
}

- (BOOL)mn_boolForKey:(NSString *)defaultName {
    if (defaultName.length > 0) {
        return [self mn_boolForKey:defaultName];
    }
    return NO;
}

- (NSInteger)mn_integerForKey:(NSString *)defaultName {
    if (defaultName.length > 0) {
        return [self mn_integerForKey:defaultName];
    }
    return 0;
}

- (NSString *)mn_stringForKey:(NSString *)defaultName {
    if (defaultName.length > 0) {
        return [self mn_stringForKey:defaultName];
    }
    return nil;
}

#pragma mark - 预设默认值
+ (id)objectForKey:(NSString *)key def:(id)def {
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!obj) obj = def;
    return obj;
}

+ (NSString *)stringForKey:(NSString *)key def:(NSString *)def {
    NSString *string = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if (!string) string = def;
    return string;
}

+ (BOOL)boolForKey:(NSString *)key {
    return [self boolForKey:key def:NO];
}

+ (BOOL)boolForKey:(NSString *)key def:(BOOL)def {
    id value = [self objectForKey:key def:nil];
    if (value) return [value boolValue];
    return def;
}

+ (NSData *)dataForKey:(NSString *)key def:(NSData *)def {
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:key];
    if (!data) data = def;
    return data;
}

+ (NSArray *)arrayForKey:(NSString *)key def:(NSArray *)def {
    NSArray *array = [[NSUserDefaults standardUserDefaults] arrayForKey:key];
    if (!array) array = def;
    return array;
}

+ (NSArray<NSString *> *)stringArrayForKey:(NSString *)key def:(NSArray <NSString *>*)def {
    NSArray <NSString *>*array = [[NSUserDefaults standardUserDefaults] stringArrayForKey:key];
    if (!array) array = def;
    return array;
}

+ (NSDictionary<NSString *, id> *)dictionaryForKey:(NSString *)key def:(NSDictionary<NSString *, id> *)def {
    NSDictionary<NSString *, id> *dic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
    if (!dic) dic = def;
    return dic;
}

#pragma mark -
- (void)setImage:(UIImage *)image forKey:(NSString *)defaultName {
    if (defaultName.length <= 0) return;
    NSData *data = UIImagePNGRepresentation(image);
    if (data.length) {
        [self setObject:data forKey:defaultName];
    } else {
        [self removeObjectForKey:defaultName];
    }
}

- (UIImage *)imageForKey:(NSString *)key {
    return [self imageForKey:key def:nil];
}

- (UIImage *)imageForKey:(NSString *)key def:(UIImage *)def {
    NSData *data = [self dataForKey:key];
    if (data.length) {
        return [UIImage imageWithData:data];
    }
    return def;
}

#pragma mark -
+ (void)synchronly:(void(^)(NSUserDefaults *userDefaults))handler {
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    if (handler) {
        handler(userDefaults);
        [userDefaults synchronize];
    }
}

@end
