//
//  MNSafeArray.h
//  MNKit
//
//  Created by Vincent on 2019/3/29.
//  Copyright © 2019 Vincent. All rights reserved.
//  线程安全数组 

#import <Foundation/Foundation.h>
@class NSArray<ObjectType>, NSEnumerator<ObjectType>, NSSet, NSString, NSURL;

NS_ASSUME_NONNULL_BEGIN

@interface MNSafeArray<__covariant ObjectType> : NSObject <NSCopying, NSMutableCopying>

#pragma mark - instance
- (instancetype)init;

+ (instancetype)array;

- (instancetype)initWithObject:(ObjectType)anObject;

+ (instancetype)arrayWithObject:(ObjectType)anObject;

- (instancetype)initWithCapacity:(NSUInteger)numItems;

+ (instancetype)arrayWithCapacity:(NSUInteger)numItems;

- (instancetype)initWithArray:(NSArray<ObjectType> *)array;

+ (instancetype)arrayWithArray:(NSArray<ObjectType> *)array;

- (instancetype)initWithArray:(NSArray<ObjectType> *)array copyItems:(BOOL)flag;

+ (instancetype)arrayWithArray:(NSArray<ObjectType> *)array copyItems:(BOOL)flag;

- (instancetype)initWithObjects:(ObjectType)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

+ (instancetype)arrayWithObjects:(ObjectType)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

- (instancetype)initWithObjects:(const ObjectType _Nonnull [_Nullable])objects count:(NSUInteger)count;

+ (instancetype)arrayWithObjects:(const ObjectType _Nonnull [_Nullable])objects count:(NSUInteger)count;

- (instancetype)initWithContentsOfFile:(NSString *)path;

+ (instancetype)arrayWithContentsOfFile:(NSString *)path;

- (instancetype)initWithContentsOfURL:(NSURL *)url;

+ (instancetype)arrayWithContentsOfURL:(NSURL *)url;

#pragma mark - NSArray
- (NSUInteger)count;

- (ObjectType)objectAtIndex:(NSUInteger)index;

- (nullable ObjectType)lastObject;

- (nullable ObjectType)firstObject;

- (NSUInteger)indexOfObject:(ObjectType)anObject;

- (NSUInteger)indexOfObject:(ObjectType)anObject inRange:(NSRange)range;

- (NSUInteger)indexOfObjectIdenticalTo:(ObjectType)anObject;

- (NSUInteger)indexOfObjectIdenticalTo:(ObjectType)anObject inRange:(NSRange)range;

- (NSArray<ObjectType> *)arrayByAddingObject:(ObjectType)anObject;

- (NSArray<ObjectType> *)arrayByAddingObjectsFromArray:(NSArray<ObjectType> *)otherArray;

- (NSString *)componentsJoinedByString:(NSString *)separator;

- (BOOL)containsObject:(ObjectType)anObject;

- (NSEnumerator<ObjectType> *)objectEnumerator;

- (NSEnumerator<ObjectType> *)reverseObjectEnumerator;

- (NSString *)description;

- (NSString *)descriptionWithLocale:(nullable id)locale;

- (NSString *)descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level;

- (void)makeObjectsPerformSelector:(SEL)aSelector;

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument;

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(ObjectType obj, NSUInteger idx, BOOL *stop))block;

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(ObjectType obj, NSUInteger idx, BOOL *stop))block;

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(ObjectType obj, NSUInteger idx, BOOL *stop))block;

- (BOOL)isEqualToArray:(nullable id)otherArray;

#pragma mark - NSMutableArray
- (void)addObject:(ObjectType)anObject;

- (void)addObjectsFromArray:(NSArray<ObjectType> *)otherArray;

- (void)insertObject:(ObjectType)anObject atIndex:(NSUInteger)index;

- (void)insertObjects:(NSArray<ObjectType> *)objects atIndexes:(NSIndexSet *)indexes;

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(ObjectType)anObject;

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray<ObjectType> *)objects;

- (void)setObject:(ObjectType)obj atIndexedSubscript:(NSUInteger)idx;

- (void)removeLastObject;

- (void)removeAllObjects;

- (void)removeObject:(ObjectType)anObject;

- (void)removeObjectsInArray:(NSArray<ObjectType> *)otherArray;

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;

- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)removeObjectsInRange:(NSRange)range;

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<ObjectType> *)otherArray range:(NSRange)otherRange;

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<ObjectType> *)otherArray;

- (void)setArray:(NSArray<ObjectType> *)otherArray;

- (void)sortUsingFunction:(NSInteger (NS_NOESCAPE *)(ObjectType,  ObjectType, void * _Nullable))compare context:(nullable void *)context;

- (NSArray<ObjectType> *)sortedArrayUsingFunction:(NSInteger (NS_NOESCAPE *)(ObjectType, ObjectType, void * _Nullable))comparator context:(nullable void *)context;

- (void)sortUsingSelector:(SEL)comparator;

- (void)sortUsingDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors;

- (void)sortUsingComparator:(NSComparator NS_NOESCAPE)cmptr;

- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator NS_NOESCAPE)cmptr;

@end

NS_ASSUME_NONNULL_END
