//
//  MNSafeDictionary.m
//  MNKit
//
//  Created by Vincent on 2019/3/29.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNSafeDictionary.h"

#define MNSafeInit(...) \
self = [super init]; \
if (!self) return nil; \
__VA_ARGS__; \
if (!_dic) return nil; \
if (![_dic isKindOfClass:NSMutableDictionary.class]) { \
_dic = [[NSMutableDictionary alloc] initWithDictionary:_dic.copy]; \
} \
if (!_dic) return nil; \
_lock = dispatch_semaphore_create(1); \
return self;

#define MNSafeLock(...) \
dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

@implementation MNSafeDictionary
{
    NSMutableDictionary *_dic;
    dispatch_semaphore_t _lock;
}

#pragma mark - Instance
- (instancetype)init {
    MNSafeInit(_dic = [[NSMutableDictionary alloc] init]);
}

+ (instancetype)dictionary {
    return [[self alloc] init];
}

- (instancetype)initWithObjects:(NSArray *)objects forKeys:(NSArray<id<NSCopying>> *)keys {
    MNSafeInit(_dic =  [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys]);
}

+ (instancetype)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray<id<NSCopying>> *)keys {
    return [[self alloc] initWithObjects:objects forKeys:keys];
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    MNSafeInit(_dic = [[NSMutableDictionary alloc] initWithCapacity:capacity]);
}

+ (instancetype)dictionaryWithCapacity:(NSUInteger)numItems {
    return [[self alloc] initWithCapacity:numItems];
}

- (instancetype)initWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    if (firstObject) {
        id value;
        va_list args;
        va_start(args, firstObject);
        id obj = firstObject;
        while ((value = va_arg(args, id))) {
            if (!obj) {
                obj = value;
            } else {
                [dic setObject:obj forKey:value];
                value = nil;
            }
        }
        va_end(args);
    }
    return [self initWithDictionary:dic.copy];
}

+ (instancetype)dictionaryWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    if (firstObject) {
        id value;
        va_list args;
        va_start(args, firstObject);
        id obj = firstObject;
        while ((value = va_arg(args, id))) {
            if (!obj) {
                obj = value;
            } else {
                [dic setObject:obj forKey:value];
                value = nil;
            }
        }
        va_end(args);
    }
    return [self dictionaryWithDictionary:dic.copy];
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
    MNSafeInit(_dic = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary]);
}

+ (instancetype)dictionaryWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag {
    MNSafeInit(_dic = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary copyItems:flag]);
}

+ (instancetype)dictionaryWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag {
    return [[self alloc] initWithDictionary:otherDictionary copyItems:flag];
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    MNSafeInit(_dic = [[NSMutableDictionary alloc] initWithContentsOfFile:path]);
}

+ (instancetype)dictionaryWithContentsOfFile:(NSString *)path {
    return [[self alloc] initWithContentsOfFile:path];
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
    MNSafeInit(_dic = [[NSMutableDictionary alloc] initWithContentsOfURL:url]);
}

+ (instancetype)dictionaryWithContentsOfURL:(NSURL *)url {
    return [[self alloc] initWithContentsOfURL:url];
}

#pragma mark - NSDictionary
- (NSUInteger)count {
    MNSafeLock(NSUInteger cou = [_dic count]);
    return cou;
}

- (id)objectForKey:(id)aKey {
    if (!aKey) return nil;
    MNSafeLock(id obj = [_dic objectForKey:aKey]);
    return obj;
}

- (NSEnumerator *)keyEnumerator {
    MNSafeLock(NSEnumerator *enu = [_dic keyEnumerator]);
    return enu;
}

- (NSEnumerator *)objectEnumerator {
    MNSafeLock(NSEnumerator *enu = [_dic objectEnumerator]);
    return enu;
}

- (NSArray *)allKeys {
    MNSafeLock(NSArray *keys = [_dic allKeys]);
    return keys;
}

- (NSArray *)allValues {
    MNSafeLock(NSArray *values = [_dic allValues]);
    return values;
}

- (NSArray *)allKeysForObject:(id)anObject {
    MNSafeLock(NSArray *keys = [_dic allKeysForObject:anObject]);
    return keys;
}

- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator {
    MNSafeLock(NSArray *keys = [_dic keysSortedByValueUsingSelector:comparator]);
    return keys;
}

- (void)getObjects:(id __unsafe_unretained [])objects andKeys:(id __unsafe_unretained [])keys count:(NSUInteger)count {
    MNSafeLock([_dic getObjects:objects andKeys:keys count:count]);
}

- (id)objectForKeyedSubscript:(id)key {
    if (!key) return nil;
    MNSafeLock(id obj = [_dic objectForKeyedSubscript:key]);
    return obj;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block {
    MNSafeLock([_dic enumerateKeysAndObjectsUsingBlock:block]);
}

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block {
    MNSafeLock([_dic enumerateKeysAndObjectsWithOptions:opts usingBlock:block]);
}

- (NSArray *)keysSortedByValueUsingComparator:(NSComparator NS_NOESCAPE)cmptr {
    MNSafeLock(NSArray *keys = [_dic keysSortedByValueUsingComparator:cmptr]);
    return keys;
}
- (NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator NS_NOESCAPE)cmptr {
    MNSafeLock(NSArray *keys = [_dic keysSortedByValueWithOptions:opts usingComparator:cmptr]);
    return keys;
}

- (NSSet *)keysOfEntriesPassingTest:(BOOL (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))predicate {
    MNSafeLock(NSSet *keys = [_dic keysOfEntriesPassingTest:predicate]);
    return keys;
}
- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))predicate {
    MNSafeLock(NSSet *keys = [_dic keysOfEntriesWithOptions:opts passingTest:predicate]);
    return keys;
}

- (NSString *)descriptionWithLocale:(id)locale {
    MNSafeLock(NSString *desc = [_dic descriptionWithLocale:locale]);
    return desc;
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    MNSafeLock(NSString *desc = [_dic descriptionWithLocale:locale indent:level]);
    return desc;
}

- (BOOL)isEqualToDictionary:(id)otherDictionary {
    if (!otherDictionary) return NO;
    if (otherDictionary == self) return YES;
    BOOL isEqual = NO;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if ([otherDictionary isKindOfClass:MNSafeDictionary.class]) {
        MNSafeDictionary *dic = (MNSafeDictionary *)otherDictionary;
        dispatch_semaphore_wait(dic->_lock, DISPATCH_TIME_FOREVER);
        isEqual = [_dic isEqualToDictionary:dic->_dic];
        dispatch_semaphore_signal(dic->_lock);
    } else if ([otherDictionary isKindOfClass:NSDictionary.class]) {
        isEqual = [_dic isEqualToDictionary:(NSDictionary *)otherDictionary];
    }
    dispatch_semaphore_signal(_lock);
    return isEqual;
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile {
    MNSafeLock(BOOL succeed = [_dic writeToFile:path atomically:useAuxiliaryFile]);
    return succeed;
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically {
    MNSafeLock(BOOL succeed = [_dic writeToURL:url atomically:atomically]);
    return succeed;
}

#pragma mark - NSMutableDictionary
- (void)removeObjectForKey:(id)aKey {
    if (!aKey) return;
    MNSafeLock([_dic removeObjectForKey:aKey]);
}

- (void)removeObjectsForKeys:(NSArray *)keyArray {
    if (keyArray.count <= 0) return;
    MNSafeLock([_dic removeObjectsForKeys:keyArray]);
}

- (void)setObject:(id)anObject forKey:(id)aKey {
    if (!anObject || !aKey) return;
    MNSafeLock([_dic setObject:anObject forKey:aKey]);
}

- (void)setDictionary:(NSDictionary *)otherDictionary {
    MNSafeLock([_dic setDictionary:otherDictionary]);
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key {
    if (!obj || !key) return;
    MNSafeLock([_dic setObject:obj forKeyedSubscript:key]);
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
    if (!otherDictionary) return;
    MNSafeLock([_dic addEntriesFromDictionary:otherDictionary]);
}

#pragma mark - Protocol
- (NSUInteger)hash {
    MNSafeLock(NSUInteger hash = [_dic hash]);
    return hash;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self mutableCopyWithZone:zone];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    MNSafeLock(id obj = [[self.class allocWithZone:zone] initWithDictionary:_dic]);
    return obj;
}

- (BOOL)isEqual:(id)object {
    if (!object || ![object isKindOfClass:MNSafeDictionary.class]) return NO;
    if (object == self) return YES;
    MNSafeDictionary *dic = (MNSafeDictionary *)object;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(dic->_lock, DISPATCH_TIME_FOREVER);
    BOOL isEqual = [_dic isEqual:dic->_dic];
    dispatch_semaphore_signal(dic->_lock);
    dispatch_semaphore_signal(_lock);
    return isEqual;
}

#pragma mark - Other
- (void)setValue:(id)value forKey:(NSString *)key {
    if (!key) return;
    MNSafeLock([_dic setValue:value forKey:key]);
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
    if (!keyPath) return;
    MNSafeLock([_dic setValue:value forKeyPath:keyPath]);
}

- (NSString *)description {
    MNSafeLock(NSString *desc = [_dic description]);
    return desc;
}

- (NSString *)debugDescription {
    MNSafeLock(NSString *desc = [_dic debugDescription]);
    return desc;
}

@end
