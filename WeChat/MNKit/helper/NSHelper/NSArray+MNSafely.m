//
//  NSArray+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/9/28.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSArray+MNSafely.h"
#import "NSObject+MNSwizzle.h"

@implementation NSArray (MNSafely)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [NSClassFromString(@"__NSPlaceholderArray") swizzleInstanceMethod:@selector(initWithObjects:count:) withSelector:@selector(mn_initWithObjects:count:)];
        
        [NSClassFromString(@"__NSArray0") swizzleInstanceMethod:@selector(objectAtIndex:) withSelector:@selector(objectAtIndex_0:)];
        [NSClassFromString(@"__NSArray0") swizzleInstanceMethod:@selector(objectAtIndexedSubscript:) withSelector:@selector(objectAtIndexedSubscript_0:)];
        [NSClassFromString(@"__NSArray0") swizzleInstanceMethod:@selector(arrayByAddingObject:) withSelector:@selector(arrayByAddingObject_0:)];
        [NSClassFromString(@"__NSArray0") swizzleInstanceMethod:@selector(lastObject) withSelector:@selector(lastObject_0)];
        [NSClassFromString(@"__NSArray0") swizzleInstanceMethod:@selector(firstObject) withSelector:@selector(firstObject_0)];
        
        [NSClassFromString(@"__NSSingleObjectArrayI") swizzleInstanceMethod:@selector(objectAtIndex:) withSelector:@selector(objectAtIndex_single:)];
        [NSClassFromString(@"__NSSingleObjectArrayI") swizzleInstanceMethod:@selector(objectAtIndexedSubscript:) withSelector:@selector(objectAtIndexedSubscript_single:)];
        [NSClassFromString(@"__NSSingleObjectArrayI") swizzleInstanceMethod:@selector(arrayByAddingObject:) withSelector:@selector(arrayByAddingObject_single:)];
        
        [NSClassFromString(@"__NSArrayI") swizzleInstanceMethod:@selector(objectAtIndex:) withSelector:@selector(objectAtIndex_I:)];
        [NSClassFromString(@"__NSArrayI") swizzleInstanceMethod:@selector(objectAtIndexedSubscript:) withSelector:@selector(objectAtIndexedSubscript_I:)];
        [NSClassFromString(@"__NSArrayI") swizzleInstanceMethod:@selector(arrayByAddingObject:) withSelector:@selector(arrayByAddingObject_I:)];
    });
}

#pragma mark - __NSPlaceholderArray
- (instancetype)mn_initWithObjects:(const id _Nonnull [_Nullable])objects count:(NSUInteger)cnt {
    BOOL hasNilObject = NO;
    for (NSUInteger i = 0; i < cnt; i++) {
        id obj = objects[i];
        if (obj == nil) {
            hasNilObject = YES;
            //NSLog(@"%s object at index %lu is nil, it will be filtered", __FUNCTION__, i);
            break;
        }
    }
    // 因为有值为nil的元素，那么我们可以过滤掉值为nil的元素
    if (hasNilObject) {
        id __unsafe_unretained newObjects[cnt];
        NSUInteger index = 0;
        for (NSUInteger i = 0; i < cnt; ++i) {
            if (objects[i] != nil) {
                newObjects[index++] = objects[i];
            }
        }
        return [self mn_initWithObjects:newObjects count:index];
    }
    return [self mn_initWithObjects:objects count:cnt];
}

#pragma mark - NSArrayI
- (id)objectAtIndex_I:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex_I:index];
    }
    return nil;
}

- (id)objectAtIndexedSubscript_I:(NSUInteger)idx {
    if (idx < self.count) {
        return [self objectAtIndexedSubscript_I:idx];
    }
    return nil;
}

- (NSArray *)arrayByAddingObject_I:(id)anObject {
    if (!anObject) return self;
    return [self arrayByAddingObject_I:anObject];
}

#pragma mark - __NSSingleObjectArrayI
- (id)objectAtIndex_single:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex_single:index];
    }
    return nil;
}

- (id)objectAtIndexedSubscript_single:(NSUInteger)idx {
    if (idx < self.count) {
        return [self objectAtIndexedSubscript_single:idx];
    }
    return nil;
}

- (NSArray *)arrayByAddingObject_single:(id)anObject {
    if (!anObject) return self;
    return [self arrayByAddingObject_single:anObject];
}

#pragma mark - __NSArray0
- (id)objectAtIndex_0:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex_0:index];
    }
    return nil;
}

- (id)objectAtIndexedSubscript_0:(NSUInteger)idx {
    if (idx < self.count) {
        return [self objectAtIndexedSubscript_0:idx];
    }
    return nil;
}

- (NSArray *)arrayByAddingObject_0:(id)anObject {
    if (!anObject) return self;
    return [self arrayByAddingObject_0:anObject];
}

- (id)firstObject_0 {
    return nil;
}

- (id)lastObject_0 {
    return nil;
}

@end
