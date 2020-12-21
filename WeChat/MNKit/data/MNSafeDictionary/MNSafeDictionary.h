//
//  MNSafeDictionary.h
//  MNKit
//
//  Created by Vincent on 2019/3/29.
//  Copyright © 2019 Vincent. All rights reserved.
//  线程安全字典, 不可继承, 重写

#import <Foundation/Foundation.h>
@class NSArray<ObjectType>, NSSet<ObjectType>, NSEnumerator<ObjectType>, NSString, NSURL;

NS_ASSUME_NONNULL_BEGIN

@interface MNSafeDictionary<__covariant KeyType, __covariant ObjectType> : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, readonly, copy) NSArray<KeyType> *allKeys;
@property (nonatomic, readonly, copy) NSArray<ObjectType> *allValues;
@property (nonatomic, readonly, copy) NSString *description;

#pragma mark - Instance
- (instancetype)init;

+ (instancetype)dictionary;

- (instancetype)initWithObjects:(NSArray <ObjectType>*)objects forKeys:(NSArray<KeyType<NSCopying>> *)keys;

+ (instancetype)dictionaryWithObjects:(NSArray <ObjectType>*)objects forKeys:(NSArray<KeyType<NSCopying>> *)keys;

- (instancetype)initWithCapacity:(NSUInteger)capacity;

+ (instancetype)dictionaryWithCapacity:(NSUInteger)numItems;

- (instancetype)initWithDictionary:(NSDictionary <KeyType, ObjectType>*)otherDictionary;

+ (instancetype)dictionaryWithDictionary:(NSDictionary <KeyType, ObjectType>*)dict;

- (instancetype)initWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

+ (instancetype)dictionaryWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

- (instancetype)initWithDictionary:(NSDictionary <KeyType, ObjectType>*)otherDictionary copyItems:(BOOL)flag;

+ (instancetype)dictionaryWithDictionary:(NSDictionary <KeyType, ObjectType>*)otherDictionary copyItems:(BOOL)flag;

- (instancetype)initWithContentsOfFile:(NSString *)path;

+ (instancetype)dictionaryWithContentsOfFile:(NSString *)path;

- (instancetype)initWithContentsOfURL:(NSURL *)url;

+ (instancetype)dictionaryWithContentsOfURL:(NSURL *)url;

#pragma mark - NSDictionary
- (NSUInteger)count;

- (nullable ObjectType)objectForKey:(KeyType)aKey;

- (NSEnumerator<KeyType>*)keyEnumerator;

- (NSEnumerator<ObjectType>*)objectEnumerator;

- (NSArray<KeyType>*)allKeysForObject:(ObjectType)anObject;

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;

- (NSArray<KeyType> *)keysSortedByValueUsingSelector:(SEL)comparator;

- (void)getObjects:(ObjectType _Nonnull __unsafe_unretained [_Nullable])objects andKeys:(KeyType _Nonnull __unsafe_unretained [_Nullable])keys count:(NSUInteger)count;

- (nullable ObjectType)objectForKeyedSubscript:(KeyType)key;

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(KeyType key, ObjectType obj, BOOL *stop))block;

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(KeyType key, ObjectType obj, BOOL *stop))block;

- (NSArray<KeyType> *)keysSortedByValueUsingComparator:(NSComparator NS_NOESCAPE)cmptr;

- (NSArray<KeyType> *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator NS_NOESCAPE)cmptr;

- (NSSet<KeyType> *)keysOfEntriesPassingTest:(BOOL (NS_NOESCAPE ^)(KeyType key, ObjectType obj, BOOL *stop))predicate;

- (NSSet<KeyType> *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(KeyType key, ObjectType obj, BOOL *stop))predicate;

- (NSString *)descriptionWithLocale:(nullable id)locale;

- (NSString *)descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level;

- (BOOL)isEqualToDictionary:(nullable id)otherDictionary;

#pragma mark - NSMutableDictionary
- (void)removeObjectForKey:(KeyType)aKey;

- (void)removeObjectsForKeys:(NSArray<KeyType> *)keyArray;

- (void)setObject:(ObjectType)anObject forKey:(KeyType<NSCopying>)aKey;

- (void)setDictionary:(NSDictionary<KeyType, ObjectType> *)otherDictionary;

- (void)setObject:(nullable ObjectType)obj forKeyedSubscript:(KeyType<NSCopying>)key;

- (void)addEntriesFromDictionary:(NSDictionary<KeyType, ObjectType> *)otherDictionary;

@end

NS_ASSUME_NONNULL_END
