//
//  NSMutableDictionary+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/9/28.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSMutableDictionary+MNSafely.h"
#import "NSObject+MNSwizzle.h"

@implementation NSMutableDictionary (MNSafely)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSClassFromString(@"__NSDictionaryM") swizzleInstanceMethod:@selector(objectForKey:) withSelector:@selector(mn_objectForKey:)];
        [NSClassFromString(@"__NSDictionaryM") swizzleInstanceMethod:@selector(objectForKeyedSubscript:) withSelector:@selector(mn_objectForKeyedSubscript:)];
        [NSClassFromString(@"__NSDictionaryM") swizzleInstanceMethod:@selector(setObject:forKey:) withSelector:@selector(mn_setObject:forKey:)];
        [NSClassFromString(@"__NSDictionaryM") swizzleInstanceMethod:@selector(setObject:forKeyedSubscript:) withSelector:@selector(mn_setObject:forKeyedSubscript:)];
        [NSClassFromString(@"__NSDictionaryM") swizzleInstanceMethod:@selector(removeObjectForKey:) withSelector:@selector(mn_removeObjectForKey:)];
        //KVC
        [NSClassFromString(@"__NSDictionaryM") swizzleInstanceMethod:@selector(setValue:forKey:) withSelector:@selector(mn_setValue:forKey:)];
        [NSClassFromString(@"__NSDictionaryM") swizzleInstanceMethod:@selector(valueForKey:) withSelector:@selector(mn_valueForKey:)];
        [NSClassFromString(@"__NSDictionaryM") swizzleInstanceMethod:@selector(setValue:forKeyPath:) withSelector:@selector(mn_setValue:forKeyPath:)];
        [NSClassFromString(@"__NSDictionaryM") swizzleInstanceMethod:@selector(valueForKeyPath:) withSelector:@selector(mn_valueForKeyPath:)];
    });
}

- (id)mn_objectForKey:(id)key {
    if (key) {
        return [self mn_objectForKey:key];
    }
    return nil;
}

- (id)mn_objectForKeyedSubscript:(id)key {
    if (key) {
        return [self mn_objectForKeyedSubscript:key];
    }
    return nil;
}

- (void)mn_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject && aKey) {
        [self mn_setObject:anObject forKey:aKey];
    }
}

- (void)mn_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (obj && key) {
        [self mn_setObject:obj forKeyedSubscript:key];
    }
}

- (void)mn_removeObjectForKey:(id)aKey {
    if (aKey) {
        [self mn_removeObjectForKey:aKey];
    }
}

- (void)mn_setValue:(id)value forKey:(NSString *)key {
    if (value && key) {
        [self mn_setValue:value forKey:key];
    }
}

- (id)mn_valueForKey:(NSString *)key {
    if (key) {
        return [self mn_valueForKey:key];
    }
    return nil;
}

- (void)mn_setValue:(id)value forKeyPath:(NSString *)keyPath {
    if (value && keyPath) {
        [self mn_setValue:value forKeyPath:keyPath];
    }
}

- (id)mn_valueForKeyPath:(NSString *)keyPath {
    if (keyPath) {
        return [self mn_valueForKeyPath:keyPath];
    }
    return nil;
}

@end
