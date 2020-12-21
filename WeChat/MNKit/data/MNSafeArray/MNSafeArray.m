//
//  MNSafeArray.m
//  MNKit
//
//  Created by Vincent on 2019/3/29.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNSafeArray.h"

#define MNSafeInit(...) \
self = [super init]; \
if (!self) return nil; \
__VA_ARGS__; \
if (!_array) return nil; \
if (![_array isKindOfClass:NSMutableArray.class]) { \
_array = [NSMutableArray arrayWithArray:_array.copy]; \
} \
if (!_array) return nil; \
_lock = dispatch_semaphore_create(1); \
return self;

#define MNSafeLock(...) \
dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

@implementation MNSafeArray
{
    NSMutableArray *_array;
    dispatch_semaphore_t _lock;
}

#pragma mark - instance
- (instancetype)init {
    MNSafeInit(_array = [[NSMutableArray alloc] init]);
}

+ (instancetype)array {
    return [[self alloc] init];
}

- (instancetype)initWithObject:(id)anObject {
    return [self initWithObjects:anObject, nil];
}

+ (instancetype)arrayWithObject:(id)anObject {
    return [[self alloc] initWithObject:anObject];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    MNSafeInit(_array = [[NSMutableArray alloc] initWithCapacity:numItems]);
}

+ (instancetype)arrayWithCapacity:(NSUInteger)numItems {
    return [[self alloc] initWithCapacity:numItems];
}

- (instancetype)initWithArray:(NSArray *)array {
    MNSafeInit(_array = [[NSMutableArray alloc] initWithArray:array]);
}

+ (instancetype)arrayWithArray:(NSArray *)array {
    return [[self alloc] initWithArray:array];
}

- (instancetype)initWithArray:(NSArray *)array copyItems:(BOOL)flag {
    MNSafeInit(_array = [[NSMutableArray alloc] initWithArray:array copyItems:flag]);
}

+ (instancetype)arrayWithArray:(NSArray *)array copyItems:(BOOL)flag {
    return [[self alloc] initWithArray:array copyItems:flag];
}

- (instancetype)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *array = [NSMutableArray array];
    if (firstObj) {
        [array addObject:firstObj];
        id value;
        va_list args;
        va_start(args, firstObj);
        while ((value = va_arg(args, id))) {
            [array addObject:value];
        }
        va_end(args);
    }
    return [self initWithArray:array.copy];
}

+ (instancetype)arrayWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *array = [NSMutableArray array];
    if (firstObj) {
        [array addObject:firstObj];
        id value;
        va_list args;
        va_start(args, firstObj);
        while ((value = va_arg(args, id))) {
            [array addObject:value];
        }
        va_end(args);
    }
    return [self arrayWithArray:array.copy];
}

- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt {
    MNSafeInit(_array = [[NSMutableArray alloc] initWithObjects:objects count:cnt]);
}

+ (instancetype)arrayWithObjects:(const id [])objects count:(NSUInteger)count {
    return [[self alloc] initWithObjects:objects count:count];
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    MNSafeInit(_array = [[NSMutableArray alloc] initWithContentsOfFile:path]);
}

+ (instancetype)arrayWithContentsOfFile:(NSString *)path {
    return [[self alloc] initWithContentsOfFile:path];
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
    MNSafeInit(_array = [[NSMutableArray alloc] initWithContentsOfURL:url]);
}

+ (instancetype)arrayWithContentsOfURL:(NSURL *)url {
    return [[self alloc] initWithContentsOfURL:url];
}

#pragma mark - NSArray
- (NSUInteger)count {
    MNSafeLock(NSUInteger count = [_array count]);
    return count;
}

- (id)objectAtIndex:(NSUInteger)index {
    MNSafeLock(id obj = [_array objectAtIndex:index]);
    return obj;
}

- (id)lastObject {
    MNSafeLock(id obj = [_array lastObject]);
    return obj;
}

- (id)firstObject {
    MNSafeLock(id obj = [_array firstObject]);
    return obj;
}

- (NSUInteger)indexOfObject:(id)anObject {
    MNSafeLock(NSUInteger index = [_array indexOfObject:anObject]);
    return index;
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range {
    MNSafeLock(NSUInteger index = [_array indexOfObject:anObject inRange:range]);
    return index;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject {
    MNSafeLock(NSUInteger index = [_array indexOfObjectIdenticalTo:anObject]);
    return index;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    MNSafeLock(NSUInteger index = [_array indexOfObjectIdenticalTo:anObject inRange:range]);
    return index;
}

- (NSArray<id> *)arrayByAddingObject:(id)anObject {
    MNSafeLock(NSArray *array = [_array arrayByAddingObject:anObject]);
    return array;
}

- (NSArray<id> *)arrayByAddingObjectsFromArray:(NSArray<id> *)otherArray {
    MNSafeLock(NSArray *array = [_array arrayByAddingObjectsFromArray:otherArray]);
    return array;
}

- (NSString *)componentsJoinedByString:(NSString *)separator {
    MNSafeLock(NSString *string = [_array componentsJoinedByString:separator]);
    return string;
}

- (BOOL)containsObject:(id)anObject {
    MNSafeLock(BOOL contains = [_array containsObject:anObject]);
    return contains;
}

- (NSEnumerator<id> *)objectEnumerator {
    MNSafeLock(NSEnumerator<id> *enu = [_array objectEnumerator]);
    return enu;
}

- (NSEnumerator<id> *)reverseObjectEnumerator {
    MNSafeLock(NSEnumerator<id> *enu = [_array reverseObjectEnumerator]);
    return enu;
}

- (NSString *)descriptionWithLocale:(id)locale {
    MNSafeLock(NSString *desc = [_array descriptionWithLocale:locale]);
    return desc;
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    MNSafeLock(NSString *desc = [_array descriptionWithLocale:locale indent:level]);
    return desc;
}

- (NSString *)description {
    MNSafeLock(NSString *desc = [_array description]);
    return desc;
}

- (void)makeObjectsPerformSelector:(SEL)aSelector {
    if (!aSelector) return;
    MNSafeLock([_array makeObjectsPerformSelector:aSelector]);
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument {
    if (!aSelector) return;
    MNSafeLock([_array makeObjectsPerformSelector:aSelector withObject:argument]);
}

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block {
    MNSafeLock([_array enumerateObjectsUsingBlock:block]);
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block {
    MNSafeLock([_array enumerateObjectsWithOptions:opts usingBlock:block]);
}

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block {
    MNSafeLock([_array enumerateObjectsAtIndexes:s options:opts usingBlock:block]);
}

- (BOOL)isEqualToArray:(id)otherArray {
    if (!otherArray) return NO;
    if (otherArray == self) return YES;
    BOOL isEqual = NO;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if ([otherArray isKindOfClass:MNSafeArray.class]) {
        MNSafeArray *array = (MNSafeArray *)otherArray;
        dispatch_semaphore_wait(array->_lock, DISPATCH_TIME_FOREVER);
        isEqual = [_array isEqualToArray:array->_array];
        dispatch_semaphore_signal(array->_lock);
    } else if ([otherArray isKindOfClass:NSArray.class]) {
        isEqual = [_array isEqualToArray:(NSArray *)otherArray];
    }
    dispatch_semaphore_signal(_lock);
    return isEqual;
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile {
    MNSafeLock(BOOL succeed = [_array writeToFile:path atomically:useAuxiliaryFile]);
    return succeed;
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically {
    MNSafeLock(BOOL succeed = [_array writeToURL:url atomically:atomically]);
    return succeed;
}

#pragma mark - NSMutableArray
- (void)addObject:(id)anObject {
    if (!anObject) return;
    MNSafeLock([_array addObject:anObject]);
}

- (void)addObjectsFromArray:(NSArray *)otherArray {
    if (!otherArray) return;
    MNSafeLock([_array addObjectsFromArray:otherArray]);
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (!anObject) return;
    MNSafeLock([_array insertObject:anObject atIndex:index]);
}

- (void)insertObjects:(NSArray<id> *)objects atIndexes:(NSIndexSet *)indexes {
    if (objects.count <= 0 || indexes.count <= 0) return;
    MNSafeLock([_array insertObjects:objects atIndexes:indexes]);
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (!anObject) return;
    MNSafeLock([_array replaceObjectAtIndex:index withObject:anObject]);
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray<id> *)objects {
    if (indexes.count <= 0 || objects.count <= 0) return;
    MNSafeLock([_array replaceObjectsAtIndexes:indexes withObjects:objects]);
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    if (!obj) return;
    MNSafeLock([_array setObject:obj atIndexedSubscript:idx]);
}

- (void)removeLastObject {
    MNSafeLock([_array removeLastObject]);
}

- (void)removeAllObjects {
    MNSafeLock([_array removeAllObjects]);
}

- (void)removeObject:(id)anObject {
    if (!anObject) return;
    MNSafeLock([_array removeObject:anObject]);
}

- (void)removeObjectsInArray:(NSArray *)otherArray {
    if (otherArray.count <= 0) return;
    MNSafeLock([_array removeObjectsInArray:otherArray]);
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    if (indexes.count <= 0) return;
    MNSafeLock([_array removeObjectsAtIndexes:indexes]);
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    MNSafeLock([_array removeObjectAtIndex:index]);
}

- (void)removeObjectsInRange:(NSRange)range {
    MNSafeLock([_array removeObjectsInRange:range]);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<id> *)otherArray range:(NSRange)otherRange {
    MNSafeLock([_array replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange]);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<id> *)otherArray {
    MNSafeLock([_array replaceObjectsInRange:range withObjectsFromArray:otherArray]);
}

- (void)setArray:(NSArray<id> *)otherArray {
    MNSafeLock([_array setArray:otherArray]);
}

- (void)sortUsingFunction:(NSInteger (NS_NOESCAPE *)(id, id, void * _Nullable))compare context:(nullable void *)context {
    MNSafeLock([_array sortUsingFunction:compare context:context]);
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (NS_NOESCAPE *)(id, id, void * _Nullable))comparator context:(nullable void *)context {
    MNSafeLock(NSArray *arr = [_array sortedArrayUsingFunction:comparator context:context]);
    return arr;
}

- (void)sortUsingSelector:(SEL)comparator {
    MNSafeLock([_array sortUsingSelector:comparator]);
}

- (void)sortUsingDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors {
    MNSafeLock([_array sortUsingDescriptors:sortDescriptors]);
}

- (void)sortUsingComparator:(NSComparator NS_NOESCAPE)cmptr {
    MNSafeLock([_array sortUsingComparator:cmptr]);
}

- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator NS_NOESCAPE)cmptr {
    MNSafeLock([_array sortWithOptions:opts usingComparator:cmptr]);
}

#pragma mark - Protocol
- (NSUInteger)hash {
    MNSafeLock(NSUInteger hash = [_array hash]);
    return hash;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self mutableCopyWithZone:zone];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    MNSafeLock(id obj = [[self.class allocWithZone:zone] initWithArray:_array]);
    return obj;
}

- (BOOL)isEqual:(id)object {
    if (!object || ![object isKindOfClass:MNSafeArray.class]) return NO;
    if (object == self) return YES;
    MNSafeArray *array = (MNSafeArray *)object;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(array->_lock, DISPATCH_TIME_FOREVER);
    BOOL isEqual = [_array isEqual:array->_array];
    dispatch_semaphore_signal(array->_lock);
    dispatch_semaphore_signal(_lock);
    return isEqual;
}

#pragma mark - Other
- (NSString *)debugDescription {
    MNSafeLock(NSString *desc = [_array debugDescription]);
    return desc;
}

@end
