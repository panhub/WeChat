//
//  NSDictionary+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/9/28.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSDictionary+MNSafely.h"
#import "NSObject+MNSwizzle.h"

@implementation NSDictionary (MNSafely)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSClassFromString(@"__NSDictionary0") swizzleInstanceMethod:@selector(objectForKey:) withSelector:@selector(objectForKey_0:)];
        [NSClassFromString(@"__NSDictionary0") swizzleInstanceMethod:@selector(objectForKeyedSubscript:) withSelector:@selector(objectForKeyedSubscript_0:)];
        
        [NSClassFromString(@"__NSDictionaryI") swizzleInstanceMethod:@selector(objectForKey:) withSelector:@selector(objectForKey_I:)];
        [NSClassFromString(@"__NSDictionaryI") swizzleInstanceMethod:@selector(objectForKeyedSubscript:) withSelector:@selector(objectForKeyedSubscript_I:)];
        
        [NSClassFromString(@"__NSSingleEntryDictionaryI") swizzleInstanceMethod:@selector(objectForKey:) withSelector:@selector(objectForKey_single:)];
        [NSClassFromString(@"__NSSingleEntryDictionaryI") swizzleInstanceMethod:@selector(objectForKeyedSubscript:) withSelector:@selector(objectForKeyedSubscript_single:)];
    });
}

#pragma mark - __NSDictionary0
- (id)objectForKey_0:(id)key {
    if (key) {
        return [self objectForKey_0:key];
    }
    //NSLog(@"key is nil");
    return nil;
}

- (id)objectForKeyedSubscript_0:(id)key {
    if (key) {
        return [self objectForKeyedSubscript_0:key];
    }
    //NSLog(@"key is nil");
    return nil;
}

#pragma mark - __NSDictionaryI
- (id)objectForKey_I:(id)key {
    if (key) {
        return [self objectForKey_I:key];
    }
    //NSLog(@"key is nil");
    return nil;
}

- (id)objectForKeyedSubscript_I:(id)key {
    if (key) {
        return [self objectForKeyedSubscript_I:key];
    }
    //NSLog(@"key is nil");
    return nil;
}

#pragma mark - __NSSingleEntryDictionaryI
- (id)objectForKey_single:(id)key {
    if (key) {
        return [self objectForKey_single:key];
    }
    //NSLog(@"key is nil");
    return nil;
}

- (id)objectForKeyedSubscript_single:(id)key {
    if (key) {
        return [self objectForKeyedSubscript_single:key];
    }
    //NSLog(@"key is nil");
    return nil;
}
@end
