//
//  NSArray+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/10/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSArray+MNHelper.h"
#import <objc/runtime.h>

@implementation NSArray (MNHelper)

#pragma mark - 分割数组
- (NSArray <NSArray *>*)componentArrayByCapacity:(NSUInteger)count {
    if (count <= 0 || self.count <= 0) return nil;
    NSUInteger number = self.count%count == 0 ? (self.count/count) : (self.count/count + 1);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:number];
    for (NSUInteger i = 0; i < number; i ++) {
        NSUInteger location = i*count;
        NSUInteger length = self.count - location >= count ? count : (self.count - location);
        NSArray *subArray = [self subarrayWithRange:NSMakeRange(location, length)];
        [array addObject:subArray];
    }
    return [array copy];
}

#pragma mark - 倒序数组
- (NSArray *)reverseObjects {
    return [[self.copy reverseObjectEnumerator] allObjects];
}

#pragma mark - 随机元素
- (id)randomObject {
    if (self.count <= 0) return nil;
    return [self objectAtIndex:self.randomIndex];
}

#pragma mark - 随机索引
- (NSInteger)randomIndex {
    if (self.count <= 0) return 0;
    return arc4random_uniform((u_int32_t)self.count);
}

#pragma mark - 乱序数组
- (NSArray *)scrambledArray {
    if (self.count <= 1) return self.copy;
    NSMutableArray <NSNumber *>*indexs = @[].mutableCopy;
    for (int i = 0; i < self.count; i++) {
        [indexs addObject:[NSNumber numberWithInt:i]];
    }
    NSMutableArray *array = @[].mutableCopy;
    do {
        NSNumber *num = [indexs objectAtIndex:(arc4random()%indexs.count)];
        [indexs removeObject:num];
        [array addObject:[self objectAtIndex:num.integerValue]];
    } while (indexs.count > 0);
    return array.copy;
}

@end

@implementation NSMutableArray (MNHelper)
#pragma mark - 移动元素
- (void)moveSubjectAtIndex:(NSInteger)index toIndex:(NSInteger)toIndex {
    if (toIndex == index || index >= self.count) return;
    if (toIndex > index) {
        /// 下移
        if (toIndex >= self.count) {
            toIndex = self.count - 1;
        }
    }
    toIndex = MAX(0, toIndex);
    /// 约束了索引, 要再次判断
    if (toIndex == index) return;
    id obj = [self objectAtIndex:index];
    [self removeObject:obj];
    [self insertObject:obj atIndex:toIndex];
}

- (void)moveSubject:(id)subject toIndex:(NSInteger)toIndex {
    if (![self containsObject:subject]) return;
    NSUInteger index = [self indexOfObject:subject];
    [self moveSubjectAtIndex:index toIndex:toIndex];
}

- (void)bringSubjectToFront:(id)subject {
    if (!subject) return;
    if ([self containsObject:subject]) {
        NSUInteger idx = [self indexOfObject:subject];
        [self bringSubjectToFrontAtIndex:idx];
    } else {
        [self insertObject:subject atIndex:0];
    }
}

- (void)sendSubjectToBack:(id)subject {
    if (!subject) return;
    if ([self containsObject:subject]) {
        NSUInteger idx = [self indexOfObject:subject];
        [self sendSubjectToBackAtIndex:idx];
    } else {
        [self addObject:subject];
    }
}

- (void)bringSubjectToFrontAtIndex:(NSUInteger)index {
    if (self.count <= 0 || index >= self.count) return;
    id obj = [self objectAtIndex:index];
    [self removeObject:obj];
    [self insertObject:obj atIndex:0];
}

- (void)sendSubjectToBackAtIndex:(NSUInteger)index {
    if (self.count <= 0 || index >= self.count) return;
    id obj = [self objectAtIndex:index];
    [self removeObject:obj];
    [self addObject:obj];
}

- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index {
    NSUInteger i = index;
    for (id obj in objects) {
        [self insertObject:obj atIndex:i++];
    }
}


@end
