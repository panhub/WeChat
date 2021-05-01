//
//  NSMutableArray+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/9/28.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSMutableArray+MNSafely.h"
#import "NSObject+MNSwizzle.h"

@implementation NSMutableArray (MNSafely)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [NSClassFromString(@"__NSArrayM") swizzleInstanceMethod:@selector(objectAtIndex:) withSelector:@selector(mn_objectAtIndex:)];
    
        [NSClassFromString(@"__NSArrayM") swizzleInstanceMethod:@selector(objectAtIndexedSubscript:) withSelector:@selector(mn_objectAtIndexedSubscript:)];
        
        [NSClassFromString(@"__NSArrayM") swizzleInstanceMethod:@selector(arrayByAddingObject:) withSelector:@selector(mn_arrayByAddingObject:)];
        
        [NSClassFromString(@"__NSArrayM") swizzleInstanceMethod:@selector(removeObjectAtIndex:) withSelector:@selector(mn_removeObjectAtIndex:)];
        
        [NSClassFromString(@"__NSArrayM") swizzleInstanceMethod:@selector(removeObjectsInArray:) withSelector:@selector(mn_removeObjectsInArray:)];
        
        [NSClassFromString(@"__NSArrayM") swizzleInstanceMethod:@selector(removeObject:) withSelector:@selector(mn_removeObject:)];
        
        [NSClassFromString(@"__NSArrayM") swizzleInstanceMethod:@selector(replaceObjectAtIndex:withObject:) withSelector:@selector(mn_replaceObjectAtIndex:withObject:)];
        
        [NSClassFromString(@"__NSArrayM") swizzleInstanceMethod:@selector(addObject:) withSelector:@selector(mn_addObject:)];
        
        [NSClassFromString(@"__NSArrayM") swizzleInstanceMethod:@selector(addObjectsFromArray:) withSelector:@selector(mn_addObjectsFromArray:)];
        
        [NSClassFromString(@"__NSArrayM") swizzleInstanceMethod:@selector(insertObject:atIndex:) withSelector:@selector(mn_insertObject:atIndex:)];
    });
}

#pragma mark - __NSArrayM
- (id)mn_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self mn_objectAtIndex:index];
    }
    return nil;
}

- (id)mn_objectAtIndexedSubscript:(NSUInteger)idx {
    if (idx < self.count) {
        return [self mn_objectAtIndexedSubscript:idx];
    }
    return nil;
}

- (void)mn_addObject:(id)anObject {
    if (anObject) {
        [self mn_addObject:anObject];
    }
}

- (void)mn_addObjectsFromArray:(NSArray *)otherArray {
    if (otherArray.count > 0) {
        [self mn_addObjectsFromArray:otherArray];
    }
}

- (NSArray *)mn_arrayByAddingObject:(id)anObject {
    if (!anObject) return self;
    return [self mn_arrayByAddingObject:anObject];
}

- (void)mn_removeObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) return;
    [self mn_removeObjectAtIndex:index];
}

- (void)mn_removeObjectsInArray:(NSArray *)otherArray {
    if (otherArray.count > 0) {
        [self mn_removeObjectsInArray:otherArray];
    }
}

- (void)mn_removeObject:(id)anObject {
    if (anObject && [self containsObject:anObject]) {
        [self mn_removeObject:anObject];
    }
}

- (void)mn_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (anObject && index < self.count) {
        [self mn_replaceObjectAtIndex:index withObject:anObject];
    }
}

- (void)mn_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (anObject && index <= self.count) {
        [self mn_insertObject:anObject atIndex:index];
    }
}

@end
